import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/devpad_card.dart';
import '../../domain/entities/pad.dart';

/// Cyber Overview section: pad telemetry and metadata.
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
              const _Label('DESCRIPTION // WORKSPACE BRIEF'),
              const SizedBox(height: 8),
              DevPadCard(
                padding: const EdgeInsets.all(18),
                child: Text(
                  pad.description.isEmpty
                      ? '// No description configured. Click "Rename / edit" in top right menu to set mission parameters.'
                      : pad.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: pad.description.isEmpty
                        ? AppColors.textDim
                        : AppColors.text,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _Label('TELEMETRY & DETAILS'),
              const SizedBox(height: 8),
              DevPadCard(
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Status',
                      value: pad.archived ? 'ARCHIVED' : 'ACTIVE & RUNNING',
                      valueColor:
                          pad.archived ? AppColors.warning : AppColors.neonGreen,
                      isTag: true,
                    ),
                    const Divider(color: AppColors.border, height: 24),
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
        fontWeight: FontWeight.w600,
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
    this.isTag = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTag;

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? AppColors.text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label.toUpperCase(),
            style: AppTheme.mono.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDim,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: isTag
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: color.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        value,
                        style: AppTheme.mono.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: AppTheme.mono.copyWith(
                    color: color,
                    fontSize: 13,
                  ),
                ),
        ),
      ],
    );
  }
}