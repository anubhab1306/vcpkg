# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/math
    REF boost-${VERSION}
    SHA512 3e7f7534641a9e201f6fd5bd1b8b77018f9bc4254376a11e84a2478943ae050b7bc9de7516d86477794e700c385414936998c674ba091326a00420bf2acffd0c
    HEAD_REF master
    PATCHES
        build-old-libs.patch
        opt-random.diff
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
