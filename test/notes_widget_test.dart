import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:devpad/features/notes/domain/entities/note.dart';
import 'package:devpad/features/notes/presentation/providers/note_providers.dart';
import 'package:devpad/features/pads/domain/entities/pad.dart';
import 'package:devpad/features/pads/presentation/providers/pad_providers.dart';
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

Widget _app(List<Note> notes) => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(_user)),
        padsProvider.overrideWith((ref) => Stream<List<Pad>>.value([_pad])),
        notesProvider('p1')
            .overrideWith((ref) => Stream<List<Note>>.value(notes)),
      ],
      child: const DevPadApp(),
    );

Future<void> _openNotesTab(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.folder_copy_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text('FieldForce Pro'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Notes'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Notes tab lists the notes of the pad', (tester) async {
    final note = Note(
      id: 'n1',
      padId: 'p1',
      title: 'API Integration',
      content: '# Plan\nCall the endpoint',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(_app([note]));
    await tester.pumpAndSettle();
    await _openNotesTab(tester);

    expect(find.text('API Integration'), findsOneWidget);
    expect(find.text('Select a note'), findsOneWidget);
  });

  testWidgets('Notes tab shows the empty state with no notes',
      (tester) async {
    await tester.pumpWidget(_app(const []));
    await tester.pumpAndSettle();
    await _openNotesTab(tester);

    expect(find.text('No notes yet.'), findsOneWidget);
    expect(find.text('Create your first note →'), findsOneWidget);
  });
}