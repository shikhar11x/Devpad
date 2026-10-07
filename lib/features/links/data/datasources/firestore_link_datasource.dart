import 'dart:async';

import '../../../../core/services/pending_writes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/resource_link.dart';
import '../models/resource_link_model.dart';

/// The only class that talks to Firestore for links.
class FirestoreLinkDataSource {
  FirestoreLinkDataSource(this._db);

  final FirebaseFirestore _db;

  /// Offline, writes never get a server confirmation. After this long we
  /// stop waiting: the write stays queued locally and syncs later.
  /// Real errors (e.g. permission-denied) still surface immediately.
  static const _pendingAfter = Duration(seconds: 5);

  CollectionReference<Map<String, dynamic>> _links(String padId) =>
      _db.collection('pads').doc(padId).collection('links');

  Stream<List<ResourceLink>> watchLinks(String padId) =>
      _links(padId).snapshots().map(
        (snap) => snap.docs
            .map<ResourceLink>((d) => ResourceLinkModel.fromDoc(padId, d))
            .toList(),
      );

  Future<void> create(
    String padId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) => _queued(
    _links(padId).doc().set(
      ResourceLinkModel.createData(
        title: title,
        url: url,
        description: description,
        category: category,
      ),
    ),
  );

  Future<void> update(
    String padId,
    String linkId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) => _queued(
    _links(padId)
        .doc(linkId)
        .update(
          ResourceLinkModel.updateData(
            title: title,
            url: url,
            description: description,
            category: category,
          ),
        ),
  );

  Future<void> delete(String padId, String linkId) =>
      _queued(_links(padId).doc(linkId).delete());

    Future<void> _queued(Future<void> write) async {
    try {
      await write.timeout(_pendingAfter);
    } on TimeoutException {
      // Offline: the write is queued locally and will sync later.
      PendingWrites.track(write);
    }
  }
}
