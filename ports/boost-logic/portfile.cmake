# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/logic
    REF boost-1.78.0
    SHA512 0f190c66e1f6ae30173c95db14c7a4373ffc55d3f48a0c54a1814e222b1cba05cf6668e6d90a780506dfa40b5060c0c0c1a4a0c76929fb420770d2134a8cbcd0
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-logic requires a newer version of vcpkg.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
