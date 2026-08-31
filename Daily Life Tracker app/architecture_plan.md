# Daily Life Tracker - Architecture & Development Plan v2.4.0

## Overview
This document outlines the refactoring, feature enhancements, database backward-compatibility strategy, and modular code architecture standards for the Daily Life Tracker Flutter application.

---

## 1. Core Life Tracking Logic & Structure

The tracking logic is structured into four primary modules:

### A. Daily Habits & Routines (Habits Engine)
- Track mandatory daily routines (e.g., Prayers/Salah, Daily Athkar, Exercise, Reading).
- Maintain consecutive day streaks (`current_streak`, `best_streak`).
- Support daily check-ins with date-stamped completion records.

### B. Habit Cessation (Break Habits Engine)
- Track behaviors targeted for elimination/quit milestones.
- Record start timestamp (`quit_date`) and track elapsed time in days/hours.
- Log relapse events while maintaining historical quit attempts.

### C. Task Management (To-Do System)
- Support actionable tasks with categorization: Today, Next Week, Future/Someday.
- Include priority levels (`low`, `medium`, `high`, `urgent`) and due dates.
- Maintain completion status, completion timestamp, and soft deletion flags.

### D. Activity & Time Logging (Activity Tracker)
- Log dedicated durations for focus sessions, work, sports, and studies.
- Store duration metrics in minutes, timestamps, and associated project/category IDs.
- Aggregate daily/weekly metrics for Gamification (XP engine).

---

## 2. Database Compatibility & Migration Strategy (Supabase)

To guarantee seamless backward compatibility for existing users receiving updates:

### Principles
- **Non-Destructive Updates**: Never drop, rename, or alter data types of existing columns in Supabase tables.
- **Safe Defaults**: All newly introduced columns must define safe `DEFAULT` values or be `NULLable`.
- **Version Tracking**: Include a `schema_version` attribute in the user settings table to handle lightweight client-side migrations dynamically.

### Schema Blueprint (Supabase Tables)

```sql
-- User Profile & Gamification (Extended safely)
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS schema_version INT DEFAULT 1,
ADD COLUMN IF NOT EXISTS total_xp INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS current_level INT DEFAULT 1;

-- Habits Table
CREATE TABLE IF NOT EXISTS public.habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    frequency TEXT DEFAULT 'daily',
    is_break_habit BOOLEAN DEFAULT FALSE,
    quit_date TIMESTAMP WITH TIME ZONE,
    current_streak INT DEFAULT 0,
    best_streak INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habit Logs Table
CREATE TABLE IF NOT EXISTS public.habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    completed_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(habit_id, completed_at)
);

-- Tasks Table
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    category TEXT DEFAULT 'general',
    priority TEXT DEFAULT 'medium',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Logs Table
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_name TEXT NOT NULL,
    category TEXT DEFAULT 'general',
    duration_minutes INT NOT NULL DEFAULT 0,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 3. Local Backup & Restore System

### Export Architecture (JSON Format)
- Generate a standalone JSON file containing user configuration, habits, logs, tasks, and activity records.
- Format structure:
```json
{
  "version": "2.4.0",
  "exported_at": "2026-08-31T10:30:00Z",
  "user_id": "uuid-v4-string",
  "data": {
    "profile": {},
    "habits": [],
    "habit_logs": [],
    "tasks": [],
    "activity_logs": []
  }
}
```

### Import / Restore Architecture
- Read JSON payload and validate schema version compatibility.
- Execute batch `upsert` operations on Supabase using conflict resolution on primary keys (`id`).
- Fallback local cache mechanism using Hive/SharedPreferences if offline.

---

## 4. Codebase Architecture & Maintenance Guidelines

To ensure high maintainability, small file sizes, and easy handover for future engineers:

### Development Rules
1. **Single Responsibility Principle (SRP)**: Each file must contain only one class or a small set of tightly coupled functions. File size target: under 200 lines per file.
2. **Modular Directory Structure**:
   - `lib/core/` (constants, themes, helpers, database contracts)
   - `lib/models/` (Data transfer objects and serialization)
   - `lib/providers/` (State management split per domain: `habit_provider.dart`, `task_provider.dart`, `backup_provider.dart`)
   - `lib/repositories/` (Supabase API abstraction layer)
   - `lib/screens/` (View containers)
   - `lib/widgets/` (Small reusable UI component widgets)
3. **Documentation Standard**:
   - Write all code comments strictly in clean, technical English.
   - Prohibit emojis in code comments, class headers, and documentation blocks.
   - Explain function intents, parameters, return types, and side effects clearly.
4. **Error Handling**: Wrap all remote database transactions in explicit `try-catch` blocks with custom app exceptions.

---

## 5. Implementation Roadmap

1. **Phase 1**: Setup Backup & Restore Service (`backup_service.dart` & `backup_provider.dart`).
2. **Phase 2**: Refactor Database Schema contracts & repositories for backward compatibility.
3. **Phase 3**: Refactor Tasks and Habits domain models into small, isolated files.
4. **Phase 4**: Implement UI for Manual Backup/Restore in Settings screen.
