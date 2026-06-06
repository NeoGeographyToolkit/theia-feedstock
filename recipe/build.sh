#!/usr/bin/env bash
set -ex

# TheiaSfM (NeoGeographyToolkit fork). Source of truth for flags: the MultiView
# section of stereopipeline-feedstock/recipe/build.sh.

# FLANN has conda libs/headers but no cmake config; TheiaSfM does
# find_package(FLANN REQUIRED). Drop in the shim (TheiaSfM/cmake is on its own
# CMAKE_MODULE_PATH).
cp "${RECIPE_DIR}/FindFLANN.cmake" cmake/FindFLANN.cmake

# Strip -flto (osx-64 cross LTO finalize choke; benign elsewhere, also faster).
perl -i -pe 's/ -flto"/"/g' \
  cmake/OptimizeTheiaCompilerFlags.cmake \
  libraries/akaze/cmake/OptimizeCompilerFlags.cmake

# Strip host-CPU-tuning flags. On Linux TheiaSfM adds -march=native -mtune=native
# (and -msse3 on Darwin). -march=native bakes the BUILD host's CPU features into
# a package meant to run on other machines (e.g. NCCS Grace) -> illegal
# instruction risk. -msse3 is invalid on aarch64. Remove all; keep the conda
# baseline arch.
perl -i -pe 's/-march=native//g; s/-mtune=native//g; s/-msse3//g;' \
  cmake/OptimizeTheiaCompilerFlags.cmake \
  libraries/akaze/cmake/OptimizeCompilerFlags.cmake

mkdir -p build && cd build
# Do NOT pass ${CMAKE_ARGS}: its CMAKE_FIND_ROOT_PATH_MODE=ONLY breaks the
# module-mode find_package calls (matches the MultiView build, which relies on
# CMAKE_PREFIX_PATH/MULTIVIEW_DEPS_DIR=$PREFIX instead). TheiaSfM adds its own
# -std=c++17.
cmake                                          \
    -DCMAKE_BUILD_TYPE=Release                 \
    -DMULTIVIEW_DEPS_DIR=${PREFIX}             \
    -DCMAKE_PREFIX_PATH=${PREFIX}              \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}           \
    -DCMAKE_CXX_FLAGS="-O3 -Wno-error -I${PREFIX}/include" \
    -DCMAKE_C_FLAGS='-O3 -Wno-error'           \
    -DCMAKE_SKIP_INSTALL_RPATH=ON              \
    -DCMAKE_VERBOSE_MAKEFILE=ON                \
    ..
make -j${CPU_COUNT}
make install
