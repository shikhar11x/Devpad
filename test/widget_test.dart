import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:devpad/features/pads/domain/entities/pad.dart';
import 'package:devpad/features/pads/presentation/providers/pad_providers.dart';
import 'package:devpad/features/pads/presentation/widgets/pad_section_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AuthUser(uid: 'u1', email: 'dev@example.com');

final _pad = Pad(
  id: 'p1',
  ownerId: 'u1',
  title: 'FieldForce Pro',
  description: 'Field sales app',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 2),
);

Widget _app({AuthUser? user, List<Pad> pads = const []}) => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(user)),
        padsProvider.overrideWith((ref) => Stream<List<Pad>>.value(pads)),
      ],
      child: const DevPadApp(),
    );

void main() {
  testWidgets('signed out users see the login screen', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('signed in users see home with Coming Soon items',
      (tester) async {
    await tester.pumpWidget(_app(user: _user));
    await tester.pumpAndSettle();

    expect(find.text('Think. Plan. Build.'), findsOneWidget);
    expect(find.text('Coming Soon'), findsWidgets);
  });

  testWidgets("Pads tab lists the user's pads", (tester) async {
    await tester.pumpWidget(_app(user: _user, pads: [_pad]));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.folder_copy_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('My Pads'), findsOneWidget);
    expect(find.text('FieldForce Pro'), findsOneWidget);
  });

  testWidgets('Pads tab shows the empty state with no pads', (tester) async {
    await tester.pumpWidget(_app(user: _user));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.folder_copy_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('No pads yet.'), findsOneWidget);
    expect(find.text('Create your first Pad →'), findsOneWidget);
  });

  testWidgets('opening a pad shows the workspace sections', (tester) async {
    await tester.pumpWidget(_app(user: _user, pads: [_pad]));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.folder_copy_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('FieldForce Pro'));
    await tester.pumpAndSettle();

    for (final label in [
      'Overview',
      'Notes',
      'Canvas',
      'Code',
      'Tasks',
      'Links',
      'Files',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('Field sales app'), findsOneWidget);

    // Files is the only section still marked Coming Soon. The tab bar
    // scrolls sideways, so bring the tab into view before tapping it.
    final filesTab = find.descendant(
      of: find.byType(PadSectionBar),
      matching: find.text('Files'),
    );
    await tester.ensureVisible(filesTab);
    await tester.pumpAndSettle();
    await tester.tap(filesTab);
    await tester.pumpAndSettle();

    expect(find.text('Coming Soon'), findsWidgets);
  });
}