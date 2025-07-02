import 'dart:ui';
import 'package:flutter/material.dart';
import 'stroke.dart';
import 'shape.dart';
import 'text_element.dart';

enum DrawingTool { pen, eraser, shape, text }

class WhiteboardState {
  final List<Stroke> strokes;
  final List<Shape> shapes;
  final List<TextElement> texts;
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentStrokeWidth;
  final ShapeType? selectedShapeType;
  final int? polygonSides;
  final List<WhiteboardState> undoStack;
  final List<WhiteboardState> redoStack;

  const WhiteboardState({
    this.strokes = const [],
    this.shapes = const [],
    this.texts = const [],
    this.currentTool = DrawingTool.pen,
    this.currentColor = Colors.black,
    this.currentStrokeWidth = 3.0,
    this.selectedShapeType,
    this.polygonSides,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'strokes': strokes.map((stroke) => stroke.toJson()).toList(),
      'shapes': shapes.map((shape) => shape.toJson()).toList(),
      'texts': texts.map((text) => text.toJson()).toList(),
    };
  }

  factory WhiteboardState.fromJson(Map<String, dynamic> json) {
    return WhiteboardState(
      strokes:
          (json['strokes'] as List?)
              ?.map((stroke) => Stroke.fromJson(stroke))
              .toList() ??
          [],
      shapes:
          (json['shapes'] as List?)
              ?.map((shape) => Shape.fromJson(shape))
              .toList() ??
          [],
      texts:
          (json['texts'] as List?)
              ?.map((text) => TextElement.fromJson(text))
              .toList() ??
          [],
    );
  }

  WhiteboardState copyWith({
    List<Stroke>? strokes,
    List<Shape>? shapes,
    List<TextElement>? texts,
    DrawingTool? currentTool,
    Color? currentColor,
    double? currentStrokeWidth,
    ShapeType? selectedShapeType,
    int? polygonSides,
    List<WhiteboardState>? undoStack,
    List<WhiteboardState>? redoStack,
  }) {
    return WhiteboardState(
      strokes: strokes ?? this.strokes,
      shapes: shapes ?? this.shapes,
      texts: texts ?? this.texts,
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      selectedShapeType: selectedShapeType ?? this.selectedShapeType,
      polygonSides: polygonSides ?? this.polygonSides,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }

  WhiteboardState addStroke(Stroke stroke) {
    return copyWith(strokes: [...strokes, stroke], redoStack: []);
  }

  WhiteboardState addShape(Shape shape) {
    return copyWith(shapes: [...shapes, shape], redoStack: []);
  }

  WhiteboardState addText(TextElement text) {
    return copyWith(texts: [...texts, text], redoStack: []);
  }

  WhiteboardState removeStroke(Stroke stroke) {
    return copyWith(
      strokes: strokes.where((s) => s != stroke).toList(),
      redoStack: [],
    );
  }

  WhiteboardState removeShape(Shape shape) {
    return copyWith(
      shapes: shapes.where((s) => s.id != shape.id).toList(),
      redoStack: [],
    );
  }

  WhiteboardState removeText(TextElement text) {
    return copyWith(
      texts: texts.where((t) => t.id != text.id).toList(),
      redoStack: [],
    );
  }

  WhiteboardState updateText(TextElement updatedText) {
    return copyWith(
      texts:
          texts.map((text) {
            return text.id == updatedText.id ? updatedText : text;
          }).toList(),
      redoStack: [],
    );
  }

  WhiteboardState clear() {
    return copyWith(strokes: [], shapes: [], texts: [], redoStack: []);
  }

  WhiteboardState saveForUndo() {
    final currentState = copyWith(undoStack: [], redoStack: []);
    return copyWith(undoStack: [...undoStack, currentState]);
  }

  WhiteboardState? undo() {
    if (undoStack.isEmpty) return null;

    final previousState = undoStack.last;
    final newUndoStack = undoStack.sublist(0, undoStack.length - 1);

    return previousState.copyWith(
      undoStack: newUndoStack,
      redoStack: [...redoStack, copyWith(undoStack: [], redoStack: [])],
    );
  }

  WhiteboardState? redo() {
    if (redoStack.isEmpty) return null;

    final nextState = redoStack.last;
    final newRedoStack = redoStack.sublist(0, redoStack.length - 1);

    return nextState.copyWith(
      undoStack: [...undoStack, copyWith(undoStack: [], redoStack: [])],
      redoStack: newRedoStack,
    );
  }

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
}
