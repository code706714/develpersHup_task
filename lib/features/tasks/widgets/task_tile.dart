import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFF5252);
      case 'low':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFFF9800); // Medium
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => onChanged(!task.isDone),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                  color: task.isDone
                      ? const Color(0xFF6C63FF)
                      : Colors.transparent,
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: task.isDone
                          ? const Color(0xFFAAAAAA)
                          : const Color(0xFF1A1A2E),
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: const Color(0xFFAAAAAA),
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Category icon + due date
                      if (task.dueDate.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEF5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.dueDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Priority dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _priorityColor(task.priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.only(left: 8, top: 2),
                child: Icon(
                  Icons.more_horiz,
                  color: Color(0xFFCCCCCC),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}