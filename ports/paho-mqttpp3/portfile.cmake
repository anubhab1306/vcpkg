include(vcpkg_common_functions)

# Download from Github
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.cpp
  REF 0e44dd31ff725d66df4a928d50a26309626dcfd5
  SHA512 b61850f4c146c520ceb9632137b0c172fc9225e73ed3b45e34b406aa38b943fcaa09df675e5bee05176b34522d9c67fcc2694552623b4c4ee01bd06a52b3c397
  HEAD_REF master
  PATCHES
    fix-include-path.patch
    fix-dependency.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS 
  "ssl" PAHO_WITH_SSL
)

# Link with 'paho-mqtt3as' library
set(PAHO_C_LIBNAME paho-mqtt3as)

# Setting the library path
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  set(PAHO_C_LIBRARY_PATH "${CURRENT_INSTALLED_DIR}/lib")
else()
  set(PAHO_C_LIBRARY_PATH "${CURRENT_INSTALLED_DIR}/debug/lib")
endif()

# Setting the include path where MqttClient.h is present
set(PAHO_C_INC "${CURRENT_INSTALLED_DIR}/include")

# Set the generator to Ninja
set(PAHO_CMAKE_GENERATOR "Ninja")

# NOTE: the Paho C++ cmake files on Github are problematic. 
# It uses two different options PAHO_BUILD_STATIC and PAHO_BUILD_SHARED instead of just using one variable.
# Unless the open source community cleans up the cmake files, we are stuck with setting both of them.
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(PAHO_MQTTPP3_STATIC ON)
  set(PAHO_MQTTPP3_SHARED OFF)
  set(PAHO_C_LIB "${PAHO_C_LIBRARY_PATH}/${PAHO_C_LIBNAME}")
  set(PAHO_OPTIONS -DPAHO_MQTT_C_LIBRARIES=${PAHO_C_LIB})
else()
  set(PAHO_MQTTPP3_STATIC OFF)
  set(PAHO_MQTTPP3_SHARED ON)
  set(PAHO_OPTIONS)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  GENERATOR ${PAHO_CMAKE_GENERATOR}
  OPTIONS
  -DPAHO_BUILD_STATIC=${PAHO_MQTTPP3_STATIC}
  -DPAHO_BUILD_SHARED=${PAHO_MQTTPP3_SHARED}
  -DPAHO_MQTT_C_INCLUDE_DIRS=${PAHO_C_INC}
  ${FEATURE_OPTIONS}
  ${PAHO_OPTIONS}
)

# Run the build, copy pdbs and fixup the cmake targets
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/PahoMqttCpp" TARGET_PATH "share/pahomqttcpp")

# Remove the include and share folders in debug folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Add copyright
file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
