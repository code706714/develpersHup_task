import 'dart:convert';

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate = '',
    this.priority = 'Medium',
    this.category = 'Work',
    this.isDone = false,
    this.isSynced = true,
    this.isDeleted = false,
  });
  final String id;

  final String title;
  final String description;
  final String dueDate;
  final String priority;
  final String category;
  final bool isDone;
  final bool isSynced;
  final bool isDeleted;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? priority,
    String? category,
    bool? isDone,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'category': category,
      'isDone': isDone,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      category: json['category'] as String? ?? 'Work',
      isDone: json['isDone'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toFirestoreJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'category': category,
      'isDone': isDone,
    };
  }

  factory Task.fromFirestore(String id, Map<String, dynamic> json) {
    return Task(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      category: json['category'] as String? ?? 'Work',
      isDone: json['isDone'] as bool? ?? false,
      isSynced: true,
      isDeleted: false,
    );
  }
  String toStorageString() => jsonEncode(toJson());
  factory Task.fromStorageString(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return Task.fromJson(decoded);
      }
    } catch (_) {
    }

    final parts = value.split('|');
    return Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: parts.first,
      isDone: parts.length > 1 && parts[1] == 'true',
    );
  }
}