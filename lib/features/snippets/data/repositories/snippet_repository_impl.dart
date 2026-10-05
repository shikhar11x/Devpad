import 'dart:async';

import '../../../pads/data/pad_error_mapper.dart';
import '../../domain/entities/snippet.dart';
import '../../domain/repositories/snippet_repository.dart';
import '../datasources/firestore_snippet_datasource.dart';

class SnippetRepositoryImpl implements SnippetRepository {
  SnippetRepositoryImpl(this._dataSource);

  final FirestoreSnippetDataSource _dataSource;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw mapPadException(e);
    }
  }

  @override
  Stream<List<Snippet>> watchSnippets(String padId) =>
      _dataSource.watchSnippets(padId).transform(
            StreamTransformer<List<Snippet>, List<Snippet>>.fromHandlers(
              handleError: (error, stack, sink) =>
                  sink.addError(mapPadException(error), stack),
            ),
          );

  @override
  Future<String> createSnippet(String padId, {required String language}) =>
      _guard(() => _dataSource.create(padId, language: language));

  @override
  Future<SnippetSaveOutcome> updateSnippet({
    required String padId,
    required String snippetId,
    required String title,
    required String language,
    required String code,
  }) =>
      _guard(() async {
        final confirmed = await _dataSource.update(
          padId,
          snippetId,
          title: title,
          language: language,
          code: code,
        );
        return confirmed ? SnippetSaveOutcome.synced : SnippetSaveOutcome.queued;
      });

  @override
  Future<void> deleteSnippet(String padId, String snippetId) =>
      _guard(() => _dataSource.delete(padId, snippetId));
}