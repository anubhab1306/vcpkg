# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/container_hash
    REF boost-1.80.0.beta1
    SHA512 c4b16517d996e51c4926117efb864df5d3219250cdadbe09053bef679219ebc4a020ba04c8800f33bcc5412d3a4fd1aa4880ee19b657de0fce850124f2a1357e
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
