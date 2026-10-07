import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:devpad/features/canvas/domain/entities/canvas_element.dart';
import 'package:devpad/features/canvas/presentation/providers/canvas_providers.dart';
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

Widget _app() => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(_user)),
        padsProvider.overrideWith((ref) => Stream<List<Pad>>.value([_pad])),
        canvasElementsProvider('p1')
            .overrideWith((ref) async => const <CanvasElement>[]),
      ],
      child: const DevPadApp(),
    );

void main() {
  testWidgets('Canvas tab shows the toolbar and the empty hint',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.folder_copy_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('FieldForce Pro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Canvas').first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Rectangle (R)'), findsOneWidget);
    expect(find.byTooltip('Undo (Ctrl+Z)'), findsOneWidget);
    expect(find.textContaining('start drawing'), findsOneWidget);
  });
}