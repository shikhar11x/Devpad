import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        border: Border(
          bottom: BorderSide(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SYNC CONFLICT // This $what was modified remotely while you were editing. Choose resolution strategy:',
                  style: AppTheme.mono.copyWith(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: onKeepMine,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Keep mine'),
              ),
              OutlinedButton(
                onPressed: onUseTheirs,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Use theirs'),
              ),
              FilledButton(
                onPressed: onKeepBoth,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: const Color(0xFF060911),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Keep both'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}