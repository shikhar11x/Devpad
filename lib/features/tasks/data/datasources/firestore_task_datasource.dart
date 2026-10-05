import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// The only class that talks to Firestore for tasks.
class FirestoreTaskDataSource {
  FirestoreTaskDataSource(this._db);

  final FirebaseFirestore _db;

  /// Offline, writes never get a server confirmation. After this long we
  /// stop waiting: the write stays queued locally and syncs later.
  /// Real errors (e.g. permission-denied) still surface immediately.
  static const _pendingAfter = Duration(seconds: 5);

  CollectionReference<Map<String, dynamic>> _tasks(String padId) =>
      _db.collection('pads').doc(padId).collection('tasks');

  Stream<List<Task>> watchTasks(String padId) => _tasks(padId)
      .snapshots()
      .map((snap) => snap.docs
          .map<Task>((d) => TaskModel.fromDoc(padId, d))
          .toList());

  Future<void> create(
    String padId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      _queued(_tasks(padId).doc().set(TaskModel.createData(
            title: title,
            description: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
          )));

  Future<void> update(
    String padId,
    String taskId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      _queued(_tasks(padId).doc(taskId).update(TaskModel.updateData(
            title: title,
            description: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
          )));

  Future<void> setStatus(String padId, String taskId, TaskStatus status) =>
      _queued(_tasks(padId).doc(taskId).update({
        'status': status.key,
        'updatedAt': FieldValue.serverTimestamp(),
      }));

  Future<void> delete(String padId, String taskId) =>
      _queued(_tasks(padId).doc(taskId).delete());

  Future<void> _queued(Future<void> write) async {
    try {
      await write.timeout(_pendingAfter);
    } on TimeoutException {
      // Offline: the write is queued locally and will sync later.
    }
  }
}