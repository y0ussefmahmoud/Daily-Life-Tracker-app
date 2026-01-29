import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService.client;

  // Get current user session
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (name != null) 'name': name,
      },
    );
    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    
    return response;
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', userId);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
