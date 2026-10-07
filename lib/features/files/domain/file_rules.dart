abstract final class FileRules {
  static const maxBytes = 5 * 1024 * 1024;
  static const retention = Duration(days: 7);

  /// Allowed extensions and the content type sent to storage.
  static const types = <String, String>{
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
  };

  static List<String> get extensions => types.keys.toList();

  /// Lowercase extension if allowed, else null.
  static String? extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return null;
    final ext = name.substring(dot + 1).toLowerCase();
    return types.containsKey(ext) ? ext : null;
  }
}