import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/file_format.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../../domain/entities/pad_file.dart';

enum _FileMenu { open, copy, delete }

class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.file,
    required this.url,
    required this.onOpen,
    required this.onCopy,
    required this.onDelete,
  });

  final PadFile file;
  final String url;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  Widget _fallbackIcon() => Icon(
        file.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
        color: AppColors.accent,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DevPadCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      onTap: onOpen,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: file.isImage
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    cacheWidth: 88,
                    errorBuilder: (_, _, _) => _fallbackIcon(),
                  )
                : _fallbackIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatBytes(file.size)} · ${expiryLabel(file.expiresAt)}',
                  style: AppTheme.mono.copyWith(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_FileMenu>(
            tooltip: 'File options',
            color: AppColors.surfaceHigh,
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (action) => switch (action) {
              _FileMenu.open => onOpen(),
              _FileMenu.copy => onCopy(),
              _FileMenu.delete => onDelete(),
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _FileMenu.open,
                child: Row(children: [
                  Icon(Icons.open_in_new, size: 18),
                  SizedBox(width: 8),
                  Text('Open'),
                ]),
              ),
              PopupMenuItem(
                value: _FileMenu.copy,
                child: Row(children: [
                  Icon(Icons.copy_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Copy link'),
                ]),
              ),
              PopupMenuItem(
                value: _FileMenu.delete,
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