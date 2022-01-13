# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/dynamic_bitset
    REF boost-1.78.0
    SHA512 cb3b6542f16d97126eac963a48ace71b795bcc32148c2a8608694045afd833520c104c5ac7ad98ba8196bfa182040e4edd4c54d9af88b257aee0e390251c74a7
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-dynamic-bitset requires a newer version of vcpkg.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
