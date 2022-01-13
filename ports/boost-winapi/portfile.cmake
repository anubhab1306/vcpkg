# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/winapi
    REF boost-1.78.0
    SHA512 431d0091574e857f895a9b8659a474e5aaf7ba0e80f0a15da445f2ed3612e192bdd0763e024a62ad94f8a0efbfadbd00c7caf20836409fb46fb0dc1520236dd6
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-winapi requires a newer version of vcpkg.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
