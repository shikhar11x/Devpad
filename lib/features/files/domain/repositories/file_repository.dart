import 'dart:typed_data';

import '../entities/pad_file.dart';

/// Methods throw `AppFailure` with a user-presentable message.
abstract interface class FileRepository {
  /// False when storage keys were not provided to the app.
  bool get isAvailable;

  Stream<List<PadFile>> watchFiles(String padId);

  Future<void> upload(
    String padId, {
    required String name,
    required Uint8List bytes,
  });

  /// Removes the stored object, then its record.
  Future<void> delete(PadFile file);

  String urlFor(PadFile file);

  /// Storage paths of every file of a Pad (empty on any failure).
  Future<List<String>> pathsForPad(String padId);

  /// Best effort: never throws.
  Future<void> removeObjects(List<String> paths);
}