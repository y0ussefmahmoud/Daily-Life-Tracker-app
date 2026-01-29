import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/water_service.dart';

class WaterProvider extends ChangeNotifier {
  final WaterService _waterService = WaterService();

  int _currentIntakeMl = 0;
  int _goalMl = 2000;

  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  int get currentCups => (_currentIntakeMl / 250).floor();
  int get targetCups => (_goalMl / 250.0).ceil().toInt();
  int get currentIntakeMl => _currentIntakeMl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goalMl = await _waterService.getWaterGoal();
      _currentIntakeMl = await _waterService.getTodayWaterIntake();
    } on PostgrestException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'حدث خطأ غير متوقع';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCup() async {
    if (_currentIntakeMl >= _goalMl) {
      return;
    }

    final previousIntake = _currentIntakeMl;
    _currentIntakeMl += 250;
    _error = null;
    notifyListeners();

    try {
      await _waterService.logWaterIntake(250);
    } on PostgrestException catch (e) {
      _currentIntakeMl = previousIntake;
      _error = e.message;
    } catch (_) {
      _currentIntakeMl = previousIntake;
      _error = 'حدث خطأ غير متوقع';
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _error = null;
    notifyListeners();
  }

  double getProgress() {
    if (_goalMl <= 0) return 0.0;
    return _currentIntakeMl / _goalMl;
  }

  Future<void> refreshWaterData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goalMl = await _waterService.getWaterGoal();
      _currentIntakeMl = await _waterService.getTodayWaterIntake();
    } on PostgrestException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'حدث خطأ غير متوقع';
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
