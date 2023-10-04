vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kaitai-io/kaitai_struct_cpp_stl_runtime
    REF 083df99f6c7e8dc1030a82a226a055611299b036
    SHA512 5371b866da29d83b1060d8ea49243f97944d4c7a9da007045ccf4250145dd7de86b77210066fc51f9970e100344e51aec4f597e98b0d6dff73385749b8038d92
    HEAD_REF master
)

set(STRING_ENCODING_TYPE "NONE")
if ("iconv" IN_LIST FEATURES)
    set(STRING_ENCODING_TYPE "ICONV")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS    
        -DSTRING_ENCODING_TYPE=${STRING_ENCODING_TYPE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
