import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/pad_form_dialog.dart';
import '../widgets/pads_browser.dart';

/// Desktop: the explorer panel already lists Pads, so show a prompt.
/// Tablet/mobile: this screen is the Pad list.
class PadsScreen extends StatelessWidget {
  const PadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;

    if (size.isDesktop) {
      return EmptyState(
        icon: Icons.folder_open_outlined,
        title: 'Select a Pad',
        message: 'Choose a Pad from the explorer, or initialize a new workspace.',
        actionLabel: 'Initialize Pad',
        onAction: () => showPadFormDialog(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'WORKSPACES // REPOSITORIES',
                      style: AppTheme.mono.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'My Pads',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const Spacer(),
              if (!size.isMobile)
                DevPadButton(
                  label: 'New Pad',
                  icon: const Icon(Icons.add, size: 18),
                  expand: false,
                  onPressed: () => showPadFormDialog(context),
                ),
            ],
          ),
        ),
        const Expanded(child: PadsBrowser()),
      ],
    );
  }
}