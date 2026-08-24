plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.thelittlebroadway.tlb_mobile_ui"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (uses java.time on older APIs).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.thelittlebroadway.tlb_mobile_ui"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            // Pinned to a keystore committed in this repo (debug.keystore,
            // password "android", alias "androiddebugkey" — the standard
            // Android debug defaults) rather than each machine's own
            // auto-generated ~/.android/debug.keystore. Google Sign-In only
            // works from a certificate whose SHA-1 is registered in
            // Firebase; with a per-machine keystore that fingerprint differs
            // on every developer's machine, so Sign-In breaks until someone
            // registers that one machine's SHA-1. Pinning here means the
            // whole team builds with the identical certificate, so one
            // registered fingerprint covers everyone.
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // Shrink & obfuscate Java/Kotlin/plugin code (R8) and strip unused
            // Android resources. Only affects native/Android code + res/ — it
            // does NOT touch Flutter (Dart) assets in flutter_assets/. Keep
            // rules for reflection-heavy plugins are in proguard-rules.pro.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Backports java.time etc. so flutter_local_notifications works below API 26.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
