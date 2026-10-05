import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.padId,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromDoc(
    String padId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    // A null server timestamp means the write is still pending, so it
    // happened "just now".
    DateTime time(Object? value) =>
        value is Timestamp ? value.toDate() : DateTime.now();

    return NoteModel(
      id: doc.id,
      padId: padId,
      title: (data['title'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      createdAt: time(data['createdAt']),
      updatedAt: time(data['updatedAt']),
    );
  }

  static Map<String, dynamic> createData() => {
        'title': '',
        'content': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Map<String, dynamic> updateData({
    required String title,
    required String content,
  }) =>
      {
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}