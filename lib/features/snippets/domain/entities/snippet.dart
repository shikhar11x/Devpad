class Snippet {
  const Snippet({
    required this.id,
    required this.padId,
    required this.title,
    required this.language,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String padId;
  final String title;

  /// Language id, e.g. "dart" (see code_languages.dart).
  final String language;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;
}