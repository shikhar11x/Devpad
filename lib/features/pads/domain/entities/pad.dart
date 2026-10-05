class Pad {
  const Pad({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description = '',
    this.icon = defaultIcon,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
    this.archived = false,
  });

  static const defaultIcon = 'folder';

  final String id;
  final String ownerId;
  final String title;
  final String description;

  /// Key into the icon set used by the UI (e.g. "rocket").
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  final bool archived;
}