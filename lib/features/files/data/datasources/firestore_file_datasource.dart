import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pad_file.dart';
import '../models/pad_file_model.dart';

/// The only class that talks to Firestore for file records.
class FirestoreFileDataSource {
  FirestoreFileDataSource(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _files(String padId) =>
      _db.collection('pads').doc(padId).collection('files');

  Stream<List<PadFile>> watch(String padId) => _files(padId).snapshots().map(
        (snap) => snap.docs
            .map<PadFile>((d) => PadFileModel.fromDoc(padId, d))
            .toList(),
      );

  Future<void> add(
    String padId, {
    required String name,
    required int size,
    required String contentType,
    required String path,
    required DateTime expiresAt,
  }) =>
      _files(padId).doc().set({
        'name': name,
        'size': size,
        'contentType': contentType,
        'path': path,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

  Future<void> remove(String padId, String fileId) =>
      _files(padId).doc(fileId).delete();

  Future<List<String>> paths(String padId) async {
    final snap = await _files(padId).get();
    return [
      for (final d in snap.docs)
        if (d.data()['path'] is String) d.data()['path'] as String,
    ];
  }
}