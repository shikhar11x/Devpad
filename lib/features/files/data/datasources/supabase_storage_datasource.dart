import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_failure.dart';

/// Talks to Supabase Storage over its REST API. No Supabase SDK needed,
/// because sign-in is handled by Firebase.
class SupabaseStorageDataSource {
  SupabaseStorageDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 60);

  bool get isAvailable => SupabaseConfig.isConfigured;

  Map<String, String> get _auth => {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
      };

  Uri _object(String path) => Uri.parse(
        '${SupabaseConfig.url}/storage/v1/object/${SupabaseConfig.bucket}/$path',
      );

  String publicUrl(String path) =>
      '${SupabaseConfig.url}/storage/v1/object/public/${SupabaseConfig.bucket}/$path';

  Future<void> upload(String path, Uint8List bytes, String contentType) async {
    final res = await _client
        .post(
          _object(path),
          headers: {..._auth, 'Content-Type': contentType},
          body: bytes,
        )
        .timeout(_timeout);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw AppFailure('Upload failed (code ${res.statusCode}).');
    }
  }

  /// A missing object counts as removed.
  Future<void> remove(String path) async {
    final res =
        await _client.delete(_object(path), headers: _auth).timeout(_timeout);
    final ok = res.statusCode == 200 ||
        res.statusCode == 204 ||
        res.statusCode == 404;
    if (!ok) throw AppFailure('Could not remove the file (code ${res.statusCode}).');
  }
}