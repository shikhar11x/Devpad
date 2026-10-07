import 'dart:ui';

/// Shortest distance from [p] to the segment a-b.
double distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
  if (lengthSquared == 0) return (p - a).distance;
  final double t =
      (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lengthSquared)
          .clamp(0.0, 1.0)
          .toDouble();
  final projection = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - projection).distance;
}