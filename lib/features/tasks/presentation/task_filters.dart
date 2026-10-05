import '../domain/entities/task.dart';

/// Keeps tasks matching the given status and/or priority (null = any).
List<Task> filterTasks(
  List<Task> tasks, {
  TaskStatus? status,
  TaskPriority? priority,
}) =>
    tasks
        .where((t) =>
            (status == null || t.status == status) &&
            (priority == null || t.priority == priority))
        .toList();

/// Unfinished first, then higher priority, then earlier due date
/// (no date last), then newest first. Returns a new list.
List<Task> sortTasks(List<Task> tasks) {
  final sorted = [...tasks];
  sorted.sort((a, b) {
    final byDone = (a.isDone ? 1 : 0).compareTo(b.isDone ? 1 : 0);
    if (byDone != 0) return byDone;

    final byPriority = b.priority.index.compareTo(a.priority.index);
    if (byPriority != 0) return byPriority;

    final da = a.dueDate;
    final db = b.dueDate;
    if (da != null || db != null) {
      if (da == null) return 1;
      if (db == null) return -1;
      final byDue = da.compareTo(db);
      if (byDue != 0) return byDue;
    }

    return b.createdAt.compareTo(a.createdAt);
  });
  return sorted;
}

/// True when the task is not done and its due day is before today.
bool isOverdue(Task task, {DateTime? now}) {
  final due = task.dueDate;
  if (due == null || task.isDone) return false;
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  return due.isBefore(today);
}