plugins {
    application
    java
}

group = "com.tomato"
version = "0.1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.formdev:flatlaf:3.4.1")
}

application {
    mainClass = "com.tomato.app.TomatoApp"
}

tasks.jar {
    manifest {
        attributes["Main-Class"] = "com.tomato.app.TomatoApp"
    }
}
