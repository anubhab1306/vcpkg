# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/lambda2
    REF boost-1.82.0
    SHA512 6d7cc0fdc170aab6aebfc14f76598b2c0d7a5330b594c6796c4c40b0f4e30ecb1473d25c83cb16851cd54cc835360711eb16afca8a6406cd407be980ae5ac31e
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
