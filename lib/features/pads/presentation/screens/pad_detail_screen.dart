import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../domain/entities/pad.dart';
import '../providers/pad_actions.dart';
import '../providers/pad_providers.dart';
import '../widgets/pad_icons.dart';
import '../widgets/pad_menu.dart';

/// A single Pad. The real workspace (Notes, Canvas, ...) arrives in Stage 3.
class PadDetailScreen extends ConsumerStatefulWidget {
  const PadDetailScreen({super.key, required this.padId});

  final String padId;

  @override
  ConsumerState<PadDetailScreen> createState() => _PadDetailScreenState();
}

class _PadDetailScreenState extends ConsumerState<PadDetailScreen> {
  bool _markedOpened = false;

  void _markOpenedOnce(Pad pad) {
    if (_markedOpened) return;
    _markedOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(padActionsProvider).markOpened(pad.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final padsAsync = ref.watch(padsProvider);
    final pad = ref.watch(padByIdProvider(widget.padId));

    if (pad == null) {
      if (!padsAsync.hasValue) {
        if (padsAsync.hasError) {
          return ErrorState(
            message: padErrorMessage(padsAsync.error!),
            onRetry: () => ref.invalidate(padsProvider),
          );
        }
        return const LoadingState();
      }
      return EmptyState(
        icon: Icons.search_off,
        title: 'Pad not found',
        message: 'It may have been deleted.',
        actionLabel: 'Back to Pads',
        onAction: () => context.go(AppRoutes.pads),
      );
    }

    _markOpenedOnce(pad);

    final size = context.screenSize;
    final theme = Theme.of(context);
    final metaStyle = AppTheme.mono.copyWith(
      fontSize: 12,
      color: AppColors.textMuted,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(size.isMobile ? 16 : 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!size.isDesktop)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton.icon(
                    onPressed: () => context.go(AppRoutes.pads),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('All Pads'),
                  ),
                ),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      padIconFor(pad.icon),
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pad.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (pad.archived)
                          Text(
                            'ARCHIVED',
                            style: AppTheme.mono.copyWith(
                              fontSize: 11,
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PadMenuButton(pad: pad, leaveOnDelete: true),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pad.description.isEmpty
                    ? 'No description yet. Use "Rename / edit" to add one.'
                    : pad.description,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text('Created ${DateFormatter.short(pad.createdAt)}',
                      style: metaStyle),
                  Text('Updated ${DateFormatter.relative(pad.updatedAt)}',
                      style: metaStyle),
                ],
              ),
              const SizedBox(height: 24),
              const DevPadCard(
                child: SizedBox(
                  height: 280,
                  child: ComingSoonPlaceholder(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Pad workspace',
                    description:
                        'Overview, Notes, Canvas, Code, Tasks, Links and Files will live here.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}