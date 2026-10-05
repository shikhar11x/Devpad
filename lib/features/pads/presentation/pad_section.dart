import 'package:flutter/material.dart';

/// Sections inside a Pad. [stage] is the roadmap stage that implements it;
/// null means it is already implemented.
enum PadSection {
  overview('overview', 'Overview', Icons.dashboard_outlined, null, ''),
  notes('notes', 'Notes', Icons.sticky_note_2_outlined, null, ''),
  canvas(
    'canvas',
    'Canvas',
    Icons.draw_outlined,
    9,
    'An infinite canvas for architecture diagrams and brainstorming.',
  ),
  code(
    'code',
    'Code',
    Icons.code,
    5,
    'Code snippets with syntax highlighting and one-tap copy.',
  ),
  tasks(
    'tasks',
    'Tasks',
    Icons.checklist_rounded,
    6,
    'TODO, In Progress and Done with priorities and due dates.',
  ),
  links(
    'links',
    'Links',
    Icons.link,
    7,
    'Docs, repos and references organized by category.',
  ),
  files(
    'files',
    'Files',
    Icons.attach_file,
    8,
    'Upload images, PDFs and attachments to this Pad.',
  );

  const PadSection(
    this.key,
    this.label,
    this.icon,
    this.stage,
    this.description,
  );

  /// Value used in the URL: /pads/<id>?section=<key>
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
