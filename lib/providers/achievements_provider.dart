import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import '../models/user_level_model.dart';
import '../models/leaderboard_user_model.dart';
import '../utils/constants.dart';
import '../services/achievements_service.dart';

class AchievementsProvider extends ChangeNotifier {
  final AchievementsService _achievementsService = AchievementsService();
  UserLevelModel? _userLevel;
  List<BadgeModel> _badges = [];
  List<LeaderboardUserModel> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserLevelModel? get userLevel => _userLevel;
  List<BadgeModel> get earnedBadges => _badges.where((badge) => badge.isEarned).toList();
  List<BadgeModel> get lockedBadges => _badges.where((badge) => !badge.isEarned).toList();
  List<BadgeModel> get allBadges => [...earnedBadges, ...lockedBadges];
  List<BadgeModel> get badges => _badges; // Add this for compatibility
  List<LeaderboardUserModel> get leaderboard => _leaderboard;
  int get earnedBadgeCount => earnedBadges.length;
  bool get isLoading => _isLoading;
  int get currentLevelPoints => _userLevel?.currentXP ?? 0;
  String? get error => _error;

  Future<void> loadAchievementsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load real data from AchievementsService
      _userLevel = await _achievementsService.fetchUserLevel();
      _badges = await _achievementsService.fetchUserBadges();
      _leaderboard = await _achievementsService.fetchLeaderboard();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading achievements data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> earnBadge(String badgeId) async {
    try {
      await _achievementsService.earnBadge(badgeId);
      
      final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
      if (badgeIndex != -1 && !_badges[badgeIndex].isEarned) {
        // Update local badge state
        _badges[badgeIndex] = _badges[badgeIndex].copyWith(
          isEarned: true,
          progress: 1.0,
          earnedDate: DateTime.now(),
        );

        // Add XP for earning badge
        await addXP(50);

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error earning badge: $e');
    }
  }

  Future<void> addXP(int amount) async {
    try {
      await _achievementsService.addXP(amount);
      await _achievementsService.checkBadgeProgress();
      
      // Refresh user level to get updated XP
      _userLevel = await _achievementsService.fetchUserLevel();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding XP: $e');
    }
  }

  Future<void> refreshLeaderboard() async {
    try {
      _leaderboard = await _achievementsService.fetchLeaderboard();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error refreshing leaderboard: $e');
    }
  }
}
