vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF 5173a76ba49936d252a85ee49b7eb96e3dff4033#version 7.0.0
    SHA512 4a27931d3bef9f792cf9bbe64ceac42303ade5be27d6e00f398c53be8693ed81c6da3f41568f85c219eb50b05d8c9ab7e2b9454f75dcd87ab9c4c01dd52fe3d1
    HEAD_REF master
    PATCHES fix-warning4189.patch
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll")
                file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
                file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fmtd.dll)
            endif()
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/fmt.dll")
                file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
                file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/bin/fmt.dll)
            endif()
        endif()
    endif()

    # Force FMT_SHARED to 1
    file(READ ${CURRENT_PACKAGES_DIR}/include/fmt/core.h FMT_CORE_H)
    string(REPLACE "defined(FMT_SHARED)" "1" FMT_CORE_H "${FMT_CORE_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fmt/core.h "${FMT_CORE_H}")
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
        string(REPLACE "lib/fmtd.dll" "bin/fmtd.dll" FMT_DEBUG_MODULE ${FMT_DEBUG_MODULE})
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake FMT_RELEASE_MODULE)
        string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_RELEASE_MODULE ${FMT_RELEASE_MODULE})
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake "${FMT_RELEASE_MODULE}")
    endif()
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
