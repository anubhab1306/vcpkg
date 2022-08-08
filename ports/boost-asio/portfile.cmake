# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/asio
    REF boost-1.80.0.beta1
    SHA512 2448d1f47fbb6c0199f50678937bb770a528cda37f6a7fca0edbd56e095f43a50f0b8bfb9db4e23af29a2f7c225e67dd3f07c8efe2d837a6db0f84009d434ae8
    HEAD_REF master
    PATCHES windows_alloca_header.patch
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
