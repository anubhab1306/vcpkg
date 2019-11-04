include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO niXman/yas
	REF 7.0.4
	SHA512 34fd9198dc1a9f69f109f6311e24083492edadb152a05ccb00a95a2d01fc034aaadf11b6f4ee266d8e7b647bb147591114789c0baf29242cf404ba78406d779b
	HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/yas DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
