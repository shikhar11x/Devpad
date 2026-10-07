import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../code_highlighter.dart';

/// Read-only, selectable, highlighted code with cyber hacker terminal styling.
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
    height: 1.55,
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.terminal, size: 36, color: AppColors.textDim),
              const SizedBox(height: 12),
              Text(
                '// BUFFER_EMPTY',
                style: AppTheme.mono.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Switch to Edit mode and paste or write code.',
                textAlign: TextAlign.center,
                style: AppTheme.mono.copyWith(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Hacker terminal title bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surfaceHigh,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              // Terminal dots
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF5F56),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66FF5F56),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFBD2E),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66FFBD2E),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF27C93F),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6627C93F),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Text(
                'SOURCE // ${widget.language.toUpperCase()}',
                style: AppTheme.mono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDim,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'READ_ONLY',
                  style: AppTheme.mono.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Code content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: SelectableText.rich(_span),
            ),
          ),
        ),
      ],
    );
  }
}