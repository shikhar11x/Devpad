import 'dart:math' as math;
import 'dart:ui';

import '../canvas_geometry.dart';

enum CanvasElementType { rectangle, ellipse, line, arrow, text, pen }

/// One drawing on the canvas. Immutable: edits create a new element.
/// All coordinates are in world space (not screen pixels).
class CanvasElement {
  const CanvasElement({
    required this.id,
    required this.type,
    this.rect = Rect.zero,
    this.points = const <Offset>[],
    this.text = '',
    required this.color,
    this.strokeWidth = 2,
    this.fontSize = 20,
  });

  final String id;
  final CanvasElementType type;

  /// Used by rectangle, ellipse and text.
  final Rect rect;

  /// Used by line/arrow (start, end) and pen (stroke points).
  final List<Offset> points;

  final String text;

  /// ARGB value.
  final int color;
  final double strokeWidth;
  final double fontSize;

  bool get isLinear =>
      type == CanvasElementType.line || type == CanvasElementType.arrow;

  bool get usesRect =>
      type == CanvasElementType.rectangle ||
      type == CanvasElementType.ellipse ||
      type == CanvasElementType.text;

  Rect get bounds {
    if (usesRect) return rect;
    if (points.isEmpty) return Rect.zero;
    var left = points.first.dx;
    var right = left;
    var top = points.first.dy;
    var bottom = top;
    for (final p in points) {
      left = math.min(left, p.dx);
      right = math.max(right, p.dx);
      top = math.min(top, p.dy);
      bottom = math.max(bottom, p.dy);
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// Resize handles: the two endpoints for lines/arrows, otherwise the
  /// four corners (top-left, top-right, bottom-right, bottom-left).
  List<Offset> get handles {
    if (isLinear) return points.length >= 2 ? [points[0], points[1]] : const [];
    final b = bounds;
    return [b.topLeft, b.topRight, b.bottomRight, b.bottomLeft];
  }

  CanvasElement copyWith({
    Rect? rect,
    List<Offset>? points,
    String? text,
    int? color,
    double? strokeWidth,
    double? fontSize,
  }) =>
      CanvasElement(
        id: id,
        type: type,
        rect: rect ?? this.rect,
        points: points ?? this.points,
        text: text ?? this.text,
        color: color ?? this.color,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        fontSize: fontSize ?? this.fontSize,
      );

  CanvasElement translated(Offset delta) {
    if (usesRect) return copyWith(rect: rect.shift(delta));
    return copyWith(points: [for (final p in points) p + delta]);
  }

  /// Stretches the element from its current bounds to [to]. For text this
  /// only moves the box; the controller scales the font itself.
  CanvasElement withBounds(Rect to) {
    if (usesRect) return copyWith(rect: to);
    final from = bounds;
    Offset map(Offset p) {
      final x = from.width < 1e-6
          ? p.dx - from.left + to.left
          : to.left + (p.dx - from.left) / from.width * to.width;
      final y = from.height < 1e-6
          ? p.dy - from.top + to.top
          : to.top + (p.dy - from.top) / from.height * to.height;
      return Offset(x, y);
    }

    return copyWith(points: [for (final p in points) map(p)]);
  }

  /// Moves one endpoint of a line/arrow.
  CanvasElement withPoint(int index, Offset point) {
    if (index < 0 || index >= points.length) return this;
    final next = [...points];
    next[index] = point;
    return copyWith(points: next);
  }

  /// Whether [p] touches this element. [tolerance] is in world units.
  /// Shapes are hit on their outline, so shapes behind them stay reachable.
  bool hitTest(Offset p, double tolerance) {
    final reach = tolerance + strokeWidth / 2;
    switch (type) {
      case CanvasElementType.rectangle:
        if (!rect.inflate(reach).contains(p)) return false;
        final inner = rect.deflate(reach);
        return inner.width <= 0 || inner.height <= 0 || !inner.contains(p);
      case CanvasElementType.ellipse:
        final c = rect.center;
        final a = math.max(rect.width / 2, 0.5);
        final b = math.max(rect.height / 2, 0.5);
        final dx = (p.dx - c.dx) / a;
        final dy = (p.dy - c.dy) / b;
        final d = math.sqrt(dx * dx + dy * dy);
        return (d - 1).abs() * math.min(a, b) <= reach;
      case CanvasElementType.line:
      case CanvasElementType.arrow:
        if (points.length < 2) return false;
        return distanceToSegment(p, points[0], points[1]) <= reach;
      case CanvasElementType.pen:
        if (points.isEmpty) return false;
        if (points.length == 1) return (p - points.first).distance <= reach;
        for (var i = 0; i < points.length - 1; i++) {
          if (distanceToSegment(p, points[i], points[i + 1]) <= reach) {
            return true;
          }
        }
        return false;
      case CanvasElementType.text:
        return rect.inflate(tolerance).contains(p);
    }
  }
}