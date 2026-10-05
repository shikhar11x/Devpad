import 'dart:async';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/firestore_note_datasource.dart';
import '../note_error_mapper.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._dataSource);

  final FirestoreNoteDataSource _dataSource;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw mapNoteException(e);
    }
  }

  @override
  Stream<List<Note>> watchNotes(String padId) =>
      _dataSource.watchNotes(padId).transform(
            StreamTransformer<List<Note>, List<Note>>.fromHandlers(
              handleError: (error, stack, sink) =>
                  sink.addError(mapNoteException(error), stack),
            ),
          );

  @override
  Future<String> createNote(String padId) =>
      _guard(() => _dataSource.create(padId));

  @override
  Future<SaveOutcome> updateNote({
    required String padId,
    required String noteId,
    required String title,
    required String content,
  }) =>
      _guard(() async {
        final confirmed = await _dataSource.update(
          padId,
          noteId,
          title: title,
          content: content,
        );
        return confirmed ? SaveOutcome.synced : SaveOutcome.queued;
      });

  @override
  Future<void> deleteNote(String padId, String noteId) =>
      _guard(() => _dataSource.delete(padId, noteId));
}