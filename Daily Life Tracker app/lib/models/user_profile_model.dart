// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

/// Profile model including schema_version, XP, and level metrics.
/// Supports backward compatibility with safe defaults for schema migration.
class UserProfileModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? bio;
  final String? avatar;
  final int schemaVersion;
  final int totalXp;
  final int currentLevel;
  final int completedTasks;
  final int totalProjects;
  final int streakDays;
  final int badgeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.bio,
    this.avatar,
    this.schemaVersion = 1,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.completedTasks = 0,
    this.totalProjects = 0,
    this.streakDays = 0,
    this.badgeCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserProfileModel from a JSON map with safe fallbacks for null values.
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String?,
      avatar: map['avatar'] as String?,
      schemaVersion: map['schema_version'] as int? ?? 1,
      totalXp: map['total_xp'] as int? ?? 0,
      currentLevel: map['current_level'] as int? ?? 1,
      completedTasks: map['completed_tasks'] as int? ?? 0,
      totalProjects: map['total_projects'] as int? ?? 0,
      streakDays: map['streak_days'] as int? ?? 0,
      badgeCount: map['badge_count'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the UserProfileModel to a JSON map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'bio': bio,
      'avatar': avatar,
      'schema_version': schemaVersion,
      'total_xp': totalXp,
      'current_level': currentLevel,
      'completed_tasks': completedTasks,
      'total_projects': totalProjects,
      'streak_days': streakDays,
      'badge_count': badgeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of the UserProfileModel with updated fields.
  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? bio,
    String? avatar,
    int? schemaVersion,
    int? totalXp,
    int? currentLevel,
    int? completedTasks,
    int? totalProjects,
    int? streakDays,
    int? badgeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      completedTasks: completedTasks ?? this.completedTasks,
      totalProjects: totalProjects ?? this.totalProjects,
      streakDays: streakDays ?? this.streakDays,
      badgeCount: badgeCount ?? this.badgeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates XP required for the next level.
  int get xpToNextLevel {
    return currentLevel * 100;
  }

  /// Returns progress percentage to next level.
  double get levelProgress {
    final required = xpToNextLevel;
    if (required == 0) return 0.0;
    return (totalXp % required) / required;
  }
}
