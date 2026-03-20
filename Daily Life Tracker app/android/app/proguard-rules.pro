# ProGuard rules for Daily Life Tracker app - Samsung A55 Compatible

# Keep ALL annotations for reflection
-keepattributes *Annotation*

# Keep ALL attributes needed for serialization
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# Keep ALL Hive classes
-keep class io.hivedb.** { *; }
-keep class hive.** { *; }
-keep class io.hive.** { *; }
-dontwarn io.hivedb.**
-dontwarn hive.**
-dontwarn io.hive.**

# Keep ALL Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }

# Keep ALL application classes
-keep class com.dailylifetracker.app.** { *; }
-keep class daily_life_tracker.** { *; }

# Keep ALL model classes
-keep class com.dailylifetracker.app.models.** { *; }
-keep class daily_life_tracker.models.** { *; }

# Keep ALL provider classes
-keep class com.dailylifetracker.app.providers.** { *; }
-keep class daily_life_tracker.providers.** { *; }

# Keep ALL service classes
-keep class com.dailylifetracker.app.services.** { *; }
-keep class daily_life_tracker.services.** { *; }

# Keep ALL generated classes
-keep class **_g.** { *; }
-keep class **_$** { *; }
-keep class **_HiveAdapter { *; }
-keep class **HiveAdapter { *; }

# Keep ALL enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep ALL native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep ALL constructors
-keepclassmembers class * {
    <init>(...);
}

# Keep ALL fields and methods
-keepclassmembers class * {
    <fields>;
    <methods>;
}

# Keep file_picker classes (SAMSUNG FIX)
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.flutter.plugins.filepicker.** { *; }
-keep class file_picker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**
-dontwarn com.flutter.plugins.filepicker.**

# Keep Supabase classes
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }

# Keep connectivity classes
-keep class connectivity_plus.** { *; }

# Keep AndroidX classes
-keep class androidx.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class androidx.annotation.** { *; }

# Keep UUID and other essential classes
-keep class java.util.UUID { *; }
-keep class java.util.Date { *; }
-keep class java.time.** { *; }

# Keep serialization classes
-keep class java.io.** { *; }
-keep class java.nio.** { *; }

# Don't optimize any classes (SAMSUNG COMPATIBILITY)
-keep class ** { *; }

# Don't warn about missing classes
-dontwarn **
-ignorewarnings

# Samsung specific fixes
-keep class android.os.** { *; }
-keep class android.content.** { *; }
-keep class android.provider.** { *; }
-dontwarn android.os.**
-dontwarn android.content.**
-dontwarn android.provider.**
