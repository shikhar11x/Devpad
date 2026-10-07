import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Cyber Terminal form field with glowing focus state and tech label.
class DevPadTextField extends StatefulWidget {
  const DevPadTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final int? maxLength;

  @override
  State<DevPadTextField> createState() => _DevPadTextFieldState();
}

class _DevPadTextFieldState extends State<DevPadTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '// ',
              style: AppTheme.mono.copyWith(
                fontSize: 11,
                color: _isFocused ? AppColors.accent : AppColors.textDim,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.label,
              style: AppTheme.mono.copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
                color: _isFocused ? AppColors.accent : AppColors.textMuted,
                fontWeight: _isFocused ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.22),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            enabled: widget.enabled,
            obscureText: widget.obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: AppTheme.mono.copyWith(
              fontSize: 13,
              color: AppColors.text,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIcon: widget.suffixIcon,
              counterText: '',
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.accent, width: 1.5),
              errorBorder: _border(AppColors.error),
              focusedErrorBorder: _border(AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}