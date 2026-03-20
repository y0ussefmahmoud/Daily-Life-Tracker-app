class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? bio;
  final String? avatar;
  final int completedTasks;
  final int totalProjects;
  final int streakDays;
  final int points;
  final int badgeCount;
  final String subtitle;
  final int currentLevel;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.avatar,
    this.completedTasks = 0,
    this.totalProjects = 0,
    this.streakDays = 0,
    this.points = 0,
    this.badgeCount = 0,
    this.subtitle = '',
    this.currentLevel = 1,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? avatar,
    int? completedTasks,
    int? totalProjects,
    int? streakDays,
    int? points,
    int? badgeCount,
    String? subtitle,
    int? currentLevel,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      completedTasks: completedTasks ?? this.completedTasks,
      totalProjects: totalProjects ?? this.totalProjects,
      streakDays: streakDays ?? this.streakDays,
      points: points ?? this.points,
      badgeCount: badgeCount ?? this.badgeCount,
      subtitle: subtitle ?? this.subtitle,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? 'user_001',
      name: json['name'] as String? ?? 'المستخدم',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String?,
      avatar: json['avatar'] as String?,
      completedTasks: json['completedTasks'] as int? ?? 0,
      totalProjects: json['totalProjects'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      badgeCount: json['badgeCount'] as int? ?? 0,
      subtitle: json['subtitle'] as String? ?? '',
      currentLevel: json['currentLevel'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'avatar': avatar,
      'completedTasks': completedTasks,
      'totalProjects': totalProjects,
      'streakDays': streakDays,
      'points': points,
      'badgeCount': badgeCount,
      'subtitle': subtitle,
      'currentLevel': currentLevel,
    };
  }
}
