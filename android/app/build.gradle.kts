plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
}

android {
    namespace = "Apple.Tech"
    compileSdk = 34

    defaultConfig {
        applicationId = "Apple.Tech"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.13.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
}