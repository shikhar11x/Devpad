import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pads/presentation/providers/pad_providers.dart';
import '../../data/datasources/firestore_task_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

// Composition root for the tasks feature.
final taskDataSourceProvider = Provider<FirestoreTaskDataSource>(
  (ref) => FirestoreTaskDataSource(ref.watch(firestoreProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(taskDataSourceProvider)),
);

/// Live tasks of one Pad (served from the local cache when offline).
final tasksProvider =
    StreamProvider.autoDispose.family<List<Task>, String>((ref, padId) {
  return ref.watch(taskRepositoryProvider).watchTasks(padId);
});