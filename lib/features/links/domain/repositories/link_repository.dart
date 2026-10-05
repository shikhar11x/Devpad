import '../entities/resource_link.dart';

/// Contract the UI depends on. Methods throw `AppFailure` with a
/// user-presentable message.
abstract interface class LinkRepository {
  Stream<List<ResourceLink>> watchLinks(String padId);

  Future<void> createLink(
    String padId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  });

  Future<void> updateLink(
    String padId,
    String linkId, {
    required String title,
    required String url,
    required String description,
    required LinkCategory category,
  });

  Future<void> deleteLink(String padId, String linkId);
}