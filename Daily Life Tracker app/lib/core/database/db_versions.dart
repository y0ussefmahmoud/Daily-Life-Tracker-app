/**
 * Developed by:
 * - Arabic: م / يوسف محمود عبد الجواد
 * - English: Eng / Youssef Mahmoud Abdelgawad
 * - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
 * - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
 * - Email: info@Youssef.com
 */

/// Database schema versioning constants and migration support.
/// Defines current schema version and provides safe default values for backward compatibility.
class DbVersions {
  /// Current database schema version.
  static const int currentSchemaVersion = 1;

  /// Minimum supported schema version for backward compatibility.
  static const int minSupportedVersion = 1;

  /// Safe default values for new columns added in schema updates.
  /// These defaults ensure existing users can continue using the app without data loss.
  static const Map<String, dynamic> safeDefaults = {
    'schema_version': 1,
    'total_xp': 0,
    'current_level': 1,
    'frequency': 'daily',
    'is_break_habit': false,
    'current_streak': 0,
    'best_streak': 0,
    'priority': 'medium',
    'duration_minutes': 0,
  };

  /// Checks if a given schema version is compatible with current version.
  /// 
  /// Parameters:
  /// - version: Schema version to check
  /// 
  /// Returns true if version is within supported range, false otherwise.
  static bool isVersionCompatible(int version) {
    return version >= minSupportedVersion && version <= currentSchemaVersion;
  }

  /// Gets safe default value for a specific column.
  /// 
  /// Parameters:
  /// - columnName: Name of the column
  /// 
  /// Returns default value if column exists in safeDefaults, null otherwise.
  static dynamic getSafeDefault(String columnName) {
    return safeDefaults[columnName];
  }

  /// Returns all safe default column names.
  static List<String> getSafeDefaultColumns() {
    return safeDefaults.keys.toList();
  }
}
