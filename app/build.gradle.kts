plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

// 读取签名配置
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keystore.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.clocker.clocker"
    compileSdk = 34

    // 签名配置
    signingConfigs {
        create("release") {
            // 优先从环境变量读取（用于 CI/CD），否则从 keystore.properties 读取
            val keystorePath = System.getenv("KEYSTORE_FILE") ?: keystoreProperties["keystoreFile"] as String?
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD") ?: keystoreProperties["keystorePassword"] as String?
            val keyAliasValue = System.getenv("KEY_ALIAS") ?: keystoreProperties["keyAlias"] as String?
            val keyPasswordValue = System.getenv("KEY_PASSWORD") ?: keystoreProperties["keyPassword"] as String?

            if (keystorePath != null && keystorePassword != null && keyAliasValue != null && keyPasswordValue != null) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    defaultConfig {
        applicationId = "com.clocker.clocker"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 使用签名配置
            signingConfig = signingConfigs.findByName("release")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.google.code.gson:gson:2.10.1")
}
