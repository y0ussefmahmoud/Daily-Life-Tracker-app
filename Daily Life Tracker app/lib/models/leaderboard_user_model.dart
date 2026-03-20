class LeaderboardUserModel {
  final String id;
  final String name;
  final String avatar;
  final String avatarUrl;
  final int totalPoints;
  final int rank;
  final bool isCurrentUser;
  final String badge;

  const LeaderboardUserModel({
    required this.id,
    required this.name,
    this.avatar = '',
    this.avatarUrl = '',
    this.totalPoints = 0,
    this.rank = 0,
    this.isCurrentUser = false,
    this.badge = '', required int points,
  });

  // Add getters for compatibility
  String get rankDisplay => rank.toString();
  bool get hasMedal => rank <= 3;
  int get xp => totalPoints;
  int get level => (totalPoints / 100).floor() + 1; // Simple level calculation
}
