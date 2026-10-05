import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pads/presentation/providers/pad_providers.dart';
import '../../data/datasources/firestore_note_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

// Composition root for the notes feature.
final noteDataSourceProvider = Provider<FirestoreNoteDataSource>(
  (ref) => FirestoreNoteDataSource(ref.watch(firestoreProvider)),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(ref.watch(noteDataSourceProvider)),
);

/// Live notes of one Pad (served from the local cache when offline).
final notesProvider =
    StreamProvider.autoDispose.family<List<Note>, String>((ref, padId) {
  return ref.watch(noteRepositoryProvider).watchNotes(padId);
});