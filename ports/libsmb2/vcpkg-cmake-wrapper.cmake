set(SMB2_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

vcpkg_underlying_find_package(${ARGS})

set(CMAKE_MODULE_PATH ${SMB2_PREV_MODULE_PATH})
