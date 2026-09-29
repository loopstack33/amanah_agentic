import 'package:flutter/material.dart';
import '../models/daily_task.dart';

class TaskCard extends StatelessWidget {
  final DailyTask task;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onNudge;

  const TaskCard({
    super.key,
    required this.task,
    required this.completed,
    required this.onToggle,
    required this.onNudge,
  });

  Color _categoryColor(String category) {
    switch (category) {
      case 'worship':
        return const Color(0xFF0E6B5C);
      case 'charity':
        return const Color(0xFFB7791F);
      case 'family':
        return const Color(0xFF9B2C5D);
      case 'work':
        return const Color(0xFF2B4C8C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(task.category);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: completed
            ? color.withOpacity(0.08)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        onTap: onToggle,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(task.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          task.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Nudge via WhatsApp / Email',
              icon: const Icon(Icons.send_rounded, size: 20),
              onPressed: onNudge,
            ),
            Checkbox(
              value: completed,
              activeColor: color,
              shape: const CircleBorder(),
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}
