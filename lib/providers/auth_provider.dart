import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  Stream<AuthState>? _authStateStream;
  
  AuthProvider({
    AuthService? authService,
    Stream<AuthState>? authStateStream,
  }) : _authService = authService ?? AuthService(),
       _authStateStream = authStateStream;
  
  bool _isLoading = false;
  String? _error;
  User? _user;
  Map<String, dynamic>? _userProfile;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the auth provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = _authService.currentUser;
      if (_user != null) {
        await _loadUserProfile();
      }
      _listenToAuthChanges();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToAuthChanges() {
    final authStream = _authStateStream ?? _authService.onAuthStateChange;
    authStream.listen((event) async {
      final session = event.session;
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        if (session?.user != null) {
          _user = session!.user;
          await _loadUserProfile();
        } else {
          _user = null;
          _userProfile = null;
        }
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      _userProfile = await _authService.getUserProfile();
    } catch (e) {
      _error = handleSupabaseError(e);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = handleSupabaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = handleSupabaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = handleSupabaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = handleSupabaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
    } catch (e) {
      _error = handleSupabaseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        userId: _user!.id,
        updates: updates,
      );
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = handleSupabaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = handleSupabaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
