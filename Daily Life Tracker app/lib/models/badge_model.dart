import 'package:flutter/material.dart';

class BadgeModel {
  final String badge;
  final String title;
  final String color;
  final String iconUrl;
  final int points;

  const BadgeModel({
    required this.badge,
    required this.title,
    required this.color,
    required this.iconUrl,
    this.points = 0,
  });

  // Add getters for compatibility
  String get title_ => title.isNotEmpty ? title : badge;
  String get color_ => color;
  String get iconUrl_ => iconUrl;
  IconData get icon => Icons.emoji_events;
  bool get isEarned => true; // Default to earned
  
  // Gradient colors method
  List<Color> getGradientColors() {
    final baseColor = Color(int.parse(color.replaceFirst('#', '0xFF')));
    return [
      baseColor,
      baseColor.withValues(alpha: 0.7),
    ];
  }
  
  // Badge color method
  Color getBadgeColor() {
    return Color(int.parse(color.replaceFirst('#', '0xFF')));
  }
}
