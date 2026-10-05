import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pads/presentation/providers/pad_providers.dart';
import '../../data/datasources/firestore_snippet_datasource.dart';
import '../../data/repositories/snippet_repository_impl.dart';
import '../../domain/entities/snippet.dart';
import '../../domain/repositories/snippet_repository.dart';

// Composition root for the snippets feature.
final snippetDataSourceProvider = Provider<FirestoreSnippetDataSource>(
  (ref) => FirestoreSnippetDataSource(ref.watch(firestoreProvider)),
);

final snippetRepositoryProvider = Provider<SnippetRepository>(
  (ref) => SnippetRepositoryImpl(ref.watch(snippetDataSourceProvider)),
);

/// Live snippets of one Pad (served from the local cache when offline).
final snippetsProvider =
    StreamProvider.autoDispose.family<List<Snippet>, String>((ref, padId) {
  return ref.watch(snippetRepositoryProvider).watchSnippets(padId);
});