import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../../domain/entities/pad.dart';

/// Overview section: real Pad details only.
class PadOverview extends StatelessWidget {
  const PadOverview({super.key, required this.pad});

  final Pad pad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final edge = context.screenSize.isMobile ? 16.0 : 32.0;
    final opened = pad.lastOpenedAt;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(edge, 20, edge, edge),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('DESCRIPTION'),
              const SizedBox(height: 8),
              Text(
                pad.description.isEmpty
                    ? 'No description yet. Use "Rename / edit" to add one.'
                    : pad.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: pad.description.isEmpty
                      ? AppColors.textMuted
                      : AppColors.text,
                ),
              ),
              const SizedBox(height: 24),
              const _Label('DETAILS'),
              const SizedBox(height: 8),
              DevPadCard(
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Status',
                      value: pad.archived ? 'Archived' : 'Active',
                      valueColor:
                          pad.archived ? AppColors.warning : AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Created',
                      value: DateFormatter.short(pad.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Updated',
                      value: DateFormatter.relative(pad.updatedAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Last opened',
                      value: opened == null
                          ? 'Never'
                          : DateFormatter.relative(opened),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.mono.copyWith(
        fontSize: 11,
        letterSpacing: 1.2,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTheme.mono.copyWith(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor ?? AppColors.text),
          ),
        ),
      ],
    );
  }
}