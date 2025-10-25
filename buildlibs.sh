#!/bin/bash
set -e
. setdevkitpath.sh
cd freetype-$BUILD_FREETYPE_VERSION

echo "Building Freetype"

export PATH=$TOOLCHAIN/bin:$PATH

chmod +x $TOOLCHAIN/bin/android-wrapped-clang  

./configure \
  --host=$TARGET \
  --prefix=${PWD}/build_android-${TARGET_SHORT} \
  --without-zlib \
  --with-brotli=system \
  --with-png=no \
  --with-harfbuzz=no $EXTRA_ARGS \
  || error_code=$?

if [[ "$error_code" -ne 0 ]]; then
  echo "
CONFIGURE ERROR $error_code , config.log:"
  cat builds/unix/config.log  # 简化路径（已在 freetype 目录下）
  exit $error_code
fi

CFLAGS=-fno-rtti CXXFLAGS=-fno-rtti make -j4
make install
