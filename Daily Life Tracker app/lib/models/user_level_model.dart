class UserLevelModel {
  final int level;
  final String title;
  final int minPoints;
  final int maxPoints;

  const UserLevelModel({
    required this.level,
    required this.title,
    required this.minPoints,
    required this.maxPoints,
  });

  // Add missing getters for compatibility
  int get totalXP => minPoints;
  int get currentXP => minPoints;
  int get xpForNextLevel => maxPoints;
  int get xpRemaining => maxPoints - minPoints;
  double get xpProgress => minPoints / maxPoints;
  int get currentLevel => level;
  String get levelTitle => title;

  static UserLevelModel initial() {
    return const UserLevelModel(
      level: 1,
      title: 'مبتدئ',
      minPoints: 0,
      maxPoints: 100,
    );
  }
}
