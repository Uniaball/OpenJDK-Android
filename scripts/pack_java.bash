#!/bin/bash
set -e

echo "Packing java..."


cd ${CURRENT_DIR}/openjdk/build/${TARGET}/images/jre
tar cJf ../jre26-${TARGET_OS}-${TARGET_ARCH}-${GITHUB_SHA}.tar.xz .

cd ${CURRENT_DIR}/openjdk/build/${TARGET}/images/jdk
tar cJf ../jdk26-${TARGET_OS}-${TARGET_ARCH}-${GITHUB_SHA}.tar.xz .

cd ${CURRENT_DIR}/openjdk/build/${TARGET}/images/symbols
tar cJf ../symbols26-${TARGET_OS}-${TARGET_ARCH}-${GITHUB_SHA}.tar.xz .
