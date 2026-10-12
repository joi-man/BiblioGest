import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Clave de firma del APK de release (ver docs/app-movil.md). Vive en android/key.properties,
// que NO se sube a git. Sin ella, el release se firma con la clave de depuracion y solo sirve
// para probar: Android no permite actualizar una app instalada con otra clave de firma.
val propiedadesClave = Properties().apply {
    val archivo = rootProject.file("key.properties")
    if (archivo.exists()) archivo.inputStream().use { load(it) }
}
val hayClaveDeRelease = propiedadesClave.getProperty("storeFile") != null

android {
    namespace = "com.bibliogest.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "com.bibliogest.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hayClaveDeRelease) {
            create("release") {
                storeFile = rootProject.file(propiedadesClave.getProperty("storeFile"))
                storePassword = propiedadesClave.getProperty("storePassword")
                keyAlias = propiedadesClave.getProperty("keyAlias")
                keyPassword = propiedadesClave.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hayClaveDeRelease) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
