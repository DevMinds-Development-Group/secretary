import kotlin.io.path.exists

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.koinos.app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"


    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.koinos.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("APP_KEYSTORE_PATH") ?: "upload-keystore.jks"
            storeFile = file(keystorePath)
            storePassword = System.getenv("APP_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("APP_KEY_ALIAS")
            keyPassword = System.getenv("APP_KEYSTORE_PASSWORD")
        }
    }

    buildTypes {
        getByName("release") {
            // Importante: Esto vincula la configuración de firma que creamos arriba
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = false // o true si usas ProGuard
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
            val versionName = variant.versionName
            // Esto cambiará el nombre a Koinos-v1.0.x.apk
            output.outputFileName = "Koinos-v${versionName}.apk"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 3. Agregar la librería necesaria para el desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
