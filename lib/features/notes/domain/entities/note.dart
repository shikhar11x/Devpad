class Note {
  const Note({
    required this.id,
    required this.padId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String padId;
  final String title;

  /// Markdown source.
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
}