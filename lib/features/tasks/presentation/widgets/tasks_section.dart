import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/responsive.dart';
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

  void _say(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
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
                padding: EdgeInsets.symmetric(horizontal: edge, vertical: 4),
                child: Text(
                  '$doneCount of ${tasks.length} done',
                  style: AppTheme.mono.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
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
          child: TextField(
            controller: _quick,
            focusNode: _quickFocus,
            textInputAction: TextInputAction.done,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            onSubmitted: (_) => _quickAdd(),
            decoration: const InputDecoration(
              hintText: 'Add a task and press Enter',
              prefixIcon: Icon(Icons.add, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'New task with details',
          icon: const Icon(Icons.tune, size: 20),
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
      padding: EdgeInsets.symmetric(horizontal: edge, vertical: 2),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label(option)),
                selected: selected == option,
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