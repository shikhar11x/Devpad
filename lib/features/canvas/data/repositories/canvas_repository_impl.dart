import 'dart:async';
import 'dart:convert';

import '../../../../core/errors/app_failure.dart';
import '../../../pads/data/pad_error_mapper.dart';
import '../../domain/entities/canvas_element.dart';
import '../../domain/repositories/canvas_repository.dart';
import '../datasources/firestore_canvas_datasource.dart';
import '../models/canvas_codec.dart';

class CanvasRepositoryImpl implements CanvasRepository {
  CanvasRepositoryImpl(this._dataSource);

  final FirestoreCanvasDataSource _dataSource;

  static const _loadTimeout = Duration(seconds: 15);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw mapPadException(e);
    }
  }

  @override
  Future<List<CanvasElement>> loadElements(String padId) =>
      _guard<List<CanvasElement>>(() async {
        final source = await _dataSource.load(padId).timeout(_loadTimeout);
        if (source == null) return const <CanvasElement>[];
        try {
          return CanvasCodec.decode(source);
        } on FormatException {
          throw const AppFailure('This canvas could not be read.');
        }
      });

  @override
  Future<CanvasSaveOutcome> saveElements(
    String padId,
    List<CanvasElement> elements,
  ) =>
      _guard<CanvasSaveOutcome>(() async {
        final encoded = CanvasCodec.encode(elements);
        if (utf8.encode(encoded).length > CanvasCodec.maxBytes) {
          throw const AppFailure(
            'This canvas is too large to save. Delete some drawings.',
          );
        }
        final confirmed = await _dataSource.save(padId, encoded);
        return confirmed ? CanvasSaveOutcome.synced : CanvasSaveOutcome.queued;
      });
}