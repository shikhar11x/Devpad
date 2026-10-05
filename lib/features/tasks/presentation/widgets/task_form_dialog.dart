import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/devpad_text_field.dart';
import '../../domain/entities/task.dart';
import '../providers/task_actions.dart';

/// Opens the create dialog, or the edit dialog when [task] is given.
Future<void> showTaskFormDialog(
  BuildContext context, {
  required String padId,
  Task? task,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => TaskFormDialog(padId: padId, task: task),
  );
}

class TaskFormDialog extends ConsumerStatefulWidget {
  const TaskFormDialog({super.key, required this.padId, this.task});

  final String padId;
  final Task? task;

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskStatus _status;
  late TaskPriority _priority;
  DateTime? _due;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? TaskStatus.todo;
    _priority = t?.priority ?? TaskPriority.medium;
    _due = t?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final oldest = DateTime(now.year - 1);
    final due = _due;
    final picked = await showDatePicker(
      context: context,
      initialDate: due ?? now,
      firstDate: (due != null && due.isBefore(oldest)) ? due : oldest,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() => _due = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final actions = ref.read(taskActionsProvider);
    try {
      final task = widget.task;
      if (task == null) {
        await actions.create(
          widget.padId,
          title: _title.text,
          description: _description.text,
          status: _status,
          priority: _priority,
          dueDate: _due,
        );
      } else {
        await actions.update(
          widget.padId,
          task.id,
          title: _title.text,
          description: _description.text,
          status: _status,
          priority: _priority,
          dueDate: _due,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on AppFailure catch (f) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = f.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Something went wrong. Try again.';
        });
      }
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: AppTheme.mono.copyWith(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(_editing ? 'Edit task' : 'New task'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                DevPadTextField(
                  controller: _title,
                  label: 'TITLE',
                  hint: 'What needs to be done?',
                  maxLength: 200,
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Give your task a title'
                      : null,
                ),
                const SizedBox(height: 16),
                DevPadTextField(
                  controller: _description,
                  label: 'DETAILS (OPTIONAL)',
                  maxLength: 2000,
                  maxLines: 3,
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                _label('STATUS'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in TaskStatus.values)
                      ChoiceChip(
                        label: Text(s.label),
                        selected: s == _status,
                        showCheckmark: false,
                        onSelected:
                            _saving ? null : (_) => setState(() => _status = s),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _label('PRIORITY'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in TaskPriority.values)
                      ChoiceChip(
                        label: Text(p.label),
                        selected: p == _priority,
                        showCheckmark: false,
                        onSelected: _saving
                            ? null
                            : (_) => setState(() => _priority = p),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _label('DUE DATE'),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDate,
                      icon: const Icon(Icons.event_outlined, size: 18),
                      label: Text(
                        _due == null
                            ? 'No due date'
                            : DateFormatter.short(_due!),
                      ),
                    ),
                    if (_due != null)
                      IconButton(
                        tooltip: 'Clear due date',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed:
                            _saving ? null : () => setState(() => _due = null),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        DevPadButton(
          label: _editing ? 'Save' : 'Add task',
          isLoading: _saving,
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}