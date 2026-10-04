import 'package:flutter/material.dart';

class PlannedFeature {
  const PlannedFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.stage,
  });

  final String title;
  final String description;
  final IconData icon;
  final int stage;
}

/// Roadmap items shown as "Coming Soon". None of these are functional yet.
const plannedFeatures = <PlannedFeature>[
  PlannedFeature(
    title: 'Pads',
    description: 'Create, search and organize your personal workspaces.',
    icon: Icons.folder_copy_outlined,
    stage: 2,
  ),
  PlannedFeature(
    title: 'Notes',
    description: 'Markdown notes with autosave, stored per Pad.',
    icon: Icons.sticky_note_2_outlined,
    stage: 4,
  ),
  PlannedFeature(
    title: 'Code',
    description: 'Snippets with syntax highlighting and one-tap copy.',
    icon: Icons.code,
    stage: 5,
  ),
  PlannedFeature(
    title: 'Tasks',
    description: 'TODO, In Progress and Done with priorities and due dates.',
    icon: Icons.checklist_rounded,
    stage: 6,
  ),
  PlannedFeature(
    title: 'Links',
    description: 'Docs, repos and references organized by category.',
    icon: Icons.link,
    stage: 7,
  ),
  PlannedFeature(
    title: 'Files',
    description: 'Upload images, PDFs and attachments to a Pad.',
    icon: Icons.attach_file,
    stage: 8,
  ),
  PlannedFeature(
    title: 'Canvas',
    description: 'Infinite Excalidraw-style canvas for architecture diagrams.',
    icon: Icons.draw_outlined,
    stage: 9,
  ),
];