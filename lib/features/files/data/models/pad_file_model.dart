import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pad_file.dart';
import '../../domain/file_rules.dart';

class PadFileModel extends PadFile {
  const PadFileModel({
    required super.id,
    required super.padId,
    required super.name,
    required super.size,
    required super.contentType,
    required super.path,
    required super.createdAt,
    required super.expiresAt,
  });

  factory PadFileModel.fromDoc(
    String padId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final created = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final expires = data['expiresAt'] is Timestamp
        ? (data['expiresAt'] as Timestamp).toDate()
        : created.add(FileRules.retention);
    return PadFileModel(
      id: doc.id,
      padId: padId,
      name: (data['name'] as String?) ?? 'file',
      size: (data['size'] as num?)?.toInt() ?? 0,
      contentType: (data['contentType'] as String?) ?? 'application/octet-stream',
      path: (data['path'] as String?) ?? '',
      createdAt: created,
      expiresAt: expires,
    );
  }
}