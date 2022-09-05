vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF 12c98cd529b3bb8c779b5a45846aec6f452b9ed4 # v1.3.20
    SHA512 8f9343eccf9b8b12398a4897d8519149ce016db7b6371af4dc0dec57d8b5ce3ce3152d4b8708ff1880944696bfaab3c7ee13ee360a2ee6fe178651e92f87d889
    PATCHES
        fix-cmake-target-path.patch
        use-openssl-crypto.patch
        remove-trycompile.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tests   BUILD_TESTING
)

set(EXTRA_ARGS)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    set(EXTRA_ARGS "-DS2N_NO_PQ=TRUE")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${EXTRA_ARGS}
        ${FEATURE_OPTIONS}
        -DUNSAFE_TREAT_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/s2n/cmake)

if(BUILD_TESTING)
    message(STATUS Testing)
    vcpkg_cmake_build(TARGET test LOGFILE_BASE test)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/s2n"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/s2n"
    "${CURRENT_PACKAGES_DIR}/share/s2n/modules"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
