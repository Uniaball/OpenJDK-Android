#!/bin/bash
set -e
. setdevkitpath.sh

cd freetype

if [[ -d "build_android-${TARGET_SHORT}" ]]; then
    echo "Freetype already built, skipping."
else
    echo "Building Freetype"
    export PATH=$TOOLCHAIN/bin:$PATH
    ./autogen.sh
    ./configure \
        --host=$TARGET \
        --prefix=${PWD}/build_android-${TARGET_SHORT} \
        LD=$TOOLCHAIN/bin/ld.lld \
        --without-zlib \
        --with-brotli=system \
        --with-png=no \
        --with-harfbuzz=no \
        || { echo "Freetype configure failed"; exit 1; }
    CFLAGS="-O3 -fno-rtti -mllvm -polly" CXXFLAGS="-O3 -fno-rtti -mllvm -polly" make -j$(nproc)
    make install
fi

cd ..

cd libiconv

mkdir -p build_tools
cd build_tools
gcc -o genaliases ../lib/genaliases.c
gcc -DUSE_AIX_ALIASES -o genaliases_sysaix ../lib/genaliases.c
gcc -DUSE_HPUX_ALIASES -o genaliases_syshpux ../lib/genaliases.c
gcc -DUSE_OSF1_ALIASES -o genaliases_sysosf1 ../lib/genaliases.c
gcc -DUSE_SOLARIS_ALIASES -o genaliases_syssolaris ../lib/genaliases.c
gcc -DUSE_AIX -o genaliases_aix ../lib/genaliases2.c
gcc -DUSE_AIX -DUSE_AIX_ALIASES -o genaliases_aix_sysaix ../lib/genaliases2.c
gcc -DUSE_OSF1 -o genaliases_osf1 ../lib/genaliases2.c
gcc -DUSE_OSF1 -DUSE_OSF1_ALIASES -o genaliases_osf1_sysosf1 ../lib/genaliases2.c
gcc -DUSE_DOS -o genaliases_dos ../lib/genaliases2.c
gcc -DUSE_ZOS -o genaliases_zos ../lib/genaliases2.c
gcc -DUSE_EXTRA -o genaliases_extra ../lib/genaliases2.c
gcc -o genflags ../lib/genflags.c
gcc -o gentranslit ../lib/gentranslit.c
cd ..

mkdir -p build_android
cd build_android

cmake .. \
    -DANDROID_PLATFORM=${API} \
    -DANDROID_TOOLCHAIN_NAME=${TARGET} \
    -DANDROID_TOOLCHAIN=clang \
    -DCMAKE_ANDROID_STL_TYPE=c++_static \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_MAKE_PROGRAM=$(which make) \
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_LATEST_HOME}/build/cmake/android.toolchain.cmake \
    -DCMAKE_INSTALL_PREFIX=${PWD}/install \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    ${CFLAGS:+-DCMAKE_C_FLAGS="$CFLAGS"} \
    ${CPPFLAGS:+-DCMAKE_CXX_FLAGS="$CPPFLAGS"} \
    ${LDFLAGS:+-DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS" -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS"}

cmake --build . --config Release --parallel $(nproc)
cmake --install . --config Release

mkdir -p ../../dummy_libs
cp -v install/lib/libiconv.a ../../dummy_libs/

cd ../..