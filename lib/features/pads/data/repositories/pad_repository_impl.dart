import 'dart:async';

import '../../domain/entities/pad.dart';
import '../../domain/repositories/pad_repository.dart';
import '../datasources/firestore_pad_datasource.dart';
import '../pad_error_mapper.dart';

class PadRepositoryImpl implements PadRepository {
  PadRepositoryImpl(this._dataSource);

  final FirestorePadDataSource _dataSource;

  // Firestore writes wait for the server when offline; don't hang the UI.
  static const _writeTimeout = Duration(seconds: 15);
  static const _deleteTimeout = Duration(seconds: 60);

  Future<void> _guard(
    Future<void> Function() action, {
    Duration timeout = _writeTimeout,
  }) async {
    try {
      await action().timeout(timeout);
    } catch (e) {
      throw mapPadException(e);
    }
  }

  @override
  Stream<List<Pad>> watchPads(String ownerId) => _dataSource
      .watchPads(ownerId)
      .transform(
        StreamTransformer<List<Pad>, List<Pad>>.fromHandlers(
          handleError: (error, stack, sink) =>
              sink.addError(mapPadException(error), stack),
        ),
      );

  @override
  Stream<bool> watchIsFromCache(String ownerId) =>
      _dataSource.watchFromCache(ownerId);

  @override
  Future<void> createPad({
    required String ownerId,
    required String title,
    required String description,
    required String icon,
  }) => _guard(
    () => _dataSource.create(
      ownerId: ownerId,
      title: title.trim(),
      description: description.trim(),
      icon: icon,
    ),
  );

  @override
  Future<void> updatePad({
    required String padId,
    required String title,
    required String description,
    required String icon,
  }) => _guard(
    () => _dataSource.update(
      padId,
      title: title.trim(),
      description: description.trim(),
      icon: icon,
    ),
  );

  @override
  Future<void> setArchived(String padId, bool archived) =>
      _guard(() => _dataSource.setArchived(padId, archived));

  @override
  Future<void> deletePad(String padId) =>
      _guard(() => _dataSource.delete(padId), timeout: _deleteTimeout);

  @override
  Future<void> markOpened(String padId) =>
      _guard(() => _dataSource.markOpened(padId));
}
