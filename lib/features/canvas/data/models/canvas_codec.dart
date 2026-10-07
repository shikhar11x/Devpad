import 'dart:convert';
import 'dart:ui';

import '../../domain/canvas_text.dart';
import '../../domain/entities/canvas_element.dart';

/// Converts elements to and from the JSON string stored in Firestore.
abstract final class CanvasCodec {
  /// Firestore documents are limited to 1 MiB; stay well below it.
  static const maxBytes = 800000;

  static double _r(double v) => (v * 10).roundToDouble() / 10;

  static String encode(List<CanvasElement> elements) =>
      jsonEncode([for (final e in elements) _toMap(e)]);

  static Map<String, Object> _toMap(CanvasElement e) {
    final map = <String, Object>{
      'id': e.id,
      't': e.type.name,
      'c': e.color,
      'sw': e.strokeWidth,
    };
    switch (e.type) {
      case CanvasElementType.rectangle:
      case CanvasElementType.ellipse:
        map['r'] = [
          _r(e.rect.left),
          _r(e.rect.top),
          _r(e.rect.width),
          _r(e.rect.height),
        ];
      case CanvasElementType.text:
        map['r'] = [_r(e.rect.left), _r(e.rect.top)];
        map['s'] = e.text;
        map['fs'] = e.fontSize;
      case CanvasElementType.line:
      case CanvasElementType.arrow:
      case CanvasElementType.pen:
        map['p'] = [
          for (final p in e.points) ...[_r(p.dx), _r(p.dy)],
        ];
    }
    return map;
  }

  /// Throws [FormatException] when the data is not a canvas at all.
  /// Individual unreadable elements are skipped.
  static List<CanvasElement> decode(String source) {
    final raw = jsonDecode(source);
    if (raw is! List) throw const FormatException('Canvas data is not a list');
    final result = <CanvasElement>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final element = _fromMap(item);
      if (element != null) result.add(element);
    }
    return result;
  }

  static List<double> _numbers(Object? value) => value is List
      ? [
          for (final n in value)
            if (n is num) n.toDouble(),
        ]
      : const <double>[];

  static CanvasElement? _fromMap(Map<dynamic, dynamic> m) {
    try {
      final id = m['id'];
      final t = m['t'];
      if (id is! String || t is! String) return null;
      final type = CanvasElementType.values
          .where((v) => v.name == t)
          .firstOrNull;
      if (type == null) return null;

      final color = (m['c'] as num?)?.toInt() ?? 0xFFE6EDF3;
      final width = (m['sw'] as num?)?.toDouble() ?? 2.0;

      switch (type) {
        case CanvasElementType.rectangle:
        case CanvasElementType.ellipse:
          final r = _numbers(m['r']);
          if (r.length < 4) return null;
          return CanvasElement(
            id: id,
            type: type,
            rect: Rect.fromLTWH(r[0], r[1], r[2], r[3]),
            color: color,
            strokeWidth: width,
          );
        case CanvasElementType.text:
          final r = _numbers(m['r']);
          final s = m['s'];
          if (r.length < 2 || s is! String) return null;
          final fontSize = (m['fs'] as num?)?.toDouble() ?? 20.0;
          // Re-measure so the box matches the font on this device.
          final size = measureText(s, fontSize);
          return CanvasElement(
            id: id,
            type: type,
            rect: Rect.fromLTWH(r[0], r[1], size.width, size.height),
            text: s,
            color: color,
            strokeWidth: width,
            fontSize: fontSize,
          );
        case CanvasElementType.line:
        case CanvasElementType.arrow:
        case CanvasElementType.pen:
          final n = _numbers(m['p']);
          final points = [
            for (var i = 0; i + 1 < n.length; i += 2) Offset(n[i], n[i + 1]),
          ];
          final needed = type == CanvasElementType.pen ? 1 : 2;
          if (points.length < needed) return null;
          return CanvasElement(
            id: id,
            type: type,
            points: points,
            color: color,
            strokeWidth: width,
          );
      }
    } catch (_) {
      return null;
    }
  }
}