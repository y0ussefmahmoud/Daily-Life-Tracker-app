import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';
import '../config/supabase_config.dart';
import '../utils/constants.dart';
import '../utils/app_exception.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static bool _initialized = false;
  static late final SupabaseClient _client;

  factory SupabaseService() {
    if (!_initialized) {
      throw Exception('SupabaseService not initialized. Call initialize() first.');
    }
    return _instance;
  }

  SupabaseService._internal();

  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('SupabaseService not initialized. Call initialize() first.');
    }
    return _client;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _client = Supabase.instance.client;
      _initialized = true;
    } on SocketException {
      throw AppException(AppStrings.errorNoInternet);
    } on TimeoutException {
      throw AppException(AppStrings.errorTimeout);
    } catch (e) {
      throw AppException('${AppStrings.errorDatabaseConnection}: ${e.toString()}');
    }
  }

  static Future<bool> checkConnection() async {
    try {
      final response = await _client.from('profiles').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
