# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/timer
    REF boost-1.82.0
    SHA512 24eef96802278f2839e83e9d3213b24bb88e669e97614e03335b0f77e65d1ddb2e0679cdc7bb96fb46e2b513ff0b40d94d3317410e9e5cbeb18079252dc8287d
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
