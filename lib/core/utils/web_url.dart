/// Turns user input into a clean http(s) URL, or null if it isn't one.
/// "flutter.dev" becomes "https://flutter.dev".
String? normalizeWebUrl(String input) {
  var value = input.trim();
  if (value.isEmpty || value.contains(RegExp(r'\s'))) return null;
  if (!value.contains('://')) value = 'https://$value';

  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;

  final host = uri.host;
  if (host.isEmpty) return null;
  if (host != 'localhost' && !host.contains('.')) return null;

  return uri.toString();
}

/// Host part for display ("docs.flutter.dev"). Falls back to the input.
String hostOf(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  return host.isEmpty ? url : host;
}