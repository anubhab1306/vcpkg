# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/chrono
    REF boost-1.82.0
    SHA512 f1edef690e9ecacdd5cece1043f68403a428a4b91f38575971976a13b040d6b7275ba2f4fa6cfb4059aaa764df89011cffe21ebd31b2acd1117fce109a5f2564
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
