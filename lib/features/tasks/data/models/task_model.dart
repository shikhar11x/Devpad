import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.padId,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.dueDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromDoc(
    String padId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    // A null server timestamp means the write is still pending ("just now").
    DateTime time(Object? value) =>
        value is Timestamp ? value.toDate() : DateTime.now();

    final due = data['dueDate'];
    return TaskModel(
      id: doc.id,
      padId: padId,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      status: TaskStatus.fromKey(data['status'] as String?),
      priority: TaskPriority.fromKey(data['priority'] as String?),
      dueDate: due is Timestamp ? due.toDate() : null,
      createdAt: time(data['createdAt']),
      updatedAt: time(data['updatedAt']),
    );
  }

  static Map<String, dynamic> createData({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      {
        'title': title,
        'description': description,
        'status': status.key,
        'priority': priority.key,
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static Map<String, dynamic> updateData({
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      {
        'title': title,
        'description': description,
        'status': status.key,
        'priority': priority.key,
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}