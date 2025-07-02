import 'dart:ui';
import 'package:flutter/material.dart';

class TextElement {
  final String id;
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  final bool isEditing;

  const TextElement({
    required this.id,
    required this.text,
    required this.position,
    required this.color,
    this.fontSize = 24.0,
    this.isEditing = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'position': [position.dx, position.dy],
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'size': fontSize,
    };
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    String colorHex = json['color'] as String;
    if (colorHex.startsWith('#')) {
      colorHex = colorHex.substring(1);
    }
    final colorValue = int.parse('FF$colorHex', radix: 16);

    return TextElement(
      id: json['id'] as String,
      text: json['text'] as String,
      position: Offset(
        json['position'][0].toDouble(),
        json['position'][1].toDouble(),
      ),
      color: Color(colorValue),
      fontSize: json['size']?.toDouble() ?? 24.0,
    );
  }

  TextElement copyWith({
    String? id,
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
    bool? isEditing,
  }) {
    return TextElement(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  Rect getBounds(TextPainter painter) {
    painter.text = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize),
    );
    painter.layout();

    return Rect.fromLTWH(
      position.dx,
      position.dy,
      painter.width,
      painter.height,
    );
  }

  bool contains(Offset point, TextPainter painter) {
    final bounds = getBounds(painter);
    return bounds.contains(point);
  }
}
