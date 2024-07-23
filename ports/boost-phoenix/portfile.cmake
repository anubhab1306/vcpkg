# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/phoenix
    REF boost-${VERSION}
    SHA512 3bd9a2cb2f2b3cb9428166e96474fdc8772c8f7c8b8265513a31ca7fb0c7e2039577e369488a612c64ac3061a6cc75962a38a9885adb892d5f82ab635c113585
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
