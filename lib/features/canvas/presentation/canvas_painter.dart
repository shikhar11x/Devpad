import 'dart:math' as math;
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/canvas_text.dart';
import '../domain/entities/canvas_element.dart';
import 'canvas_controller.dart';

/// Draws the grid, all elements, the element being drawn and the selection.
class CanvasPainter extends CustomPainter {
  CanvasPainter(this.controller) : super(repaint: controller.repaint);

  final CanvasController controller;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _paintGrid(canvas, size);

    canvas.save();
    canvas.translate(controller.offset.dx, controller.offset.dy);
    canvas.scale(controller.scale);

    for (final e in controller.elements) {
      _paintElement(canvas, e);
    }
    final draft = controller.draft;
    if (draft != null) _paintElement(canvas, draft);

    final selected = controller.selected;
    if (selected != null && draft == null) _paintSelection(canvas, selected);
    canvas.restore();
  }

  void _paintGrid(Canvas canvas, Size size) {
    final scale = controller.scale;
    var step = 24.0;
    while (step * scale < 14) {
      step *= 2;
    }
    final spacing = step * scale;
    final startX = controller.offset.dx % spacing;
    final startY = controller.offset.dy % spacing;

    final dots = <Offset>[
      for (var x = startX; x < size.width; x += spacing)
        for (var y = startY; y < size.height; y += spacing) Offset(x, y),
    ];
    canvas.drawPoints(
      PointMode.points,
      dots,
      Paint()
        ..color = AppColors.border.withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintElement(Canvas canvas, CanvasElement e) {
    final paint = Paint()
      ..color = Color(e.color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = e.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (e.type) {
      case CanvasElementType.rectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(e.rect, const Radius.circular(4)),
          paint,
        );
      case CanvasElementType.ellipse:
        canvas.drawOval(e.rect, paint);
      case CanvasElementType.line:
        if (e.points.length >= 2) {
          canvas.drawLine(e.points[0], e.points[1], paint);
        }
      case CanvasElementType.arrow:
        if (e.points.length >= 2) _paintArrow(canvas, e, paint);
      case CanvasElementType.pen:
        _paintPen(canvas, e, paint);
      case CanvasElementType.text:
        final painter = TextPainter(
          text: TextSpan(
            text: e.text,
            style: canvasTextStyle(e.fontSize, color: Color(e.color)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, e.rect.topLeft);
        painter.dispose();
    }
  }

  void _paintArrow(Canvas canvas, CanvasElement e, Paint paint) {
    final a = e.points[0];
    final b = e.points[1];
    canvas.drawLine(a, b, paint);
    if ((b - a).distance < 1) return;

    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    final length = 10 + e.strokeWidth * 3;
    const spread = 0.5;
    for (final sign in const [-1.0, 1.0]) {
      final theta = angle + sign * spread;
      canvas.drawLine(
        b,
        b - Offset(math.cos(theta), math.sin(theta)) * length,
        paint,
      );
    }
  }

  void _paintPen(Canvas canvas, CanvasElement e, Paint paint) {
    final pts = e.points;
    if (pts.isEmpty) return;
    if (pts.length < 3) {
      canvas.drawLine(pts.first, pts.last, paint);
      return;
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final mid = (pts[i] + pts[i + 1]) / 2;
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(path, paint);
  }

  void _paintSelection(Canvas canvas, CanvasElement e) {
    final scale = controller.scale;
    final outline = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;

    if (!e.isLinear) {
      canvas.drawRect(e.bounds.inflate(4 / scale), outline);
    }

    final half = 5 / scale;
    final fill = Paint()..color = AppColors.surface;
    for (final h in e.handles) {
      final box = Rect.fromCenter(center: h, width: half * 2, height: half * 2);
      canvas.drawRect(box, fill);
      canvas.drawRect(box, outline);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) =>
      oldDelegate.controller != controller;
}