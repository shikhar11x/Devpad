/// Values come from `--dart-define-from-file=env.json`, never from source.
abstract final class SupabaseConfig {
  static const _rawUrl = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const bucket = String.fromEnvironment(
    'SUPABASE_BUCKET',
    defaultValue: 'devpad-files',
  );

  static String get url =>
      _rawUrl.endsWith('/') ? _rawUrl.substring(0, _rawUrl.length - 1) : _rawUrl;

  static bool get isConfigured => _rawUrl.isNotEmpty && anonKey.isNotEmpty;
}