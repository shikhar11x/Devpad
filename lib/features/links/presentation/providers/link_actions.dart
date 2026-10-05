import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/resource_link.dart';
import '../../domain/repositories/link_repository.dart';
import 'link_providers.dart';

/// Write operations for links. All methods throw `AppFailure` on error.
class LinkActions {
  LinkActions(this._ref);

  final Ref _ref;

  LinkRepository get _repo => _ref.read(linkRepositoryProvider);

  Future<void> create(
    String padId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) =>
      _repo.createLink(
        padId,
        title: title,
        url: url,
        description: description,
        category: category,
      );

  Future<void> update(
    String padId,
    String linkId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  }) =>
      _repo.updateLink(
        padId,
        linkId,
        title: title,
        url: url,
        description: description,
        category: category,
      );

  Future<void> delete(String padId, String linkId) =>
      _repo.deleteLink(padId, linkId);
}

final linkActionsProvider = Provider<LinkActions>((ref) => LinkActions(ref));