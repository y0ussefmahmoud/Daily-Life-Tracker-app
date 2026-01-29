import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../utils/constants.dart';

part 'badge_model.g.dart';

enum BadgeCategory {
  @JsonValue('prayer')
  prayer,
  @JsonValue('projects')
  projects,
  @JsonValue('health')
  health,
  @JsonValue('social')
  social,
  @JsonValue('productivity')
  productivity,
  @JsonValue('learning')
  learning,
}

@JsonSerializable()
class BadgeModel {
  final String? userId; // Added for Supabase operations
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  @JsonKey(fromJson: _iconDataFromJson, toJson: _iconDataToJson)
  final IconData icon;
  final bool isEarned;
  final double progress;
  final DateTime? earnedDate;
  final BadgeCategory category;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;

  const BadgeModel({
    this.userId, // Added for Supabase operations
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.icon,
    required this.isEarned,
    required this.progress,
    this.earnedDate,
    required this.category,
    required this.color,
  });

  BadgeModel copyWith({
    String? userId,
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    IconData? icon,
    bool? isEarned,
    double? progress,
    DateTime? earnedDate,
    BadgeCategory? category,
    Color? color,
  }) {
    return BadgeModel(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      icon: icon ?? this.icon,
      isEarned: isEarned ?? this.isEarned,
      progress: progress ?? this.progress,
      earnedDate: earnedDate ?? this.earnedDate,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) => _$BadgeModelFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeModelToJson(this);

  List<Color> getGradientColors() {
    switch (category) {
      case BadgeCategory.prayer:
        return [Colors.teal.shade400, Colors.teal.shade600];
      case BadgeCategory.projects:
        return [AppColors.primaryColor, AppColors.secondaryColor];
      case BadgeCategory.health:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case BadgeCategory.social:
        return [Colors.pink.shade400, Colors.pink.shade600];
      case BadgeCategory.productivity:
        return [Colors.green.shade400, Colors.green.shade600];
      case BadgeCategory.learning:
        return [Colors.indigo.shade400, Colors.indigo.shade600];
    }
  }

  Color getBadgeColor() {
    if (isEarned) {
      return color;
    } else {
      return AppColors.gray400;
    }
  }

  String get categoryText {
    switch (category) {
      case BadgeCategory.prayer:
        return 'الصلاة';
      case BadgeCategory.projects:
        return 'المشاريع';
      case BadgeCategory.health:
        return 'الصحة';
      case BadgeCategory.social:
        return 'الاجتماعي';
      case BadgeCategory.productivity:
        return 'الإنتاجية';
      case BadgeCategory.learning:
        return 'التعلم';
    }
  }

  // Helper methods for JSON serialization
  static IconData _iconDataFromJson(int codePoint) => IconData(codePoint);
  static int _iconDataToJson(IconData icon) => icon.codePoint;
  
  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color color) => color.value;
}
