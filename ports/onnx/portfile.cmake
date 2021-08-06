# uwp: LOAD_LIBRARY_SEARCH_DEFAULT_DIRS undefined identifier
vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onnx/onnx
    REF v1.9.0
    SHA512 a3eecc74ce4f22524603fb86367d21c87a143ba27eef93ef4bd2e2868c2cadeb724b84df58a429286e7824adebdeba7fa059095b7ab29df8dcea8777bd7f4101
    PATCHES
        fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pybind11 BUILD_ONNX_PYTHON
)

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RUNTIME)
    list(APPEND PLATFORM_OPTIONS
        -DONNX_USE_MSVC_STATIC_RUNTIME=${USE_STATIC_RUNTIME}
    )
endif()

# ONNX_USE_PROTOBUF_SHARED_LIBS: find the library and check its suffix
find_library(PROTOBUF_LIBPATH NAMES protobuf PATHS ${CURRENT_INSTALLED_DIR}/bin ${CURRENT_INSTALLED_DIR}/lib REQUIRED)
get_filename_component(PROTOBUF_LIBPATH ${PROTOBUF_LIBPATH} NAME)
string(COMPARE EQUAL "${PROTOBUF_LIBPATH}" "${CMAKE_SHARED_LIBRARY_SUFFIX}" USE_PROTOBUF_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPython3_ROOT_DIR=${CURRENT_INSTALLED_DIR}
        -DPY_VERSION=3.9 # see version of the 'python3' package
        -DONNX_ML=ON
        -DONNX_GEN_PB_TYPE_STUBS=ON
        -DONNX_USE_PROTOBUF_SHARED_LIBS=${USE_PROTOBUF_SHARED}
        -DONNX_USE_LITE_PROTO=OFF
        -DONNX_BUILD_TESTS=OFF
        -DONNX_BUILD_BENCHMARKS=OFF
)

if("pybind11" IN_LIST FEATURES)
    # This target is not in install/export
    vcpkg_cmake_build(TARGET onnx_cpp2py_export)
endif()
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ONNX)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    # the others are empty
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_ml"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_data"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_operators_ml"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/onnx_cpp2py_export"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/backend"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/tools"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/test"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/bin"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/examples"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/frontend"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/controlflow"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/generator"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/logical"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/math"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/nn"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/object_detection"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/quantization"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/reduction"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/rnn"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/sequence"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/traditionalml"
                    "${CURRENT_PACKAGES_DIR}/include/onnx/defs/training"
)
