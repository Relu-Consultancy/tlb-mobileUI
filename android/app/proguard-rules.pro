# ─────────────────────────────────────────────────────────────────────────
# ProGuard / R8 keep rules for release (minify + resource shrink).
# Flutter, Firebase, geolocator, image_picker, etc. ship their own consumer
# rules automatically; these cover the reflection-heavy libs that don't.
# ─────────────────────────────────────────────────────────────────────────

# ── Flutter embedding / deferred components (Play Core is optional) ──
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.**

# ── Razorpay (uses JS interfaces + reflection for the checkout webview) ──
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keep class com.razorpay.** { *; }
-keep class proguard.annotation.** { *; }
-dontwarn com.razorpay.**
-dontwarn proguard.annotation.**
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
    public void onPayment*(...);
}

# ── Google Pay / Wallet (pulled in transitively by Razorpay) ──
-keep class com.google.android.apps.nbu.paisa.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.**

# ── Gson / model reflection (used by some plugins) ──
-keepattributes AnnotationDefault,RuntimeVisibleAnnotations
-keep class * implements java.io.Serializable { *; }

# ── flutter_local_notifications (Gson-serialised scheduled notifications) ──
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
