# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/serialization
    REF boost-1.82.0
    SHA512 e59acbe632a80b6fcaa9c53f76d6ea2264bb6859af57b10dc4f0b84dfec1e0617e2d1a60ec0acbcdca9c121b49bcc4ddb16d9dae2b2db42aee30b2b6ec00665c
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
