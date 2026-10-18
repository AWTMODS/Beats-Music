# ============================================================
# GSON – Preserve generic signatures (fixes flutter_local_notifications
# TypeToken crash when R8 full mode is active)
# See: https://github.com/google/gson/blob/main/examples/android-proguard-example/proguard.cfg
# ============================================================
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-dontwarn com.google.gson.**

# flutter_local_notifications – keep scheduled notification model classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# ============================================================
# MediaKit (libmpv native player)
# ============================================================
-keep class com.alexmercerind.mediakit.** { *; }
-dontwarn com.alexmercerind.mediakit.**

# ============================================================
# AudioService (Android AudioService / MediaBrowserService / MediaSession)
# ============================================================
-keep class com.ryanheise.audioservice.** { *; }
-dontwarn com.ryanheise.audioservice.**

# ============================================================
# Isar Core Database (JNI / Native bindings)
# ============================================================
-keep class dev.isar.** { *; }
-dontwarn dev.isar.**

# ============================================================
# Native JNI Methods & Rust FFI
# ============================================================
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class com.beats.app.rust.** { *; }
-dontwarn com.beats.app.rust.**

# ============================================================
# Flutter Engine & Plugins (Pigeon & Platform Channels)
# ============================================================
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ============================================================
# Kotlin Coroutines
# ============================================================
-keepnames class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ============================================================
# Google Play Core (optional deferred components referenced by Flutter embedding)
# ============================================================
-dontwarn com.google.android.play.core.**
