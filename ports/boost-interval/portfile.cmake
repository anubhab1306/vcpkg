# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/interval
    REF boost-1.78.0
    SHA512 8de185456a462e76a73b01b016e71ab4586a2676cbaaa666e52dbddd37341a6ba313bd51814f3d2bb22541c4cc067626b3d3c8346a02e7a0a38d6cae6cc59f80
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-interval requires a newer version of vcpkg.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
