#!/bin/bash
set -e

echo "Packing java..."

CURRENT_DATE=$(TZ='Asia/Shanghai' date +%Y%m%d)

cd ${CURRENT_DIR}/openjdk/build/${TARGET}/images/jre
tar cJf ../jre28-${TARGET_OS}-${TARGET_ARCH}-${CURRENT_DATE}.tar.xz .

cd ${CURRENT_DIR}/openjdk/build/${TARGET}/images/jdk
tar cJf ../jdk28-${TARGET_OS}-${TARGET_ARCH}-${CURRENT_DATE}.tar.xz .

cd ${CURRENT_DIR}/openjdk/build/${TARGET}/images/symbols
tar cJf ../symbols28-${TARGET_OS}-${TARGET_ARCH}-${CURRENT_DATE}.tar.xz .