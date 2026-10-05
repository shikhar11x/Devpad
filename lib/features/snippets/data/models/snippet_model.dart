import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/snippet.dart';

class SnippetModel extends Snippet {
  const SnippetModel({
    required super.id,
    required super.padId,
    required super.title,
    required super.language,
    required super.code,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SnippetModel.fromDoc(
    String padId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    // A null server timestamp means the write is still pending ("just now").
    DateTime time(Object? value) =>
        value is Timestamp ? value.toDate() : DateTime.now();

    return SnippetModel(
      id: doc.id,
      padId: padId,
      title: (data['title'] as String?) ?? '',
      language: (data['language'] as String?) ?? 'plaintext',
      code: (data['code'] as String?) ?? '',
      createdAt: time(data['createdAt']),
      updatedAt: time(data['updatedAt']),
    );
  }

  static Map<String, dynamic> createData({required String language}) => {
        'title': '',
        'language': language,
        'code': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Map<String, dynamic> updateData({
    required String title,
    required String language,
    required String code,
  }) =>
      {
        'title': title,
        'language': language,
        'code': code,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}