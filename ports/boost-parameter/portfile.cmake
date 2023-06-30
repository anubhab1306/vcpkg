# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/parameter
    REF boost-1.82.0
    SHA512 bf96a37f4939be58e8d21bd49bc5ffb8900604038e3c43b32793cb3d012dbfaf161e6015f583afae96b4c4e9d082930a93f49d631881fd40e03e1872182d2ae2
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
