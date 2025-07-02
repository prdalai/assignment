import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/whiteboard_state.dart';
import '../models/shape.dart';
import '../services/whiteboard_provider.dart';

/// Whiteboard toolbar widget
class WhiteboardToolbar extends ConsumerWidget {
  final GlobalKey canvasKey;

  const WhiteboardToolbar({super.key, required this.canvasKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTool = ref.watch(currentToolProvider);
    final currentColor = ref.watch(currentColorProvider);
    final currentStrokeWidth = ref.watch(currentStrokeWidthProvider);
    final canUndo = ref.watch(canUndoProvider);
    final canRedo = ref.watch(canRedoProvider);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Drawing tools
            _buildToolSection(
              children: [
                _buildToolButton(
                  icon: Icons.edit,
                  isSelected: currentTool == DrawingTool.pen,
                  onTap:
                      () => ref
                          .read(whiteboardStateProvider.notifier)
                          .setTool(DrawingTool.pen),
                  tooltip: 'Pen',
                ),
                _buildToolButton(
                  icon: Icons.auto_fix_high,
                  isSelected: currentTool == DrawingTool.eraser,
                  onTap:
                      () => ref
                          .read(whiteboardStateProvider.notifier)
                          .setTool(DrawingTool.eraser),
                  tooltip: 'Eraser',
                ),
                _buildToolButton(
                  icon: Icons.crop_square,
                  isSelected: currentTool == DrawingTool.shape,
                  onTap:
                      () => ref
                          .read(whiteboardStateProvider.notifier)
                          .setTool(DrawingTool.shape),
                  tooltip: 'Shapes',
                ),
                _buildToolButton(
                  icon: Icons.text_fields,
                  isSelected: currentTool == DrawingTool.text,
                  onTap:
                      () => ref
                          .read(whiteboardStateProvider.notifier)
                          .setTool(DrawingTool.text),
                  tooltip: 'Text',
                ),
              ],
            ),

            const VerticalDivider(),

            // Shape selector (only visible when shape tool is selected)
            if (currentTool == DrawingTool.shape) _buildShapeSelector(ref),

            const VerticalDivider(),

            // Color picker
            _buildColorPicker(ref, currentColor),

            const VerticalDivider(),

            // Stroke width selector
            _buildStrokeWidthSelector(ref, currentStrokeWidth),

            const SizedBox(width: 20),

            // Action buttons
            _buildActionButtons(ref, canUndo, canRedo),

            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  /// Build tool section
  Widget _buildToolSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: child,
                  ),
                )
                .toList(),
      ),
    );
  }

  /// Build tool button
  Widget _buildToolButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.blue) : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue[700] : Colors.grey[700],
            size: 24,
          ),
        ),
      ),
    );
  }

  /// Build shape selector
  Widget _buildShapeSelector(WidgetRef ref) {
    final selectedShapeType = ref.watch(selectedShapeTypeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShapeButton(
            icon: Icons.crop_square,
            shapeType: ShapeType.rectangle,
            isSelected: selectedShapeType == ShapeType.rectangle,
            onTap:
                () => ref
                    .read(whiteboardStateProvider.notifier)
                    .setShapeType(ShapeType.rectangle),
            tooltip: 'Rectangle',
          ),
          _buildShapeButton(
            icon: Icons.circle_outlined,
            shapeType: ShapeType.circle,
            isSelected: selectedShapeType == ShapeType.circle,
            onTap:
                () => ref
                    .read(whiteboardStateProvider.notifier)
                    .setShapeType(ShapeType.circle),
            tooltip: 'Circle',
          ),
          _buildShapeButton(
            icon: Icons.remove,
            shapeType: ShapeType.line,
            isSelected: selectedShapeType == ShapeType.line,
            onTap:
                () => ref
                    .read(whiteboardStateProvider.notifier)
                    .setShapeType(ShapeType.line),
            tooltip: 'Line',
          ),
          _buildShapeButton(
            icon: Icons.pentagon_outlined,
            shapeType: ShapeType.polygon,
            isSelected: selectedShapeType == ShapeType.polygon,
            onTap: () => _showPolygonDialog(ref),
            tooltip: 'Polygon',
          ),
        ],
      ),
    );
  }

  /// Build shape button
  Widget _buildShapeButton({
    required IconData icon,
    required ShapeType shapeType,
    required bool isSelected,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.blue) : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue[700] : Colors.grey[700],
            size: 24,
          ),
        ),
      ),
    );
  }

  /// Show polygon sides dialog
  void _showPolygonDialog(WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Polygon Sides'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [3, 4, 5, 6, 7, 8]
                      .map(
                        (sides) => ListTile(
                          title: Text('$sides sides'),
                          onTap: () {
                            ref
                                .read(whiteboardStateProvider.notifier)
                                .setShapeType(ShapeType.polygon);
                            ref
                                .read(whiteboardStateProvider.notifier)
                                .setPolygonSides(sides);
                            Navigator.of(context).pop();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  /// Build color picker
  Widget _buildColorPicker(WidgetRef ref, Color currentColor) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            colors
                .map(
                  (color) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildColorButton(
                      color: color,
                      isSelected: currentColor == color,
                      onTap:
                          () => ref
                              .read(whiteboardStateProvider.notifier)
                              .setColor(color),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  /// Build color button
  Widget _buildColorButton({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  /// Build stroke width selector
  Widget _buildStrokeWidthSelector(WidgetRef ref, double currentStrokeWidth) {
    final widths = [1.0, 3.0, 6.0, 12.0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            widths
                .map(
                  (width) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildStrokeWidthButton(
                      width: width,
                      isSelected: currentStrokeWidth == width,
                      onTap:
                          () => ref
                              .read(whiteboardStateProvider.notifier)
                              .setStrokeWidth(width),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  /// Build stroke width button
  Widget _buildStrokeWidthButton({
    required double width,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue) : null,
        ),
        child: Center(
          child: Container(
            width: width * 2,
            height: width * 2,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(WidgetRef ref, bool canUndo, bool canRedo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.undo,
            onTap:
                canUndo
                    ? () => ref.read(whiteboardStateProvider.notifier).undo()
                    : null,
            tooltip: 'Undo',
            isEnabled: canUndo,
          ),
          _buildActionButton(
            icon: Icons.redo,
            onTap:
                canRedo
                    ? () => ref.read(whiteboardStateProvider.notifier).redo()
                    : null,
            tooltip: 'Redo',
            isEnabled: canRedo,
          ),
          _buildActionButton(
            icon: Icons.clear,
            onTap: () => _showClearDialog(ref),
            tooltip: 'Clear',
            isEnabled: true,
          ),
          _buildActionButton(
            icon: Icons.save,
            onTap: () => _showSaveDialog(ref),
            tooltip: 'Save',
            isEnabled: true,
          ),
          _buildActionButton(
            icon: Icons.folder_open,
            onTap: () => _showLoadDialog(ref),
            tooltip: 'Load',
            isEnabled: true,
          ),
          _buildActionButton(
            icon: Icons.image,
            onTap: () => _showExportDialog(ref),
            tooltip: 'Export as PNG',
            isEnabled: true,
          ),
          _buildActionButton(
            icon: Icons.preview,
            onTap: () => _showPreviewDialog(ref),
            tooltip: 'Preview Saved',
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    required bool isEnabled,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isEnabled ? Colors.grey[700] : Colors.grey[400],
            size: 24,
          ),
        ),
      ),
    );
  }

  /// Show clear confirmation dialog
  void _showClearDialog(WidgetRef ref) {
    showDialog(
      context: ref.context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Whiteboard'),
            content: const Text('Are you sure you want to clear all content?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(whiteboardStateProvider.notifier).clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  /// Show save dialog
  void _showSaveDialog(WidgetRef ref) async {
    try {
      final fileName =
          await ref.read(whiteboardStateProvider.notifier).saveToStorage();
      if (ref.context.mounted) {
        ScaffoldMessenger.of(
          ref.context,
        ).showSnackBar(SnackBar(content: Text('Saved as $fileName')));
      }
    } catch (e) {
      if (ref.context.mounted) {
        ScaffoldMessenger.of(
          ref.context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  /// Show load dialog
  void _showLoadDialog(WidgetRef ref) async {
    try {
      final files =
          await ref.read(whiteboardStateProvider.notifier).getSavedFiles();

      if (ref.context.mounted) {
        showDialog(
          context: ref.context,
          builder:
              (context) => AlertDialog(
                title: const Text('Load Whiteboard'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child:
                      files.isEmpty
                          ? const Center(
                            child: Text('No saved whiteboards found'),
                          )
                          : ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return ListTile(
                                title: Text(file),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  try {
                                    await ref
                                        .read(whiteboardStateProvider.notifier)
                                        .loadFromStorage(file);
                                    if (ref.context.mounted) {
                                      ScaffoldMessenger.of(
                                        ref.context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Loaded $file')),
                                      );
                                    }
                                  } catch (e) {
                                    if (ref.context.mounted) {
                                      ScaffoldMessenger.of(
                                        ref.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to load: $e'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (ref.context.mounted) {
        ScaffoldMessenger.of(
          ref.context,
        ).showSnackBar(SnackBar(content: Text('Failed to load files: $e')));
      }
    }
  }

  /// Show export dialog
  void _showExportDialog(WidgetRef ref) async {
    try {
      // Show loading dialog
      showDialog(
        context: ref.context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Exporting image...'),
                ],
              ),
            ),
      );

      // Get the canvas state and export
      final canvasState = ref.read(canvasStateProvider);
      if (canvasState != null) {
        final imageBytes = await canvasState.exportAsImage();
        if (imageBytes != null) {
          final fileName = await ref
              .read(whiteboardStateProvider.notifier)
              .exportAsImage(imageBytes);

          if (ref.context.mounted) {
            Navigator.of(ref.context).pop(); // Close loading dialog

            showDialog(
              context: ref.context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Export Successful'),
                    content: Text('Image exported as $fileName'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        } else {
          throw Exception('Failed to capture image');
        }
      } else {
        throw Exception('Canvas not found');
      }
    } catch (e) {
      if (ref.context.mounted) {
        Navigator.of(ref.context).pop(); // Close loading dialog
        ScaffoldMessenger.of(
          ref.context,
        ).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
      }
    }
  }

  /// Show preview dialog
  void _showPreviewDialog(WidgetRef ref) async {
    try {
      final files =
          await ref.read(whiteboardStateProvider.notifier).getSavedFiles();

      if (ref.context.mounted) {
        showDialog(
          context: ref.context,
          builder:
              (context) => AlertDialog(
                title: const Text('Saved Whiteboards'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child:
                      files.isEmpty
                          ? const Center(
                            child: Text('No saved whiteboards found'),
                          )
                          : ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.description),
                                  title: Text(file),
                                  subtitle: Text('Tap to load'),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    try {
                                      await ref
                                          .read(
                                            whiteboardStateProvider.notifier,
                                          )
                                          .loadFromStorage(file);
                                      if (ref.context.mounted) {
                                        ScaffoldMessenger.of(
                                          ref.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Loaded $file'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (ref.context.mounted) {
                                        ScaffoldMessenger.of(
                                          ref.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to load: $e'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (ref.context.mounted) {
        ScaffoldMessenger.of(
          ref.context,
        ).showSnackBar(SnackBar(content: Text('Failed to load files: $e')));
      }
    }
  }
}
