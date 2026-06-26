#!/bin/bash
export NDK_VERSION=r29

export JDK_DEBUG_LEVEL=${JDK_DEBUG_LEVEL:-release}
export JVM_VARIANTS=${JVM_VARIANTS:-server}

export TARGET=aarch64-linux-android
export TARGET_SHORT=arm64
export TARGET_JDK=aarch64

export JVM_PLATFORM=android
export API=24

if [[ -z "$ANDROID_NDK_HOME" ]]; then
    export ANDROID_NDK_HOME="$PWD/android-ndk-$NDK_VERSION"
fi

export TOOLCHAIN="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64"

export ANDROID_INCLUDE="$TOOLCHAIN/sysroot/usr/include"

export CPPFLAGS="-I$ANDROID_INCLUDE -I$ANDROID_INCLUDE/$TARGET"
export LDFLAGS="-fuse-ld=lld"

export CC="ccache $TOOLCHAIN/bin/${TARGET}${API}-clang"
export CXX="ccache $TOOLCHAIN/bin/${TARGET}${API}-clang++"

export LD="$TOOLCHAIN/bin/ld.lld"

export DLLTOOL="$TOOLCHAIN/bin/llvm-dlltool"
export CXXFILT="$TOOLCHAIN/bin/llvm-cxxfilt"
export NM="$TOOLCHAIN/bin/llvm-nm"
export AR="$TOOLCHAIN/bin/llvm-ar"
export AS="$TOOLCHAIN/bin/llvm-as"
export OBJCOPY="$TOOLCHAIN/bin/llvm-objcopy"
export OBJDUMP="$TOOLCHAIN/bin/llvm-objdump"
export READELF="$TOOLCHAIN/bin/llvm-readelf"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"
export LINK="$TOOLCHAIN/bin/llvm-link"
export TARGET_OS=android