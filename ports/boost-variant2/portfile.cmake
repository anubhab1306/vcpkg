# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/variant2
    REF boost-1.80.0.beta1
    SHA512 314ab2daef31db4e33e9196a9c15a3c38130165db320baf584390886a86cb27e8ac1ed3fcaa8e290f0b9af652d15b7ff048eab61274bbf74577e8c718671acbb
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
