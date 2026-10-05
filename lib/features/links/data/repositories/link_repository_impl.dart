import 'dart:async';

import '../../../pads/data/pad_error_mapper.dart';
import '../../domain/entities/resource_link.dart';
import '../../domain/repositories/link_repository.dart';
import '../datasources/firestore_link_datasource.dart';

class LinkRepositoryImpl implements LinkRepository {
  LinkRepositoryImpl(this._dataSource);

  final FirestoreLinkDataSource _dataSource;

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      throw mapPadException(e);
    }
  }

  @override
  Stream<List<ResourceLink>> watchLinks(String padId) =>
      _dataSource.watchLinks(padId).transform(
            StreamTransformer<List<ResourceLink>, List<ResourceLink>>
                .fromHandlers(
              handleError: (error, stack, sink) =>
                  sink.addError(mapPadException(error), stack),
            ),
          );

  @override
  Future<void> createLink(
    String padId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) =>
      _guard(() => _dataSource.create(
            padId,
            title: title.trim(),
            url: url.trim(),
            description: description.trim(),
            category: category,
          ));

  @override
  Future<void> updateLink(
    String padId,
    String linkId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) =>
      _guard(() => _dataSource.update(
            padId,
            linkId,
            title: title.trim(),
            url: url.trim(),
            description: description.trim(),
            category: category,
          ));

  @override
  Future<void> deleteLink(String padId, String linkId) =>
      _guard(() => _dataSource.delete(padId, linkId));
}