import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CanvasTool {
  select('Select', Icons.near_me_outlined, LogicalKeyboardKey.keyV, 'V'),
  hand('Pan', Icons.pan_tool_outlined, LogicalKeyboardKey.keyH, 'H'),
  rectangle('Rectangle', Icons.crop_square, LogicalKeyboardKey.keyR, 'R'),
  ellipse('Circle', Icons.circle_outlined, LogicalKeyboardKey.keyO, 'O'),
  arrow('Arrow', Icons.arrow_right_alt, LogicalKeyboardKey.keyA, 'A'),
  line('Line', Icons.horizontal_rule, LogicalKeyboardKey.keyL, 'L'),
  text('Text', Icons.title, LogicalKeyboardKey.keyT, 'T'),
  pen('Pen', Icons.gesture, LogicalKeyboardKey.keyP, 'P'),
  eraser('Eraser', Icons.auto_fix_normal_outlined, LogicalKeyboardKey.keyE, 'E');

  const CanvasTool(this.label, this.icon, this.key, this.keyLabel);

  final String label;
  final IconData icon;
  final LogicalKeyboardKey key;
  final String keyLabel;

  String get tooltip => '$label ($keyLabel)';
}

/// ARGB colors that read well on the dark canvas.
const canvasPalette = <int>[
  0xFFE6EDF3, // white
  0xFF7C83FF, // blue
  0xFFA371F7, // purple
  0xFF3FB950, // green
  0xFFF0883E, // orange
  0xFFF85149, // red
];

const canvasStrokeWidths = <double>[2, 4, 6];