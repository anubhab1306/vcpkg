# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/variant
    REF boost-1.76.0
    SHA512 d4c5afd1bda28021b4c1eaa0a98db16320144aec2595cf52564486da3c33d89b7a486ec35389af228169a37b928956b6e6405fe86c3dfb3f949cf3e26f372779
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
