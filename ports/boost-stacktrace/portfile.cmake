# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/stacktrace
    REF boost-1.82.0
    SHA512 18e01cce338e67f9474ff7ca6732e749216e57fc7d5cbf5f78a5e6b7d6c16e70ee0b92a74986c744c6ee9dd2a34c16fc7b6ac918c783b60835e834fac5749707
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
