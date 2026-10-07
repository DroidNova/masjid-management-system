# Flutter's own rules are added by the Flutter Gradle plugin.
# flutter_secure_storage uses Android Keystore / EncryptedSharedPreferences.
-keep class androidx.security.crypto.** { *; }
-dontwarn com.google.errorprone.annotations.**
