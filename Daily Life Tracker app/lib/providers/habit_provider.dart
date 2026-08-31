// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../repositories/habit_repository.dart';

/// Provider for managing habits and habit logs state.
/// Handles both regular habits and break habits with streak tracking.
class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  
  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _error;

  List<HabitModel> get habits => List.unmodifiable(_habits);
  List<HabitModel> get regularHabits => _habits.where((h) => !h.isBreakHabit).toList();
  List<HabitModel> get breakHabits => _habits.where((h) => h.isBreakHabit).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initializes the provider by loading all habits.
  Future<void> initialize() async {
    await loadHabits();
  }

  /// Loads all habits from the repository.
  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _repository.getAll();
    } catch (e) {
      _error = 'Failed to load habits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new habit.
  Future<void> addHabit(HabitModel habit) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdHabit = await _repository.create(habit);
      _habits.add(createdHabit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add habit: $e';
      notifyListeners();
    }
  }

  /// Updates an existing habit.
  Future<void> updateHabit(HabitModel habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      notifyListeners();

      try {
        await _repository.update(habit);
      } catch (e) {
        await loadHabits();
        _error = 'Failed to update habit: $e';
        notifyListeners();
      }
    }
  }

  /// Deletes a habit by ID.
  Future<void> deleteHabit(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    _habits.remove(habit);
    notifyListeners();

    try {
      await _repository.delete(habitId);
    } catch (e) {
      _habits.add(habit);
      _error = 'Failed to delete habit: $e';
      notifyListeners();
    }
  }

  /// Logs habit completion for a specific date.
  Future<void> logHabitCompletion(String habitId, DateTime date) async {
    try {
      await _repository.logHabitCompletion(habitId, date);
      await loadHabits();
    } catch (e) {
      _error = 'Failed to log habit completion: $e';
      notifyListeners();
    }
  }

  /// Clears the current error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
