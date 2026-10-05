import 'package:devpad/app/app.dart';
import 'package:devpad/features/auth/domain/entities/auth_user.dart';
import 'package:devpad/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(AuthUser? user) => ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream<AuthUser?>.value(user)),
      ],
      child: const DevPadApp(),
    );

void main() {
  testWidgets('signed out users see the login screen', (tester) async {
    await tester.pumpWidget(_app(null));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('signed in users see home with Coming Soon items', (tester) async {
    await tester.pumpWidget(
      _app(const AuthUser(uid: 'u1', email: 'dev@example.com')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Think. Plan. Build.'), findsOneWidget);
    expect(find.text('Coming Soon'), findsWidgets);
  });
}