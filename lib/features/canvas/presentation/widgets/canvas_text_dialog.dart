import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

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
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(widget.title),
      content: SizedBox(
        width: 380,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(hintText: 'Type your text'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}