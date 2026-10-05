import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/snippet_repository.dart';
import 'snippet_providers.dart';

/// Write operations for snippets. All methods throw `AppFailure` on error.
class SnippetActions {
  SnippetActions(this._ref);

  final Ref _ref;

  SnippetRepository get _repo => _ref.read(snippetRepositoryProvider);

  Future<String> create(String padId, {required String language}) =>
      _repo.createSnippet(padId, language: language);

  Future<SnippetSaveOutcome> save(
    String padId,
    String snippetId, {
    required String title,
    required String language,
    required String code,
  }) =>
      _repo.updateSnippet(
        padId: padId,
        snippetId: snippetId,
        title: title,
        language: language,
        code: code,
      );

  Future<void> delete(String padId, String snippetId) =>
      _repo.deleteSnippet(padId, snippetId);
}

final snippetActionsProvider =
    Provider<SnippetActions>((ref) => SnippetActions(ref));