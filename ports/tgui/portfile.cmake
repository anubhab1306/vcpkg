if(NOT "sdl2" IN_LIST FEATURES AND NOT "sfml" IN_LIST FEATURES)
    message(FATAL_ERROR "At least one of the backend features must be selected: sdl2 sfml")
endif()

if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
elseif(VCPKG_TARGET_IS_IOS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO texus/TGUI
    REF 6515153c2466e6677ba933679b3dca6c283daf87
    SHA512 109e64c114336979a4bd0d44765e4bc26cb4ecb6e4db92d7441230d148438b084d01cb56dd292f09a6fd28b0f7420044455ffb519147cc3aea71e322142cd9a0
    HEAD_REF 0.9
    PATCHES
        fix-dependencies.patch
        devendor-stb.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/Backends/SDL/cmake_modules") # Config available
file(REMOVE_RECURSE "${SOURCE_PATH}/include/TGUI/extlibs/stb")

set(TGUI_SHARE_PATH "${CURRENT_PACKAGES_DIR}/share/${PORT}")
set(TGUI_TOOLS_PATH "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" TGUI_USE_STATIC_STD_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    sdl2    TGUI_HAS_BACKEND_SDL
    sfml    TGUI_HAS_BACKEND_SFML
    tool    TGUI_BUILD_GUI_BUILDER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DTGUI_MISC_INSTALL_PREFIX=${TGUI_SHARE_PATH}"
        "-DCMAKE_INSTALL_DOCDIR=${TGUI_SHARE_PATH}"
        -DTGUI_USE_STATIC_STD_LIBS=${TGUI_USE_STATIC_STD_LIBS}
        -DTGUI_BACKEND=Custom
        -DTGUI_BUILD_DOC=OFF
        -DTGUI_BUILD_FRAMEWORK=OFF
    OPTIONS_DEBUG
        -DTGUI_BUILD_GUI_BUILDER=OFF
    MAYBE_UNUSED_VARIABLES
        TGUI_BUILD_FRAMEWORK
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TGUI)
vcpkg_copy_pdbs()

if("tool" IN_LIST FEATURES)
    message(STATUS "Check for: ${TGUI_SHARE_PATH}/gui-builder/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(EXISTS "${TGUI_SHARE_PATH}/gui-builder/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(MAKE_DIRECTORY "${TGUI_TOOLS_PATH}")
        file(RENAME
            "${TGUI_SHARE_PATH}/gui-builder/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${TGUI_TOOLS_PATH}/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        # Need to copy `resources` and `themes` directories
        file(COPY "${TGUI_SHARE_PATH}/gui-builder/resources" DESTINATION "${TGUI_TOOLS_PATH}")
        file(COPY "${TGUI_SHARE_PATH}/gui-builder/themes" DESTINATION "${TGUI_TOOLS_PATH}")
        file(REMOVE_RECURSE "${TGUI_SHARE_PATH}/gui-builder")
        vcpkg_copy_tool_dependencies("${TGUI_TOOLS_PATH}")
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
     # Empty folders
    "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/nanosvg"
    "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/glad"
)

vcpkg_fixup_pkgconfig()
set(lib " -ltgui")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(APPEND lib "-s")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/tgui.pc" " -ltgui" "${lib}")
endif()
if(NOT VCPKG_BUILD_TYPE)
    string(APPEND lib "-d")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tgui.pc" " -ltgui" "${lib}")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/license.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
