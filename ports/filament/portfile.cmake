vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/filament
    REF 77aec40a5663fa75cb849e2d1b274b0e080016ee
    SHA512 030a62366e125ca15aa28e604db42192149e74bb047eade38c4d650f2f5cf95849c297df406962ddb88e24bff10201fe06eb707d11b6cdccd67a54558a6f85db
    HEAD_REF master
    PATCHES
        use_external_libs.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(USE_STATIC_CRT ON)
else()
    set(USE_STATIC_CRT OFF)
endif()

file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/getopt")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libassimp")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libgtest")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/imgui")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libpng")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libsdl2")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/spirv-cross")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/spirv-tools")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/stb")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/tinyexr")
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/libz")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_STATIC_CRT=${USE_STATIC_CRT}
        -DFILAMENT_ENABLE_JAVA=OFF
        -DFILAMENT_USE_EXTERNAL_GLES3=OFF
        -DFILAMENT_USE_SWIFTSHADER=OFF
        -DFILAMENT_GENERATE_JS_DOCS=OFF
        -DFILAMENT_ENABLE_LTO=OFF
        -DFILAMENT_SKIP_SAMPLES=OFF

)

vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES
    cmgen
    filamesh
    glslminifier
    matc
    matinfo
    mipgen
    normal-blending
    resgen
    roughness-prefilter
    specular-color
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE ${CURRENT_PACKAGES_DIR}/README.md)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE ${CURRENT_PACKAGES_DIR}/debug/README.md)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/filament RENAME copyright)
