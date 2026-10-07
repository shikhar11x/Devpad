import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/canvas_element.dart';
import '../../domain/repositories/canvas_repository.dart';
import 'canvas_providers.dart';

/// Write operations for the canvas. Throws `AppFailure` on error.
class CanvasActions {
  CanvasActions(this._ref);

  final Ref _ref;

  CanvasRepository get _repo => _ref.read(canvasRepositoryProvider);

  Future<CanvasSaveOutcome> save(
    String padId,
    List<CanvasElement> elements,
  ) =>
      _repo.saveElements(padId, elements);
}

final canvasActionsProvider =
    Provider<CanvasActions>((ref) => CanvasActions(ref));