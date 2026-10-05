import 'package:flutter/material.dart';

import '../../features/pads/presentation/widgets/pad_form_dialog.dart';
import '../../features/pads/presentation/widgets/pads_browser.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Middle column of the desktop layout: the user's Pads.
class PadExplorerPanel extends StatelessWidget {
  const PadExplorerPanel({super.key, this.selectedPadId});

  final String? selectedPadId;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'PADS',
                    style: AppTheme.mono.copyWith(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'New Pad',
                  icon: const Icon(Icons.add, size: 20),
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