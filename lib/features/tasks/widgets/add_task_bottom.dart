import 'package:flutter/material.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({
    super.key,
    required this.onAddTask,
  });

  final Function(String title, String description, String dueDate,
      String priority, String category) onAddTask;

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Work';
  String _dueDate = '';

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _categories = ['Work', 'Personal', 'Health', 'Learning'];

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return const Color(0xFFFF5252);
      case 'Low':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFFF9800);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onAddTask(
      title,
      _descController.text.trim(),
      _dueDate,
      _selectedPriority,
      _selectedCategory,
    );
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final today = DateTime.now();
      final diff = picked.difference(DateTime(today.year, today.month, today.day)).inDays;
      setState(() {
        if (diff == 0) {
          _dueDate = 'Today';
        } else if (diff == 1) {
          _dueDate = 'Tomorrow';
        } else {
          _dueDate = '${picked.day}/${picked.month}/${picked.year}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Title
                  _label('Task Title'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _titleController,
                    hint: 'Enter task title',
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _label('Description'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: _boxDecoration(),
                    child: TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add task description...',
                        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Due Date
                  _label('Due Date'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      decoration: _boxDecoration(),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: Color(0xFF6C63FF), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            _dueDate.isEmpty ? 'Select date' : _dueDate,
                            style: TextStyle(
                              color: _dueDate.isEmpty
                                  ? const Color(0xFFBBBBBB)
                                  : const Color(0xFF1A1A2E),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  _label('Priority'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: _boxDecoration(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPriority,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF888888)),
                        items: _priorities.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _priorityColor(p),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(p, style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedPriority = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _label('Category'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: _boxDecoration(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF888888)),
                        items: _categories.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontSize: 15)),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFDDDDDD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
      );

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}