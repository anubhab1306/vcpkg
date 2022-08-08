# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/static_string
    REF boost-1.80.0.beta1
    SHA512 baf3582a68c1d0819ceb21b7139800538f34100429aee562297dd3869fea129a8d4bbd2ad95874302531806bce3f1b6dc9616190ac37b8a5c7106e7578c8c196
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
