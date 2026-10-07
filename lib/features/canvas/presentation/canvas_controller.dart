import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../domain/canvas_text.dart';
import '../domain/entities/canvas_element.dart';
import 'canvas_tools.dart';

enum _Gesture { none, move, resize, draw, erase, text }

class _Frame extends ChangeNotifier {
  void bump() => notifyListeners();
}

/// All canvas editing state and logic: elements, undo/redo, tools,
/// selection and the viewport. It has no Flutter widgets and no Firebase,
/// so it is easy to test.
///
/// [notifyListeners] fires for structural changes (tool, selection, history).
/// Per-move changes (drawing, dragging, panning) only repaint, through
/// [repaint], so the toolbar does not rebuild on every pointer move.
class CanvasController extends ChangeNotifier {
  CanvasController({List<CanvasElement> initial = const []})
      : _elements = List.of(initial);

  static const minScale = 0.1;
  static const maxScale = 5.0;
  static const _maxHistory = 100;
  static const _hitSlop = 8.0; // screen px
  static const _handleSlop = 14.0; // screen px
  static const _minShape = 4.0; // screen px
  static const _defaultFontSize = 20.0;

  final _Frame _frame = _Frame();

  /// Listen to this from painters.
  late final Listenable repaint = Listenable.merge([this, _frame]);

  List<CanvasElement> _elements;
  final List<List<CanvasElement>> _undoStack = [];
  final List<List<CanvasElement>> _redoStack = [];

  CanvasTool _tool = CanvasTool.select;
  int _color = canvasPalette.first;
  double _strokeWidth = canvasStrokeWidths.first;
  String? _selectedId;
  Offset _offset = Offset.zero;
  double _scale = 1;
  CanvasElement? _draft;
  final List<Offset> _penPoints = [];
  int _idSeq = 0;

  /// Increases on every change to the drawing itself (not view or tool).
  int revision = 0;

  /// Called after every change to the drawing (used for autosave).
  VoidCallback? onContentChanged;

  /// Called when the Text tool is used; the UI asks for the text.
  ValueChanged<Offset>? onTextRequested;

  _Gesture _gesture = _Gesture.none;
  List<CanvasElement>? _before;
  CanvasElement? _original;
  Offset _start = Offset.zero;
  Offset _last = Offset.zero;
  int _handle = -1;
  bool _changed = false;

  // ---- read-only state ----

