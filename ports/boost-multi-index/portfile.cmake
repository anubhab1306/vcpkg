# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multi_index
    REF boost-1.80.0.beta1
    SHA512 1554d2499fdfde880448229a2320e1902ee8b0d2fee7c1c1f51a51fd26436842fecdf939b24424273b82582ef6f02696a5a3503e777ad52ff5c5e6cfbead18cd
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
