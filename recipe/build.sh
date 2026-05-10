#!/bin/sh
set -ex

if [ -n "${cuda_compiler_version}" ] && [ "${cuda_compiler_version}" != "None" ]; then
  CUDA_CMAKE_ARGS="-DUSE_CUDA=ON"
  case "${cuda_compiler_version}" in
    13.*)
      # Ceres 2.2.0 CMakeLists hardcodes "50;60;70;80" (unguarded set()), which
      # nvcc 13.x rejects — Maxwell/Pascal/Volta were dropped. Rewrite in place
      # to Turing+Ampere+Hopper. (-DCMAKE_CUDA_ARCHITECTURES is silently
      # overridden by Ceres' unconditional set(), so we patch the source.)
      sed -i 's/"50;60;70;80"/"75;80;86;90"/' CMakeLists.txt
      ;;
  esac
else
  CUDA_CMAKE_ARGS="-DUSE_CUDA=OFF"
fi

mkdir build_ && cd build_

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
