plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.io.FileInputStream
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")


android {
    namespace = "com.beats.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.beats.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = true
        }
    }
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    signingConfigs {
        val storePath = System.getenv("ANDROID_KEYSTORE_PATH")
            ?: (if (keystorePropertiesFile.exists()) {
                val p = Properties().apply { load(FileInputStream(keystorePropertiesFile)) }
                p.getProperty("storeFile")
            } else null)

        val resolvedStoreFile = storePath?.let { path ->
            val f = rootProject.file(path)
            if (f.exists()) f else file(path)
        }

        if (resolvedStoreFile != null && resolvedStoreFile.exists()) {
            val keyProps = if (keystorePropertiesFile.exists()) {
                Properties().apply { load(FileInputStream(keystorePropertiesFile)) }
            } else Properties()

            create("release") {
                keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: keyProps.getProperty("keyAlias")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD") ?: keyProps.getProperty("keyPassword")
                storeFile = resolvedStoreFile
                storePassword = System.getenv("ANDROID_STORE_PASSWORD") ?: keyProps.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            val hasReleaseSigning = signingConfigs.findByName("release") != null
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
                println("   Release build: Using release signing config")
            } else {
                signingConfig = signingConfigs.getByName("debug")
                println("   Release build: Using debug signing config (no valid release keystore found)")
            }
            // Enable R8 minification and supply rules that preserve GSON generic
            // signatures – required by flutter_local_notifications to deserialise
            // scheduled notifications without crashing on TypeToken.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // To reduce the size of the APK, since from AGP 8.0.0 the default value of useLegacyPackaging is false.
     packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

