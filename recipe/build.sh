#!/bin/sh
set -ex

mkdir build_ && cd build_

if [ -n "${cuda_compiler_version}" ] && [ "${cuda_compiler_version}" != "None" ]; then
  CUDA_CMAKE_ARGS="-DUSE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=all"
else
  CUDA_CMAKE_ARGS="-DUSE_CUDA=OFF"
fi

cmake ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON -DCMAKE_MACOSX_RPATH=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTING=OFF \
  -DLIB_SUFFIX="" \
  ${CUDA_CMAKE_ARGS} \
  ..
make install -j${CPU_COUNT}
