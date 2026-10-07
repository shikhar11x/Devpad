import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../canvas_controller.dart';
import '../canvas_painter.dart';
import '../canvas_tools.dart';

/// The drawing surface. Turns raw pointer events into controller calls:
/// one pointer draws with the current tool, two pointers pinch-zoom and
/// pan, the mouse wheel pans, Ctrl+wheel zooms, and a middle-button drag,
/// Space+drag or the Pan tool also pan.
class CanvasView extends StatefulWidget {
  const CanvasView({super.key, required this.controller, this.onActivated});

  final CanvasController controller;

  /// Called on every touch, so the editor can take keyboard focus.
  final VoidCallback? onActivated;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  final Map<int, Offset> _pointers = {};
  bool _panning = false;
  bool _locked = false; // a pinch happened; ignore single-finger input
  double _pinchDistance = 0;
  Offset _pinchFocal = Offset.zero;
  Size _size = Size.zero;
  bool _fitted = false;

  CanvasController get _c => widget.controller;

  void _down(PointerDownEvent e) {
    widget.onActivated?.call();
    if (e.kind == PointerDeviceKind.mouse) {
      if (e.buttons == kSecondaryMouseButton) return;
      // A mouse is a single pointer; drop anything stale.
      _pointers.clear();
      _panning = false;
      _locked = false;
    }
    _pointers[e.pointer] = e.localPosition;

    if (_pointers.length >= 2) {
      _c.cancelGesture();
      _panning = false;
      _locked = true;
      _startPinch();
      return;
    }
    if (_locked) return;

    final space =
        HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.space);
    if (e.buttons == kMiddleMouseButton || _c.tool == CanvasTool.hand || space) {
      _panning = true;
      return;
    }
    _c.pointerDown(e.localPosition);
  }

  void _move(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.localPosition;

    if (_pointers.length >= 2) {
      _updatePinch();
      return;
    }
    if (_locked) return;
    if (_panning) {
      _c.panBy(e.delta);
      return;
    }
    _c.pointerMove(e.localPosition);
  }

  void _up(PointerEvent e, {bool cancelled = false}) {
    if (_pointers.remove(e.pointer) == null) return;
    if (_pointers.isEmpty) {
      if (!_locked && !_panning) {
        cancelled ? _c.cancelGesture() : _c.pointerUp();
      }
      _panning = false;
      _locked = false;
    }
  }

  void _startPinch() {
    final pts = _pointers.values.take(2).toList();
    _pinchDistance = (pts[0] - pts[1]).distance;
    _pinchFocal = (pts[0] + pts[1]) / 2;
  }

  void _updatePinch() {
    final pts = _pointers.values.take(2).toList();
    final distance = (pts[0] - pts[1]).distance;
    final focal = (pts[0] + pts[1]) / 2;
    if (_pinchDistance > 0 && distance > 0) {
      _c.panBy(focal - _pinchFocal);
      _c.zoomAround(focal, distance / _pinchDistance);
    }
    _pinchDistance = distance;
    _pinchFocal = focal;
  }

  void _signal(PointerSignalEvent e) {
    if (e is! PointerScrollEvent) return;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed || keyboard.isMetaPressed) {
      _c.zoomAround(e.localPosition, math.exp(-e.scrollDelta.dy / 300));
    } else {
      _c.panBy(-e.scrollDelta);
    }
  }

  MouseCursor _cursor(CanvasTool tool) => switch (tool) {
        CanvasTool.select => SystemMouseCursors.basic,
        CanvasTool.hand => SystemMouseCursors.grab,
        CanvasTool.text => SystemMouseCursors.text,
        _ => SystemMouseCursors.precise,
      };

  void _zoomBy(double factor) =>
      _c.zoomAround(Offset(_size.width / 2, _size.height / 2), factor);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        if (!_fitted) {
          _fitted = true;
          final size = _size;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _c.fitToContent(size);
          });
        }

        return ListenableBuilder(
          listenable: _c,
          builder: (context, _) {
            return ClipRect(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MouseRegion(
                      cursor: _cursor(_c.tool),
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: _down,
                        onPointerMove: _move,
                        onPointerUp: _up,
                        onPointerCancel: (e) => _up(e, cancelled: true),
                        onPointerSignal: _signal,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: CanvasPainter(_c),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_c.elements.isEmpty && _c.draft == null)
                    IgnorePointer(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Pick a tool and start drawing.\n'
                            'Scroll to pan, Ctrl+scroll to zoom.',
                            textAlign: TextAlign.center,
                            style: AppTheme.mono.copyWith(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _zoomControls(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _zoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom out',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () => _zoomBy(1 / 1.25),
          ),
          Tooltip(
            message: 'Reset zoom',
            child: InkWell(
              onTap: _c.resetView,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  '${(_c.scale * 100).round()}%',
                  style: AppTheme.mono.copyWith(fontSize: 12),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Zoom in',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => _zoomBy(1.25),
          ),
          IconButton(
            tooltip: 'Fit to content',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.fit_screen_outlined, size: 18),
            onPressed: () => _c.fitToContent(_size),
          ),
        ],
      ),
    );
  }
}