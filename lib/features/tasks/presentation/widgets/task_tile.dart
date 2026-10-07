import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../../domain/entities/task.dart';
import '../task_filters.dart';

Color priorityColor(TaskPriority p) => switch (p) {
      TaskPriority.high => AppColors.error,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.low => AppColors.accent,
    };

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = task.isDone;
    final overdue = isOverdue(task);
    final due = task.dueDate;
    final prioColor = priorityColor(task.priority);

    return DevPadCard(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      glowColor: prioColor,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: done,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.accent,
            checkColor: const Color(0xFF060911),
            side: BorderSide(
              color: done
                  ? AppColors.accent
                  : AppColors.borderBright,
              width: 1.5,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? AppColors.textDim : AppColors.text,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Badge(
                        label: task.priority.label.toUpperCase(),
                        color: prioColor,
                      ),
                      if (task.status == TaskStatus.inProgress)
                        const _Badge(
                          label: 'IN PROGRESS',
                          color: AppColors.accentAlt,
                        ),
                      if (due != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 13,
                              color: overdue
                                  ? AppColors.error
                                  : AppColors.textDim,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              overdue
                                  ? 'OVERDUE // ${DateFormatter.short(due)}'
                                  : 'DUE // ${DateFormatter.short(due)}',
                              style: AppTheme.mono.copyWith(
                                fontSize: 10,
                                fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
                                color: overdue
                                    ? AppColors.error
                                    : AppColors.textDim,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete task',
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.textDim,
            hoverColor: AppColors.error.withValues(alpha: 0.1),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTheme.mono.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}