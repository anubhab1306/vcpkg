# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/array
    REF boost-1.80.0.beta1
    SHA512 c443a9eaea7cf6ad125e40c3c4b88a5efab54553d4d61f9c0d2167109599c1d083864e1b324cfc054a7b80d343720c4bebe9182ee386d983b672c2c639983612
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
