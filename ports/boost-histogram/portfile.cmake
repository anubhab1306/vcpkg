# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/histogram
    REF boost-1.82.0
    SHA512 8b5dd702c9e27600003cd929a9efa4570253310df411ce98224d23978eb1d45644139b6c00bd77aa8b39bce3ea79a62b3a45ebd6a58a4b20e5b56010e2499b49
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
