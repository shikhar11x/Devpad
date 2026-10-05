import '../entities/task.dart';

/// Contract the UI depends on. Methods throw `AppFailure` with a
/// user-presentable message.
abstract interface class TaskRepository {
  Stream<List<Task>> watchTasks(String padId);

  Future<void> createTask(
    String padId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  });

  Future<void> updateTask(
    String padId,
    String taskId, {
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
  });

  Future<void> setStatus(String padId, String taskId, TaskStatus status);

  Future<void> deleteTask(String padId, String taskId);
}