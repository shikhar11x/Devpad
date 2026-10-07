import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pads/presentation/providers/pad_providers.dart';
import '../../data/datasources/firestore_canvas_datasource.dart';
import '../../data/repositories/canvas_repository_impl.dart';
import '../../domain/entities/canvas_element.dart';
import '../../domain/repositories/canvas_repository.dart';

// Composition root for the canvas feature.
final canvasDataSourceProvider = Provider<FirestoreCanvasDataSource>(
  (ref) => FirestoreCanvasDataSource(ref.watch(firestoreProvider)),
);

final canvasRepositoryProvider = Provider<CanvasRepository>(
  (ref) => CanvasRepositoryImpl(ref.watch(canvasDataSourceProvider)),
);

/// Loads the saved canvas of a Pad once, when its Canvas tab opens.
final canvasElementsProvider =
    FutureProvider.autoDispose.family<List<CanvasElement>, String>(
  (ref, padId) => ref.watch(canvasRepositoryProvider).loadElements(padId),
);