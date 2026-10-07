import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../../core/errors/app_failure.dart';
import '../../../pads/data/pad_error_mapper.dart';
import '../../domain/entities/pad_file.dart';
import '../../domain/file_rules.dart';
import '../../domain/repositories/file_repository.dart';
import '../datasources/firestore_file_datasource.dart';
import '../datasources/supabase_storage_datasource.dart';

class FileRepositoryImpl implements FileRepository {
  FileRepositoryImpl(this._meta, this._storage);

  final FirestoreFileDataSource _meta;
  final SupabaseStorageDataSource _storage;

  static const _metaTimeout = Duration(seconds: 15);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppFailure {
      rethrow;
    } on http.ClientException {
      throw const AppFailure(
        'No connection to file storage. Check your network and try again.',
      );
    } catch (e) {
      throw mapPadException(e);
    }
  }

  static String _randomName(String padId, String ext) {
    final rng = Random.secure();
    final id = List.generate(
      16,
      (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '$padId/$id.$ext';
  }

  @override
  bool get isAvailable => _storage.isAvailable;

  @override
  Stream<List<PadFile>> watchFiles(String padId) =>
      _meta.watch(padId).transform(
            StreamTransformer<List<PadFile>, List<PadFile>>.fromHandlers(
              handleError: (error, stack, sink) =>
                  sink.addError(mapPadException(error), stack),
            ),
          );

  @override
  Future<void> upload(
    String padId, {
    required String name,
    required Uint8List bytes,
  }) =>
      _guard(() async {
        if (!isAvailable) {
          throw const AppFailure('File storage is not set up.');
        }
        final ext = FileRules.extensionOf(name);
        if (ext == null) {
          throw const AppFailure('Only images (PNG, JPG, GIF, WebP) and PDFs.');
        }
        if (bytes.isEmpty) throw const AppFailure('That file is empty.');
        if (bytes.length > FileRules.maxBytes) {
          throw const AppFailure('Files can be at most 5 MB.');
        }

        final contentType = FileRules.types[ext]!;
        final path = _randomName(padId, ext);
        await _storage.upload(path, bytes, contentType);

        try {
          await _meta
              .add(
                padId,
                name: name.length > 200 ? name.substring(0, 200) : name,
                size: bytes.length,
                contentType: contentType,
                path: path,
                expiresAt: DateTime.now().add(FileRules.retention),
              )
              .timeout(_metaTimeout);
        } catch (_) {
          await removeObjects([path]); // don't leave an unlisted file behind
          rethrow;
        }
      });

  @override
  Future<void> delete(PadFile file) => _guard(() async {
        if (isAvailable && file.path.isNotEmpty) {
          await _storage.remove(file.path);
        }
        await _meta.remove(file.padId, file.id).timeout(_metaTimeout);
      });

  @override
  String urlFor(PadFile file) => _storage.publicUrl(file.path);

  @override
  Future<List<String>> pathsForPad(String padId) async {
    try {
      return await _meta.paths(padId).timeout(_metaTimeout);
    } catch (_) {
      return const <String>[];
    }
  }

  @override
  Future<void> removeObjects(List<String> paths) async {
    if (!isAvailable) return;
    for (final path in paths) {
      try {
        await _storage.remove(path);
      } catch (_) {}
    }
  }
}