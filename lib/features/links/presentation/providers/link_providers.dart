import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pads/presentation/providers/pad_providers.dart';
import '../../data/datasources/firestore_link_datasource.dart';
import '../../data/repositories/link_repository_impl.dart';
import '../../domain/entities/resource_link.dart';
import '../../domain/repositories/link_repository.dart';

// Composition root for the links feature.
final linkDataSourceProvider = Provider<FirestoreLinkDataSource>(
  (ref) => FirestoreLinkDataSource(ref.watch(firestoreProvider)),
);

final linkRepositoryProvider = Provider<LinkRepository>(
  (ref) => LinkRepositoryImpl(ref.watch(linkDataSourceProvider)),
);

/// Live links of one Pad (served from the local cache when offline).
final linksProvider = StreamProvider.autoDispose
    .family<List<ResourceLink>, String>((ref, padId) {
  return ref.watch(linkRepositoryProvider).watchLinks(padId);
});