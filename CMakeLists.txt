cmake_minimum_required(VERSION 3.16)

project(quick VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appquick
    main.cpp
    firebaseauth.cpp
    firebaseauth.h
)

qt_add_qml_module(appquick
    URI quick
    VERSION 1.0
    QML_FILES
        Main.qml
        loginpage.qml
        selectrestaurant.qml
        pratimamenu.qml
        pawanmenu.qml
        nightordermenu.qml
        hkmenu.qml
        sherpamenu.qml
        paymentpage.qml
    SOURCES
        firebaseauth.cpp
        firebaseauth.h
        QML_FILES ordertracking.qml
        QML_FILES OrderStatus.qml
        QML_FILES
        QML_FILES
)

set_target_properties(appquick PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appquick
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Network
)

# FIXED: Simple Android SSL libraries integration
if(ANDROID)
    set_target_properties(appquick PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
    )

    # Set Android extra libraries using the correct Qt6 method
    set_property(TARGET appquick PROPERTY QT_ANDROID_EXTRA_LIBS
        ${CMAKE_CURRENT_SOURCE_DIR}/ssl_3/lib/armeabi-v7a/libssl_3.so
        ${CMAKE_CURRENT_SOURCE_DIR}/ssl_3/lib/armeabi-v7a/libcrypto_3.so
        ${CMAKE_CURRENT_SOURCE_DIR}/ssl_3/lib/arm64-v8a/libssl_3.so
        ${CMAKE_CURRENT_SOURCE_DIR}/ssl_3/lib/arm64-v8a/libcrypto_3.so
    )
endif()

string(TIMESTAMP CURRENT_DATETIME "2025-07-16 10:10:00" UTC)
add_compile_definitions(
    APP_BUILD_DATE="${CURRENT_DATETIME}"
    APP_USER="Sumit-51"
)

include(GNUInstallDirs)
install(TARGETS appquick
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
