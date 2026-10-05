enum TaskStatus {
  todo('todo', 'To do'),
  inProgress('in_progress', 'In progress'),
  done('done', 'Done');

  const TaskStatus(this.key, this.label);

  /// Value stored in Firestore.
  final String key;
  final String label;

  static TaskStatus fromKey(String? key) =>
      values.firstWhere((s) => s.key == key, orElse: () => todo);
}

enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const TaskPriority(this.key, this.label);

  final String key;
  final String label;

  static TaskPriority fromKey(String? key) =>
      values.firstWhere((p) => p.key == key, orElse: () => medium);
}

class Task {
  const Task({
    required this.id,
    required this.padId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String padId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;

  /// Calendar day the task is due (local midnight), or null.
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDone => status == TaskStatus.done;
}