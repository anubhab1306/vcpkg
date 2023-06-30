# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/phoenix
    REF boost-1.82.0
    SHA512 a0dbbff345e669801be5b93766db5bade30ac9978ddbaf6cae2a613bb16564bdc6a9a70dcb747b95fa3aeb8c3ad139c89bcf372a4026b75c74ebf0941f2d100d
    HEAD_REF master
    PATCHES fix-duplicate-symbols.patch
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
