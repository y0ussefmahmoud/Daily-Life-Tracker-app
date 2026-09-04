# Daily Life Tracker v2.4.2

A modern, comprehensive Flutter productivity and lifestyle tracking application built with a high-performance offline-first architecture, rich gamification system, and responsive bilingual UI (Arabic & English).

---

## Project Vision & Goals

**Daily Life Tracker** is designed to transform daily routine management into an engaging, structured, and consistent lifestyle. Rather than treating productivity as dry checklists, the application blends holistic personal tracking (tasks, software projects, religious commitments, physical workouts, nutrition, and hydration) with RPG-inspired gamification.

### Primary Objectives:
1. **Holistic Daily Organization**: Unify disparate aspects of daily life into one coherent dashboard:
   - Actionable time-categorized tasks and subtasks.
   - Long-term engineering/study projects with progress metrics and tech-stack management.
   - Spiritual routines (5 daily prayers with logging, daily Dhikr counters).
   - Health and fitness (hydration tracking, workout tracking, nutrition logging).
2. **Behavioral Gamification & Motivation**: Keep users consistent and engaged over the long term through:
   - Experience points (XP) awarded for task and habit completions.
   - Progressive user levels with dynamic titles and milestone roadmaps.
   - Badges and achievements commemorating streaks and productivity milestones.
3. **High Performance & Offline Reliability**:
   - Zero cloud dependency for core features using fast local NoSQL storage (Hive).
   - Single-flight initialization guards and memoized futures to eliminate duplicate database calls and main-thread blocking.
   - Impeller rendering optimization with widget rebuild minimization.
4. **Data Privacy & Full Portability**:
   - Full JSON-based export and import with robust schema versioning (`v2.4.x` compatibility validation) allowing seamless cross-device backups.
5. **Universal Accessibility**:
   - Native RTL support (Arabic first) and LTR (English), adaptive responsive layouts for phones and tablets, and system/custom dark mode.

---

## Tech Stack & Architecture

