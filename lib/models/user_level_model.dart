import 'package:json_annotation/json_annotation.dart';

part 'user_level_model.g.dart';

@JsonSerializable()
class UserLevelModel {
  final int currentLevel;
  final String levelTitle;
  final int currentXP;
  final int xpForNextLevel;
  final int totalXP;

  const UserLevelModel({
    required this.currentLevel,
    required this.levelTitle,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.totalXP,
  });

  UserLevelModel copyWith({
    int? currentLevel,
    String? levelTitle,
    int? currentXP,
    int? xpForNextLevel,
    int? totalXP,
  }) {
    return UserLevelModel(
      currentLevel: currentLevel ?? this.currentLevel,
      levelTitle: levelTitle ?? this.levelTitle,
      currentXP: currentXP ?? this.currentXP,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      totalXP: totalXP ?? this.totalXP,
    );
  }

  factory UserLevelModel.fromJson(Map<String, dynamic> json) => _$UserLevelModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserLevelModelToJson(this);

  double get xpProgress {
    if (xpForNextLevel == 0) return 0.0;
    return currentXP / xpForNextLevel;
  }

  int get xpRemaining {
    return xpForNextLevel - currentXP;
  }

  int get progressPercentage {
    return (xpProgress * 100).round();
  }

  bool get isMaxLevel {
    return currentXP >= xpForNextLevel;
  }
}
