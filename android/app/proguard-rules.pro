## Flutter specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

## SQLite / sqflite
-keep class com.tekartik.sqflite.** { *; }

## Keep data classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
