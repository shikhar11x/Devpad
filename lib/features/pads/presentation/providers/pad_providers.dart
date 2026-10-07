import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/firestore_pad_datasource.dart';
import '../../data/repositories/pad_repository_impl.dart';
import '../../domain/entities/pad.dart';
import '../../domain/repositories/pad_repository.dart';

// Composition root for the pads feature.
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final padDataSourceProvider = Provider<FirestorePadDataSource>(
  (ref) => FirestorePadDataSource(ref.watch(firestoreProvider)),
);

final padRepositoryProvider = Provider<PadRepository>(
  (ref) => PadRepositoryImpl(ref.watch(padDataSourceProvider)),
);

/// All of the signed-in user's Pads (active + archived), live.
/// Re-subscribes automatically when the user changes.
final padsProvider = StreamProvider<List<Pad>>((ref) {
  final uid = ref.watch(currentUserProvider.select((u) => u?.uid));
  if (uid == null) return Stream.value(const <Pad>[]);
  return ref.watch(padRepositoryProvider).watchPads(uid);
});

String padErrorMessage(Object error) =>
    error is AppFailure ? error.message : 'Something went wrong.';

// ---- UI state: search + filter ----

class PadSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final padSearchQueryProvider = NotifierProvider<PadSearchQuery, String>(
  PadSearchQuery.new,
);

enum PadFilter { active, archived }

class PadFilterNotifier extends Notifier<PadFilter> {
  @override
  PadFilter build() => PadFilter.active;

  void set(PadFilter value) => state = value;
}

final padFilterProvider = NotifierProvider<PadFilterNotifier, PadFilter>(
  PadFilterNotifier.new,
);

// ---- Derived data ----

/// Pads after applying the filter and search, newest activity first.
final visiblePadsProvider = Provider<AsyncValue<List<Pad>>>((ref) {
  final query = ref.watch(padSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(padFilterProvider);

  return ref.watch(padsProvider).whenData((pads) {
    return pads
        .where((p) => filter == PadFilter.archived ? p.archived : !p.archived)
        .where(
          (p) =>
              query.isEmpty ||
              p.title.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  });
});

/// Up to 5 active Pads, most recently opened first.
final recentPadsProvider = Provider<List<Pad>>((ref) {
  final pads = ref.watch(padsProvider).value ?? const <Pad>[];
  final recent =
      pads.where((p) => !p.archived && p.lastOpenedAt != null).toList()
        ..sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
  return recent.take(5).toList();
});

final padByIdProvider = Provider.family<Pad?, String>((ref, id) {
  final pads = ref.watch(padsProvider).value;
  if (pads == null) return null;
  for (final pad in pads) {
    if (pad.id == id) return pad;
  }
  return null;
});

/// true = connected to the server. false = offline for more than 4 seconds
/// (short blips and the first load do not count as offline).
final connectionProvider = StreamProvider<bool>((ref) {
  final uid = ref.watch(currentUserProvider.select((u) => u?.uid));
  if (uid == null) return Stream<bool>.value(true);

  final PadRepository repo;
  try {
    repo = ref.watch(padRepositoryProvider);
  } catch (_) {
    // Backend not available (for example in tests): assume online.
    return Stream<bool>.value(true);
  }

  final controller = StreamController<bool>();
  Timer? timer;
  final sub = repo.watchIsFromCache(uid).listen((fromCache) {
    timer?.cancel();
    if (fromCache) {
      timer = Timer(const Duration(seconds: 4), () => controller.add(false));
    } else {
      controller.add(true);
    }
  }, onError: (Object _) {});

  ref.onDispose(() {
    timer?.cancel();
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
