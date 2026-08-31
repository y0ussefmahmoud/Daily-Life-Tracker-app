// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/foundation.dart';
import '../services/backup_service.dart';

/// Provider for managing backup and restore operations state.
/// Handles export/import operations and provides loading/error states to the UI.
class BackupProvider extends ChangeNotifier {
  final BackupService _backupService = BackupService();

  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastExportedData;
  String? _error;

  /// Whether an export operation is currently in progress.
  bool get isExporting => _isExporting;

  /// Whether an import operation is currently in progress.
  bool get isImporting => _isImporting;

  /// The last successfully exported JSON data.
  String? get lastExportedData => _lastExportedData;

  /// Current error message, if any operation failed.
  String? get error => _error;

  /// Exports all application data to JSON format.
  /// 
  /// Sets loading state during operation and updates lastExportedData on success.
  /// Sets error state if operation fails.
  /// 
  /// Throws [Exception] if export fails.
  Future<void> exportData() async {
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      final jsonData = await _backupService.exportData();
      _lastExportedData = jsonData;
      _isExporting = false;
      notifyListeners();
    } catch (e) {
      _isExporting = false;
      _error = 'Export failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Imports application data from JSON string.
  /// 
  /// Parameters:
  /// - jsonData: JSON string containing backup data
  /// 
  /// Sets loading state during operation and clears error on success.
  /// Sets error state if operation fails.
  /// 
  /// Throws [Exception] if import fails.
  Future<void> importData(String jsonData) async {
    _isImporting = true;
    _error = null;
    notifyListeners();

    try {
      await _backupService.importData(jsonData);
      _isImporting = false;
      _lastExportedData = null; // Clear cached export after import
      notifyListeners();
    } catch (e) {
      _isImporting = false;
      _error = 'Import failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Clears the current error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clears the last exported data from memory.
  void clearLastExport() {
    _lastExportedData = null;
    notifyListeners();
  }
}