### Core Platform
- **Framework**: [Flutter](https://flutter.dev/) (SDK `^3.10.0`)
- **Language**: [Dart](https://dart.dev/) (Type-safe with sound null-safety)
- **Rendering Engine**: Impeller (Vulkan / Metal backend support)

### State Management & Architecture Pattern
- **State Management**: [Provider](https://pub.dev/packages/provider) (`^6.1.1`)
  - Decentralized provider pattern with targeted rebuild subscriptions (`Consumer`, `Selector`).
  - Separation of concerns across Models, Providers, Services, and Views.
  - Asynchronous single-flight guards (`_initFuture`) preventing redundant data fetching during app lifecycle changes.

### Local Persistence & Storage
- **Primary Database**: [Hive](https://pub.dev/packages/hive) (`^2.2.3`) & [Hive Flutter](https://pub.dev/packages/hive_flutter) (`^1.1.0`)
  - Lightweight, high-performance, disk-backed NoSQL key-value/object storage.
  - Custom Type Adapters (`WaterLogAdapter`) and structured JSON serialization for complex entities (`TaskModel`, `Project`, `SubtaskModel`).
  - Safe map cast patterns (`Map<String, dynamic>.from(...)`) guarding against Dart runtime map subtype exceptions.
- **Key-Value Preferences**: [Shared Preferences](https://pub.dev/packages/shared_preferences) (`^2.5.4`) for rapid flags and runtime settings.
- **File System**: [Path Provider](https://pub.dev/packages/path_provider) (`^2.1.3`) for document and database directory resolution.

### UI, Typography & Design System
- **Design System**: Material Design 3 (Material You) with custom adaptive styling.
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts) (`^8.0.2`) featuring **Tajawal** for Arabic/English typography.
- **Vector Graphics & Icons**:
  - Material Symbols Outlined & Cupertino Icons (`^1.0.8`).
  - [Flutter SVG](https://pub.dev/packages/flutter_svg) (`^2.0.9`) for resolution-independent vector rendering.
- **Progress Visualizations**: [Percent Indicator](https://pub.dev/packages/percent_indicator) (`^4.2.3`) for linear, circular, and custom progress tracking.
- **Responsive Layout**: Custom responsive breakpoints adapting grid columns, padding, and font sizes across device classes.

### Utilities & Native Integration
- **ID Generation**: [UUID](https://pub.dev/packages/uuid) (`^4.5.1`) for RFC4122 v4 unique identifier generation.
- **Internationalization**: [Intl](https://pub.dev/packages/intl) (`^0.20.2`) & `flutter_localizations` with full AR/EN localization dictionaries.
- **Network State**: [Connectivity Plus](https://pub.dev/packages/connectivity_plus) (`^7.0.0`).
- **Data Sharing**: [Share Plus](https://pub.dev/packages/share_plus) (`^12.0.1`) for exporting backups and reports.

### Build & Code Generation Tooling
- **Build Runner**: `build_runner` (`^2.4.13`)
- **Hive Generator**: `hive_generator` (`^2.0.1`)
- **JSON Serialization**: `json_annotation` (`^4.10.0`)
- **Code Quality**: `flutter_lints` (`^6.0.0`)

---

## Release Notes — v2.4.2 Highlights

- **Map Type Casting Hardening**: Resolved runtime subtype cast exceptions (`_Map<dynamic, dynamic>` to `Map<String, dynamic>`) across database initialization, version migration, and JSON backup/restore modules.
- **Performance & Rebuild Minimization**:
  - Added memoized Future guards across `LocalDatabaseService`, `TaskProvider`, `ProjectProvider`, and `WaterProvider` to prevent duplicated disk I/O.
  - Converted home feature cards (`الصلوات`, `الأذكار`, `الجيم`, `الأكل`) into standalone `StatelessWidget` instances with `const` constructors to decouple them from frequent provider notification cycles.
  - Refactored cold-start provider loading to execute concurrently via `Future.wait`.
- **Samsung A55 Compatibility**: Cleaned up heavy main-thread I/O logging and updated ProGuard rules for modern Android 14 (API 34) Vulkan / Impeller rendering.

---

## Features Breakdown

### 1. Task Management
- Hierarchical task structuring with subtasks.
- Time categorization: *Today*, *Next Week*, *Someday*.
- Priority categorization: *Low*, *Medium*, *High*, *Urgent*.
- Due date, reminder timestamps, and repeating task intervals.
- Automatic XP rewards upon task completion.

### 2. Software & Study Projects
- Comprehensive project tracking (Active, Paused, Completed).
- Tech-stack tagging and weekly hour allocations.
- Real-time overall productivity progress percentage.
- Task association with individual project milestones.

### 3. Spiritual & Lifestyle Modules
- **Prayers Tracker**: Interactive daily prayer check (Fajr, Dhuhr, Asr, Maghrib, Isha) with historical logging.
- **Dhikr Counter**: Digital tasbih counters with customizable targets and reset options.
- **Hydration Tracker**: Quick-add water intake (in ml), custom daily goals, target cups calculation, and history.
- **Gym & Workouts**: Exercise tracking with weight, sets, and reps logs.
- **Nutrition**: Meal tracking and dietary logs.

### 4. Gamification & Progression
- **Experience Points (XP)**: Earned through verified accomplishments.
- **User Levels & Ranks**: Level progression calculation with titles ranging from beginner to master.
- **Milestone Badges**: Unlocked based on sustained streaks and volume of completed projects and habits.

### 5. Data Backup & Restore
- Full offline export of user profiles, tasks, subtasks, projects, and settings to an indented, portable JSON file.
- Automatic schema validation ensuring backward and forward compatibility for `2.x.x` versions.
- Safe transactional import routine clearing existing tables and rebuilding the store cleanly.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, MultiProvider configuration, and theme initialization
├── constants/
│   └── app_colors.dart               # Theme color palette (primary, background, accents)
├── core/
│   └── database/
│       ├── db_tables.dart            # Database table and column constants
│       └── db_versions.dart          # Database schema versioning & migration logic
├── models/                            # Data models with fromMap/toMap serialization
│   ├── task_model.dart               # Task entity with priority and time categories
│   ├── project_model.dart            # Project entity with tech stack and status
│   ├── subtask_model.dart            # Subtask breakdown entity
│   ├── habit_model.dart              # Habit tracking model
│   ├── habit_log_model.dart          # Daily habit logs
│   ├── water_log_model.dart          # Water intake log model (Hive Adapter)
│   ├── prayer_log.dart               # Prayer status model
│   ├── user_profile_model.dart       # User profile details
│   ├── user_level_model.dart         # Level and XP calculation model
│   ├── badge_model.dart              # Achievement badges
│   ├── stats_model.dart              # Summary metrics
│   ├── report_model.dart             # Productivity reports
│   ├── activity_log_model.dart       # Chronological activity timeline
│   ├── leaderboard_user_model.dart   # Leaderboard rank representation
│   └── settings_model.dart           # App configuration state model
├── providers/                         # State management (ChangeNotifiers)
│   ├── task_provider.dart            # Task state, filtering, and XP triggering
│   ├── project_provider.dart         # Project lifecycle & progress state
│   ├── subtask_provider.dart         # Subtask manipulation
│   ├── habit_provider.dart           # Habit streak calculations
│   ├── water_provider.dart           # Water intake & goal calculations
│   ├── prayer_provider.dart          # Daily prayer logging
│   ├── profile_provider.dart         # User profile and stats state
│   ├── achievements_provider.dart    # XP distribution and badge unlocking
│   ├── stats_provider.dart           # Weekly analytics calculations
│   ├── settings_provider.dart        # Theme, locale, and notification options
│   └── backup_provider.dart          # Export and import state handler
├── repositories/                      # Repository pattern interfaces
│   ├── base_repository.dart
│   ├── habit_repository.dart
│   ├── task_repository.dart
│   └── activity_repository.dart
├── services/                          # Low-level service and database abstraction
│   ├── local_database_service.dart   # Central Hive storage and single-flight init guard
│   ├── hive_adapters.dart            # Hive type adapter registry
│   ├── backup_service.dart           # JSON export/import data processor
│   ├── backup_json_converters.dart   # Entity-to-backup JSON converters
│   ├── backup_validators.dart        # Backup schema validator
│   ├── water_service.dart            # Local water intake data access
│   └── localization_service.dart     # Dynamic string translations helper
├── screens/                           # Top-level UI views
│   ├── home_screen.dart              # Primary dashboard with summary & feature cards
│   ├── tasks_screen.dart             # Complete task management screen
│   ├── projects_screen.dart          # Project portfolio screen
│   ├── water_screen.dart             # Dedicated hydration tracker
│   ├── prayer_screen.dart            # Prayer tracking & schedule
│   ├── profile_screen.dart           # Profile, stats, and leveling overview
│   ├── achievements_screen.dart      # Badges and achievement roadmap
│   ├── dhikr_screen.dart             # Digital tasbih & dhikr counter
│   ├── food_screen.dart              # Nutrition & meal tracking
│   └── gym_screen.dart               # Workout and physical exercise tracker
├── widgets/                           # Modular reusable components
│   ├── backup_restore_card.dart      # Backup controls card
│   ├── category_chip.dart            # Category filter chips
│   ├── project_card.dart             # Project item card with progress bar
│   ├── task_item.dart                # Interactive task checkbox tile
│   ├── water_tracker.dart            # Quick water increment widget
│   └── ...                           # Progress indicators, charts, pickers
└── utils/                             # Helpers and cross-cutting concerns
    ├── constants.dart                # App-wide global constants
    ├── responsive_breakpoints.dart   # Screen dimension & grid adaptation
    ├── error_handler.dart            # Centralized exception logging
    └── app_exception.dart            # Domain-specific application errors
```

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.10.0`
- **Dart SDK**: `>= 3.0.0`
- **Android SDK**: `compileSdkVersion 34`, `minSdkVersion 21`, `targetSdkVersion 34`
- **Java**: JDK 17 recommended for Gradle 8+

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/daily-life-tracker.git
   cd daily-life-tracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run code generator** (if rebuilding adapters or models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app in debug mode**:
   ```bash
   flutter run
   ```

---

## Build & Deployment

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split-per-ABI APK (Recommended for Distribution)
Significantly reduces binary download size (~20–30 MB per architecture instead of ~60 MB universal):
```bash
flutter build apk --split-per-abi --release
```
Outputs:
- `app-arm64-v8a-release.apk` (Most modern Android phones)
- `app-armeabi-v7a-release.apk` (Older 32-bit devices)
- `app-x86_64-release.apk` (Emulators & Intel Chromebooks)

### Android App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Developer & Copyright

- **Lead Engineer**: Eng. Youssef Mahmoud Abdelgawad (م / يوسف محمود عبد الجواد)
- **Official Website**: [https://y0ussef.com/](https://y0ussef.com/)
- **WhatsApp Support**: [+201017646543](https://wa.me/Y0ussefmahmoud)
- **Direct Email**: [info@Youssef.com](mailto:info@Youssef.com)

---

## License

This project is proprietary software developed by Eng. Youssef Mahmoud Abdelgawad. All rights reserved. Unauthorized reproduction, modification, distribution, or commercial exploitation is strictly prohibited without explicit written consent.
