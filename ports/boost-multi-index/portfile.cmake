# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multi_index
    REF boost-1.81.0
    SHA512 7f08ece99ae953f8ef7855ded2c61366c5e5f751a0058ada537b21958ee8aa7a765ff01d400e61af2facb480f24cd2968a43e84aa826e5db82aac719efbe1f0e
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
