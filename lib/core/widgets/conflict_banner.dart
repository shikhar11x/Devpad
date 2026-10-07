import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Shown in an editor when the item was changed elsewhere while the user
/// has unsaved edits. Autosave pauses until the user picks an option.
class ConflictBanner extends StatelessWidget {
  const ConflictBanner({
    super.key,
    required this.what,
    required this.onKeepMine,
    required this.onUseTheirs,
    required this.onKeepBoth,
  });

  /// "note" or "snippet".
  final String what;
  final VoidCallback onKeepMine;
  final VoidCallback onUseTheirs;
  final VoidCallback onKeepBoth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This $what was changed somewhere else while you were '
                  'editing. Saving is paused until you choose.',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: onKeepMine,
                child: const Text('Keep mine'),
              ),
              OutlinedButton(
                onPressed: onUseTheirs,
                child: const Text('Use theirs'),
              ),
              FilledButton(
                onPressed: onKeepBoth,
                child: const Text('Keep both'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}