import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/snippet.dart';
import '../models/snippet_model.dart';

/// The only class that talks to Firestore for snippets.
class FirestoreSnippetDataSource {
  FirestoreSnippetDataSource(this._db);

  final FirebaseFirestore _db;

  /// Offline, writes never get a server confirmation. After this long we
  /// treat the write as queued locally.
  static const _pendingAfter = Duration(seconds: 5);

  CollectionReference<Map<String, dynamic>> _snippets(String padId) =>
      _db.collection('pads').doc(padId).collection('snippets');

  Stream<List<Snippet>> watchSnippets(String padId) =>
      _snippets(padId).snapshots().map(
            (snap) => snap.docs
                .map<Snippet>((d) => SnippetModel.fromDoc(padId, d))
                .toList(),
          );

  Future<String> create(String padId, {required String language}) async {
    final ref = _snippets(padId).doc();
    await _confirmed(ref.set(SnippetModel.createData(language: language)));
    return ref.id;
  }

  /// True when the server confirmed the write, false when still queued.
  Future<bool> update(
    String padId,
    String snippetId, {
    required String title,
    required String language,
    required String code,
  }) =>
      _confirmed(
        _snippets(padId).doc(snippetId).update(
              SnippetModel.updateData(
                title: title,
                language: language,
                code: code,
              ),
            ),
      );

  Future<void> delete(String padId, String snippetId) async {
    await _confirmed(_snippets(padId).doc(snippetId).delete());
  }

  Future<bool> _confirmed(Future<void> write) async {
    try {
      await write.timeout(_pendingAfter);
      return true;
    } on TimeoutException {
      return false;
    }
  }
}