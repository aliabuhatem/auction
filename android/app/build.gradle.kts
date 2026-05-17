plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // TODO: Replace "com.example.auction" with your production applicationId
    //       (e.g. "nl.vakantieveilingen.app") and update google-services.json.
    namespace = "com.example.auction"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.auction"
        minSdk = flutter.minSdkVersion  // Firebase minimum
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Set these environment variables in CI/CD or local.properties.
            // Never commit keystore credentials to source control.
            storeFile     = System.getenv("KEY_STORE_PATH")?.let { file(it) }
            storePassword = System.getenv("KEY_STORE_PASSWORD")
            keyAlias      = System.getenv("KEY_ALIAS")
            keyPassword   = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            // Use env-var signing config when available; fall back to debug for
            // local builds where credentials are not yet configured.
            signingConfig = if (System.getenv("KEY_STORE_PATH") != null)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    implementation("com.google.firebase:firebase-analytics")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
