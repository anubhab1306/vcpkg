vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel-isl/Open3D
    REF a124f85e02d9e6d0c89d71ce57cb473dc4b9da62
    SHA512 6cbe6141a0f70f367dc9a6ea6f31879e4624742c1b065cf7aa71590eabac4afcd75a83b04ca3fb9219a4a8905ab39800ad8d7f57f3ec2eb97ff67984a4bc1c44
    HEAD_REF master
    PATCHES
        0001-use-external-libraries.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_WINDOWS_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "openmp"   WITH_OPENMP
)

vcpkg_find_acquire_program(PYTHON3)
set(ENV{PYTHON} "${PYTHON3}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DVCPKG_CURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}/tools
        -DBUILD_CPP_EXAMPLES=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_EIGEN3=OFF
        -DBUILD_FLANN=OFF
        -DBUILD_GLEW=OFF
        -DBUILD_GLFW=OFF
        -DBUILD_PNG=OFF
        -DBUILD_JPEG=OFF
        -DBUILD_PYBIND11=OFF
        -DBUILD_PYTHON_MODULE=OFF
        -DBUILD_LIBREALSENSE=OFF
        -DBUILD_AZURE_KINECT=OFF
        -DBUILD_TINYFILEDIALOGS=OFF
        -DBUILD_QHULL=OFF
        -DBUILD_FILAMENT=OFF
        -DSTATIC_WINDOWS_RUNTIME=${STATIC_WINDOWS_RUNTIME}
        -DBUILD_CUDA_MODULE=OFF
        -DBUILD_TENSORFLOW_OPS=OFF
        -DGLIBCXX_USE_CXX11_ABI=OFF
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Open3D)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/Open3D/IO/FileFormat")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
