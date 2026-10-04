import 'package:flutter/material.dart';

class AppDestination {
  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Order must match the branch order in the router.
const appDestinations = <AppDestination>[
  AppDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppDestination(
    label: 'Pads',
    icon: Icons.folder_copy_outlined,
    selectedIcon: Icons.folder_copy,
  ),
  AppDestination(
    label: 'More',
    icon: Icons.more_horiz,
    selectedIcon: Icons.more_horiz,
  ),
];