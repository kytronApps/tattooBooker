plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services") 
}

android {
    namespace = "com.example.tattoo_booker"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.tattoobooker.app"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Firebase BoM → asegura versiones compatibles
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))

    // Firebase SDKs que usarás
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-functions")

    // Dependencias Flutter
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
}