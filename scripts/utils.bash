#!/bin/bash

cd_to_script_dir() {
    cd "$(dirname "$(readlink -f "$0")")" || {
        echo "Error: failed to cd_to_script_dir"
        exit 1
    }
}
cd_to_script_dir
export CURRENT_DIR="$(dirname "$(pwd)")"

# Fixed for Android arm64
export TARGET_OS=android
export TARGET_ARCH=arm64
export TARGET=aarch64-linux-android
export TARGET_JDK=aarch64
export NDK_ARCH=arm64-v8a

export DEPS_LIB_DIR="${CURRENT_DIR}/libs/android/arm64"
export DEPS_INCLUDE_DIR="${CURRENT_DIR}/include"

# NDK setup
if [[ -z "${USE_GCC}" ]]; then
    if [[ -z "${ANDROID_NDK_LATEST_HOME}" ]]; then
        if [[ -z "${ANDROID_NDK_HOME}" ]]; then
            export NDK_PATH="${CURRENT_DIR}/android-ndk"
        else
            export NDK_PATH="${ANDROID_NDK_HOME}"
        fi
    else
        export NDK_PATH="${ANDROID_NDK_LATEST_HOME}"
    fi
    export NDK_TOOLCHAIN="${NDK_PATH}/toolchains/llvm/prebuilt/linux-x86_64"
else
    echo "GCC not supported for this configuration"
    exit 1
fi

# Compiler and tools
if [[ -z "${ANDROID_API}" ]]; then
    echo "ANDROID_API must be set"
    exit 1
fi

export thecc="${NDK_TOOLCHAIN}/bin/aarch64-linux-android${ANDROID_API}-clang"
export thecxx="${NDK_TOOLCHAIN}/bin/aarch64-linux-android${ANDROID_API}-clang++"

if [[ ! -f "${thecc}" ]] || [[ ! -f "${thecxx}" ]]; then
    echo "Error: Compiler not found for aarch64-linux-android${ANDROID_API}"
    exit 1
fi

Set_CFLAGS() {
    if [[ -z "${CFLAGS}" ]]; then
      export CFLAGS="$*"
    else
      export CFLAGS="${CFLAGS} $*"
    fi
}

Set_CPPFLAGS() {
    if [[ -z "${CPPFLAGS}" ]]; then
      export CPPFLAGS="$*"
    else
      export CPPFLAGS="${CPPFLAGS} $*"
    fi
}

Set_C_CPPFLAGS() {
    Set_CFLAGS "$@"
    Set_CPPFLAGS "$@"
}

Set_LDFLAGS() {
    if [[ -z "${LDFLAGS}" ]]; then
      export LDFLAGS="$*"
    else
      export LDFLAGS="${LDFLAGS} $*"
    fi
}

PrintConfigurationInfo() {
  echo "Current configuration:"
  echo "  TARGET_ARCH: ${TARGET_ARCH}"
  echo "  TARGET_OS: ${TARGET_OS}"
  echo "  NDK_PATH: ${NDK_PATH}"
  echo "  ANDROID_API: ${ANDROID_API}"
  echo "  C Compiler: ${thecc}"
  echo "  C++ Compiler: ${thecxx}"
  echo "  Linker: ${LD}"
  echo "  OBJCOPY: ${OBJCOPY}"
  echo "  RANLIB: ${RANLIB}"
  echo "  Archiver: ${AR}"
  echo "  Assembler: ${AS}"
}

chmod +x ./set_devkit.bash
source ./set_devkit.bash