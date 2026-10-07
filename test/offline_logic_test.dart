import 'dart:async';

import 'package:devpad/core/services/pending_writes.dart';
import 'package:devpad/core/utils/edit_fingerprints.dart';
import 'package:devpad/core/widgets/conflict_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => PendingWrites.count.value = 0);

  test('a tracked write counts until it completes', () async {
    final write = Completer<void>();
    PendingWrites.track(write.future);
    expect(PendingWrites.count.value, 1);

    write.complete();
    await Future<void>.delayed(Duration.zero);
    expect(PendingWrites.count.value, 0);
  });

  test('a rejected write is no longer pending', () async {
    final write = Completer<void>();
    PendingWrites.track(write.future);

    write.completeError(Exception('rejected'));
    await Future<void>.delayed(Duration.zero);
    expect(PendingWrites.count.value, 0);
  });

  test('fingerprints remember versions and forget the oldest', () {
    final known = EditFingerprints(capacity: 2);
    known.remember(EditFingerprints.of(['a', '1']));
    known.remember(EditFingerprints.of(['b', '2']));
    expect(known.contains(EditFingerprints.of(['a', '1'])), isTrue);

    known.remember(EditFingerprints.of(['c', '3']));
    expect(known.contains(EditFingerprints.of(['a', '1'])), isFalse);
    expect(known.contains(EditFingerprints.of(['c', '3'])), isTrue);
  });

  testWidgets('conflict banner reports the chosen option', (tester) async {
    var chosen = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConflictBanner(
            what: 'note',
            onKeepMine: () => chosen = 'mine',
            onUseTheirs: () => chosen = 'theirs',
            onKeepBoth: () => chosen = 'both',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Use theirs'));
    expect(chosen, 'theirs');
    await tester.tap(find.text('Keep both'));
    expect(chosen, 'both');
  });
}