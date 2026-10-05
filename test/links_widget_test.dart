import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:devpad/features/links/domain/entities/resource_link.dart';
import 'package:devpad/features/links/presentation/providers/link_providers.dart';
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

Widget _app(List<ResourceLink> links) => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(_user)),
        padsProvider.overrideWith((ref) => Stream<List<Pad>>.value([_pad])),
        linksProvider('p1')
            .overrideWith((ref) => Stream<List<ResourceLink>>.value(links)),
      ],
      child: const DevPadApp(),
    );

Future<void> _openLinksTab(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.folder_copy_outlined).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('FieldForce Pro'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Links').first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Links tab lists the links of the pad', (tester) async {
    final link = ResourceLink(
      id: 'l1',
      padId: 'p1',
      title: 'Flutter Docs',
      url: 'https://docs.flutter.dev/get-started',
      category: LinkCategory.docs,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(_app([link]));
    await tester.pumpAndSettle();
    await _openLinksTab(tester);

    expect(find.text('Flutter Docs'), findsOneWidget);
    expect(find.text('docs.flutter.dev'), findsOneWidget);
  });

  testWidgets('Links tab shows the empty state with no links', (tester) async {
    await tester.pumpWidget(_app(const []));
    await tester.pumpAndSettle();
    await _openLinksTab(tester);

    expect(find.text('No links yet.'), findsOneWidget);
    expect(find.text('Add your first link →'), findsOneWidget);
  });
}