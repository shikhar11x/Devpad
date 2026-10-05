import 'dart:async';

import '../../../pads/data/pad_error_mapper.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firestore_task_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dataSource);

  final FirestoreTaskDataSource _dataSource;

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      throw mapPadException(e);
    }
  }

  @override
  Stream<List<Task>> watchTasks(String padId) =>
      _dataSource.watchTasks(padId).transform(
            StreamTransformer<List<Task>, List<Task>>.fromHandlers(
              handleError: (error, stack, sink) =>
                  sink.addError(mapPadException(error), stack),
            ),
          );

  @override
  Future<void> createTask(
    String padId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      _guard(() => _dataSource.create(
            padId,
            title: title.trim(),
            description: description.trim(),
            status: status,
            priority: priority,
            dueDate: dueDate,
          ));

  @override
  Future<void> updateTask(
    String padId,
    String taskId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      _guard(() => _dataSource.update(
            padId,
            taskId,
            title: title.trim(),
            description: description.trim(),
            status: status,
            priority: priority,
            dueDate: dueDate,
          ));

  @override
  Future<void> setStatus(String padId, String taskId, TaskStatus status) =>
      _guard(() => _dataSource.setStatus(padId, taskId, status));

  @override
  Future<void> deleteTask(String padId, String taskId) =>
      _guard(() => _dataSource.delete(padId, taskId));
}