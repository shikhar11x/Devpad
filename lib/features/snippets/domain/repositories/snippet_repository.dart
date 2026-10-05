import '../entities/snippet.dart';

/// Whether a save was confirmed by the server or is queued locally (offline).
enum SnippetSaveOutcome { synced, queued }

/// Contract the UI depends on. Methods throw `AppFailure` with a
/// user-presentable message.
abstract interface class SnippetRepository {
  Stream<List<Snippet>> watchSnippets(String padId);

  /// Creates an empty snippet and returns its id.
  Future<String> createSnippet(String padId, {required String language});

  Future<SnippetSaveOutcome> updateSnippet({
    required String padId,
    required String snippetId,
    required String title,
    required String language,
    required String code,
  });

  Future<void> deleteSnippet(String padId, String snippetId);
}