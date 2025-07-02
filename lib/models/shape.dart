import 'dart:ui';

enum ShapeType { rectangle, circle, line, polygon }

class Shape {
  final String id;
  final ShapeType type;
  final Offset topLeft;
  final Offset bottomRight;
  final Color color;
  final double strokeWidth;
  final int? polygonSides;

  const Shape({
    required this.id,
    required this.type,
    required this.topLeft,
    required this.bottomRight,
    required this.color,
    this.strokeWidth = 2.0,
    this.polygonSides,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'topLeft': [topLeft.dx, topLeft.dy],
      'bottomRight': [bottomRight.dx, bottomRight.dy],
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    };
  }

  factory Shape.fromJson(Map<String, dynamic> json) {
    String colorHex = json['color'] as String;
    if (colorHex.startsWith('#')) {
      colorHex = colorHex.substring(1);
    }
    final colorValue = int.parse('FF$colorHex', radix: 16);

    return Shape(
      id: json['id'] as String,
      type: ShapeType.values.firstWhere((e) => e.name == json['type']),
      topLeft: Offset(
        json['topLeft'][0].toDouble(),
        json['topLeft'][1].toDouble(),
      ),
      bottomRight: Offset(
        json['bottomRight'][0].toDouble(),
        json['bottomRight'][1].toDouble(),
      ),
      color: Color(colorValue),
      strokeWidth: json['strokeWidth']?.toDouble() ?? 2.0,
      polygonSides: json['polygonSides'] as int?,
    );
  }

  Shape copyWith({
    String? id,
    ShapeType? type,
    Offset? topLeft,
    Offset? bottomRight,
    Color? color,
    double? strokeWidth,
    int? polygonSides,
  }) {
    return Shape(
      id: id ?? this.id,
      type: type ?? this.type,
      topLeft: topLeft ?? this.topLeft,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      polygonSides: polygonSides ?? this.polygonSides,
    );
  }

  Offset get center => Offset(
    (topLeft.dx + bottomRight.dx) / 2,
    (topLeft.dy + bottomRight.dy) / 2,
  );

  double get width => (bottomRight.dx - topLeft.dx).abs();
  double get height => (bottomRight.dy - topLeft.dy).abs();

  bool contains(Offset point) {
    return point.dx >= topLeft.dx &&
        point.dx <= bottomRight.dx &&
        point.dy >= topLeft.dy &&
        point.dy <= bottomRight.dy;
  }
}
