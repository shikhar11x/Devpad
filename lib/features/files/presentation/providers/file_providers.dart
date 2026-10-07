import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pads/presentation/providers/pad_providers.dart';
import '../../data/datasources/firestore_file_datasource.dart';
import '../../data/datasources/supabase_storage_datasource.dart';
import '../../data/repositories/file_repository_impl.dart';
import '../../domain/entities/pad_file.dart';
import '../../domain/repositories/file_repository.dart';

// Composition root for the files feature.
final fileRepositoryProvider = Provider<FileRepository>(
  (ref) => FileRepositoryImpl(
    FirestoreFileDataSource(ref.watch(firestoreProvider)),
    SupabaseStorageDataSource(),
  ),
);

final filesProvider =
    StreamProvider.autoDispose.family<List<PadFile>, String>((ref, padId) {
  return ref.watch(fileRepositoryProvider).watchFiles(padId);
});