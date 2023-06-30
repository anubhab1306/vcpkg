# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/format
    REF boost-1.82.0
    SHA512 9103f42b8a12ebe752e0e4ccb45c2e35d13ce00d3522a49abcc95e0a5b1c389930cb782b0d7618fb0e69b66c99d527ad272098cea480656bfcdf8b4130ab27da
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
