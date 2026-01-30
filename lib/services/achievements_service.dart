import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/badge_model.dart';
import '../models/user_level_model.dart';
import '../models/leaderboard_user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

class AchievementsService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();

  Future<List<BadgeModel>> fetchUserBadges() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response is List) {
        return response
            .map((badge) => BadgeModel.fromJson(badge as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on PostgrestException catch (e) {
      debugPrint('Error fetching user badges: $e');
      return [];
    } catch (e) {
      debugPrint('Unexpected error fetching user badges: $e');
      return [];
    }
  }

  Future<UserLevelModel> fetchUserLevel() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return _getDefaultUserLevel();
      }

      final response = await _supabase
          .from('achievements')
          .select('total_xp')
          .eq('user_id', userId)
          .order('total_xp', ascending: false)
          .limit(1);

      if (response is List && response.isNotEmpty) {
        final totalXP = response.first['total_xp'] as num?;
        return _calculateUserLevel(totalXP?.toInt() ?? 0);
      }

      return _getDefaultUserLevel();
    } on PostgrestException catch (e) {
      debugPrint('Error fetching user level: $e');
      return _getDefaultUserLevel();
    } catch (e) {
      debugPrint('Unexpected error fetching user level: $e');
      return _getDefaultUserLevel();
    }
  }

  Future<void> updateBadgeProgress(String badgeId, double progress) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('achievements')
          .update({'progress': progress})
          .eq('user_id', userId)
          .eq('badge_id', badgeId);
    } on PostgrestException catch (e) {
      debugPrint('Error updating badge progress: $e');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error updating badge progress: $e');
      rethrow;
    }
  }

  Future<void> earnBadge(String badgeId) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('achievements')
          .update({
            'is_earned': true,
            'earned_date': DateTime.now().toIso8601String(),
            'progress': 1.0,
          })
          .eq('user_id', userId)
          .eq('badge_id', badgeId);
    } on PostgrestException catch (e) {
      debugPrint('Error earning badge: $e');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error earning badge: $e');
      rethrow;
    }
  }

  Future<void> addXP(int amount) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get current total XP
      final currentXPResponse = await _supabase
          .from('achievements')
          .select('total_xp')
          .eq('user_id', userId)
          .order('total_xp', ascending: false)
          .limit(1);

      int currentTotalXP = 0;
      final hasExistingRow = currentXPResponse is List && currentXPResponse.isNotEmpty;
      if (currentXPResponse is List && currentXPResponse.isNotEmpty) {
        final totalXP = currentXPResponse.first['total_xp'] as num?;
        currentTotalXP = totalXP?.toInt() ?? 0;
      }

      final newTotalXP = currentTotalXP + amount;

      if (!hasExistingRow) {
        await _supabase.from('achievements').upsert(
          {
            'user_id': userId,
            'badge_id': 'xp_total',
            'total_xp': newTotalXP,
            'current_xp': newTotalXP,
            'progress': 0.0,
            'is_earned': false,
            'created_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,badge_id',
        );
      } else {
        // Update all user achievements with new total XP
        await _supabase
            .from('achievements')
            .update({'total_xp': newTotalXP})
            .eq('user_id', userId);
      }
    } on PostgrestException catch (e) {
      debugPrint('Error adding XP: $e');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error adding XP: $e');
      rethrow;
    }
  }

  Future<List<LeaderboardUserModel>> fetchLeaderboard() async {
    try {
      final response = await _supabase
          .from('achievements')
          .select('''
            user_id,
            total_xp,
            auth!inner(
              user_metadata
            )
          ''')
          .neq('total_xp', 0)
          .order('total_xp', ascending: false)
          .limit(10);

      if (response is List) {
        final currentUserId = _authService.currentUser?.id;
        return response.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value as Map<String, dynamic>;
          final userId = data['user_id'] as String;
          final totalXP = data['total_xp'] as num?;
          final userMetadata = data['auth']?['user_metadata'] as Map<String, dynamic>? ?? {};
          final userName = userMetadata['name'] as String? ?? 'مستخدم';

          return LeaderboardUserModel(
            rank: index + 1,
            name: userId == currentUserId ? 'أنت' : userName,
            xp: totalXP?.toInt() ?? 0,
            isCurrentUser: userId == currentUserId,
            badge: index < 3 ? _getBadgeForRank(index + 1) : null,
          );
        }).toList();
      }

      return [];
    } on PostgrestException catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    } catch (e) {
      debugPrint('Unexpected error fetching leaderboard: $e');
      return [];
    }
  }

  Future<void> checkBadgeProgress() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return;
      }

      // This method would check conditions for each badge category
      // Implementation would depend on specific badge criteria
      // For now, this is a placeholder for the logic
      
      // Example: Check prayer badges
      await _checkPrayerBadges(userId);
      
      // Example: Check project badges  
      await _checkProjectBadges(userId);
      
      // Example: Check health badges
      await _checkHealthBadges(userId);
      
    } catch (e) {
      debugPrint('Error checking badge progress: $e');
    }
  }

  UserLevelModel _calculateUserLevel(int totalXP) {
    int currentLevel = 1;
    int xpForNextLevel = 600;
    int currentXP = totalXP;

    // Calculate level based on total XP
    while (currentXP >= xpForNextLevel) {
      currentXP = currentXP - xpForNextLevel;
      currentLevel++;
      xpForNextLevel = 600 + (currentLevel * 100);
    }

    // Determine level title
    String levelTitle;
    switch (currentLevel) {
      case 1:
      case 2:
        levelTitle = 'المبتدئ الطموح';
        break;
      case 3:
      case 4:
        levelTitle = 'المحارب الصاعد';
        break;
      case 5:
      case 6:
        levelTitle = 'المحارب المنضبط';
        break;
      case 7:
      case 8:
        levelTitle = 'القائد الملهم';
        break;
      case 9:
      case 10:
        levelTitle = 'الأسطورة';
        break;
      default:
        levelTitle = 'الخارق';
    }

    return UserLevelModel(
      currentLevel: currentLevel,
      levelTitle: levelTitle,
      currentXP: currentXP,
      xpForNextLevel: xpForNextLevel,
      totalXP: totalXP,
    );
  }

  UserLevelModel _getDefaultUserLevel() {
    return const UserLevelModel(
      currentLevel: 1,
      levelTitle: 'المبتدئ الطموح',
      currentXP: 0,
      xpForNextLevel: 600,
      totalXP: 0,
    );
  }

  String? _getBadgeForRank(int rank) {
    switch (rank) {
      case 1:
        return 'البطل';
      case 2:
        return 'المنافس';
      case 3:
        return 'المتميز';
      default:
        return null;
    }
  }

  Future<void> _checkPrayerBadges(String userId) async {
    // Implementation for checking prayer-related badges
    // This would query daily_stats or prayer tracking tables
  }

  Future<void> _checkProjectBadges(String userId) async {
    // Implementation for checking project-related badges
    // This would query projects table for completion stats
  }

  Future<void> _checkHealthBadges(String userId) async {
    // Implementation for checking health-related badges
    // This would query health tracking tables
  }
}
