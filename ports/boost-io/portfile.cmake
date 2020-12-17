# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/io
    REF boost-1.74.0
    SHA512 c344ea5793d25fca5c3751e8f19a1281883ad813ec7703d5df20d1f6a9642d37f028301a1f0c63bfae2465ee9d3385c0ab1e30608d35efcd98ddc3034c431286
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
