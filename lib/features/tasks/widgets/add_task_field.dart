import 'package:flutter/material.dart';

class AddTaskField extends StatefulWidget {
  const AddTaskField({
    super.key,
    required this.onAddTask,
  });

  final ValueChanged<String> onAddTask;

  @override
  State<AddTaskField> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends State<AddTaskField> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      return;
    }

    widget.onAddTask(title);
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'New task',
            ),
            onSubmitted: (_) => _submitTask(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _submitTask,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
