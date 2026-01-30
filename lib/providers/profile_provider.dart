import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';
import '../providers/achievements_provider.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../utils/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService;
  final SupabaseClient _supabase;
  
  ProfileProvider({
    AuthService? authService,
    SupabaseClient? supabaseClient,
  }) : _authService = authService ?? AuthService(),
       _supabase = supabaseClient ?? SupabaseService.client;
  UserProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(AchievementsProvider achievementsProvider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _authService.currentUser;
      if (user == null) {
        _error = handleSupabaseError('User not authenticated');
        return;
      }

      // Get user name from metadata
      final userName = user.userMetadata?['name'] as String? ?? 'مستخدم';
      final userEmail = user.email ?? '';
      
      // Get badge count and points from achievements provider
      final badgeCount = achievementsProvider.earnedBadges.length;
      final points = achievementsProvider.userLevel?.totalXP ?? 0;
      
      // Calculate streak days from daily_stats
      final streakDays = await calculateStreakDays();

      _profile = UserProfileModel(
        id: user.id,
        name: userName,
        subtitle: userEmail,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        badgeCount: badgeCount,
        streakDays: streakDays,
        points: points,
      );
      // Ensure _error remains null on success
      _error = null;
    } catch (e) {
      _error = handleSupabaseError(e);
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? subtitle,
    String? avatarUrl,
  }) async {
    if (_profile == null) return;

    try {
      // Update user metadata in Supabase
      await _authService.updateProfile(
        userId: _profile?.id ?? '',
        updates: {
          if (name != null) 'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );

      // Update local state
      _profile = _profile?.copyWith(
        name: name,
        subtitle: subtitle,
        avatarUrl: avatarUrl,
      );
      // Ensure _error remains null on success
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = handleSupabaseError(e);
      debugPrint('Error updating profile: $e');
      notifyListeners();
    }
  }

  Future<int> calculateStreakDays() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        return 0;
      }

      // Get daily stats ordered by date descending
      final response = await _supabase
          .from('daily_stats')
          .select('date, completed_tasks_count')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(30); // Check last 30 days

      if (response is List && response.isNotEmpty) {
        int streakDays = 0;
        DateTime currentDate = DateTime.now();
        
        for (final stat in response) {
          final statDate = DateTime.parse(stat['date'] as String);
          final completedTasks = stat['completed_tasks_count'] as int? ?? 0;
          
          // Check if this date is consecutive and has completed tasks
          if (completedTasks > 0 &&
              (_isSameDay(statDate, currentDate) ||
                  _isPreviousDay(statDate, currentDate))) {
            streakDays++;
            currentDate = statDate.subtract(const Duration(days: 1));
          } else {
            break; // Streak broken
          }
        }
        
        return streakDays;
      }

      return 0;
    } on PostgrestException catch (e) {
      debugPrint('Error calculating streak days: $e');
      return 0;
    } catch (e) {
      debugPrint('Unexpected error calculating streak days: $e');
      return 0;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isPreviousDay(DateTime date1, DateTime date2) {
    final previousDay = date2.subtract(const Duration(days: 1));
    return _isSameDay(date1, previousDay);
  }
}
