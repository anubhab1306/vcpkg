# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/algorithm
    REF boost-1.80.0.beta1
    SHA512 8a56fc263e019e6636b9e68c68396186c7be20b33bc78d7eaf7a5e13f72115dea7a74b0f9b0268d47361a8d9634d360a86c4547f8c084ba7e2bb0217a3078637
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
