import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:devpad/features/pads/domain/entities/pad.dart';
import 'package:devpad/features/pads/presentation/providers/pad_providers.dart';
import 'package:devpad/features/tasks/domain/entities/task.dart';
import 'package:devpad/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(uid: 'u1', email: 'dev@example.com');

final _pad = Pad(
  id: 'p1',
  ownerId: 'u1',
  title: 'FieldForce Pro',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 2),
);

Widget _app(List<Task> tasks) => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(_user)),
        padsProvider.overrideWith((ref) => Stream<List<Pad>>.value([_pad])),
        tasksProvider('p1')
            .overrideWith((ref) => Stream<List<Task>>.value(tasks)),
      ],
      child: const DevPadApp(),
    );

Future<void> _openTasksTab(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.folder_copy_outlined).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('FieldForce Pro'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tasks').first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Tasks tab lists the tasks of the pad', (tester) async {
    final task = Task(
      id: 't1',
      padId: 'p1',
      title: 'Write API client',
      priority: TaskPriority.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(_app([task]));
    await tester.pumpAndSettle();
    await _openTasksTab(tester);

    expect(find.text('Write API client'), findsOneWidget);
    expect(find.text('0 of 1 done'), findsOneWidget);
  });

  testWidgets('Tasks tab shows the empty state with no tasks', (tester) async {
    await tester.pumpWidget(_app(const []));
    await tester.pumpAndSettle();
    await _openTasksTab(tester);

    expect(find.text('No tasks yet.'), findsOneWidget);
    expect(find.text('Create your first task →'), findsOneWidget);
  });
}