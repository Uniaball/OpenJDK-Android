#!/bin/bash
set -e
. setdevkitpath.sh

if [[ -d "$ANDROID_NDK_HOME" ]]; then
    echo "NDK already exists: $ANDROID_NDK_HOME"
else
    echo "Downloading NDK"
    wget -nc -nv -O android-ndk-$NDK_VERSION-linux-x86_64.zip "https://dl.google.com/android/repository/android-ndk-$NDK_VERSION-linux.zip"
    unzip -q android-ndk-$NDK_VERSION-linux-x86_64.zip
fi
cp devkit.info.${TARGET_SHORT} ${TOOLCHAIN}

bash getlibs.sh
bash buildlibs.sh
bash clonejdk.sh
bash buildjdk.sh
bash removejdkdebuginfo.sh
bash tarjdk.sh