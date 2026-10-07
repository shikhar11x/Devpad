import '../entities/canvas_element.dart';

/// Whether a save was confirmed by the server or is queued locally (offline).
enum CanvasSaveOutcome { synced, queued }

/// Contract the UI depends on. Methods throw `AppFailure` with a
/// user-presentable message.
abstract interface class CanvasRepository {
  /// Empty list when the Pad has no canvas yet.
  Future<List<CanvasElement>> loadElements(String padId);

  Future<CanvasSaveOutcome> saveElements(
    String padId,
    List<CanvasElement> elements,
  );
}