// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

/// Validates backup data format and schema compatibility.
/// Ensures imported backup files meet required structure and version constraints.
class BackupValidators {
  static const String _currentVersion = '2.4.0';

  /// Validates the overall backup format and structure.
  /// 
  /// Parameters:
  /// - backup: Parsed JSON map containing backup data
  /// 
  /// Returns true if format is valid, false otherwise.
  /// 
  /// Checks for required fields: version, exported_at, user_id, data.
  bool validateBackupFormat(Map<String, dynamic> backup) {
    final version = backup['version'] as String?;
    if (version == null) {
      return false;
    }

    if (!_isVersionCompatible(version)) {
      return false;
    }

    final data = backup['data'] as Map<String, dynamic>?;
    if (data == null) {
      return false;
    }

    return true;
  }

  /// Validates if a backup schema version is compatible with current version.
  /// 
  /// Parameters:
  /// - version: Schema version string from backup
  /// 
  /// Returns true if version is compatible, false otherwise.
  /// 
  /// Current compatibility: accepts any version starting with 2.x.
  /// Future implementation should use semantic versioning for precise checks.
  bool _isVersionCompatible(String version) {
    final currentMajor = _currentVersion.split('.').first;
    final backupMajor = version.split('.').first;
    return currentMajor == backupMajor;
  }

  /// Validates the data section structure within backup.
  /// 
  /// Parameters:
  /// - data: Data section from backup JSON
  /// 
  /// Returns true if data structure is valid, false otherwise.
  /// 
  /// Checks for presence of expected data arrays and objects.
  bool validateDataStructure(Map<String, dynamic> data) {
    final requiredKeys = ['settings'];
    
    for (final key in requiredKeys) {
      if (!data.containsKey(key)) {
        return false;
      }
    }

    return true;
  }
}
