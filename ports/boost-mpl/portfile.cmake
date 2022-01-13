# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/mpl
    REF boost-1.78.0
    SHA512 0aa3d20b10f5a4a655d07499372ac74114458a6209dc536a3a061e13683a12c98c9b129e3e5d103d95773fcf14afc6f94ac82ddb84d21dee55338bb5bbf2a47f
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-mpl requires a newer version of vcpkg.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
