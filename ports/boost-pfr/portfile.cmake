# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/pfr
    REF boost-1.80.0.beta1
    SHA512 2422d77068d7ed2ad6f350942c0b085af7c06d8ece4dd1189f7cdc9ef49926213b3e5044d5b7429182473fe95a1081029dc2d80d96d02504dc6295c6bd83401c
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
