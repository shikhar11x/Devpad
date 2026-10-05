import 'package:devpad/features/tasks/domain/entities/task.dart';
import 'package:devpad/features/tasks/presentation/task_filters.dart';
import 'package:flutter_test/flutter_test.dart';

Task _t(
  String id, {
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? due,
}) =>
    Task(
      id: id,
      padId: 'p1',
      title: id,
      status: status,
      priority: priority,
      dueDate: due,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  test('sortTasks puts done last, then high priority, then earlier due', () {
    final tasks = [
      _t('done', status: TaskStatus.done, priority: TaskPriority.high),
      _t('low', priority: TaskPriority.low),
      _t('high-late', priority: TaskPriority.high, due: DateTime(2026, 5, 1)),
      _t('high-soon', priority: TaskPriority.high, due: DateTime(2026, 3, 1)),
      _t('high-none', priority: TaskPriority.high),
    ];

    final ids = sortTasks(tasks).map((t) => t.id).toList();

    expect(ids, ['high-soon', 'high-late', 'high-none', 'low', 'done']);
  });

  test('filterTasks filters by status and priority', () {
    final tasks = [
      _t('a', status: TaskStatus.inProgress, priority: TaskPriority.high),
      _t('b', status: TaskStatus.inProgress, priority: TaskPriority.low),
      _t('c', priority: TaskPriority.high),
    ];

    expect(
      filterTasks(tasks, status: TaskStatus.inProgress).map((t) => t.id),
      ['a', 'b'],
    );
    expect(
      filterTasks(tasks, priority: TaskPriority.high).map((t) => t.id),
      ['a', 'c'],
    );
    expect(
      filterTasks(tasks, status: TaskStatus.inProgress, priority: TaskPriority.high)
          .map((t) => t.id),
      ['a'],
    );
    expect(filterTasks(tasks), hasLength(3));
  });

  test('isOverdue ignores done tasks and today', () {
    final now = DateTime(2026, 6, 10, 15);

    expect(isOverdue(_t('x', due: DateTime(2026, 6, 9)), now: now), isTrue);
    expect(isOverdue(_t('x', due: DateTime(2026, 6, 10)), now: now), isFalse);
    expect(isOverdue(_t('x', due: DateTime(2026, 6, 11)), now: now), isFalse);
    expect(isOverdue(_t('x'), now: now), isFalse);
    expect(
      isOverdue(
        _t('x', status: TaskStatus.done, due: DateTime(2026, 6, 1)),
        now: now,
      ),
      isFalse,
    );
  });
}