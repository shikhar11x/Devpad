class CodeLanguage {
  const CodeLanguage(this.id, this.label);

  /// highlight.js language id. Also what gets stored in Firestore.
  final String id;
  final String label;
}

const defaultCodeLanguage = 'dart';

const codeLanguages = <CodeLanguage>[
  CodeLanguage('dart', 'Dart'),
  CodeLanguage('javascript', 'JavaScript'),
  CodeLanguage('typescript', 'TypeScript'),
  CodeLanguage('python', 'Python'),
  CodeLanguage('java', 'Java'),
  CodeLanguage('kotlin', 'Kotlin'),
  CodeLanguage('swift', 'Swift'),
  CodeLanguage('go', 'Go'),
  CodeLanguage('rust', 'Rust'),
  CodeLanguage('cpp', 'C++'),
  CodeLanguage('cs', 'C#'),
  CodeLanguage('php', 'PHP'),
  CodeLanguage('ruby', 'Ruby'),
  CodeLanguage('sql', 'SQL'),
  CodeLanguage('json', 'JSON'),
  CodeLanguage('yaml', 'YAML'),
  CodeLanguage('bash', 'Bash'),
  CodeLanguage('xml', 'HTML / XML'),
  CodeLanguage('css', 'CSS'),
  CodeLanguage('markdown', 'Markdown'),
  CodeLanguage('dockerfile', 'Dockerfile'),
  CodeLanguage('plaintext', 'Plain text'),
];

String languageLabel(String id) {
  for (final l in codeLanguages) {
    if (l.id == id) return l.label;
  }
  return id;
}