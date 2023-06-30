# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multiprecision
    REF boost-1.82.0
    SHA512 f2441a918e595dca1c2618ff37a5ddebb3bc9e6b923e27e2604ea7ec8f003621b2506f4fd1ec41b3ed3de68c01cd19ff637e205aad0341d272a63edf1469ba5c
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
