import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pad.dart';

class PadModel extends Pad {
  const PadModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.icon,
    required super.createdAt,
    required super.updatedAt,
    required super.lastOpenedAt,
    required super.archived,
  });

  factory PadModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};

    // Server timestamps are null locally until the write is confirmed.
    DateTime? time(Object? value) =>
        value is Timestamp ? value.toDate() : null;

    final created = time(data['createdAt']) ?? DateTime.now();
    return PadModel(
      id: doc.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      title: (data['title'] as String?) ?? 'Untitled',
      description: (data['description'] as String?) ?? '',
      icon: (data['icon'] as String?) ?? Pad.defaultIcon,
      createdAt: created,
      updatedAt: time(data['updatedAt']) ?? created,
      lastOpenedAt: time(data['lastOpenedAt']),
      archived: (data['archived'] as bool?) ?? false,
    );
  }

  static Map<String, dynamic> createData({
    required String ownerId,
    required String title,
    required String description,
    required String icon,
  }) =>
      {
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'icon': icon,
        'archived': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Map<String, dynamic> updateData({
    required String title,
    required String description,
    required String icon,
  }) =>
      {
        'title': title,
        'description': description,
        'icon': icon,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}