import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
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
    
    // compileSdk를 flutter 기본값과 동기화하거나 targetSdk와 일치시킵니다.
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.han.TapToBeat"
        minSdk = flutter.minSdkVersion
        // targetSdk를 임의로 고정하는 대신 플러터 기본값을 사용하거나 
        // 꼭 필요하다면 compileSdk와 동일하게 맞추는 것이 안전합니다.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release 서명 설정 (key.properties가 없을 경우 대비 안전장치 추가)
    signingConfigs {
        create("release") {
            val hasKeyProps = keystoreProperties.isNotEmpty()
            keyAlias = if (hasKeyProps) keystoreProperties["keyAlias"] as String else ""
            keyPassword = if (hasKeyProps) keystoreProperties["keyPassword"] as String else ""
            storeFile = if (hasKeyProps && keystoreProperties["storeFile"] != null) file(keystoreProperties["storeFile"] as String) else null
            storePassword = if (hasKeyProps) keystoreProperties["storePassword"] as String else ""
        }
    }

    buildTypes {
        release {
            // 릴리스 빌드시에만 서명 적용 (디버그 모드 실행 시 충돌 방지)
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}