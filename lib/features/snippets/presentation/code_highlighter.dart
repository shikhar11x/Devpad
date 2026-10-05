import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart' show Node, highlight;

import '../../../app/theme/app_colors.dart';

/// Turns source code into a colored [TextSpan] (GitHub-dark style colors).
abstract final class CodeHighlighter {
  static const _red = Color(0xFFFF7B72);
  static const _blue = Color(0xFF79C0FF);
  static const _lightBlue = Color(0xFFA5D6FF);
  static const _purple = Color(0xFFD2A8FF);
  static const _orange = Color(0xFFFFA657);
  static const _green = Color(0xFF7EE787);

  static const _colors = <String, Color>{
    'keyword': _red,
    'selector-tag': _red,
    'doctag': _red,
    'string': _lightBlue,
    'regexp': _lightBlue,
    'meta-string': _lightBlue,
    'number': _blue,
    'literal': _blue,
    'symbol': _blue,
    'bullet': _blue,
    'attr': _blue,
    'attribute': _blue,
    'variable': _blue,
    'template-variable': _blue,
    'selector-attr': _blue,
    'meta': _blue,
    'title': _purple,
    'section': _purple,
    'selector-id': _purple,
    'selector-class': _purple,
    'built_in': _orange,
    'type': _orange,
    'class': _orange,
    'params': _orange,
    'tag': _green,
    'name': _green,
    'addition': _green,
    'deletion': Color(0xFFFFA198),
    'comment': AppColors.textMuted,
    'quote': AppColors.textMuted,
    'doc': AppColors.textMuted,
  };

  static TextStyle? _styleFor(String? className) {
    if (className == null) return null;
    final color = _colors[className];
    if (color == null) return null;
    final italic = className == 'comment' || className == 'quote';
    return TextStyle(
      color: color,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  static InlineSpan _node(Node node) {
    final style = _styleFor(node.className);
    final value = node.value;
    if (value != null) return TextSpan(text: value, style: style);
    return TextSpan(
      style: style,
      children: [for (final c in node.children ?? const <Node>[]) _node(c)],
    );
  }

  /// Never throws. Falls back to plain text for empty code, "plaintext",
  /// unknown languages, or if highlighting would alter the text.
  static TextSpan build(String code, String language, TextStyle base) {
    final plain = TextSpan(text: code, style: base);
    if (code.isEmpty || language == 'plaintext') return plain;
    try {
      final nodes = highlight.parse(code, language: language).nodes;
      if (nodes == null || nodes.isEmpty) return plain;
      final span = TextSpan(
        style: base,
        children: [for (final n in nodes) _node(n)],
      );
      return span.toPlainText() == code ? span : plain;
    } catch (_) {
      return plain;
    }
  }
}