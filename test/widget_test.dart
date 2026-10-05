// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devpad/app/app.dart';

void main() {
  testWidgets('shows DevPad home shell with Coming Soon items', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DevPadApp()));
    await tester.pumpAndSettle();

    expect(find.text('Think. Plan. Build.'), findsOneWidget);
    expect(find.text('Coming Soon'), findsWidgets);
  });
}