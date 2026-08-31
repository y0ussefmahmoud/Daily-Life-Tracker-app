# Daily Life Tracker v2.4.0

A comprehensive Flutter application for daily life tracking with task management, projects, and statistics.

## Overview

Daily Life Tracker is a comprehensive application designed to help users organize their daily lives through:
- Task and Project Management - Advanced tracking and management system
- Level System - Experience points (XP), levels, and progression roadmap
- Integrated Profile - Edit name, avatar, and settings
- Statistics and Achievements Tracking - Detailed performance analysis
- Badge and Motivation System - Rewards and achievements
- Advanced Settings - Dark mode, language, notifications
- Professional Arabic User Interface - Modern and easy-to-use design

## Application Goals

The primary goals of Daily Life Tracker are:

1. Productivity Enhancement - Help users manage their daily tasks and projects efficiently through organized tracking and categorization
2. Gamification - Motivate users through experience points, levels, badges, and achievement systems to maintain consistency
3. Data Organization - Provide structured storage for tasks, projects, habits, water intake, prayers, and other daily activities
4. Progress Tracking - Enable users to monitor their progress through detailed statistics, charts, and performance metrics
5. User Engagement - Maintain user interest through interactive features, rewards, and personalized experiences
6. Data Portability - Allow users to backup and restore their data for seamless transitions between devices
7. Offline Capability - Ensure core functionality works without internet connection using local storage

## Tech Stack

### Core Framework
- Flutter SDK (3.10.0+)
- Dart programming language

### State Management
- Provider (6.1.1+) - State management solution

### Local Storage
- Hive (2.2.3+) - Local NoSQL database
- Hive Flutter (1.1.0+) - Flutter integration for Hive
- Path Provider (2.1.3+) - File system access
- Shared Preferences (2.5.4+) - Key-value storage

### UI Components
- Google Fonts (8.0.2+) - Custom typography
- Cupertino Icons (1.0.8+) - iOS-style icons
- Material Design - Built-in Flutter UI components
- Percent Indicator (4.2.3+) - Progress indicators
- Flutter SVG (2.0.9+) - SVG rendering

### Utilities
- UUID (4.5.1+) - Unique identifier generation
- Intl (0.20.2+) - Internationalization and date formatting
- Connectivity Plus (7.0.0+) - Network connectivity monitoring
- Share Plus (12.0.1+) - File sharing functionality

### Code Generation
- Build Runner (2.4.13+) - Code generation tool
- Hive Generator (2.0.1+) - Hive adapter code generation
- JSON Annotation (4.10.0+) - JSON serialization annotations

### Development Tools
- Flutter Test - Built-in testing framework
- Mockito (5.4.4+) - Mocking framework for unit tests
- Flutter Lints (6.0.0+) - Code quality and style analysis

### App Configuration
- Flutter Launcher Icons (0.14.1+) - App icon generation
- Flutter Native Splash (2.4.1+) - Splash screen configuration

### Localization
- Flutter Localizations - Built-in localization support

## Features

### Task Management
- Create, edit, and delete tasks
- Task categorization with icons
- Priority levels (low, medium, high, urgent)
- Time categories (today, tomorrow, this week, later)
- Due date and reminder settings
- Task completion tracking
- Subtask support for complex tasks

### Project Management
- Create and manage projects
- Project status tracking (active, paused, completed, in progress)
- Project progress visualization
- Project-specific task organization
- Time tracking for projects

### Habit Tracking
- Daily habit logging
- Streak tracking
- Break habit support (quit tracking)
- Habit categories
- Completion history

### Water Intake Tracking
- Daily water logging
- Customizable daily goals
- Progress visualization
- Intake history

### Prayer Tracking
- Five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
- Prayer completion logging
- Prayer history tracking

### Gamification System
- Experience points (XP) for completing tasks
- Level progression system
- Level roadmap with milestones
- Badge system for achievements
- Leaderboard functionality
- User profile with stats

### Statistics and Analytics
- Weekly progress charts
- Task completion rates
- Time distribution analysis
- Daily summary cards
- Monthly progress tracking

### Profile Management
- User profile customization
- Avatar management
- Profile statistics display
- Level and XP visualization
- Achievement showcase

