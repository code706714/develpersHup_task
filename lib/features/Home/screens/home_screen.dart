import 'package:dev_hup_task_week_1/features/tasks/screens/add_task.dart';
import 'package:flutter/material.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  final List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'All Tasks';

  final List<String> _filters = ['All Tasks', 'Today', 'This Week', 'High Priority'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _taskService.startAutoSync();
  }

  @override
  void dispose() {
    _taskService.stopAutoSync();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final savedTasks = await _taskService.getTasks();
    setState(() {
      _tasks
        ..clear()
        ..addAll(savedTasks);
      _isLoading = false;
    });
  }

  void _addTask(String title, String description, String dueDate, String priority, String category) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final newTask = Task(
      id: id,
      title: title,
      isDone: false,
      description: description,
      dueDate: dueDate,
      priority: priority,
      category: category,
    );

    setState(() {
      _tasks.add(newTask);
    });
    await _taskService.addTask(newTask);
  }

  void _toggleTask(int index, bool isDone) async {
    final updated = _tasks[index].copyWith(isDone: isDone);
    setState(() {
      _tasks[index] = updated;
    });
    await _taskService.updateTask(updated);
  }

  void _deleteTask(int index) async {
    final id = _tasks[index].id;
    setState(() {
      _tasks.removeAt(index);
    });
    await _taskService.deleteTask(id);
  }

  void _showAddTaskSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(onAddTask: _addTask),
      ),
    );
  }

  List<Task> get _filteredTasks {
    if (_selectedFilter == 'All Tasks') return _tasks;
    if (_selectedFilter == 'Today') {
      return _tasks.where((t) => t.dueDate.toLowerCase() == 'today').toList();
    }
    if (_selectedFilter == 'High Priority') {
      return _tasks.where((t) => t.priority.toLowerCase() == 'high').toList();
    }
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF6C63FF),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF555555),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : const Color(0xFFDDDDDD),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : _filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          final realIndex = _tasks.indexWhere((t) => t.id == task.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TaskTile(
                              task: task,
                              onChanged: (value) => _toggleTask(realIndex, value ?? false),
                              onDelete: () => _deleteTask(realIndex),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _tasks.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddTaskSheet,
              backgroundColor: const Color(0xFF6C63FF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 40,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Tasks Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first task to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _showAddTaskSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create Task',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}