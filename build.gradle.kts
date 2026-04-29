plugins {
    application
    java
    id("org.openjfx.javafxplugin") version "0.1.0"
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

val javafxModules = listOf("javafx.controls", "javafx.graphics", "javafx.fxml")

javafx {
    version = "21.0.5"
    modules = javafxModules
}

application {
    mainClass = "com.tomato.app.TomatoApp"
}

/*
 * org.openjfx.javafxplugin 0.1.0 只对名为 `run` 的 JavaExec 做「把 JavaFX 从 classpath 挪到 --module-path」的修补。
 * IntelliJ 用 Gradle 执行主类时会生成其它 JavaExec（例如 :com.tomato.app.TomatoApp.main()），不修补会报
 * 「缺少 JavaFX 运行时组件」。
 */
tasks.withType<JavaExec>().configureEach {
    if (name == "run") {
        return@configureEach
    }
    doFirst {
        val fullClasspath = classpath
        val javafxJars = fullClasspath.filter { it.isFile && it.name.startsWith("javafx-") }
        if (javafxJars.isEmpty) {
            return@doFirst
        }
        classpath = fullClasspath.filter { !it.isFile || !it.name.startsWith("javafx-") }
        val modulePath = javafxJars.asPath
        val addModules = javafxModules.joinToString(",")
        jvmArgs = listOf("--module-path", modulePath, "--add-modules", addModules) + jvmArgs.orEmpty()
    }
}

tasks.jar {
    manifest {
        attributes["Main-Class"] = "com.tomato.app.TomatoApp"
    }
}
