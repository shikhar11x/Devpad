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
    title: 'Sharing',
    description: 'Invite people to a Pad as Owner, Editor or Viewer.',
    icon: Icons.group_outlined,
    stage: 11,
  ),
  PlannedFeature(
    title: 'GitHub',
    description: 'Connect a repository to a Pad: README, issues, commits.',
    icon: Icons.account_tree_outlined,
    stage: 12,
  ),
  PlannedFeature(
    title: 'AI assistant',
    description: 'Summarize notes, explain code and plan from your Pad.',
    icon: Icons.auto_awesome_outlined,
    stage: 13,
  ),
  PlannedFeature(
    title: 'Public Pads',
    description: 'Publish a Pad as a developer portfolio page.',
    icon: Icons.public,
    stage: 14,
  ),
];