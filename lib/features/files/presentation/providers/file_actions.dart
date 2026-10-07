import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pad_file.dart';
import 'file_providers.dart';

class FileActions {
  FileActions(this._ref);

  final Ref _ref;

  Future<void> upload(
    String padId, {
    required String name,
    required Uint8List bytes,
  }) =>
      _ref
          .read(fileRepositoryProvider)
          .upload(padId, name: name, bytes: bytes);

  Future<void> delete(PadFile file) =>
      _ref.read(fileRepositoryProvider).delete(file);

  /// Best effort: removes files whose 7 days are over.
  Future<void> purgeExpired(List<PadFile> files) async {
    for (final f in files) {
      if (!f.isExpired()) continue;
      try {
        await delete(f);
      } catch (_) {}
    }
  }
}

final fileActionsProvider = Provider<FileActions>((ref) => FileActions(ref));