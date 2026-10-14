import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/cyber_confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../pads/presentation/providers/pad_providers.dart';
import '../../domain/entities/task.dart';
import '../providers/task_actions.dart';
import '../providers/task_providers.dart';
import '../task_filters.dart';
import 'task_form_dialog.dart';
import 'task_tile.dart';

/// The Tasks tab of a Pad: quick add, filters and the task list.
class TasksSection extends ConsumerStatefulWidget {
  const TasksSection({super.key, required this.padId});

  final String padId;

  @override
  ConsumerState<TasksSection> createState() => _TasksSectionState();
}

class _TasksSectionState extends ConsumerState<TasksSection> {
  final _quick = TextEditingController();
  final _quickFocus = FocusNode();
  TaskStatus? _status;
  TaskPriority? _priority;

  @override
  void dispose() {
    _quick.dispose();
    _quickFocus.dispose();
    super.dispose();
  }


  Future<void> _quickAdd() async {
    final title = _quick.text.trim();
    if (title.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(taskActionsProvider);

    _quick.clear();
    _quickFocus.requestFocus();
    try {
      await actions.create(
        widget.padId,
        title: title,
        description: '',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
      );
    } on AppFailure catch (f) {
      if (mounted && _quick.text.isEmpty) _quick.text = title;
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      if (mounted && _quick.text.isEmpty) _quick.text = title;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not add the task.')),
      );
    }
  }

  Future<void> _toggle(Task task) async {
    final messenger = ScaffoldMessenger.of(context);
    final next = task.isDone ? TaskStatus.todo : TaskStatus.done;
    try {
      await ref
          .read(taskActionsProvider)
          .setStatus(widget.padId, task.id, next);
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not update the task.')),
      );
    }
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showCyberConfirmDialog(
      context,
      title: 'Delete "${task.title}"?',
      message: 'This task will be permanently deleted from the workspace.',
      confirmLabel: 'Delete Task',
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(taskActionsProvider).delete(widget.padId, task.id);
      messenger.showSnackBar(const SnackBar(content: Text('Task deleted')));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the task.')),
      );
    }
  }

  void _clearFilters() => setState(() {
        _status = null;
        _priority = null;
      });

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tasksProvider(widget.padId));
    return async.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: padErrorMessage(e),
        onRetry: () => ref.invalidate(tasksProvider(widget.padId)),
      ),
      data: _buildData,
    );
  }

  Widget _buildData(List<Task> tasks) {
    final edge = context.screenSize.isMobile ? 16.0 : 24.0;
    final visible =
        sortTasks(filterTasks(tasks, status: _status, priority: _priority));
    final doneCount = tasks.where((t) => t.isDone).length;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(edge, 16, edge, 8),
              child: _quickAddField(),
            ),
            if (tasks.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: edge, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'SPRINT // $doneCount OF ${tasks.length} RESOLVED (${(tasks.isEmpty ? 0 : (doneCount / tasks.length * 100)).toInt()}%)',
                        style: AppTheme.mono.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.cyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: tasks.isEmpty ? 0.0 : doneCount / tasks.length,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _chipRow<TaskStatus>(
                edge: edge,
                options: [null, ...TaskStatus.values],
                selected: _status,
                label: (s) =>
                    '${s?.label ?? 'All'} ${s == null ? tasks.length : tasks.where((t) => t.status == s).length}',
                onSelected: (s) => setState(() => _status = s),
              ),
              _chipRow<TaskPriority>(
                edge: edge,
                options: [null, ...TaskPriority.values],
                selected: _priority,
                label: (p) => p?.label ?? 'Any priority',
                onSelected: (p) => setState(() => _priority = p),
              ),
            ],
            Expanded(child: _content(tasks, visible, edge)),
          ],
        ),
      ),
    );
  }

  Widget _quickAddField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _quick,
              focusNode: _quickFocus,
              textInputAction: TextInputAction.done,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              onSubmitted: (_) => _quickAdd(),
              style: AppTheme.mono.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: '// quick add task... (press Enter)',
                hintStyle: AppTheme.mono.copyWith(
                  color: AppColors.textDim,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.terminal_rounded, size: 18, color: AppColors.cyan),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'New task with details',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.25)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.cyan),
          onPressed: () => showTaskFormDialog(context, padId: widget.padId),
        ),
      ],
    );
  }

  Widget _chipRow<T>({
    required double edge,
    required List<T?> options,
    required T? selected,
    required String Function(T?) label,
    required ValueChanged<T?> onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: edge, vertical: 3),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  label(option),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected == option ? FontWeight.w600 : FontWeight.w400,
                    color: selected == option ? AppColors.cyan : AppColors.textDim,
                  ),
                ),
                selected: selected == option,
                selectedColor: AppColors.cyan.withValues(alpha: 0.15),
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(
                  color: selected == option
                      ? AppColors.cyan.withValues(alpha: 0.6)
                      : AppColors.border,
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onSelected(option),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(List<Task> all, List<Task> visible, double edge) {
    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.checklist_rounded,
        title: 'No tasks yet.',
        message: 'Track what needs to be built, fixed or decided in this Pad.',
        actionLabel: 'Create your first task →',
        onAction: () => showTaskFormDialog(context, padId: widget.padId),
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'No matching tasks',
        message: 'No tasks match the current filters.',
        actionLabel: 'Clear filters',
        onAction: _clearFilters,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(edge, 8, edge, 24),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final task = visible[i];
        return TaskTile(
          task: task,
          onToggle: () => _toggle(task),
          onTap: () =>
              showTaskFormDialog(context, padId: widget.padId, task: task),
          onDelete: () => _delete(task),
        );
      },
    );
  }
}