import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/whiteboard_state.dart';
import '../models/stroke.dart';
import '../models/shape.dart';
import '../models/text_element.dart';
import 'storage_service.dart';

final canvasStateProvider = StateProvider<dynamic>((ref) => null);

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final whiteboardStateProvider =
    StateNotifierProvider<WhiteboardNotifier, WhiteboardState>((ref) {
      return WhiteboardNotifier();
    });

class WhiteboardNotifier extends StateNotifier<WhiteboardState> {
  WhiteboardNotifier() : super(const WhiteboardState());

  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(currentStrokeWidth: width);
  }

  void setShapeType(ShapeType? shapeType) {
    state = state.copyWith(selectedShapeType: shapeType);
  }

  void setPolygonSides(int? sides) {
    state = state.copyWith(polygonSides: sides);
  }

  void addStroke(Stroke stroke) {
    state = state.saveForUndo().addStroke(stroke);
  }

  void addShape(Shape shape) {
    state = state.saveForUndo().addShape(shape);
  }

  void addText(TextElement text) {
    state = state.saveForUndo().addText(text);
  }

  void removeStroke(Stroke stroke) {
    state = state.saveForUndo().removeStroke(stroke);
  }

  void removeShape(Shape shape) {
    state = state.saveForUndo().removeShape(shape);
  }

  void removeText(TextElement text) {
    state = state.saveForUndo().removeText(text);
  }

  void updateText(TextElement updatedText) {
    state = state.saveForUndo().updateText(updatedText);
  }

  void clear() {
    state = state.saveForUndo().clear();
  }

  void undo() {
    final newState = state.undo();
    if (newState != null) {
      state = newState;
    }
  }

  void redo() {
    final newState = state.redo();
    if (newState != null) {
      state = newState;
    }
  }

  Future<void> loadFromStorage(String fileName) async {
    try {
      final storageService = StorageService();
      final loadedState = await storageService.loadWhiteboard(fileName);
      state = loadedState;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> saveToStorage() async {
    try {
      final storageService = StorageService();
      return await storageService.saveWhiteboard(state);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getSavedFiles() async {
    try {
      final storageService = StorageService();
      return await storageService.getSavedWhiteboards();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final storageService = StorageService();
      await storageService.deleteWhiteboard(fileName);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> exportAsImage(List<int> imageBytes) async {
    try {
      final storageService = StorageService();
      final fileName = 'whiteboard_${DateTime.now().millisecondsSinceEpoch}';
      return await storageService.exportAsImage(fileName, imageBytes);
    } catch (e) {
      rethrow;
    }
  }
}

final currentToolProvider = Provider<DrawingTool>((ref) {
  return ref.watch(whiteboardStateProvider).currentTool;
});

final currentColorProvider = Provider<Color>((ref) {
  return ref.watch(whiteboardStateProvider).currentColor;
});

final currentStrokeWidthProvider = Provider<double>((ref) {
  return ref.watch(whiteboardStateProvider).currentStrokeWidth;
});

final selectedShapeTypeProvider = Provider<ShapeType?>((ref) {
  return ref.watch(whiteboardStateProvider).selectedShapeType;
});

final polygonSidesProvider = Provider<int?>((ref) {
  return ref.watch(whiteboardStateProvider).polygonSides;
});

final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(whiteboardStateProvider).canUndo;
});

final canRedoProvider = Provider<bool>((ref) {
  return ref.watch(whiteboardStateProvider).canRedo;
});
