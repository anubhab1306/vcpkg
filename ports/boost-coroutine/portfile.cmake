# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/coroutine
    REF boost-1.78.0
    SHA512 ebb8319388b2a57143a3fb5a66cc930547a804fd8b04374632c2fbaff8f28a1d9b22ea5862e39c1e653c2062c2137e97d38fa5cb44ce5699b07cc5c7526f311f
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-coroutine requires a newer version of vcpkg.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/vcpkg_boost_build.cmake)
vcpkg_boost_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
