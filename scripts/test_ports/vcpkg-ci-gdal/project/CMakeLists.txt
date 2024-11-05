cmake_minimum_required(VERSION 3.10)
project(gdal-test CXX)

set(CMAKE_CXX_STANDARD 11)

find_package(GDAL CONFIG REQUIRED)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE GDAL::GDAL)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PC_GDAL gdal REQUIRED IMPORTED_TARGET)

add_executable(main-pkgconfig main.cpp)
target_link_libraries(main-pkgconfig PRIVATE PkgConfig::PC_GDAL)
