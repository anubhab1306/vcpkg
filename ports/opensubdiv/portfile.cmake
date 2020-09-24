vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "osx" "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PixarAnimationStudios/OpenSubdiv
    REF 82ab1b9f54c87fdd7e989a3470d53e137b8ca270 # 3.4.3
    SHA512 607cb9aa05d83a24bc2102bfd28abfec58f5723b1c56f6f431111ebf98f105ff7ca2a77610953acd21f73cb74d8d8ec68db3aeb11be1f9ca56d87c36c58dd095
    HEAD_REF master
    PATCHES
        fix_compile-option.patch
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path("${PYTHON2_DIR}")


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DNO_DX=ON
        -DNO_EXAMPLES=ON
        -DNO_TUTORIALS=ON
        -DNO_REGRESSION=ON
        -DNO_TESTS=ON
)

vcpkg_install_cmake()

# # Moves all .cmake files from /debug/share/opensubdiv/ to /share/opensubdiv/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/opensubdiv)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
