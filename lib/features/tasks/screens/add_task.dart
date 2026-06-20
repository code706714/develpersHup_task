import 'package:flutter/material.dart';

typedef OnAddTask = void Function(
  String title,
  String description,
  String dueDate,
  String priority,
  String category,
);

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, required this.onAddTask});

  final OnAddTask onAddTask;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const _purple = Color(0xFF6C63FF);
  static const _ink = Color(0xFF1A1A2E);
  static const _bg = Color(0xFFF5F5F7);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _dueDateOptions = const ['Today', 'Tomorrow', 'This Week', 'No Date'];
  final List<String> _priorityOptions = const ['Low', 'Medium', 'High'];
  final List<String> _categoryOptions = const ['Personal', 'Work', 'Study', 'Other'];

  String _selectedDueDate = 'Today';
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Personal';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onAddTask(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _selectedDueDate,
      _selectedPriority,
      _selectedCategory,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _ink,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _buildLabel('Title'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hintText: 'e.g. Finish project proposal',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Add more details (optional)',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              _buildLabel('Due Date'),
              const SizedBox(height: 8),
              _buildChipGroup(
                options: _dueDateOptions,
                selected: _selectedDueDate,
                onSelected: (value) => setState(() => _selectedDueDate = value),
              ),
              const SizedBox(height: 20),
              _buildLabel('Priority'),
              const SizedBox(height: 8),
              _buildChipGroup(
                options: _priorityOptions,
                selected: _selectedPriority,
                onSelected: (value) => setState(() => _selectedPriority = value),
              ),
              const SizedBox(height: 20),
              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildChipGroup(
                options: _categoryOptions,
                selected: _selectedCategory,
                onSelected: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          backgroundColor: Colors.white,
          selectedColor: _purple,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}