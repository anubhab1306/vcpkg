vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF db81d37b683bc2d1e74785565cf96d0e9030efe2
	SHA512 dec840b4390786c4e9d8dc3df25ceb7c6e2783881fbc223c1e1c71427541216e4fc9b56e1ae419ec64f6f2880551650a0b3280aed2bdb2ee2fca137bc651f012
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	MAYBE_UNUSED_VARIABLES
	"${_VCPKG_INSTALLED_DIR}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
