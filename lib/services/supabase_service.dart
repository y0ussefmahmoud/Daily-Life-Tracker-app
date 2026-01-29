import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'dart:async';
import '../config/supabase_config.dart';
import '../utils/constants.dart';
import '../utils/app_exception.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static bool _initialized = false;
  static late final SupabaseClient _client;
  static final Connectivity _connectivity = Connectivity();
  static StreamController<bool>? _connectivityController;

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
      // Check internet connection first
      final hasConnection = await checkInternetConnection();
      if (!hasConnection) {
        throw AppException(AppStrings.errorNoInternet);
      }
      
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _client = Supabase.instance.client;
      _initialized = true;
      
      // Start listening to connectivity changes
      _startConnectivityListener();
    } on SocketException {
      throw AppException(AppStrings.errorNoInternet);
    } on TimeoutException {
      throw AppException(AppStrings.errorTimeout);
    } catch (e) {
      throw AppException('${AppStrings.errorDatabaseConnection}: ${e.toString()}');
    }
  }

  static Future<bool> checkInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isOnline() async {
    return await checkInternetConnection();
  }

  static Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  static void _startConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      _connectivityController?.add(isOnline);
    });
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
