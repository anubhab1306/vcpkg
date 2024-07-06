set(FFMPEG_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

include(SelectLibraryConfigurations)

cmake_policy(SET CMP0012 NEW)

set(vcpkg_no_avcodec_target ON)
set(vcpkg_no_avformat_target ON)
set(vcpkg_no_avutil_target ON)
set(vcpkg_no_swresample_target ON)
if(TARGET FFmpeg::avcodec)
  set(vcpkg_no_avcodec_target OFF)
endif()
if(TARGET FFmpeg::avformat)
  set(vcpkg_no_avformat_target OFF)
endif()
if(TARGET FFmpeg::avutil)
  set(vcpkg_no_avutil_target OFF)
endif()
if(TARGET FFmpeg::swresample)
  set(vcpkg_no_swresample_target OFF)
endif()

z_vcpkg_underlying_find_package(${ARGS})

if(WIN32)
  set(PKG_CONFIG_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/../../../@_HOST_TRIPLET@/tools/pkgconf/pkgconf.exe" CACHE STRING "" FORCE)
endif()

set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH ON) # Required for CMAKE_MINIMUM_REQUIRED_VERSION VERSION_LESS 3.1 which otherwise ignores CMAKE_PREFIX_PATH

if(@WITH_MP3LAME@)
  find_package(mp3lame CONFIG )
  list(APPEND FFMPEG_LIBRARIES mp3lame::mp3lame)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    # target exists after find_package and wasn't defined before
    target_link_libraries(FFmpeg::avcodec INTERFACE mp3lame::mp3lame)
  endif()
endif()

if(@WITH_XML2@)
  find_package(LibXml2 )
  list(APPEND FFMPEG_LIBRARIES LibXml2::LibXml2)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE LibXml2::LibXml2)
  endif()
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE LibXml2::LibXml2)
  endif()
endif()

if(@WITH_ICONV@)
  find_package(Iconv )
  list(APPEND FFMPEG_LIBRARIES Iconv::Iconv)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE Iconv::Iconv)
  endif()
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE Iconv::Iconv)
  endif()
endif()

if(@WITH_LZMA@)
  find_package(liblzma CONFIG )
  list(APPEND FFMPEG_LIBRARIES liblzma::liblzma)
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE liblzma::liblzma)
  endif()
endif()

if(@WITH_SSH@)
  find_package(libssh CONFIG )
  list(APPEND FFMPEG_LIBRARIES ssh)
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE ssh)
  endif()
endif()

if(@WITH_OPENMPT@)
  find_package(libopenmpt CONFIG )
  list(APPEND FFMPEG_LIBRARIES libopenmpt::libopenmpt)
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE libopenmpt::libopenmpt)
  endif()
endif()

if(@WITH_MODPLUG@)
  find_package(PkgConfig )
  pkg_check_modules(modplug  IMPORTED_TARGET libmodplug)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::modplug)
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE PkgConfig::modplug)
  endif()
endif()

if(@WITH_SRT@)
  find_package(PkgConfig )
  pkg_check_modules(srt  IMPORTED_TARGET srt)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::srt)
  if(vcpkg_no_avformat_target AND TARGET FFmpeg::avformat)
    target_link_libraries(FFmpeg::avformat INTERFACE PkgConfig::srt)
  endif()
endif()

if(@WITH_DAV1D@)
  find_package(PkgConfig )
  pkg_check_modules(dav1d  IMPORTED_TARGET dav1d)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::dav1d)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::dav1d)
  endif()
endif()

if(@WITH_OPENH264@)
  find_package(PkgConfig )
  pkg_check_modules(openh264  IMPORTED_TARGET openh264)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::openh264)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::openh264)
  endif()
endif()

if(@WITH_WEBP@)
  find_package(WebP CONFIG )
  list(APPEND FFMPEG_LIBRARIES WebP::webp WebP::webpdecoder WebP::webpdemux WebP::libwebpmux)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE WebP::webp WebP::webpdecoder WebP::webpdemux WebP::libwebpmux)
  endif()
endif()