### Settings
- Dark mode toggle
- Theme color customization
- Language settings
- Notification preferences
- Sound settings
- Backup and restore functionality

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── constants/
│   └── app_colors.dart      # Application color constants
├── core/
│   └── database/
│       ├── db_tables.dart   # Database table definitions
│       └── db_versions.dart # Database version management
├── models/                   # Data models
│   ├── task_model.dart
│   ├── project_model.dart
│   ├── subtask_model.dart
│   ├── habit_model.dart
│   ├── habit_log_model.dart
│   ├── water_log_model.dart
│   ├── prayer_log.dart
│   ├── user_profile_model.dart
│   ├── user_level_model.dart
│   ├── badge_model.dart
│   ├── stats_model.dart
│   ├── report_model.dart
│   ├── activity_log_model.dart
│   ├── leaderboard_user_model.dart
│   └── settings_model.dart
├── providers/                # State management
│   ├── task_provider.dart
│   ├── project_provider.dart
│   ├── projects_provider.dart
│   ├── subtask_provider.dart
│   ├── habit_provider.dart
│   ├── water_provider.dart
│   ├── prayer_provider.dart
│   ├── profile_provider.dart
│   ├── achievements_provider.dart
│   ├── stats_provider.dart
│   ├── settings_provider.dart
│   └── backup_provider.dart
├── repositories/             # Data access layer
│   ├── base_repository.dart
│   └── habit_repository.dart
├── services/                 # Business logic
│   ├── local_database_service.dart
│   ├── hive_adapters.dart
│   ├── backup_service.dart
│   ├── backup_json_converters.dart
│   ├── backup_validators.dart
│   └── water_service.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── projects_screen.dart
│   ├── projects_manager_screen.dart
│   ├── water_screen.dart
│   ├── prayer_screen.dart
│   ├── profile_screen.dart
│   ├── achievements_screen.dart
│   ├── dhikr_screen.dart
│   ├── food_screen.dart
│   ├── gym_screen.dart
│   └── simple_home_screen.dart
├── widgets/                  # Reusable UI components
│   ├── widgets.dart          # Widget exports
│   ├── backup_restore_card.dart
│   ├── category_chip.dart
│   ├── project_card.dart
│   ├── task_item.dart
│   ├── water_tracker.dart
│   ├── custom_checkbox.dart
│   ├── custom_circular_progress.dart
│   ├── custom_bottom_navigation.dart
│   ├── section_header.dart
│   ├── profile_header.dart
│   ├── progress_bar_widget.dart
│   ├── task_section.dart
│   ├── daily_summary_card.dart
│   ├── skeleton_loader.dart
│   ├── achievement_item.dart
│   ├── add_subtask_dialog.dart
│   ├── conic_progress_indicator.dart
│   ├── date_picker_field.dart
│   ├── ios_toggle.dart
│   ├── level_hero_card.dart
│   ├── monthly_progress_widget.dart
│   ├── paused_project_card.dart
│   ├── profile_stats_card.dart
│   ├── settings_list_item.dart
│   ├── tech_stack_input.dart
│   ├── time_distribution_item.dart
│   ├── time_picker_field.dart
│   └── weekly_chart.dart
└── utils/                    # Utility functions
    ├── constants.dart
    ├── error_handler.dart
    └── app_exception.dart

android/
├── app/
│   ├── build.gradle.kts       # Build configuration
│   ├── proguard-rules.pro     # ProGuard rules
│   └── src/main/
│       ├── AndroidManifest.xml
│       └── res/
└── ...

assets/
├── fonts/                     # Custom fonts
│   └── MaterialSymbolsOutlined.ttf
└── images/                    # Image assets
```

## Installation

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Android SDK (minSdk 21, targetSdk 34)
- Android device or emulator for testing

### Setup Steps

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd daily-life-tracker
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the application
   ```bash
   flutter run
   ```

## Building APK

### Debug APK
```bash
flutter build apk --debug
```
- Location: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: Larger, includes debugging symbols
- Usage: Development and testing only

### Release APK
```bash
flutter build apk --release
```
- Location: `build/app/outputs/flutter-apk/app-release.apk`
- Size: Smaller, optimized for performance
- Features: Uses ProGuard for size reduction and performance optimization

### Split APKs (by Architecture)
```bash
flutter build apk --split-per-abi
```
- Results: Separate files for each architecture:
  - `app-arm64-v8a-release.apk`
  - `app-armeabi-v7a-release.apk`
  - `app-x86_64-release.apk`
- Benefit: Smaller size per file (~20-30 MB instead of ~50-60 MB)

## App Configuration

### Android Requirements
- Minimum Android: API 21 (Android 5.0)
- Target Android: API 34 (Android 14)
- App Size: ~50MB (Release APK)
- Language Support: Arabic and English
- Screen Orientation: Portrait & Landscape

### Permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Testing

### Pre-Testing Checklist
- Verify internet connection
- Check local database initialization
- Enable required permissions (Internet, Network State)

### Test List
- Task creation, editing, and deletion
- Project management
- Habit tracking
- Water intake logging
- Prayer tracking
- Profile customization
- Statistics viewing
- Settings modifications
- Backup and restore functionality

## Troubleshooting

### Database Issues
```bash
# Clear and rebuild
flutter clean
flutter pub get
flutter run
```

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter doctor
```

### APK Size Optimization
- Use `--split-per-abi` for building
- Review unused assets
- Analyze size: `flutter build apk --release --analyze-size`

## Developer Information

### Developer
- Arabic: م / يوسف محمود عبد الجواد
- English: Eng / Youssef Mahmoud Abdelgawad
- Business Website: https://y0ussef.com/
- Whatsapp: https://wa.me/Y0ussefmahmoud
- Email: info@Youssef.com

## License

This project is proprietary software. All rights reserved.

## Support

For any inquiries or issues, please contact:
- Email: info@Youssef.com
- Website: https://y0ussef.com/
- Whatsapp: https://wa.me/Y0ussefmahmoud
