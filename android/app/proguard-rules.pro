# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# SharedPreferences
-keep class androidx.datastore.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.Metadata { *; }