if(@WITH_SOXR@)
  find_library(SOXR_LIBRARY_RELEASE NAMES soxr PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
  find_library(SOXR_LIBRARY_DEBUG   NAMES soxr PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
  select_library_configurations(SOXR)
  if(SOXR_LIBRARY_RELEASE)
    list(APPEND FFMPEG_LIBRARIES $<$<NOT:$<CONFIG:DEBUG>>:${SOXR_LIBRARY_RELEASE}>)
  endif()
  if(SOXR_LIBRARY_DEBUG)
    list(APPEND FFMPEG_LIBRARIES $<$<CONFIG:DEBUG>:${SOXR_LIBRARY_DEBUG}>)
  endif()
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE ${SOXR_LIBRARIES})
  endif()
  if(vcpkg_no_swresample_target AND TARGET FFmpeg::swresample)
    target_link_libraries(FFmpeg::swresample INTERFACE ${SOXR_LIBRARIES})
  endif()
endif()

if(@WITH_THEORA@)
  find_package(PkgConfig )
  pkg_check_modules(theora  IMPORTED_TARGET theora)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::theora)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::theora)
  endif()
endif()

if(@WITH_MFX@)
  find_package(PkgConfig )
  pkg_check_modules(libmfx  IMPORTED_TARGET libmfx)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::libmfx)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::libmfx)
  endif()
  if(vcpkg_no_avutil_target AND TARGET FFmpeg::avutil)
    target_link_libraries(FFmpeg::avutil INTERFACE PkgConfig::libmfx)
  endif()
endif()

if(@WITH_ILBC@)
  find_package(PkgConfig )
  pkg_check_modules(libilbc  IMPORTED_TARGET libilbc)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::libilbc)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::libilbc)
  endif()
endif()

if(@WITH_THEORA@)
  find_package(PkgConfig )
  pkg_check_modules(theora  IMPORTED_TARGET theora)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::theora)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::theora)
  endif()
endif()

if(@WITH_VORBIS@)
  find_package(Vorbis CONFIG )
  list(APPEND FFMPEG_LIBRARIES Vorbis::vorbis Vorbis::vorbisenc)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE Vorbis::vorbis Vorbis::vorbisenc)
  endif()
endif()

if(@WITH_VPX@)
  find_package(PkgConfig )
  pkg_check_modules(vpx  IMPORTED_TARGET vpx)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::vpx)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::vpx)
  endif()
endif()

if(@WITH_OPUS@)
  find_package(Opus CONFIG )
  list(APPEND FFMPEG_LIBRARIES Opus::opus)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE Opus::opus)
  endif()
endif()

if(@WITH_SPEEX@)
  find_package(PkgConfig )
  pkg_check_modules(speex  IMPORTED_TARGET speex)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::speex)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::speex)
  endif()
endif()

if(@WITH_OPENJPEG@)
  find_package(OpenJPEG CONFIG )
  list(APPEND FFMPEG_LIBRARIES openjp2)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE openjp2)
  endif()
endif()

if(@WITH_SNAPPY@)
  find_package(Snappy CONFIG )
  list(APPEND FFMPEG_LIBRARIES Snappy::snappy)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE Snappy::snappy)
  endif()
endif()

if(@WITH_AOM@)
  find_package(PkgConfig )
  pkg_check_modules(aom  IMPORTED_TARGET aom)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::aom)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::aom)
  endif()
endif()

if(@WITH_X264@)
  find_package(PkgConfig )
  pkg_check_modules(x264  IMPORTED_TARGET x264)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::x264)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::x264)
  endif()
endif()

if(@WITH_X265@)
  find_package(PkgConfig )
  pkg_check_modules(x265  IMPORTED_TARGET x265)
  list(APPEND FFMPEG_LIBRARIES PkgConfig::x265)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE PkgConfig::x265)
  endif()
endif()

if(@WITH_AAC@)
  find_package(fdk-aac CONFIG)
    list(APPEND FFMPEG_LIBRARIES FDK-AAC::fdk-aac)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE FDK-AAC::fdk-aac)
  endif()
endif()

if(@WITH_OPENCL@)
  find_package(OpenCL )
  list(APPEND FFMPEG_LIBRARIES OpenCL::OpenCL)
  if(vcpkg_no_avcodec_target AND TARGET FFmpeg::avcodec)
    target_link_libraries(FFmpeg::avcodec INTERFACE OpenCL::OpenCL)
  endif()
  if(vcpkg_no_avutil_target AND TARGET FFmpeg::avutil)
    target_link_libraries(FFmpeg::avutil INTERFACE OpenCL::OpenCL)
  endif()
endif()

set(FFMPEG_LIBRARY ${FFMPEG_LIBRARIES})

set(CMAKE_MODULE_PATH ${FFMPEG_PREV_MODULE_PATH})

unset(vcpkg_no_avformat_target)
unset(vcpkg_no_avcodec_target)
unset(vcpkg_no_avutil_target)
