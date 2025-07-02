import 'dart:ui';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  const Stroke({
    required this.points,
    required this.color,
    required this.width,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((point) => [point.dx, point.dy]).toList(),
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'width': width,
    };
  }

  factory Stroke.fromJson(Map<String, dynamic> json) {
    String colorHex = json['color'] as String;
    if (colorHex.startsWith('#')) {
      colorHex = colorHex.substring(1);
    }
    final colorValue = int.parse('FF$colorHex', radix: 16);

    return Stroke(
      points:
          (json['points'] as List)
              .map((point) => Offset(point[0].toDouble(), point[1].toDouble()))
              .toList(),
      color: Color(colorValue),
      width: json['width'].toDouble(),
    );
  }

  Stroke copyWith({List<Offset>? points, Color? color, double? width}) {
    return Stroke(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }
}
