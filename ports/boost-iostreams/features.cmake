vcpkg_check_features(
  OUT_FEATURE_OPTIONS
    FEATURE_OPTIONS
  FEATURES
    "bzip2"    BOOST_IOSTREAMS_ENABLE_BZIP2
    "lzma"     BOOST_IOSTREAMS_ENABLE_LZMA
    "zlib"     BOOST_IOSTREAMS_ENABLE_ZLIB
    "zstd"     BOOST_IOSTREAMS_ENABLE_ZSTD
)