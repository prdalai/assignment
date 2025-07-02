import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/whiteboard_state.dart';
import '../models/stroke.dart';
import '../models/shape.dart';
import '../models/text_element.dart';
import '../services/whiteboard_provider.dart';

/// Custom painter for the whiteboard canvas
class WhiteboardPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Shape> shapes;
  final List<TextElement> texts;
  final Stroke? currentStroke;
  final Shape? currentShape;
  final DrawingTool currentTool;
  final Color eraserColor;

  WhiteboardPainter({
    required this.strokes,
    required this.shapes,
    required this.texts,
    this.currentStroke,
    this.currentShape,
    required this.currentTool,
    this.eraserColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Draw all strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke if exists
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    // Draw all shapes
    for (final shape in shapes) {
      _drawShape(canvas, shape);
    }

    // Draw current shape if exists
    if (currentShape != null) {
      _drawShape(canvas, currentShape!);
    }

    // Draw all text elements
    for (final text in texts) {
      _drawText(canvas, text);
    }
  }

  /// Draw a stroke on the canvas
  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.length < 2) return;

    final paint =
        Paint()
          ..color = stroke.color
          ..strokeWidth = stroke.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  /// Draw a shape on the canvas
  void _drawShape(Canvas canvas, Shape shape) {
    final paint =
        Paint()
          ..color = shape.color
          ..strokeWidth = shape.strokeWidth
          ..style = PaintingStyle.stroke;

    final rect = Rect.fromPoints(shape.topLeft, shape.bottomRight);

    switch (shape.type) {
      case ShapeType.rectangle:
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
        break;
      case ShapeType.line:
        canvas.drawLine(shape.topLeft, shape.bottomRight, paint);
        break;
      case ShapeType.polygon:
        if (shape.polygonSides != null && shape.polygonSides! > 2) {
          _drawPolygon(canvas, shape, paint);
        }
        break;
    }
  }

  /// Draw a polygon on the canvas
  void _drawPolygon(Canvas canvas, Shape shape, Paint paint) {
    final center = shape.center;
    final radius = (shape.width + shape.height) / 4;
    final sides = shape.polygonSides!;
    final angleStep = 2 * pi / sides;

    final path = Path();
    final firstPoint = Offset(
      center.dx + radius * cos(0),
      center.dy + radius * sin(0),
    );
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i <= sides; i++) {
      final angle = i * angleStep;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  /// Draw a text element on the canvas
  void _drawText(Canvas canvas, TextElement text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.text,
        style: TextStyle(color: text.color, fontSize: text.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, text.position);
  }

  @override
  bool shouldRepaint(WhiteboardPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.shapes != shapes ||
        oldDelegate.texts != texts ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.currentShape != currentShape ||
        oldDelegate.currentTool != currentTool;
  }
}

/// Whiteboard canvas widget
class WhiteboardCanvas extends ConsumerStatefulWidget {
  const WhiteboardCanvas({super.key});

  @override
  ConsumerState<WhiteboardCanvas> createState() => _WhiteboardCanvasState();
}

