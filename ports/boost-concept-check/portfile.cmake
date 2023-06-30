# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/concept_check
    REF boost-1.82.0
    SHA512 a5e4faf91f8edbca84440fe8ce188abe86088d1249bedabfb866755f238c2dad52312201f764d9b19d15e787824a580b7bb66259e4940c9f7d465b6939648869
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
