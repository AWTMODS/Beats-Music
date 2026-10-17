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

