find_path(SQLite3_INCLUDE_DIRS NAMES sqlite3.h PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" NO_DEFAULT_PATH)
find_library(SQLite3_LIBRARY_RELEASE NAMES SQLite3 sqlite PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
find_library(SQLite3_LIBRARY_DEBUG NAMES SQLite3 sqlite PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
if(NOT SQLite3_INCLUDE_DIRS OR NOT (SQLite3_LIBRARY_RELEASE OR SQLite3_LIBRARY_DEBUG))
    message(FATAL_ERROR "Broken installation of vcpkg port SQLite3")
endif()
if(CMAKE_VERSION VERSION_LESS 3.14)
    include(SelectLibraryConfigurations)
    select_library_configurations(SQLite3)
    unset(SQLite3_FOUND)
endif()
_find_package(${ARGS})
