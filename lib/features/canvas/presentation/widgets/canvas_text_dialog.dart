import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/devpad_button.dart';

/// Asks for canvas text. Returns the trimmed text, or null if cancelled.
Future<String?> showCanvasTextDialog(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _CanvasTextDialog(title: title, initial: initial),
  );
}

class _CanvasTextDialog extends StatefulWidget {
  const _CanvasTextDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_CanvasTextDialog> createState() => _CanvasTextDialogState();
}

class _CanvasTextDialogState extends State<_CanvasTextDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceSecondary,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.cyan.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.cyan.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.text_fields_rounded, size: 20, color: AppColors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CANVAS // TEXT NODE',
                  style: AppTheme.mono.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.cyan.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: TextField(
            controller: _controller,
            autofocus: true,
            minLines: 2,
            maxLines: 5,
            maxLength: 500,
            style: AppTheme.mono.copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText: '// type canvas label or diagram note...',
              hintStyle: AppTheme.mono.copyWith(
                color: AppColors.textDim,
                fontSize: 13,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        DevPadButton(
          label: 'Apply Text',
          icon: const Icon(Icons.check, size: 16),
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}