import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../models/task.dart';

/// Offline-first task storage.
///
/// Strategy:
/// - Every read/write hits [StorageService] (SharedPreferences) first,
///   so the UI is always fast and works with no network at all.
/// - Tasks created/changed while offline are marked `isSynced: false`
///   (or `isDeleted: true` for deletions) and kept locally.
/// - Whenever connectivity is available, [syncPendingChanges] pushes
///   those local changes to Firestore under the signed-in user's
///   document, then pulls remote changes back down and merges them.
/// - Call [startAutoSync] once (e.g. from HomeScreen.initState) to
///   sync automatically whenever the connection comes back.
class TaskService {
  TaskService({
    StorageService? storageService,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _storageService = storageService ?? StorageService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final StorageService _storageService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _tasksCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  // ---------------------------------------------------------------------
  // Local read/write (always available, offline or online)
  // ---------------------------------------------------------------------

  /// Returns all non-deleted tasks from local storage.
  Future<List<Task>> getTasks() async {
    final all = await _getAllLocalTasks();
    return all.where((t) => !t.isDeleted).toList();
  }

  Future<List<Task>> _getAllLocalTasks() async {
    final saved = await _storageService.getStringList(AppStrings.tasksKey);
    return saved.map(Task.fromStorageString).toList();
  }

  Future<void> _saveAllLocalTasks(List<Task> tasks) async {
    final saved = tasks.map((t) => t.toStorageString()).toList();
    await _storageService.saveStringList(AppStrings.tasksKey, saved);
  }

  /// Adds a task locally (instantly) and tries to sync in the background.
  Future<Task> addTask(Task task) async {
    final newTask = task.copyWith(isSynced: false);
    final all = await _getAllLocalTasks();
    all.add(newTask);
    await _saveAllLocalTasks(all);

    unawaited(syncPendingChanges());
    return newTask;
  }

  /// Updates a task locally (instantly) and tries to sync in the background.
  Future<void> updateTask(Task task) async {
    final all = await _getAllLocalTasks();
    final index = all.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    all[index] = task.copyWith(isSynced: false);
    await _saveAllLocalTasks(all);

    unawaited(syncPendingChanges());
  }

  /// Soft-deletes a task locally so the deletion can be propagated to
  /// Firestore later, then tries to sync in the background.
  Future<void> deleteTask(String id) async {
    final all = await _getAllLocalTasks();
    final index = all.indexWhere((t) => t.id == id);
    if (index == -1) return;

    all[index] = all[index].copyWith(isDeleted: true, isSynced: false);
    await _saveAllLocalTasks(all);

    unawaited(syncPendingChanges());
  }

  /// Kept for compatibility with existing call sites that save the
  /// whole list at once (e.g. bulk reorder). Marks every task as
  /// unsynced so the next sync pass pushes them all.
  Future<void> saveTasks(List<Task> tasks) async {
    final marked = tasks.map((t) => t.copyWith(isSynced: false)).toList();
    await _saveAllLocalTasks(marked);
    unawaited(syncPendingChanges());
  }

  // ---------------------------------------------------------------------
  // Sync with Firestore
  // ---------------------------------------------------------------------

  /// Pushes local unsynced changes to Firestore, then pulls remote
  /// tasks down and merges them into local storage. Safe to call
  /// repeatedly; it's a no-op if there's no signed-in user or no
  /// network.
  Future<void> syncPendingChanges() async {
    final collection = _tasksCollection;
    if (collection == null) return; // not logged in

    final hasNetwork = await _hasNetwork();
    if (!hasNetwork) return;

    try {
      final all = await _getAllLocalTasks();

      // 1. Push local deletions.
      final toDelete = all.where((t) => t.isDeleted && !t.isSynced).toList();
      for (final task in toDelete) {
        await collection.doc(task.id).delete();
      }

      // 2. Push local creates/updates.
      final toPush = all.where((t) => !t.isDeleted && !t.isSynced).toList();
      for (final task in toPush) {
        await collection.doc(task.id).set(task.toFirestoreJson());
      }

      // 3. Remove fully-synced deleted tasks from local storage.
      var merged = all.where((t) => !(t.isDeleted && t.isSynced)).toList();
      merged = merged
          .where((t) => !toDelete.any((d) => d.id == t.id))
          .toList();

      // 4. Mark pushed tasks as synced.
      merged = merged.map((t) {
        final wasPushed = toPush.any((p) => p.id == t.id);
        return wasPushed ? t.copyWith(isSynced: true) : t;
      }).toList();

      // 5. Pull remote tasks and merge (remote wins for tasks that
      //    have no pending local edits).
      final remoteSnapshot = await collection.get();
      final remoteTasks = remoteSnapshot.docs
          .map((doc) => Task.fromFirestore(doc.id, doc.data()))
          .toList();

      for (final remoteTask in remoteTasks) {
        final localIndex = merged.indexWhere((t) => t.id == remoteTask.id);
        if (localIndex == -1) {
          // New task from another device — add it.
          merged.add(remoteTask);
        } else if (merged[localIndex].isSynced) {
          // No pending local edits — safe to take the remote version.
          merged[localIndex] = remoteTask;
        }
        // If local has pending edits (isSynced == false), keep local;
        // it will overwrite remote on the next push.
      }

      // 6. Drop local tasks that were deleted remotely (no longer in
      //    remoteTasks) and have no pending local edits.
      final remoteIds = remoteTasks.map((t) => t.id).toSet();
      merged = merged
          .where((t) => t.isSynced ? remoteIds.contains(t.id) : true)
          .toList();

      await _saveAllLocalTasks(merged);
    } catch (_) {
      // Sync failed (network dropped mid-way, permission error, etc).
      // Local data is untouched, so nothing is lost — we'll retry on
      // the next connectivity change or app open.
    }
  }

  Future<bool> _hasNetwork() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Starts listening for connectivity changes and automatically runs
  /// [syncPendingChanges] whenever the device regains a network
  /// connection. Call once, e.g. in HomeScreen.initState(), and call
  /// [stopAutoSync] in dispose().
  void startAutoSync() {
    _connectivitySub?.cancel();
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncPendingChanges();
      }
    });
  }

  void stopAutoSync() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}