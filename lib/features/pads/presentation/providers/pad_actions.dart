import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/repositories/pad_repository.dart';
import 'pad_providers.dart';

/// Write operations for Pads. All methods throw `AppFailure` on error.
class PadActions {
  PadActions(this._ref);

  final Ref _ref;

  PadRepository get _repo => _ref.read(padRepositoryProvider);

  Future<void> create({
    required String title,
    required String description,
    required String icon,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) throw const AppFailure('Please sign in again.');
    await _repo.createPad(
      ownerId: user.uid,
      title: title,
      description: description,
      icon: icon,
    );
  }

  Future<void> update(
    String padId, {
    required String title,
    required String description,
    required String icon,
  }) =>
      _repo.updatePad(
        padId: padId,
        title: title,
        description: description,
        icon: icon,
      );

  Future<void> setArchived(String padId, bool archived) =>
      _repo.setArchived(padId, archived);

  Future<void> delete(String padId) => _repo.deletePad(padId);

  /// Best effort: failures are ignored so opening a Pad never errors.
  Future<void> markOpened(String padId) async {
    try {
      await _repo.markOpened(padId);
    } catch (_) {}
  }
}

final padActionsProvider = Provider<PadActions>((ref) => PadActions(ref));