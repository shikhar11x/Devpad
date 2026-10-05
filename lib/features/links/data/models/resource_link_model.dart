import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/resource_link.dart';

class ResourceLinkModel extends ResourceLink {
  const ResourceLinkModel({
    required super.id,
    required super.padId,
    required super.title,
    required super.url,
    required super.description,
    required super.category,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ResourceLinkModel.fromDoc(
    String padId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    // A null server timestamp means the write is still pending ("just now").
    DateTime time(Object? value) =>
        value is Timestamp ? value.toDate() : DateTime.now();

    return ResourceLinkModel(
      id: doc.id,
      padId: padId,
      title: (data['title'] as String?) ?? '',
      url: (data['url'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: LinkCategory.fromKey(data['category'] as String?),
      createdAt: time(data['createdAt']),
      updatedAt: time(data['updatedAt']),
    );
  }

  static Map<String, dynamic> createData({
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) =>
      {
        'title': title,
        'url': url,
        'description': description,
        'category': category.key,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Map<String, dynamic> updateData({
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) =>
      {
        'title': title,
        'url': url,
        'description': description,
        'category': category.key,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}