import 'dart:ui';

import 'package:devpad/features/canvas/data/models/canvas_codec.dart';
import 'package:devpad/features/canvas/domain/entities/canvas_element.dart';
import 'package:devpad/features/canvas/presentation/canvas_controller.dart';
import 'package:devpad/features/canvas/presentation/canvas_tools.dart';
import 'package:flutter_test/flutter_test.dart';

/// Draws a rectangle from (10,10) to (110,60) with the controller.
CanvasController _withRectangle() {
  final c = CanvasController();
  c.setTool(CanvasTool.rectangle);
  c.pointerDown(const Offset(10, 10));
  c.pointerMove(const Offset(110, 60));
  c.pointerUp();
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('drawing', () {
    test('a dragged rectangle is added, selected, and the tool resets', () {
      final c = _withRectangle();

      expect(c.elements, hasLength(1));
      expect(c.elements.first.type, CanvasElementType.rectangle);
      expect(c.elements.first.rect, const Rect.fromLTRB(10, 10, 110, 60));
      expect(c.tool, CanvasTool.select);
      expect(c.selected, isNotNull);
    });

    test('a tiny drag creates nothing', () {
      final c = CanvasController();
      c.setTool(CanvasTool.rectangle);
      c.pointerDown(const Offset(10, 10));
      c.pointerUp();

      expect(c.elements, isEmpty);
      expect(c.canUndo, isFalse);
    });

    test('the pen records points and stays active', () {
      final c = CanvasController();
      c.setTool(CanvasTool.pen);
      c.pointerDown(const Offset(0, 0));
      c.pointerMove(const Offset(10, 0));
      c.pointerMove(const Offset(20, 5));
      c.pointerUp();

      expect(c.elements, hasLength(1));
      expect(c.elements.first.type, CanvasElementType.pen);
      expect(c.elements.first.points.length, greaterThanOrEqualTo(3));
      expect(c.tool, CanvasTool.pen);
      expect(c.selected, isNull);
    });
  });

  group('history', () {
    test('undo and redo walk through changes', () {
      final c = _withRectangle();

      c.undo();
      expect(c.elements, isEmpty);
      expect(c.canRedo, isTrue);

      c.redo();
      expect(c.elements, hasLength(1));
      expect(c.revision, greaterThan(0));
    });

    test('delete selected can be undone', () {
      final c = _withRectangle();

      c.deleteSelected();
      expect(c.elements, isEmpty);

      c.undo();
      expect(c.elements, hasLength(1));
    });
  });

  group('select, move, resize, erase', () {
    test('dragging the outline moves the element', () {
      final c = _withRectangle();

      c.pointerDown(const Offset(60, 10)); // middle of the top edge
      c.pointerMove(const Offset(80, 40));
      c.pointerUp();

      expect(c.elements.first.rect, const Rect.fromLTRB(30, 40, 130, 90));
      c.undo();
      expect(c.elements.first.rect, const Rect.fromLTRB(10, 10, 110, 60));
    });

    test('dragging a corner handle resizes the element', () {
      final c = _withRectangle();

      c.pointerDown(const Offset(110, 60)); // bottom-right handle
      c.pointerMove(const Offset(210, 160));
      c.pointerUp();

      expect(c.elements.first.rect, const Rect.fromLTRB(10, 10, 210, 160));
    });

    test('clicking empty space deselects', () {
      final c = _withRectangle();

      c.pointerDown(const Offset(500, 500));
      c.pointerUp();

      expect(c.selected, isNull);
    });

    test('the eraser removes what it touches, as one undo step', () {
      final c = _withRectangle();
      c.setTool(CanvasTool.eraser);

      c.pointerDown(const Offset(60, 10));
      c.pointerUp();
      expect(c.elements, isEmpty);

      c.undo();
      expect(c.elements, hasLength(1));
    });
  });

  group('viewport', () {
    test('zoomAround keeps the point under the cursor fixed', () {
      final c = CanvasController();
      c.panBy(const Offset(30, 20));
      const focal = Offset(100, 100);
      final before = c.toWorld(focal);

      c.zoomAround(focal, 2);
      final after = c.toWorld(focal);

      expect(c.scale, 2);
      expect((after - before).distance, lessThan(1e-9));
    });

    test('zoom is clamped', () {
      final c = CanvasController();

      c.zoomAround(Offset.zero, 1000);
      expect(c.scale, CanvasController.maxScale);

      c.zoomAround(Offset.zero, 0.00001);
      expect(c.scale, CanvasController.minScale);
    });
  });

  group('codec', () {
    test('encode then decode keeps every element type', () {
      final elements = [
        const CanvasElement(
          id: 'r',
          type: CanvasElementType.rectangle,
          rect: Rect.fromLTWH(1, 2, 30, 40),
          color: 0xFF7C83FF,
          strokeWidth: 4,
        ),
        const CanvasElement(
          id: 'a',
          type: CanvasElementType.arrow,
          points: [Offset(0, 0), Offset(50, 25)],
          color: 0xFFE6EDF3,
        ),
        const CanvasElement(
          id: 'p',
          type: CanvasElementType.pen,
          points: [Offset(1, 1), Offset(2, 3), Offset(4, 9)],
          color: 0xFF3FB950,
        ),
        const CanvasElement(
          id: 't',
          type: CanvasElementType.text,
          rect: Rect.fromLTWH(5, 6, 10, 10),
          text: 'API',
          color: 0xFFF0883E,
        ),
      ];

      final decoded = CanvasCodec.decode(CanvasCodec.encode(elements));

      expect(decoded.map((e) => e.id), ['r', 'a', 'p', 't']);
      expect(decoded[0].rect, const Rect.fromLTWH(1, 2, 30, 40));
      expect(decoded[0].strokeWidth, 4);
      expect(decoded[1].points, const [Offset(0, 0), Offset(50, 25)]);
      expect(decoded[2].points, hasLength(3));
      expect(decoded[3].text, 'API');
      expect(decoded[3].rect.topLeft, const Offset(5, 6));
    });

    test('bad data throws, unknown elements are skipped', () {
      expect(() => CanvasCodec.decode('{"a":1}'), throwsFormatException);
      expect(() => CanvasCodec.decode('not json'), throwsFormatException);

      final decoded = CanvasCodec.decode(
        '[{"id":"x","t":"hologram"},{"id":"y","t":"line","c":1,"p":[0,0,5,5]}]',
      );
      expect(decoded.map((e) => e.id), ['y']);
    });
  });
}