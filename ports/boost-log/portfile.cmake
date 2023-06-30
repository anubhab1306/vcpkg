# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/log
    REF boost-1.82.0
    SHA512 ae7b1c02eec0eaf922f46e96cd895a03b74c138e1d1388e468adc0ab9bd6702d0756850b8fc039fc4b2838317b1fbccf1e84b2831c439c906d55de7d9bee55aa
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
