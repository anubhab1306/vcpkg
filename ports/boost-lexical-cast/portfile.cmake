# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/lexical_cast
    REF boost-1.77.0
    SHA512 1c9cfee10bb61f52f653f4adf68d7342fe952c24a180aa49a5cc83689567be3a0f68c05e96ade23025163262e1ba96b545ed4e182d9411deb2251b54bcfb7fab
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
