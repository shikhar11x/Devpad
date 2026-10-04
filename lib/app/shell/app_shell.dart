import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/brand_mark.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_destination.dart';
import 'pad_explorer_panel.dart';

/// Adaptive scaffold:
/// desktop = rail + explorer + workspace, tablet = compact rail, mobile = bottom bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenSize.fromWidth(constraints.maxWidth);

        if (size.isMobile) {
          return Scaffold(
            appBar: AppBar(
              title: const BrandTitle(),
              actions: const [
                IconButton(
                  tooltip: 'Coming Soon',
                  onPressed: null,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            body: navigationShell,
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
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onSelect,
                labelType: size.isDesktop
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.none,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: BrandMark(),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        AppConstants.version,
                        style: AppTheme.mono.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
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
              const VerticalDivider(width: 1),
              if (size.isDesktop) ...[
                const SizedBox(width: 280, child: PadExplorerPanel()),
                const VerticalDivider(width: 1),
              ],
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}