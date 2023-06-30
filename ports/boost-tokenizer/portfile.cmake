# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/tokenizer
    REF boost-1.82.0
    SHA512 60412277d7628c3ab8326ff0efffaa192ee39f82371eb3cac13a8f04575f90b1a80faa88e374100b9e0bd8af07521ef20a312f2d9fdf8f61be7935abf890f146
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
