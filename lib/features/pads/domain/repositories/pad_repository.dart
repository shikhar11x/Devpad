import '../entities/pad.dart';

/// Contract the UI depends on. Methods throw `AppFailure` with a
/// user-presentable message.
abstract interface class PadRepository {
  /// All Pads owned by [ownerId] (active and archived).
  Stream<List<Pad>> watchPads(String ownerId);

  Future<void> createPad({
    required String ownerId,
    required String title,
    required String description,
    required String icon,
  });

  Future<void> updatePad({
    required String padId,
    required String title,
    required String description,
    required String icon,
  });

  Future<void> setArchived(String padId, bool archived);

  Future<void> deletePad(String padId);

  /// Records that the Pad was just opened (drives "Recent").
  Future<void> markOpened(String padId);
}