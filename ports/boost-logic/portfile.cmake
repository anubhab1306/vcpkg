# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/logic
    REF boost-1.81.0
    SHA512 c21e4be1a61e711810300269fb5d6594efc5d773f92d7796bcc1c1c4e121d41d5f6cc3bdd7ff90afa286bff54890b5f8992c1d27ea589f60a2f7caae43a044bc
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