  List<CanvasElement> get elements => _elements;
  CanvasElement? get draft => _draft;
  CanvasTool get tool => _tool;
  Offset get offset => _offset;
  double get scale => _scale;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  CanvasElement? get selected {
    final id = _selectedId;
    if (id == null) return null;
    for (final e in _elements) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Color shown as active: the selected element's, else the drawing color.
  int get color => selected?.color ?? _color;
  double get strokeWidth => selected?.strokeWidth ?? _strokeWidth;

  Offset toWorld(Offset screen) => (screen - _offset) / _scale;

  // ---- tools and style ----

  void setTool(CanvasTool tool) {
    if (tool == _tool) return;
    cancelGesture();
    _tool = tool;
    if (tool != CanvasTool.select) _selectedId = null;
    notifyListeners();
  }

  void select(String? id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  void setColor(int color) {
    _color = color;
    final sel = selected;
    if (sel != null && sel.color != color) {
      final before = _elements;
      _replaceSelected((e) => e.copyWith(color: color));
      _commit(before);
    } else {
      notifyListeners();
    }
  }

  void setStrokeWidth(double width) {
    _strokeWidth = width;
    final sel = selected;
    if (sel != null &&
        sel.type != CanvasElementType.text &&
        sel.strokeWidth != width) {
      final before = _elements;
      _replaceSelected((e) => e.copyWith(strokeWidth: width));
      _commit(before);
    } else {
      notifyListeners();
    }
  }

  // ---- pointer gestures (positions are screen coordinates) ----

  void pointerDown(Offset screen) {
    final p = toWorld(screen);
    _start = p;
    _last = p;
    _before = _elements;
    _changed = false;
    _original = null;

    switch (_tool) {
      case CanvasTool.select:
        _downSelect(p);
      case CanvasTool.hand:
        break;
      case CanvasTool.rectangle:
      case CanvasTool.ellipse:
      case CanvasTool.line:
      case CanvasTool.arrow:
        _gesture = _Gesture.draw;
        _draft = _shapeFor(_tool, _newId(), p, p);
      case CanvasTool.pen:
        _gesture = _Gesture.draw;
        _penPoints
          ..clear()
          ..add(p);
        _draft = CanvasElement(
          id: _newId(),
          type: CanvasElementType.pen,
          points: _penPoints,
          color: _color,
          strokeWidth: _strokeWidth,
        );
      case CanvasTool.text:
        _gesture = _Gesture.text;
      case CanvasTool.eraser:
        _gesture = _Gesture.erase;
        _eraseAt(p);
    }
    notifyListeners();
  }

  void pointerMove(Offset screen) {
    final p = toWorld(screen);
    switch (_gesture) {
      case _Gesture.none:
      case _Gesture.text:
        return;
      case _Gesture.move:
        final delta = p - _last;
        if (delta != Offset.zero) {
          _replaceSelected((e) => e.translated(delta));
          _changed = true;
        }
      case _Gesture.resize:
        _resize(p);
      case _Gesture.draw:
        _updateDraft(p);
      case _Gesture.erase:
        _eraseAt(p);
    }
    _last = p;
    _frame.bump();
  }

  void pointerUp() {
    switch (_gesture) {
      case _Gesture.none:
        return;
      case _Gesture.text:
        onTextRequested?.call(_start);
      case _Gesture.draw:
        _finishDraw();
      case _Gesture.move:
      case _Gesture.resize:
      case _Gesture.erase:
        final before = _before;
        if (_changed && before != null) _commit(before);
    }
    _gesture = _Gesture.none;
    _draft = null;
    _original = null;
    _penPoints.clear();
    notifyListeners();
  }

  /// Aborts the gesture in progress and restores the drawing (used when a
  /// second finger touches the screen).
  void cancelGesture() {
    if (_gesture == _Gesture.none) return;
    final before = _before;
    if (before != null &&
        (_gesture == _Gesture.move ||
            _gesture == _Gesture.resize ||
            _gesture == _Gesture.erase)) {
      _elements = before;
    }
    _gesture = _Gesture.none;
    _draft = null;
    _original = null;
    _penPoints.clear();
    notifyListeners();
  }

  void _downSelect(Offset p) {
    final sel = selected;
    if (sel != null) {
      final handles = sel.handles;
      final reach = _handleSlop / _scale;
      for (var i = 0; i < handles.length; i++) {
        if ((handles[i] - p).distance <= reach) {
          _gesture = _Gesture.resize;
          _handle = i;
          _original = sel;
          return;
        }
      }
    }

    final tolerance = _hitSlop / _scale;
    CanvasElement? hit;
    for (final e in _elements.reversed) {
      if (e.hitTest(p, tolerance)) {
        hit = e;
        break;
      }
    }
    if (hit == null && sel != null && sel.bounds.inflate(tolerance).contains(p)) {
      hit = sel; // grab the inside of an already selected shape
    }

    _selectedId = hit?.id;
    if (hit != null) _gesture = _Gesture.move;
  }

  CanvasElement _shapeFor(CanvasTool tool, String id, Offset a, Offset b) {
    switch (tool) {
      case CanvasTool.rectangle:
      case CanvasTool.ellipse:
        return CanvasElement(
          id: id,
          type: tool == CanvasTool.rectangle
              ? CanvasElementType.rectangle
              : CanvasElementType.ellipse,
          rect: Rect.fromPoints(a, b),
          color: _color,
          strokeWidth: _strokeWidth,
        );
      default:
        return CanvasElement(
          id: id,
          type: tool == CanvasTool.arrow
              ? CanvasElementType.arrow
              : CanvasElementType.line,
          points: [a, b],
          color: _color,
          strokeWidth: _strokeWidth,
        );
    }
  }

  void _updateDraft(Offset p) {
    final d = _draft;
    if (d == null) return;
    if (d.type == CanvasElementType.pen) {
      if ((p - _penPoints.last).distance >= 2 / _scale) {
        _penPoints.add(p);
        _draft = d.copyWith(points: _penPoints);
      }
    } else {
      _draft = _shapeFor(_tool, d.id, _start, p);
    }
  }

  void _finishDraw() {
    final d = _draft;
    if (d == null) return;

    CanvasElement? created;
    if (d.type == CanvasElementType.pen) {
      final points = List<Offset>.of(_penPoints);
      if (points.length == 1) points.add(points.first + const Offset(0.1, 0));
      created = d.copyWith(points: points);
    } else {
      final minSize = _minShape / _scale;
      final b = d.bounds;
      final big = d.isLinear
          ? (d.points[1] - d.points[0]).distance >= minSize
          : (b.width >= minSize || b.height >= minSize);
      if (big) created = d;
    }
    if (created == null) return;

    final before = _elements;
    _elements = [..._elements, created];
    if (created.type == CanvasElementType.pen) {
      _selectedId = null; // keep the pen ready for the next stroke
    } else {
      _selectedId = created.id;
      _tool = CanvasTool.select;
    }
    _commit(before);
  }

  void _resize(Offset p) {
    final orig = _original;
    if (orig == null) return;

    CanvasElement next;
    if (orig.isLinear) {
      next = orig.withPoint(_handle, p);
    } else {
      final corners = orig.handles;
      final opposite = corners[(_handle + 2) % 4];
      if (orig.type == CanvasElementType.text) {
        final target = Rect.fromPoints(opposite, p);
        final base = orig.bounds.height;
        final ratio = base <= 0 ? 1.0 : target.height / base;
        final fontSize = (orig.fontSize * ratio).clamp(8.0, 200.0).toDouble();
        final size = measureText(orig.text, fontSize);
        final corner = corners[_handle];
        final sx = corner.dx >= opposite.dx ? 1.0 : -1.0;
        final sy = corner.dy >= opposite.dy ? 1.0 : -1.0;
        next = orig.copyWith(
          fontSize: fontSize,
          rect: Rect.fromPoints(
            opposite,
            opposite + Offset(sx * size.width, sy * size.height),
          ),
        );
      } else {
        next = orig.withBounds(Rect.fromPoints(opposite, p));
      }
    }
    _replaceSelected((_) => next);
    _changed = true;
  }

  void _eraseAt(Offset p) {
    final tolerance = _hitSlop / _scale;
    final kept = [
      for (final e in _elements)
        if (!e.hitTest(p, tolerance)) e,
    ];
    if (kept.length != _elements.length) {
      _elements = kept;
      _changed = true;
      if (selected == null) _selectedId = null;
    }
  }

  // ---- editing ----

  void addText(Offset world, String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    final size = measureText(value, _defaultFontSize);
    final element = CanvasElement(
      id: _newId(),
      type: CanvasElementType.text,
      rect: Rect.fromLTWH(world.dx, world.dy, size.width, size.height),
      text: value,
      color: _color,
      fontSize: _defaultFontSize,
    );
    final before = _elements;
    _elements = [..._elements, element];
    _selectedId = element.id;
    _tool = CanvasTool.select;
    _commit(before);
  }

  void updateText(String id, String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    CanvasElement? target;
    for (final e in _elements) {
      if (e.id == id) target = e;
    }
    if (target == null || target.type != CanvasElementType.text) return;
    if (target.text == value) return;

    final size = measureText(value, target.fontSize);
    final before = _elements;
    _elements = [
      for (final e in _elements)
        e.id == id
            ? e.copyWith(
                text: value,
                rect: Rect.fromLTWH(
                  e.rect.left,
                  e.rect.top,
                  size.width,
                  size.height,
                ),
              )
            : e,
    ];
    _commit(before);
  }

  void deleteSelected() {
    final id = _selectedId;
    if (id == null) return;
    final before = _elements;
    _elements = [
      for (final e in _elements)
        if (e.id != id) e,
    ];
    _selectedId = null;
    _commit(before);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    cancelGesture();
    _redoStack.add(_elements);
    _elements = _undoStack.removeLast();
    _afterHistoryChange();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    cancelGesture();
    _undoStack.add(_elements);
    _elements = _redoStack.removeLast();
    _afterHistoryChange();
  }

  void _afterHistoryChange() {
    if (selected == null) _selectedId = null;
    revision++;
    onContentChanged?.call();
    notifyListeners();
  }

  void _replaceSelected(CanvasElement Function(CanvasElement) change) {
    final id = _selectedId;
    if (id == null) return;
    _elements = [
      for (final e in _elements) e.id == id ? change(e) : e,
    ];
  }

  void _commit(List<CanvasElement> before) {
    _undoStack.add(before);
    if (_undoStack.length > _maxHistory) _undoStack.removeAt(0);
    _redoStack.clear();
    revision++;
    onContentChanged?.call();
    notifyListeners();
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_idSeq++}';

  // ---- viewport ----

  void panBy(Offset delta) {
    _offset += delta;
    _frame.bump();
  }

  /// Zooms by [factor] keeping the world point under [focal] fixed.
  void zoomAround(Offset focal, double factor) {
    final next = (_scale * factor).clamp(minScale, maxScale).toDouble();
    final applied = next / _scale;
    if (applied == 1) return;
    _offset = focal - (focal - _offset) * applied;
    _scale = next;
    notifyListeners();
  }

  void resetView() {
    _scale = 1;
    _offset = Offset.zero;
    notifyListeners();
  }

  /// Zooms and pans so every element is visible. Does nothing when empty.
  void fitToContent(Size view) {
    if (_elements.isEmpty || view.isEmpty) return;
    var box = _elements.first.bounds;
    for (final e in _elements) {
      box = box.expandToInclude(e.bounds);
    }
    const margin = 48.0;
    final sx = (view.width - margin * 2) / math.max(box.width, 1);
    final sy = (view.height - margin * 2) / math.max(box.height, 1);
    _scale = math.min(math.min(sx, sy), 1.5).clamp(minScale, maxScale).toDouble();
    _offset = Offset(
      view.width / 2 - box.center.dx * _scale,
      view.height / 2 - box.center.dy * _scale,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _frame.dispose();
    super.dispose();
  }
}