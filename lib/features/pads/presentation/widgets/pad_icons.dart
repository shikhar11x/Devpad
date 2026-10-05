import 'package:flutter/material.dart';

/// Icons a Pad can use. The map key is what gets stored in Firestore.
const padIcons = <String, IconData>{
  'folder': Icons.folder_outlined,
  'rocket': Icons.rocket_launch_outlined,
  'code': Icons.code,
  'terminal': Icons.terminal,
  'bolt': Icons.bolt,
  'lightbulb': Icons.lightbulb_outline,
  'bug': Icons.bug_report_outlined,
  'cloud': Icons.cloud_outlined,
  'phone': Icons.smartphone,
  'database': Icons.storage_outlined,
  'ai': Icons.psychology_outlined,
  'design': Icons.brush_outlined,
};

IconData padIconFor(String key) => padIcons[key] ?? Icons.folder_outlined;