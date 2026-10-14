import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/services/url_opener.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/web_url.dart';
import '../../../../core/widgets/cyber_confirm_dialog.dart';
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
    final confirmed = await showCyberConfirmDialog(
      context,
      title: 'Delete "${link.title}"?',
      message: '"${link.title}" will be permanently removed from bookmarks.',
      confirmLabel: 'Delete Link',
      icon: Icons.link_off_rounded,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.link_rounded, size: 13, color: AppColors.cyan),
                        const SizedBox(width: 6),
                        Text(
                          links.isEmpty ? 'RESOURCES // EMPTY' : 'RESOURCES // ${links.length} SAVED',
                          style: AppTheme.mono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  DevPadButton(
                    label: 'Add Link',
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
      padding: EdgeInsets.symmetric(horizontal: edge, vertical: 4),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  '${option?.label ?? 'All'} '
                  '${option == null ? links.length : links.where((l) => l.category == option).length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _category == option ? FontWeight.w600 : FontWeight.w400,
                    color: _category == option ? AppColors.cyan : AppColors.textDim,
                  ),
                ),
                selected: _category == option,
                selectedColor: AppColors.cyan.withValues(alpha: 0.15),
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(
                  color: _category == option
                      ? AppColors.cyan.withValues(alpha: 0.6)
                      : AppColors.border,
                ),
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