import 'package:flutter/services.dart';

enum MarkdownAction {
  bold,
  italic,
  heading,
  bulletList,
  checklist,
  quote,
  inlineCode,
  codeBlock,
  link,
}

/// Pure text transformations behind the formatting toolbar.
abstract final class MarkdownFormatter {
  static TextEditingValue apply(TextEditingValue value, MarkdownAction action) {
    return switch (action) {
      MarkdownAction.bold => wrap(value, '**', '**', placeholder: 'bold'),
      MarkdownAction.italic => wrap(value, '*', '*', placeholder: 'italic'),
      MarkdownAction.heading => prefixLines(value, '# '),
      MarkdownAction.bulletList => prefixLines(value, '- '),
      MarkdownAction.checklist => prefixLines(value, '- [ ] '),
      MarkdownAction.quote => prefixLines(value, '> '),
      MarkdownAction.inlineCode => wrap(value, '`', '`', placeholder: 'code'),
      MarkdownAction.codeBlock =>
        wrap(value, '```\n', '\n```', placeholder: 'code'),
      MarkdownAction.link =>
        wrap(value, '[', '](https://)', placeholder: 'text'),
    };
  }

  static TextSelection _selection(TextEditingValue value) {
    final s = value.selection;
    // No selection yet (field never focused): act at the end of the text.
    return s.isValid ? s : TextSelection.collapsed(offset: value.text.length);
  }

  /// Surrounds the selection with [left]/[right]. With no selection it
  /// inserts [placeholder] and selects it.
  static TextEditingValue wrap(
    TextEditingValue value,
    String left,
    String right, {
    String placeholder = 'text',
  }) {
    final sel = _selection(value);
    final selected = value.text.substring(sel.start, sel.end);
    final inner = selected.isEmpty ? placeholder : selected;
    final text = value.text.replaceRange(sel.start, sel.end, '$left$inner$right');
    final innerStart = sel.start + left.length;
    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: innerStart,
        extentOffset: innerStart + inner.length,
      ),
    );
  }

  /// Adds [prefix] to every selected line, or removes it when all of them
  /// already have it.
  static TextEditingValue prefixLines(TextEditingValue value, String prefix) {
    final sel = _selection(value);
    final text = value.text;
    final lineStart =
        sel.start == 0 ? 0 : text.lastIndexOf('\n', sel.start - 1) + 1;
    var lineEnd = text.indexOf('\n', sel.end);
    if (lineEnd == -1) lineEnd = text.length;

    final lines = text.substring(lineStart, lineEnd).split('\n');
    final allPrefixed = lines.every((l) => l.startsWith(prefix));
    final updated = lines
        .map((l) => allPrefixed ? l.substring(prefix.length) : '$prefix$l')
        .join('\n');

    return TextEditingValue(
      text: text.replaceRange(lineStart, lineEnd, updated),
      selection: TextSelection(
        baseOffset: lineStart,
        extentOffset: lineStart + updated.length,
      ),
    );
  }
}