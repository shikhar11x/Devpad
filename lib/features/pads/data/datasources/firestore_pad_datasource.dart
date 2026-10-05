import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pad.dart';
import '../models/pad_model.dart';

/// The only class that talks to Firestore for Pads.
class FirestorePadDataSource {
  FirestorePadDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _pads => _db.collection('pads');

  Stream<List<Pad>> watchPads(String ownerId) => _pads
      .where('ownerId', isEqualTo: ownerId)
      .snapshots()
      .map((snap) => snap.docs.map<Pad>((d) => PadModel.fromDoc(d)).toList());

  Future<void> create({
    required String ownerId,
    required String title,
    required String description,
    required String icon,
  }) async {
    await _pads.add(PadModel.createData(
      ownerId: ownerId,
      title: title,
      description: description,
      icon: icon,
    ));
  }

  Future<void> update(
    String padId, {
    required String title,
    required String description,
    required String icon,
  }) =>
      _pads.doc(padId).update(PadModel.updateData(
            title: title,
            description: description,
            icon: icon,
          ));

  Future<void> setArchived(String padId, bool archived) =>
      _pads.doc(padId).update({
        'archived': archived,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Subcollections under a Pad. Firestore does not delete these when the
  /// parent is deleted, so add each new one here (tasks, links, ...).
  static const _subcollections = ['notes', 'snippets', 'tasks', 'links'];
  /// Deletes the Pad's subcollections, then the Pad. Reads from the server
  /// on purpose, so this fails with a clear error when offline instead of
  /// leaving orphaned data.
  Future<void> delete(String padId) async {
    final padRef = _pads.doc(padId);
    for (final name in _subcollections) {
      final col = padRef.collection(name);
      while (true) {
        final snap =
            await col.limit(400).get(const GetOptions(source: Source.server));
        if (snap.docs.isEmpty) break;
        final batch = _db.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    await padRef.delete();
  }
  Future<void> markOpened(String padId) => _pads.doc(padId).update({
        'lastOpenedAt': FieldValue.serverTimestamp(),
      });
}