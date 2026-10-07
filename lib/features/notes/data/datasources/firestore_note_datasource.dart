import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/pending_writes.dart';
import '../../domain/entities/note.dart';
import '../models/note_model.dart';

/// The only class that talks to Firestore for notes.
class FirestoreNoteDataSource {
  FirestoreNoteDataSource(this._db);

  final FirebaseFirestore _db;

  /// Firestore writes only complete once the server confirms them. Offline
  /// that never happens, so after this long we treat the write as queued.
  static const _pendingAfter = Duration(seconds: 5);

  CollectionReference<Map<String, dynamic>> _notes(String padId) =>
      _db.collection('pads').doc(padId).collection('notes');

  Stream<List<Note>> watchNotes(String padId) => _notes(padId).snapshots().map(
    (snap) => snap.docs.map<Note>((d) => NoteModel.fromDoc(padId, d)).toList(),
  );

  Future<String> create(String padId) async {
    final ref = _notes(padId).doc();
    await _confirmed(ref.set(NoteModel.createData()));
    return ref.id;
  }

  /// Returns true when the server confirmed the write, false when it is
  /// still queued locally.
  Future<bool> update(
    String padId,
    String noteId, {
    required String title,
    required String content,
  }) => _confirmed(
    _notes(padId)
        .doc(noteId)
        .update(NoteModel.updateData(title: title, content: content)),
  );

  Future<void> delete(String padId, String noteId) async {
    await _confirmed(_notes(padId).doc(noteId).delete());
  }

  Future<bool> _confirmed(Future<void> write) async {
    try {
      await write.timeout(_pendingAfter);
      return true;
    } on TimeoutException {
      PendingWrites.track(write);
      return false;
    }
  }
}
