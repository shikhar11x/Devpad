class PadFile {
  const PadFile({
    required this.id,
    required this.padId,
    required this.name,
    required this.size,
    required this.contentType,
    required this.path,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String padId;
  final String name;
  final int size;
  final String contentType;

  /// Object path inside the storage bucket.
  final String path;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool get isImage => contentType.startsWith('image/');

  bool isExpired([DateTime? now]) => !(now ?? DateTime.now()).isBefore(expiresAt);
}