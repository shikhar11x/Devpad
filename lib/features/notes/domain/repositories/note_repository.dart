import '../entities/note.dart';

/// Whether a save was confirmed by the server or is queued locally (offline).
enum SaveOutcome { synced, queued }

/// Contract the UI depends on. Methods throw `AppFailure` with a
/// user-presentable message.
abstract interface class NoteRepository {
  Stream<List<Note>> watchNotes(String padId);

  /// Creates an empty note and returns its id without waiting for the
  /// server when offline.
  Future<String> createNote(String padId);

  Future<SaveOutcome> updateNote({
    required String padId,
    required String noteId,
    required String title,
    required String content,
  });

  Future<void> deleteNote(String padId, String noteId);
}