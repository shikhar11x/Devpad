import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/devpad_button.dart';
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
        message: 'Choose a Pad from the explorer, or create a new one.',
        actionLabel: 'New Pad',
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
              Expanded(
                child: Text(
                  'My Pads',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
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