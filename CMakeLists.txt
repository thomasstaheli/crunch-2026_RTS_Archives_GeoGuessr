cmake_minimum_required(VERSION 3.16)

project(crunch_interactive_map VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appcrunch_interactive_map
    main.cpp
)

# 1. On récupère la liste des images
file(GLOB_RECURSE ALL_IMAGES "img/*")

# 2. Pour chaque image trouvée, on calcule son chemin relatif et on met l'alias
foreach(IMG_FILE ${ALL_IMAGES})
    # On transforme le chemin absolu en chemin relatif par rapport au projet
    file(RELATIVE_PATH REL_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${IMG_FILE}")

    # On applique la propriété demandée par l'erreur
    set_source_files_properties("${IMG_FILE}" PROPERTIES QT_RESOURCE_ALIAS "${REL_PATH}")

    # On l'ajoute à une liste pour l'utiliser plus bas
    list(APPEND IMAGE_RESOURCES "${IMG_FILE}")
endforeach()

qt_add_qml_module(appcrunch_interactive_map
    URI crunch_interactive_map
    QML_FILES
        Main.qml
        SOURCES gamelogic.h
    RESOURCES ${IMAGE_RESOURCES}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appcrunch_interactive_map PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appcrunch_interactive_map
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appcrunch_interactive_map
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appcrunch_interactive_map
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
