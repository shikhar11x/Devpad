import 'package:flutter/material.dart';

import '../../features/pads/presentation/widgets/pad_form_dialog.dart';
import '../../features/pads/presentation/widgets/pads_browser.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Middle column of the desktop layout: high-tech Pad Explorer panel.
class PadExplorerPanel extends StatelessWidget {
  const PadExplorerPanel({super.key, this.selectedPadId});

  final String? selectedPadId;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EXPLORER // WORKSPACES',
                    style: AppTheme.mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Create New Pad',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add, size: 18),
                  color: AppColors.accent,
                  hoverColor: AppColors.accent.withValues(alpha: 0.12),
                  onPressed: () => showPadFormDialog(context),
                ),
              ],
            ),
          ),
          Expanded(child: PadsBrowser(selectedPadId: selectedPadId)),
        ],
      ),
    );
  }
}