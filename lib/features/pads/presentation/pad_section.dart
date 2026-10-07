import 'package:flutter/material.dart';

/// Sections inside a Pad. [stage] is the roadmap stage that implements it;
/// null means it is already implemented.
enum PadSection {
  overview('overview', 'Overview', Icons.dashboard_outlined, null, ''),
  notes('notes', 'Notes', Icons.sticky_note_2_outlined, null, ''),
  canvas('canvas', 'Canvas', Icons.draw_outlined, null, ''),
    code('code', 'Code', Icons.code, null, ''),
    tasks('tasks', 'Tasks', Icons.checklist_rounded, null, ''),
  links('links', 'Links', Icons.link, null, ''),
    files('files', 'Files', Icons.attach_file, null, '');

  const PadSection(
    this.key,
    this.label,
    this.icon,
    this.stage,
    this.description,
  );

  /// Value used in the URL: `/pads/<id>?section=<key>`
  final String key;
  final String label;
  final IconData icon;
  final int? stage;
  final String description;

  bool get isAvailable => stage == null;

  /// Unknown or missing keys fall back to Overview.
  static PadSection fromKey(String? key) =>
      values.firstWhere((s) => s.key == key, orElse: () => PadSection.overview);
}
