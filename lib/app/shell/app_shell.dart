import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/cyber_background.dart';
import '../../features/auth/presentation/widgets/account_menu.dart';
import '../../features/pads/presentation/widgets/pad_form_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_destination.dart';
import 'pad_explorer_panel.dart';
import 'sync_status_banner.dart';

/// Cyber Hacker Adaptive Scaffold:
/// desktop = cyber rail + explorer + workspace, tablet = compact rail, mobile = bottom bar.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    this.selectedPadId,
  });

  final StatefulNavigationShell navigationShell;
  final String? selectedPadId;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget get _content => Column(
        children: [
          const SyncStatusBanner(),
          Expanded(child: navigationShell),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenSize.fromWidth(constraints.maxWidth);

        if (size.isMobile) {
          return Scaffold(
            appBar: AppBar(
              title: const BrandTitle(),
              actions: [
                IconButton(
                  tooltip: 'New Pad',
                  onPressed: () => showPadFormDialog(context),
                  icon: const Icon(Icons.add, color: AppColors.accent),
                ),
                const AccountMenu(),
                const SizedBox(width: 4),
              ],
            ),
            body: CyberBackground(
              showGrid: false,
              child: _content,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              destinations: [
                for (final d in appDestinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: CyberBackground(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onSelect,
                  labelType: size.isDesktop
                      ? NavigationRailLabelType.all
                      : NavigationRailLabelType.none,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BrandMark(),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.neonGreen.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.neonGreen,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neonGreen,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              if (size.isDesktop) ...[
                                const SizedBox(width: 4),
                                Text(
                                  'SYS_ON',
                                  style: AppTheme.mono.copyWith(
                                    fontSize: 8,
                                    color: AppColors.neonGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AccountMenu(),
                            const SizedBox(height: 10),
                            Text(
                              AppConstants.version,
                              style: AppTheme.mono.copyWith(
                                fontSize: 9,
                                color: AppColors.textDim,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  destinations: [
                    for (final d in appDestinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                if (size.isDesktop) ...[
                  SizedBox(
                    width: 300,
                    child: PadExplorerPanel(selectedPadId: selectedPadId),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),
                ],
                Expanded(child: _content),
              ],
            ),
          ),
        );
      },
    );
  }
}