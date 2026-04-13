## Flutter specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

## Flutter deferred components use Play Core split-install APIs at compile time,
## but they are not present at runtime unless you use dynamic delivery.
## Suppress R8 warnings about these missing references.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

## SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }

## Keep data classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
