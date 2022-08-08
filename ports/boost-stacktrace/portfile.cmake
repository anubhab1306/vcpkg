# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/stacktrace
    REF boost-1.80.0.beta1
    SHA512 879e22a3bb2332e2289af09c78ff83b423a1b49569ccbb952992d9bc4f23ba2ef7b1b7b17da9d454093787a6bed663bfecc5c7e914eb6f843f7a1b76f5ffee59
    HEAD_REF master
)

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
