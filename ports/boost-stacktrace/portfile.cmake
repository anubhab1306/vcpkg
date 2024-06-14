# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/stacktrace
    REF boost-${VERSION}
    SHA512 21ce1826c064f04e077f9095b3c129d1d39a9aa0c7b22200990c33207dae59a80baaa6d04b7e9bb88039dc038d6f5d69fbd932b4fa3bd5cd94fd46c6f03c201c
    HEAD_REF master
    PATCHES
        fix_config-check.diff
)

set(FEATURE_OPTIONS "")
include("${CMAKE_CURRENT_LIST_DIR}/features.cmake")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
