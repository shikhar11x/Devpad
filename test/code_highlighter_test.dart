import 'package:devpad/features/snippets/presentation/code_highlighter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = TextStyle();

  test('highlighting never changes the source text', () {
    const code = "void main() {\n  print('hi'); // note\n}\n";
    final span = CodeHighlighter.build(code, 'dart', base);

    expect(span.toPlainText(), code);
  });

  test('unknown language falls back to plain text', () {
    const code = 'whatever = 1';
    final span = CodeHighlighter.build(code, 'not-a-language', base);

    expect(span.toPlainText(), code);
  });

  test('plaintext and empty code are returned as is', () {
    expect(CodeHighlighter.build('a b', 'plaintext', base).toPlainText(), 'a b');
    expect(CodeHighlighter.build('', 'dart', base).toPlainText(), '');
  });
}