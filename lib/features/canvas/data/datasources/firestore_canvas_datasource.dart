import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// The only class that talks to Firestore for the canvas.
class FirestoreCanvasDataSource {
  FirestoreCanvasDataSource(this._db);

  final FirebaseFirestore _db;

  /// Offline, writes never get a server confirmation. After this long we
  /// stop waiting: the write stays queued locally and syncs later.
  /// Real errors (e.g. permission-denied) still surface immediately.
  static const _pendingAfter = Duration(seconds: 5);

  DocumentReference<Map<String, dynamic>> _doc(String padId) =>
      _db.collection('pads').doc(padId).collection('canvas').doc('main');

  /// The stored JSON string, or null if this Pad has no canvas yet.
  Future<String?> load(String padId) async {
    final snap = await _doc(padId).get();
    final value = snap.data()?['elements'];
    return value is String ? value : null;
  }

  /// True when the server confirmed the write, false when still queued.
  Future<bool> save(String padId, String encoded) async {
    final write = _doc(padId).set({
      'elements': encoded,
      'version': 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    try {
      await write.timeout(_pendingAfter);
      return true;
    } on TimeoutException {
      return false;
    }
  }
}