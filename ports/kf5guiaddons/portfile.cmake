vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kguiaddons
    REF v5.84.0
    SHA512 e5905c0aa5343ce3d4cd3765cb81390fc89fb78aec3c8de8b31d1dada8074d04f549ff785f3988498d2e274d7cb08a35a83ba031d18562049e6ca41d18ea52ee
    HEAD_REF master
    PATCHES
        fix_cmake.patch # see https://github.com/microsoft/vcpkg/issues/17607#issuecomment-831518812
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wayland   WITH_WAYLAND
)

if("wayland" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_LINUX)
    message(FATAL_ERROR "Feature wayland is only supported on Linux.")
endif()

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DQtWaylandScanner_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-wayland/bin/qtwaylandscanner
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        QtWaylandScanner_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5GuiAddons)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# We need to substitute the CURRENT_INSTALLED_DIR introduced by fix_cmake.patch.
# configure_file() would, however, be too eager at this point, and would replace other variables, 
# which we don't want, so do manual REGEX replace instead.
file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/KF5GuiAddonsConfig.cmake" filedata)
string(REGEX REPLACE "CURRENT_INSTALLED_DIR" "${CURRENT_INSTALLED_DIR}" filedata "${filedata}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/KF5GuiAddonsConfig.cmake" "${filedata}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
