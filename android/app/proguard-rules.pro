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

## flutter_local_notifications — Gson TypeToken fix
## R8/ProGuard strips generic type signatures by default, which breaks Gson's
## TypeToken (used by flutter_local_notifications to persist scheduled
## notifications). This causes:
##   IllegalStateException: TypeToken must be created with a type argument
## on ANY call to the notifications plugin in a release/minified build.
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
## Preserve generic signatures of ALL classes so Gson TypeToken can read them
-keepattributes Signature
-keepattributes *Annotation*
