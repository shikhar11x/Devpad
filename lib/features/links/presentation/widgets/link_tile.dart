import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/web_url.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../../domain/entities/resource_link.dart';
import '../link_category_ui.dart';

enum _LinkMenu { open, copy, edit, delete }

class LinkTile extends StatelessWidget {
  const LinkTile({
    super.key,
    required this.link,
    required this.onOpen,
    required this.onCopy,
    required this.onEdit,
    required this.onDelete,
  });

  final ResourceLink link;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DevPadCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: link.category.label,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                categoryIcon(link.category),
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_outward,
                      size: 12,
                      color: AppColors.accent.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hostOf(link.url),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                if (link.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    link.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<_LinkMenu>(
            tooltip: 'Link options',
            color: AppColors.surfaceHigh,
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (action) => switch (action) {
              _LinkMenu.open => onOpen(),
              _LinkMenu.copy => onCopy(),
              _LinkMenu.edit => onEdit(),
              _LinkMenu.delete => onDelete(),
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _LinkMenu.open,
                child: Row(children: [
                  Icon(Icons.open_in_new, size: 18),
                  SizedBox(width: 8),
                  Text('Open'),
                ]),
              ),
              PopupMenuItem(
                value: _LinkMenu.copy,
                child: Row(children: [
                  Icon(Icons.copy_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Copy URL'),
                ]),
              ),
              PopupMenuItem(
                value: _LinkMenu.edit,
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ]),
              ),
              PopupMenuItem(
                value: _LinkMenu.delete,
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}