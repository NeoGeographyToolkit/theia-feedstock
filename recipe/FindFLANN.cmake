# FindFLANN shim: conda ships FLANN libs/headers but no cmake config, and
# TheiaSfM does find_package(FLANN REQUIRED). Searches MULTIVIEW_DEPS_DIR.
find_path(FLANN_INCLUDE_DIRS flann/flann.hpp
  HINTS ${MULTIVIEW_DEPS_DIR}/include)
find_library(FLANN_LIBRARIES NAMES flann_cpp
  HINTS ${MULTIVIEW_DEPS_DIR}/lib)
find_library(FLANN_LIBRARIES_STATIC NAMES flann_cpp_s
  HINTS ${MULTIVIEW_DEPS_DIR}/lib)
if(FLANN_INCLUDE_DIRS AND FLANN_LIBRARIES)
  set(FLANN_FOUND TRUE)
  message(STATUS "Found FLANN: ${FLANN_LIBRARIES}")
else()
  message(FATAL_ERROR "Cannot find FLANN")
endif()
