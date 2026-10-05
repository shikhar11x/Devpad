import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/devpad_text_field.dart';
import '../../domain/entities/pad.dart';
import '../providers/pad_actions.dart';
import 'pad_icons.dart';

/// Opens the create dialog, or the edit dialog when [pad] is given.
Future<void> showPadFormDialog(BuildContext context, {Pad? pad}) {
  return showDialog<void>(
    context: context,
    builder: (_) => PadFormDialog(pad: pad),
  );
}

class PadFormDialog extends ConsumerStatefulWidget {
  const PadFormDialog({super.key, this.pad});

  final Pad? pad;

  @override
  ConsumerState<PadFormDialog> createState() => _PadFormDialogState();
}

class _PadFormDialogState extends ConsumerState<PadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _icon;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.pad != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.pad?.title ?? '');
    _description = TextEditingController(text: widget.pad?.description ?? '');
    _icon = widget.pad?.icon ?? Pad.defaultIcon;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final actions = ref.read(padActionsProvider);
    try {
      final pad = widget.pad;
      if (pad == null) {
        await actions.create(
          title: _title.text,
          description: _description.text,
          icon: _icon,
        );
      } else {
        await actions.update(
          pad.id,
          title: _title.text,
          description: _description.text,
          icon: _icon,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(_editing ? 'Edit Pad' : 'New Pad'),
      content: SizedBox(
        width: 420,
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
                  label: 'NAME',
                  hint: 'FieldForce Pro',
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Give your Pad a name'
                      : null,
                ),
                const SizedBox(height: 16),
                DevPadTextField(
                  controller: _description,
                  label: 'DESCRIPTION (OPTIONAL)',
                  hint: 'What is this Pad for?',
                  maxLength: 500,
                  maxLines: 3,
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                Text(
                  'ICON',
                  style: AppTheme.mono.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in padIcons.entries)
                      _IconChoice(
                        label: entry.key,
                        icon: entry.value,
                        selected: entry.key == _icon,
                        onTap: _saving
                            ? null
                            : () => setState(() => _icon = entry.key),
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
          label: _editing ? 'Save' : 'Create Pad',
          isLoading: _saving,
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: selected
                ? AppColors.accent.withValues(alpha: 0.16)
                : AppColors.background,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}