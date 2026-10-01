import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing key 설정
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.han.TapToBeat"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.han.TapToBeat"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release 서명 설정 (안전한 폴백 처리)
    signingConfigs {
        create("release") {
            val hasKeyProps = keystoreProperties.isNotEmpty()
            if (hasKeyProps) {
                keyAlias = keystoreProperties.getProperty("keyAlias") ?: ""
                keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
                storePassword = keystoreProperties.getProperty("storePassword") ?: ""

                val storePath = keystoreProperties.getProperty("storeFile")
                if (!storePath.isNullOrBlank()) {
                    val keyFile = file(storePath)
                    storeFile = if (keyFile.isAbsolute) keyFile else rootProject.file(storePath)
                }
            }
        }
    }

    buildTypes {
        release {
            // key.properties가 존재할 때만 release 서명을 적용하고, 없으면 debug 서명으로 안전하게 폴백
            val hasKeyProps = keystoreProperties.isNotEmpty()
            signingConfig = if (hasKeyProps) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}