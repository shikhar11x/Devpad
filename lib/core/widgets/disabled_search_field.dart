import 'package:flutter/material.dart';

/// Visibly disabled search box. Search arrives in Stage 2 (Pads).
class DisabledSearchField extends StatelessWidget {
  const DisabledSearchField({super.key, this.hint = 'Search pads'});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Coming Soon',
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 18),
        ),
      ),
    );
  }
}