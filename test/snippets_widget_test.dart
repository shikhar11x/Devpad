import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:devpad/features/pads/domain/entities/pad.dart';
import 'package:devpad/features/pads/presentation/providers/pad_providers.dart';
import 'package:devpad/features/snippets/domain/entities/snippet.dart';
import 'package:devpad/features/snippets/presentation/providers/snippet_providers.dart';
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

Widget _app(List<Snippet> snippets) => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(_user)),
        padsProvider.overrideWith((ref) => Stream<List<Pad>>.value([_pad])),
        snippetsProvider('p1')
            .overrideWith((ref) => Stream<List<Snippet>>.value(snippets)),
      ],
      child: const DevPadApp(),
    );

Future<void> _openCodeTab(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.folder_copy_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.text('FieldForce Pro'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Code').first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Code tab lists the snippets of the pad', (tester) async {
    final snippet = Snippet(
      id: 's1',
      padId: 'p1',
      title: 'Auth service',
      language: 'dart',
      code: 'class AuthService {}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(_app([snippet]));
    await tester.pumpAndSettle();
    await _openCodeTab(tester);

    expect(find.text('Auth service'), findsOneWidget);
    expect(find.text('Select a snippet'), findsOneWidget);
  });

  testWidgets('Code tab shows the empty state with no snippets',
      (tester) async {
    await tester.pumpWidget(_app(const []));
    await tester.pumpAndSettle();
    await _openCodeTab(tester);

    expect(find.text('No snippets yet.'), findsOneWidget);
    expect(find.text('Create your first snippet →'), findsOneWidget);
  });
}