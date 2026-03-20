// ignore_for_file: unused_field

import 'package:flutter/foundation.dart';
import '../models/badge_model.dart';
import '../models/user_level_model.dart';
import '../services/local_database_service.dart';

class AchievementsProvider extends ChangeNotifier {
  final LocalDatabaseService _db = LocalDatabaseService();
  
  UserLevelModel? _userLevel;
  List<BadgeModel> _badges = [];
  bool _isLoading = false;
  String? _error;

  UserLevelModel? get userLevel => _userLevel;
  List<BadgeModel> get earnedBadges => _badges.where((badge) => badge.isEarned).toList();
  List<BadgeModel> get lockedBadges => _badges.where((badge) => !badge.isEarned).toList();
  List<BadgeModel> get allBadges => [...earnedBadges, ...lockedBadges];
  List<BadgeModel> get badges => _badges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAchievementsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize with default data
      _userLevel = const UserLevelModel(
        level: 1,
        title: 'مبتدئ',
        minPoints: 0,
        maxPoints: 100,
      );

      _badges = [
        BadgeModel(
          badge: 'first_task',
          title: 'أول مهمة',
          color: '#FF6B6B',
          iconUrl: '🎯',
          points: 10,
        ),
        BadgeModel(
          badge: 'week_streak',
          title: 'أسبوع متواصل',
          color: '#4ECDC4',
          iconUrl: '🔥',
          points: 50,
        ),
        BadgeModel(
          badge: 'bronze',
          title: 'برونزي',
          color: '#CD7F32',
          iconUrl: '🥉',
          points: 100,
        ),
      ];
    } catch (e) {
      _error = 'Failed to load achievements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    await loadAchievementsData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add missing methods for compatibility
  Future<void> addXP(int points) async {
    // Simple implementation - just notify listeners
    notifyListeners();
  }

  Future<void> refreshLeaderboard() async {
    // Simple implementation - just reload data
    await loadAchievementsData();
  }
}
