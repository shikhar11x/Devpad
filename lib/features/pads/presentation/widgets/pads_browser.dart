import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../providers/pad_providers.dart';
import 'pad_form_dialog.dart';
import 'pad_list_tile.dart';
import 'pad_search_field.dart';

/// Search + Active/Archived filter + Pad list, with loading, error and
/// empty states. Used by the desktop explorer and the mobile/tablet screen.
class PadsBrowser extends ConsumerWidget {
  const PadsBrowser({super.key, this.selectedPadId});

  final String? selectedPadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pads = ref.watch(visiblePadsProvider);
    final filter = ref.watch(padFilterProvider);
    final query = ref.watch(padSearchQueryProvider).trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: PadSearchField(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: SegmentedButton<PadFilter>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: PadFilter.active, label: Text('Active')),
              ButtonSegment(value: PadFilter.archived, label: Text('Archived')),
            ],
            selected: {filter},
            onSelectionChanged: (s) =>
                ref.read(padFilterProvider.notifier).set(s.first),
          ),
        ),
        Expanded(
          child: pads.when(
            loading: () => const LoadingState(message: 'Loading...'),
            error: (e, _) => ErrorState(
              message: padErrorMessage(e),
              onRetry: () => ref.invalidate(padsProvider),
            ),
            data: (list) {
              if (list.isEmpty) return _empty(context, filter, query);
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (context, i) {
                  final pad = list[i];
                  return PadListTile(
                    pad: pad,
                    selected: pad.id == selectedPadId,
                    onTap: () => context.go(AppRoutes.padDetail(pad.id)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, PadFilter filter, String query) {
    if (query.isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No matching Pads',
        message: 'Nothing matches "$query".',
      );
    }
    if (filter == PadFilter.archived) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No archived Pads',
        message: 'Pads you archive will show up here.',
      );
    }
    return EmptyState(
      icon: Icons.folder_copy_outlined,
      title: 'No pads yet.',
      message: 'Pads are your personal workspaces for ideas, notes and code.',
      actionLabel: 'Create your first Pad →',
      onAction: () => showPadFormDialog(context),
    );
  }
}