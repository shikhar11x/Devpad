import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_providers.dart';

/// Write operations for tasks. All methods throw `AppFailure` on error.
class TaskActions {
  TaskActions(this._ref);

  final Ref _ref;

  TaskRepository get _repo => _ref.read(taskRepositoryProvider);

  Future<void> create(
    String padId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      _repo.createTask(
        padId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );

  Future<void> update(
    String padId,
    String taskId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  }) =>
      _repo.updateTask(
        padId,
        taskId,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
      );

  Future<void> setStatus(String padId, String taskId, TaskStatus status) =>
      _repo.setStatus(padId, taskId, status);

  Future<void> delete(String padId, String taskId) =>
      _repo.deleteTask(padId, taskId);
}

final taskActionsProvider = Provider<TaskActions>((ref) => TaskActions(ref));