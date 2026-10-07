import 'package:flutter/painting.dart';

/// One text style for measuring and painting canvas text, so the selection
/// box always matches what is drawn.
TextStyle canvasTextStyle(double fontSize, {Color? color}) => TextStyle(
      fontSize: fontSize,
      height: 1.25,
      color: color,
      fontFamily: 'JetBrains Mono',
      fontFamilyFallback: const ['Consolas', 'Menlo', 'Roboto Mono', 'monospace'],
    );

Size measureText(String text, double fontSize) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: canvasTextStyle(fontSize)),
    textDirection: TextDirection.ltr,
  )..layout();
  final size = painter.size;
  painter.dispose();
  return size;
}