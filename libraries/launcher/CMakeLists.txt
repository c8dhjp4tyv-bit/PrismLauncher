cmake_minimum_required(VERSION 3.15)
project(launcher Java)
find_package(Java 1.7 REQUIRED COMPONENTS Development)

include(UseJava)
set(CMAKE_JAVA_JAR_ENTRY_POINT org.timelesslauncher.EntryPoint)
set(CMAKE_JAVA_COMPILE_FLAGS -target 7 -source 7)

set(SRC
    org/timelesslauncher/EntryPoint.java
    org/timelesslauncher/launcher/Launcher.java
    org/timelesslauncher/launcher/impl/AbstractLauncher.java
    org/timelesslauncher/launcher/impl/StandardLauncher.java
    org/timelesslauncher/exception/ParameterNotFoundException.java
    org/timelesslauncher/exception/ParseException.java
    org/timelesslauncher/utils/Parameters.java
    org/timelesslauncher/utils/ReflectionUtils.java
    org/timelesslauncher/utils/logging/Level.java
    org/timelesslauncher/utils/logging/Log.java
    org/timelesslauncher/legacy/LegacyProxy.java
)

set(LEGACY_SRC
    legacy/org/timelesslauncher/legacy/LegacyFrame.java
    legacy/org/timelesslauncher/legacy/LegacyLauncher.java
    legacy/org/timelesslauncher/legacy/fix/online/Handler.java
    legacy/org/timelesslauncher/legacy/fix/online/OnlineFixes.java
    legacy/org/timelesslauncher/legacy/fix/online/OnlineModeFix.java
    legacy/org/timelesslauncher/legacy/fix/online/SkinFix.java
    legacy/org/timelesslauncher/legacy/utils/Base64.java
    legacy/org/timelesslauncher/legacy/utils/api/MojangApi.java
    legacy/org/timelesslauncher/legacy/utils/api/Texture.java
    legacy/org/timelesslauncher/legacy/utils/json/JsonParseException.java
    legacy/org/timelesslauncher/legacy/utils/json/JsonParser.java
    legacy/org/timelesslauncher/legacy/utils/url/ByteArrayUrlConnection.java
    legacy/org/timelesslauncher/legacy/utils/url/UrlUtils.java
    legacy/net/minecraft/Launcher.java
    legacy/org/timelesslauncher/legacy/LegacyProxy.java
)

add_jar(NewLaunch ${SRC})
add_jar(NewLaunchLegacy ${LEGACY_SRC} INCLUDE_JARS NewLaunch)
install_jar(NewLaunch "${JARS_DEST_DIR}")
install_jar(NewLaunchLegacy "${JARS_DEST_DIR}")
