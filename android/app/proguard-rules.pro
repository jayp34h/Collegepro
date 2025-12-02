# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep speech_to_text plugin classes (updated for v7.0.0)
-keep class com.csdcorp.speech_to_text.** { *; }
-keep class io.flutter.plugins.speech.** { *; }
-dontwarn com.csdcorp.speech_to_text.**
-dontwarn io.flutter.plugins.speech.**

# Keep Flutter embedding classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Flutter Secure Storage classes
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Keep Google Sign In classes
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep Kotlin classes
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Keep reflection for Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep additional plugin classes for CollegePro
-keep class com.baseflow.permissionhandler.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.crazecoder.openfile.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.example.open_filex.** { *; }

# Keep Dio HTTP client classes
-keep class dio.** { *; }
-dontwarn dio.**

# Keep PDF and file handling classes
-keep class com.github.barteksc.pdfviewer.** { *; }
-dontwarn com.github.barteksc.pdfviewer.**

# Keep TTS and audio classes
-keep class com.tencent.tts.** { *; }
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn com.tencent.tts.**
-dontwarn xyz.luan.audioplayers.**

# Keep biometric authentication classes
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }
-dontwarn androidx.biometric.**

# Google Play Core classes - Keep all classes to prevent R8 issues
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store Split Application
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# The missing rules from missing_rules.txt
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.tasks.Task { *; }
