# ProGuard rules for Daily Life Tracker app

# Keep annotations for reflection
-keepattributes *Annotation*

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep Supabase classes
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }

# Keep JSON serialization classes
-keep class com.google.gson.** { *; }
-keep class com.fasterxml.jackson.** { *; }

# Keep model classes
-keep class com.yourdomain.dailylifetracker.models.** { *; }

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Provider classes
-keep class provider.** { *; }

# Keep Google Fonts
-keep class com.google.fonts.** { *; }

# Keep connectivity classes
-keep class connectivity_plus.** { *; }

# Keep build_runner generated classes
-keep class **_g.** { *; }
-keep class **_$** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
    *** get*();
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Keep serialization
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Keep Retrofit and networking classes if used
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }

# Keep any custom application class
-keep class com.yourdomain.dailylifetracker.Application { *; }
