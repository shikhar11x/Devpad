import 'package:url_launcher/url_launcher.dart';

/// Opens an http(s) URL in the browser. Returns false if it is not a web
/// URL or if the platform could not open it. Never throws.
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return false;
  }
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}