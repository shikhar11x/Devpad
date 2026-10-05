import 'package:devpad/features/notes/presentation/markdown_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wrap inserts a placeholder and selects it', () {
    const value = TextEditingValue(
      text: 'hi ',
      selection: TextSelection.collapsed(offset: 3),
    );
    final r = MarkdownFormatter.wrap(value, '**', '**', placeholder: 'bold');

    expect(r.text, 'hi **bold**');
    expect(r.selection.start, 5);
    expect(r.selection.end, 9);
  });

  test('wrap surrounds the selected text', () {
    const value = TextEditingValue(
      text: 'make bold now',
      selection: TextSelection(baseOffset: 5, extentOffset: 9),
    );
    final r = MarkdownFormatter.wrap(value, '**', '**');

    expect(r.text, 'make **bold** now');
    expect(r.selection.start, 7);
    expect(r.selection.end, 11);
  });

  test('wrap works when the field has no selection yet', () {
    const value = TextEditingValue(text: 'x');
    final r = MarkdownFormatter.apply(value, MarkdownAction.inlineCode);

    expect(r.text, 'x`code`');
  });

  test('prefixLines adds the prefix to every selected line, then removes it',
      () {
    const value = TextEditingValue(
      text: 'a\nb',
      selection: TextSelection(baseOffset: 0, extentOffset: 3),
    );
    final added = MarkdownFormatter.prefixLines(value, '- ');
    expect(added.text, '- a\n- b');

    final removed = MarkdownFormatter.prefixLines(added, '- ');
    expect(removed.text, 'a\nb');
  });

  test('prefixLines only touches the line with the cursor', () {
    const value = TextEditingValue(
      text: 'one\ntwo\nthree',
      selection: TextSelection.collapsed(offset: 5),
    );
    final r = MarkdownFormatter.apply(value, MarkdownAction.heading);

    expect(r.text, 'one\n# two\nthree');
  });
}