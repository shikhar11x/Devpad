import '../domain/entities/resource_link.dart';

/// Keeps links in [category] (null = all).
List<ResourceLink> filterLinks(
  List<ResourceLink> links, {
  LinkCategory? category,
}) =>
    links.where((l) => category == null || l.category == category).toList();

/// Newest first, then by title. Returns a new list.
List<ResourceLink> sortLinks(List<ResourceLink> links) {
  final sorted = [...links];
  sorted.sort((a, b) {
    final byDate = b.createdAt.compareTo(a.createdAt);
    if (byDate != 0) return byDate;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
  return sorted;
}