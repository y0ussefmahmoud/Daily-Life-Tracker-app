import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/user_profile_model.dart';
import '../models/user_level_model.dart';
import '../providers/achievements_provider.dart';
import '../utils/error_handler.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfileModel? _profile;
  UserLevelModel? _userLevel;
  bool _isLoading = false;
  String? _error;
  String _userName = '';
  File? _userImage;
  DateTime _joinDate = DateTime.now();
  int _level = 1;
  int _points = 0;

  UserProfileModel? get profile => _profile;
  UserLevelModel? get userLevel => _userLevel;
  UserProfileModel? get userProfile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userName => _userName;
  File? get userImage => _userImage;
  DateTime get joinDate => _joinDate;
  int get level => _level;
  int get points => _points;

  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? '';
      _level = prefs.getInt('user_level') ?? 1;
      _points = prefs.getInt('user_points') ?? 0;
      
      final joinDateStr = prefs.getString('join_date');
      if (joinDateStr != null) {
        _joinDate = DateTime.parse(joinDateStr);
      }
      
      // TODO: Load user image from storage
      
      debugPrint('User data loaded: $_userName, level $_level, points $_points');
    } catch (e) {
      _error = handleAppError(e);
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      _userName = name;
      notifyListeners();
      debugPrint('User name updated: $name');
    } catch (e) {
      _error = handleAppError(e);
      notifyListeners();
    }
  }

  Future<void> updateUserImage(File? image) async {
    try {
      // TODO: Save image to storage
      _userImage = image;
      notifyListeners();
      debugPrint('User image updated');
    } catch (e) {
      _error = handleAppError(e);
      notifyListeners();
    }
  }

  Future<void> updateUserLevel(int level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_level', level);
      _level = level;
      notifyListeners();
      debugPrint('User level updated: $level');
    } catch (e) {
      _error = handleAppError(e);
      notifyListeners();
    }
  }

  Future<void> updateUserPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_points', points);
      _points = points;
      notifyListeners();
      debugPrint('User points updated: $points');
    } catch (e) {
      _error = handleAppError(e);
      notifyListeners();
    }
  }

  Future<void> loadProfile(BuildContext context, AchievementsProvider achievementsProvider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Create a simple profile without authentication
      _profile = UserProfileModel(
        id: 'user_001',
        name: _userName.isEmpty ? 'مستخدم التطبيق' : _userName,
        email: 'user@tracker.app',
      );
      
      // Load user level from achievements provider
      if (achievementsProvider.userLevel != null) {
        _userLevel = achievementsProvider.userLevel;
      }
    } catch (e) {
      _error = handleAppError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
