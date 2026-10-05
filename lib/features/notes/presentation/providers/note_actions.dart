import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/note_repository.dart';
import 'note_providers.dart';

/// Write operations for notes. All methods throw `AppFailure` on error.
class NoteActions {
  NoteActions(this._ref);

  final Ref _ref;

  NoteRepository get _repo => _ref.read(noteRepositoryProvider);

  Future<String> create(String padId) => _repo.createNote(padId);

  Future<SaveOutcome> save(
    String padId,
    String noteId, {
    required String title,
    required String content,
  }) =>
      _repo.updateNote(
        padId: padId,
        noteId: noteId,
        title: title,
        content: content,
      );

  Future<void> delete(String padId, String noteId) =>
      _repo.deleteNote(padId, noteId);
}

final noteActionsProvider = Provider<NoteActions>((ref) => NoteActions(ref));