class _WhiteboardCanvasState extends ConsumerState<WhiteboardCanvas> {
  Stroke? _currentStroke;
  Shape? _currentShape;
  Offset? _startPoint;
  String? _editingTextId;
  String? _selectedTextId;
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _canvasKey = GlobalKey();
  bool _isDraggingText = false;
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();
    // Register this canvas state with the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(canvasStateProvider.notifier).state = this;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final whiteboardState = ref.watch(whiteboardStateProvider);
    final currentTool = ref.watch(currentToolProvider);

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20.0),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: RepaintBoundary(
            key: _canvasKey,
            child: CustomPaint(
              painter: WhiteboardPainter(
                strokes: whiteboardState.strokes,
                shapes: whiteboardState.shapes,
                texts: whiteboardState.texts,
                currentStroke: _currentStroke,
                currentShape: _currentShape,
                currentTool: currentTool,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  /// Handle pan start gesture
  void _handlePanStart(DragStartDetails details) {
    final currentTool = ref.read(currentToolProvider);
    _startPoint = details.localPosition;

    // Check if we're clicking on text first
    if (currentTool == DrawingTool.text ||
        _isTextAtPosition(details.localPosition)) {
      _handleTextInteraction(details.localPosition);
      return;
    }

    switch (currentTool) {
      case DrawingTool.pen:
        _startStroke(details.localPosition);
        break;
      case DrawingTool.eraser:
        _startErasing(details.localPosition);
        break;
      case DrawingTool.shape:
        _startShape(details.localPosition);
        break;
      case DrawingTool.text:
        // Text is handled by tap
        break;
    }
  }

  /// Handle pan update gesture
  void _handlePanUpdate(DragUpdateDetails details) {
    final currentTool = ref.read(currentToolProvider);

    // Handle text dragging
    if (_isDraggingText && _selectedTextId != null) {
      _updateTextPosition(details.localPosition);
      return;
    }

    switch (currentTool) {
      case DrawingTool.pen:
        _updateStroke(details.localPosition);
        break;
      case DrawingTool.eraser:
        _updateErasing(details.localPosition);
        break;
      case DrawingTool.shape:
        _updateShape(details.localPosition);
        break;
      case DrawingTool.text:
        // Text is handled by tap
        break;
    }
  }

  /// Handle pan end gesture
  void _handlePanEnd(DragEndDetails details) {
    final currentTool = ref.read(currentToolProvider);

    // End text dragging
    if (_isDraggingText) {
      setState(() {
        _isDraggingText = false;
        _dragStartPosition = null;
      });
      return;
    }

    switch (currentTool) {
      case DrawingTool.pen:
        _endStroke();
        break;
      case DrawingTool.eraser:
        _endErasing();
        break;
      case DrawingTool.shape:
        _endShape();
        break;
      case DrawingTool.text:
        // Text is handled by tap
        break;
    }
  }

  /// Handle tap gesture
  void _handleTap(TapDownDetails details) {
    final currentTool = ref.read(currentToolProvider);

    if (currentTool == DrawingTool.text) {
      _addText(details.localPosition);
    } else if (_isTextAtPosition(details.localPosition)) {
      _handleTextInteraction(details.localPosition);
    }
  }

  /// Start drawing a stroke
  void _startStroke(Offset position) {
    final currentColor = ref.read(currentColorProvider);
    final currentWidth = ref.read(currentStrokeWidthProvider);

    setState(() {
      _currentStroke = Stroke(
        points: [position],
        color: currentColor,
        width: currentWidth,
      );
    });
  }

  /// Update the current stroke
  void _updateStroke(Offset position) {
    if (_currentStroke != null) {
      setState(() {
        _currentStroke = _currentStroke!.copyWith(
          points: [..._currentStroke!.points, position],
        );
      });
    }
  }

  /// End the current stroke
  void _endStroke() {
    if (_currentStroke != null && _currentStroke!.points.length > 1) {
      ref.read(whiteboardStateProvider.notifier).addStroke(_currentStroke!);
      setState(() {
        _currentStroke = null;
      });
    }
  }

  /// Start erasing
  void _startErasing(Offset position) {
    _removeElementsAtPosition(position);
  }

  /// Update erasing
  void _updateErasing(Offset position) {
    _removeElementsAtPosition(position);
  }

  /// End erasing
  void _endErasing() {
    // Erasing is done in real-time
  }

  /// Start drawing a shape
  void _startShape(Offset position) {
    final selectedShapeType = ref.read(selectedShapeTypeProvider);
    if (selectedShapeType == null) return;

    final currentColor = ref.read(currentColorProvider);
    final currentWidth = ref.read(currentStrokeWidthProvider);
    final polygonSides = ref.read(polygonSidesProvider);

    setState(() {
      _currentShape = Shape(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: selectedShapeType,
        topLeft: position,
        bottomRight: position,
        color: currentColor,
        strokeWidth: currentWidth,
        polygonSides: polygonSides,
      );
    });
  }

  /// Update the current shape
  void _updateShape(Offset position) {
    if (_currentShape != null && _startPoint != null) {
      setState(() {
        _currentShape = _currentShape!.copyWith(bottomRight: position);
      });
    }
  }

  /// End the current shape
  void _endShape() {
    if (_currentShape != null) {
      ref.read(whiteboardStateProvider.notifier).addShape(_currentShape!);
      setState(() {
        _currentShape = null;
        _startPoint = null;
      });
    }
  }

  /// Add text at position
  void _addText(Offset position) {
    final currentColor = ref.read(currentColorProvider);
    final textId = DateTime.now().millisecondsSinceEpoch.toString();

    final textElement = TextElement(
      id: textId,
      text: 'Text',
      position: position,
      color: currentColor,
      isEditing: true,
    );

    ref.read(whiteboardStateProvider.notifier).addText(textElement);
    _editingTextId = textId;
    _textController.text = 'Text';

    _showTextDialog(textElement);
  }

  /// Show text editing dialog
  void _showTextDialog(TextElement textElement) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Text'),
            content: TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter text'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _editingTextId = null;
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final updatedText = textElement.copyWith(
                    text: _textController.text,
                    isEditing: false,
                  );
                  ref
                      .read(whiteboardStateProvider.notifier)
                      .updateText(updatedText);
                  Navigator.of(context).pop();
                  _editingTextId = null;
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Remove elements at a specific position
  void _removeElementsAtPosition(Offset position) {
    final whiteboardState = ref.read(whiteboardStateProvider);
    final notifier = ref.read(whiteboardStateProvider.notifier);

    // Remove strokes that contain the point
    for (final stroke in whiteboardState.strokes) {
      if (_strokeContainsPoint(stroke, position)) {
        notifier.removeStroke(stroke);
      }
    }

    // Remove shapes that contain the point
    for (final shape in whiteboardState.shapes) {
      if (shape.contains(position)) {
        notifier.removeShape(shape);
      }
    }

    // Remove text elements that contain the point
    for (final text in whiteboardState.texts) {
      if (_textContainsPoint(text, position)) {
        notifier.removeText(text);
      }
    }
  }

  /// Check if a stroke contains a point
  bool _strokeContainsPoint(Stroke stroke, Offset point) {
    for (int i = 0; i < stroke.points.length - 1; i++) {
      final start = stroke.points[i];
      final end = stroke.points[i + 1];

      final distance = _pointToLineDistance(point, start, end);
      if (distance <= stroke.width / 2) {
        return true;
      }
    }
    return false;
  }

  /// Check if a text element contains a point
  bool _textContainsPoint(TextElement text, Offset point) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.text,
        style: TextStyle(color: text.color, fontSize: text.fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final bounds = text.getBounds(textPainter);
    return bounds.contains(point);
  }

  /// Calculate distance from point to line segment
  double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final A = point.dx - lineStart.dx;
    final B = point.dy - lineStart.dy;
    final C = lineEnd.dx - lineStart.dx;
    final D = lineEnd.dy - lineStart.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) {
      return sqrt(A * A + B * B);
    }

    final param = dot / lenSq;

    double xx, yy;
    if (param < 0) {
      xx = lineStart.dx;
      yy = lineStart.dy;
    } else if (param > 1) {
      xx = lineEnd.dx;
      yy = lineEnd.dy;
    } else {
      xx = lineStart.dx + param * C;
      yy = lineStart.dy + param * D;
    }

    final dx = point.dx - xx;
    final dy = point.dy - yy;
    return sqrt(dx * dx + dy * dy);
  }

  /// Export canvas as image
  Future<List<int>?> exportAsImage() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Get the canvas key for external access
  GlobalKey get canvasKey => _canvasKey;

  /// Check if there's text at a specific position
  bool _isTextAtPosition(Offset position) {
    final whiteboardState = ref.read(whiteboardStateProvider);
    for (final text in whiteboardState.texts) {
      if (_textContainsPoint(text, position)) {
        return true;
      }
    }
    return false;
  }

  /// Handle text interaction (select, edit, or drag)
  void _handleTextInteraction(Offset position) {
    final whiteboardState = ref.read(whiteboardStateProvider);
    final currentTool = ref.read(currentToolProvider);

    for (final text in whiteboardState.texts) {
      if (_textContainsPoint(text, position)) {
        if (currentTool == DrawingTool.eraser) {
          // Erase the text
          ref.read(whiteboardStateProvider.notifier).removeText(text);
        } else {
          // Select the text for editing or dragging
          setState(() {
            _selectedTextId = text.id;
            _editingTextId = text.id;
            _textController.text = text.text;
          });

          // Show edit dialog
          _showTextDialog(text);
        }
        return;
      }
    }
  }

  /// Update text position during dragging
  void _updateTextPosition(Offset position) {
    if (_selectedTextId == null || _dragStartPosition == null) return;

    final whiteboardState = ref.read(whiteboardStateProvider);
    final text = whiteboardState.texts.firstWhere(
      (t) => t.id == _selectedTextId,
    );

    final delta = position - _dragStartPosition!;
    final newPosition = text.position + delta;

    final updatedText = text.copyWith(position: newPosition);
    ref.read(whiteboardStateProvider.notifier).updateText(updatedText);

    setState(() {
      _dragStartPosition = position;
    });
  }

  /// Start text dragging
  void _startTextDragging(Offset position) {
    setState(() {
      _isDraggingText = true;
      _dragStartPosition = position;
    });
  }
}
