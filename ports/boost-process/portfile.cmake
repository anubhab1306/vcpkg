# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/process
    REF boost-1.80.0.beta1
    SHA512 2fe70031f9e5318aad4b45e58deaf24fbaa848b4162e7acbb457c93ea3f9ae118f498075c781f855f623fb80a0fc00de59b7beaddebe157e2bdef217f46fe703
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
