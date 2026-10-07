import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/canvas_element.dart';
import '../canvas_controller.dart';
import '../canvas_tools.dart';

/// Tools, colors, stroke widths and undo/redo with cyber hacker styling.
class CanvasToolbar extends StatelessWidget {
  const CanvasToolbar({
    super.key,
    required this.controller,
    required this.onEditText,
  });

  final CanvasController controller;
  final VoidCallback onEditText;

  static const _divider = SizedBox(
    height: 24,
    child: VerticalDivider(width: 17, color: AppColors.border),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final c = controller;
          final selected = c.selected;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                for (final tool in CanvasTool.values)
                  _ToolButton(
                    tool: tool,
                    active: c.tool == tool,
                    onTap: () => c.setTool(tool),
                  ),
                _divider,
                for (final color in canvasPalette)
                  _ColorDot(
                    value: color,
                    active: c.color == color,
                    onTap: () => c.setColor(color),
                  ),
                _divider,
                for (final width in canvasStrokeWidths)
                  _WidthButton(
                    width: width,
                    active: c.strokeWidth == width,
                    onTap: () => c.setStrokeWidth(width),
                  ),
                _divider,
                IconButton(
                  tooltip: 'Undo (Ctrl+Z)',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.undo, size: 19),
                  color: c.canUndo ? AppColors.text : AppColors.textDim,
                  onPressed: c.canUndo ? c.undo : null,
                ),
                IconButton(
                  tooltip: 'Redo (Ctrl+Y)',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.redo, size: 19),
                  color: c.canRedo ? AppColors.text : AppColors.textDim,
                  onPressed: c.canRedo ? c.redo : null,
                ),
                if (selected != null &&
                    selected.type == CanvasElementType.text)
                  IconButton(
                    tooltip: 'Edit text',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.text_fields, size: 19),
                    color: AppColors.accent,
                    onPressed: onEditText,
                  ),
                IconButton(
                  tooltip: 'Delete selected (Del)',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, size: 19),
                  color: selected == null ? AppColors.textDim : AppColors.error,
                  onPressed: selected == null ? null : c.deleteSelected,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tool,
    required this.active,
    required this.onTap,
  });

  final CanvasTool tool;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active
              ? AppColors.accent.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1.0,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: IconButton(
        tooltip: tool.tooltip,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          tool.icon,
          size: 19,
          color: active ? AppColors.accent : AppColors.textMuted,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.value,
    required this.active,
    required this.onTap,
  });

  final int value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Color(value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkResponse(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: active ? 24 : 20,
          height: active ? 24 : 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
            border: Border.all(
              color: active ? Colors.white : AppColors.border,
              width: active ? 2.2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: c.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _WidthButton extends StatelessWidget {
  const _WidthButton({
    required this.width,
    required this.active,
    required this.onTap,
  });

  final double width;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Stroke ${width.round()}px',
      child: InkResponse(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Container(
            width: 16,
            height: width,
            decoration: BoxDecoration(
              color: active ? AppColors.accent : AppColors.textMuted,
              borderRadius: BorderRadius.circular(width),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}