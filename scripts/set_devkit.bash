#!/bin/bash

if [[ -z "${JDK_DEBUG_LEVEL}" ]]
then
  export JDK_DEBUG_LEVEL=release
fi

export JVM_PLATFORM=android
export FREETYPE_DIR=${CURRENT_DIR}/freetype/build
export CUPS_DIR=${CURRENT_DIR}/cups

# arm64 specific flags
Set_C_CPPFLAGS -O3 -fno-emulated-tls
Set_LDFLAGS -Wl,-plugin-opt=-emulated-tls=0

# Polly optimizations
Set_C_CPPFLAGS -mllvm -polly -mllvm -polly-vectorizer=stripmine -mllvm -polly-invariant-load-hoisting -mllvm -polly-run-inliner -mllvm -polly-run-dce -mllvm -polly-detect-keep-going -mllvm -polly-ast-use-context -mllvm -polly-parallel

# Android specific
export AR=${NDK_TOOLCHAIN}/bin/llvm-ar
export AS=${NDK_TOOLCHAIN}/bin/llvm-as
export CC=${thecc}
export CXX=${thecxx}
export LD=${NDK_TOOLCHAIN}/bin/ld.lld
export OBJCOPY=${NDK_TOOLCHAIN}/bin/llvm-objcopy
export RANLIB=${NDK_TOOLCHAIN}/bin/llvm-ranlib
export STRIP=${NDK_TOOLCHAIN}/bin/llvm-strip
export PATH=${NDK_TOOLCHAIN}/bin:${PATH}
export LD_LIBRARY_PATH=./openjdk/build/${TARGET}/buildjdk/jdk/lib:$LD_LIBRARY_PATH
export NM=${NDK_TOOLCHAIN}/bin/llvm-nm
export DLLTOOL=${NDK_TOOLCHAIN}/bin/llvm-dlltool

Set_CFLAGS -I${FREETYPE_DIR}/include/freetype2 -I${CUPS_DIR} -I${DEPS_INCLUDE_DIR} -Wno-unknown-warning-option
Set_CPPFLAGS -I${FREETYPE_DIR}/include/freetype2 -I${CUPS_DIR} -I${DEPS_INCLUDE_DIR} -Wno-unknown-warning-option
Set_LDFLAGS -L${FREETYPE_DIR}/lib -L${DEPS_LIB_DIR} -L${NDK_TOOLCHAIN}/sysroot/usr/lib/aarch64-linux-android/${ANDROID_API}