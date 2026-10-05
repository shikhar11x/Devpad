import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../code_highlighter.dart';

/// Read-only, selectable, highlighted code. The span is cached so it is
/// only recomputed when the code or language changes.
class HighlightedCode extends StatefulWidget {
  const HighlightedCode({
    super.key,
    required this.code,
    required this.language,
  });

  final String code;
  final String language;

  @override
  State<HighlightedCode> createState() => _HighlightedCodeState();
}

class _HighlightedCodeState extends State<HighlightedCode> {
  static final _base = AppTheme.mono.copyWith(
    fontSize: 13,
    height: 1.5,
    color: AppColors.text,
  );

  late TextSpan _span;

  TextSpan _compute() =>
      CodeHighlighter.build(widget.code, widget.language, _base);

  @override
  void initState() {
    super.initState();
    _span = _compute();
  }

  @override
  void didUpdateWidget(HighlightedCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code ||
        oldWidget.language != widget.language) {
      _span = _compute();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.code.isEmpty) {
      return const Center(
        child: Text(
          'Nothing to show yet. Switch to Edit and paste some code.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText.rich(_span),
    );
  }
}