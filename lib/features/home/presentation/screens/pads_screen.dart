import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/disabled_search_field.dart';

class PadsScreen extends StatelessWidget {
  const PadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenSize.isMobile;
    return Column(
      children: [
        if (isMobile)
          const Padding(
            padding: EdgeInsets.all(16),
            child: DisabledSearchField(),
          ),
        const Expanded(
          child: ComingSoonPlaceholder(
            icon: Icons.folder_copy_outlined,
            title: 'My Pads',
            description:
                'Create and organize your Pads. Arrives in Stage 2, after authentication.',
          ),
        ),
      ],
    );
  }
}