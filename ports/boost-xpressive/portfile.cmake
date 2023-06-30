# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/xpressive
    REF boost-1.82.0
    SHA512 840720a68de7e3358237d7fd59a0f541fc754283ba0ab96457bbdfc122114f749fb0b47033fc1ccc0b06a2d1b3b8d288a9828585e8870e303f06e4c96c449af4
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
