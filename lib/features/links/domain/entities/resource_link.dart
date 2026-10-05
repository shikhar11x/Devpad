enum LinkCategory {
  docs('docs', 'Docs'),
  repo('repo', 'Repository'),
  design('design', 'Design'),
  video('video', 'Video'),
  api('api', 'API'),
  tool('tool', 'Tool'),
  other('other', 'Other');

  const LinkCategory(this.key, this.label);

  /// Value stored in Firestore.
  final String key;
  final String label;

  static LinkCategory fromKey(String? key) =>
      values.firstWhere((c) => c.key == key, orElse: () => other);
}

class ResourceLink {
  const ResourceLink({
    required this.id,
    required this.padId,
    required this.title,
    required this.url,
    this.description = '',
    this.category = LinkCategory.other,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String padId;
  final String title;
  final String url;
  final String description;
  final LinkCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
}