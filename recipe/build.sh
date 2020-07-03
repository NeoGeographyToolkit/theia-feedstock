#!/usr/bin/env bash

set -e

# Fix for missing liblzma.
perl -pi -e "s#(/[^\s]*?lib)/lib([^\s]+).la#-L\$1 -l\$2#g" ${PREFIX}/lib/*.la

mkdir build && cd build

export LDFLAGS="-L$PREFIX/lib"

# Make libraries
cmake                                                  \
  -DCMAKE_BUILD_TYPE=Release                           \
  -DCMAKE_CXX_FLAGS="-O3 -std=c++11 -fPIC $LDFLAGS"    \
  -DCMAKE_PREFIX_PATH=${PREFIX}                        \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}                \
  -DBoost_INCLUDE_DIR:PATH=${PREFIX}/include           \
  -DTIFF_INCLUDE_DIR:PATH=${PREFIX}/include            \
  -DBUILD_SHARED_LIBS=ON                               \
  -DCMAKE_VERBOSE_MAKEFILE=ON                          \
  -DBUILD_SHARED_LIBS=ON                               \
  -DBUILD_TESTING=OFF                                  \
  -DBUILD_DOCUMENTATION=OFF                            \
  -DTBB_LIBRARIES=${PREFIX}/lib/libtbb.so.2            \
  -DTBB_MALLOC_LIB=${PREFIX}/lib/libtbbmalloc.so.2     \
  ${SRC_DIR}

make -j $CPU_COUNT
make install

