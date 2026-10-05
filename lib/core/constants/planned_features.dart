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