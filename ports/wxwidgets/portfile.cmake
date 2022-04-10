vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxWidgets/wxWidgets
    REF 9c0a8be1dc32063d91ed1901fd5fcd54f4f955a1 #v3.1.5
    SHA512 33817f766b36d24e5e6f4eb7666f2e4c1ec305063cb26190001e0fc82ce73decc18697e8005da990a1c99dc1ccdac9b45bb2bbe5ba73e6e2aa860c768583314c
    HEAD_REF master
    PATCHES
        disable-platform-lib-dir.patch
        fix-build.patch
        fix-linux-configure.patch # Remove this patch in the next update
        fix-libs-export.patch
        relocatable-wx-config.patch
)

set(OPTIONS)
if(VCPKG_TARGET_IS_OSX)
    set(OPTIONS -DCOTIRE_MINIMUM_NUMBER_OF_TARGET_SOURCES=9999)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm)
    set(OPTIONS
        -DwxUSE_OPENGL=OFF
        -DwxUSE_STACKWALKER=OFF
    )
endif()

# wxWidgets on Linux currently needs to find the system's `gtk+-3.0.pc`.
# vcpkg's port pkgconf would prevent this lookup.
if(VCPKG_TARGET_IS_LINUX AND NOT VCPKG_CROSSCOMPILING AND NOT DEFINED ENV{PKG_CONFIG})
    find_program(system_pkg_config NAMES pkg-config)
    if(system_pkg_config)
        set(ENV{PKG_CONFIG} "${system_pkg_config}")
    endif()
endif()

# This may be set to ON by users in a custom triplet.
# The use of 'wxUSE_STL' and 'WXWIDGETS_USE_STD_CONTAINERS' (ON or OFF) are not API compatible
# which is why they must be set in a custom triplet rather than a port feature.
if(NOT DEFINED WXWIDGETS_USE_STL)
    set(WXWIDGETS_USE_STL OFF)
endif()

if(NOT DEFINED WXWIDGETS_USE_STD_CONTAINERS)
    set(WXWIDGETS_USE_STD_CONTAINERS OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DwxUSE_REGEX=builtin
        -DwxUSE_ZLIB=sys
        -DwxUSE_EXPAT=sys
        -DwxUSE_LIBJPEG=sys
        -DwxUSE_LIBPNG=sys
        -DwxUSE_LIBTIFF=sys
        -DwxBUILD_DISABLE_PLATFORM_LIB_DIR=ON
        -DwxUSE_STL=${WXWIDGETS_USE_STL}
        -DwxUSE_STD_CONTAINERS=${WXWIDGETS_USE_STD_CONTAINERS}
        ${OPTIONS}
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS)
    file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    if(DLLS)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
        foreach(DLL IN LISTS DLLS)
            get_filename_component(N "${DLL}" NAME)
            file(RENAME "${DLL}" "${CURRENT_PACKAGES_DIR}/bin/${N}")
        endforeach()
    endif()
    file(GLOB DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
    if(DLLS)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
        foreach(DLL IN LISTS DLLS)
            get_filename_component(N "${DLL}" NAME)
            file(RENAME "${DLL}" "${CURRENT_PACKAGES_DIR}/debug/bin/${N}")
        endforeach()
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES wxrc AUTO_CLEAN)
else()
    vcpkg_copy_tools(TOOL_NAMES wxrc wx-config wxrc-3.1 AUTO_CLEAN)
    # FindwxWidgets.cmake/find_program doesn't accept a symlink for wxrc.
    file(INSTALL "${CURRENT_PACKAGES_DIR}/tools/${PORT}/wxrc-3.1"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        RENAME wxrc
        USE_SOURCE_PERMISSIONS
    )
endif()

# do the copy pdbs now after the dlls got moved to the expected /bin folder above
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/msvc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(GLOB_RECURSE INCLUDES "${CURRENT_PACKAGES_DIR}/include/*.h")
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h")
    list(APPEND INCLUDES "${CURRENT_PACKAGES_DIR}/lib/mswu/wx/setup.h")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h")
    list(APPEND INCLUDES "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h")
endif()
foreach(INC IN LISTS INCLUDES)
    file(READ "${INC}" _contents)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(WXUSINGDLL)" "0" _contents "${_contents}")
    else()
        string(REPLACE "defined(WXUSINGDLL)" "1" _contents "${_contents}")
    endif()
    # Remove install prefix from setup.h to ensure package is relocatable
    string(REGEX REPLACE "\n#define wxINSTALL_PREFIX [^\n]*" "\n#define wxINSTALL_PREFIX \"\"" _contents "${_contents}")
    file(WRITE "${INC}" "${_contents}")
endforeach()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/wx/setup.h")
    file(GLOB_RECURSE WX_SETUP_H_FILES_DBG "${CURRENT_PACKAGES_DIR}/debug/lib/*.h")
    file(GLOB_RECURSE WX_SETUP_H_FILES_REL "${CURRENT_PACKAGES_DIR}/lib/*.h")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string("${WX_SETUP_H_FILES_REL}" "${CURRENT_PACKAGES_DIR}" "")

        string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/" "" WX_SETUP_H_FILES_REL "${WX_SETUP_H_FILES_REL}")
        string(REPLACE "/setup.h" "" WX_SETUP_H_REL_RELATIVE "${WX_SETUP_H_FILES_REL}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${WX_SETUP_H_FILES_DBG}" "${CURRENT_PACKAGES_DIR}" "")

        string(REPLACE "${CURRENT_PACKAGES_DIR}/debug/lib/" "" WX_SETUP_H_FILES_DBG "${WX_SETUP_H_FILES_DBG}")
        string(REPLACE "/setup.h" "" WX_SETUP_H_DBG_RELATIVE "${WX_SETUP_H_FILES_DBG}")
    endif()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/setup.h.in" "${CURRENT_PACKAGES_DIR}/include/wx/setup.h" @ONLY)
endif()

file(GLOB configs LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/lib/wx/config/*")
foreach(config IN LISTS configs)
    vcpkg_replace_string("${config}" "${CURRENT_INSTALLED_DIR}" [[${prefix}]])
    # tools/<port>/wx-config is a symlink with absolute path. Replace it with an actual config.
    file(INSTALL "${config}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        RENAME wx-config
        USE_SOURCE_PERMISSIONS
    )
endforeach()
file(GLOB configs LIST_DIRECTORIES false "${CURRENT_PACKAGES_DIR}/debug/lib/wx/config/*")
foreach(config IN LISTS configs)
    vcpkg_replace_string("${config}" "${CURRENT_INSTALLED_DIR}/debug" [[${prefix}]])
endforeach()

# For CMake multi-config in connection with wrapper
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/debug/lib/mswud/wx/setup.h"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib/mswud/wx"
    )
endif()

if("example" IN_LIST FEATURES)
    file(INSTALL
        "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
        "${SOURCE_PATH}/samples/popup/popup.cpp"
        "${SOURCE_PATH}/samples/sample.xpm"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/example/popup.cpp" "../sample.xpm" "sample.xpm")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/docs/licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
