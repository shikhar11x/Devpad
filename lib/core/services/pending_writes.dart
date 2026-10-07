import 'package:flutter/foundation.dart';

/// Counts writes that the server has not confirmed yet (for example while
/// offline). Datasources register a write here when it takes too long.
abstract final class PendingWrites {
  static final ValueNotifier<int> count = ValueNotifier<int>(0);

  /// Call with the original write future once we stop waiting for it.
  /// The count goes down when the server confirms or rejects the write.
  static void track(Future<void> write) {
    count.value++;
    void done() {
      if (count.value > 0) count.value--;
    }

    write.then<void>((_) => done(), onError: (Object _) => done());
  }
}