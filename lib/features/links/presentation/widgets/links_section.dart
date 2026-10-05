import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/services/url_opener.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/web_url.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../pads/presentation/providers/pad_providers.dart';
import '../../domain/entities/resource_link.dart';
import '../link_filters.dart';
import '../providers/link_actions.dart';
import '../providers/link_providers.dart';
import 'link_form_dialog.dart';
import 'link_tile.dart';

/// The Links tab of a Pad: add button, category filter and the link list.
class LinksSection extends ConsumerStatefulWidget {
  const LinksSection({super.key, required this.padId});

  final String padId;

  @override
  ConsumerState<LinksSection> createState() => _LinksSectionState();
}

class _LinksSectionState extends ConsumerState<LinksSection> {
  LinkCategory? _category;

  Future<void> _open(ResourceLink link) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await openExternalUrl(link.url);
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open ${hostOf(link.url)}.')),
      );
    }
  }

  Future<void> _copy(ResourceLink link) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: link.url));
    messenger.showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  Future<void> _delete(ResourceLink link) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Delete link?'),
        content: Text('"${link.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(linkActionsProvider).delete(widget.padId, link.id);
      messenger.showSnackBar(const SnackBar(content: Text('Link deleted')));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the link.')),
      );
    }
  }

  void _add() => showLinkFormDialog(context, padId: widget.padId);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(linksProvider(widget.padId));
    return async.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: padErrorMessage(e),
        onRetry: () => ref.invalidate(linksProvider(widget.padId)),
      ),
      data: _buildData,
    );
  }

  Widget _buildData(List<ResourceLink> links) {
    final edge = context.screenSize.isMobile ? 16.0 : 24.0;
    final visible = sortLinks(filterLinks(links, category: _category));

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(edge, 16, edge, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      links.isEmpty
                          ? 'RESOURCES'
                          : 'RESOURCES · ${links.length}',
                      style: AppTheme.mono.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  DevPadButton(
                    label: 'Add link',
                    icon: const Icon(Icons.add, size: 18),
                    expand: false,
                    onPressed: _add,
                  ),
                ],
              ),
            ),
            if (links.isNotEmpty) _chipRow(links, edge),
            Expanded(child: _content(links, visible, edge)),
          ],
        ),
      ),
    );
  }

  Widget _chipRow(List<ResourceLink> links, double edge) {
    final options = <LinkCategory?>[null, ...LinkCategory.values];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: edge, vertical: 2),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  '${option?.label ?? 'All'} '
                  '${option == null ? links.length : links.where((l) => l.category == option).length}',
                ),
                selected: _category == option,
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => setState(() => _category = option),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(
    List<ResourceLink> all,
    List<ResourceLink> visible,
    double edge,
  ) {
    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.link,
        title: 'No links yet.',
        message: 'Keep docs, repos and references for this Pad in one place.',
        actionLabel: 'Add your first link →',
        onAction: _add,
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.filter_alt_off_outlined,
        title: 'No matching links',
        message: 'No links in this category.',
        actionLabel: 'Show all',
        onAction: () => setState(() => _category = null),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(edge, 8, edge, 24),
      itemCount: visible.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final link = visible[i];
        return LinkTile(
          link: link,
          onOpen: () => _open(link),
          onCopy: () => _copy(link),
          onEdit: () => showLinkFormDialog(
            context,
            padId: widget.padId,
            link: link,
          ),
          onDelete: () => _delete(link),
        );
      },
    );
  }
}