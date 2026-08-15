#!/bin/bash
set -e

cd ${CURRENT_DIR}

echo "JAVA_VERSION=28, JAVA_TAG=${TARGET_JAVA_TAG:-}"

if [ -d "openjdk" ]; then
    echo "Deleting openjdk have been existed..."
    rm -rf openjdk
fi

if [[ -n "${TARGET_JAVA_TAG:-}" ]]; then
    TAG_NAME="28-${TARGET_JAVA_TAG}"
    echo "tag: ${TAG_NAME}"
    git clone --depth 1 -b ${TAG_NAME} https://github.com/openjdk/jdk28u openjdk
    exit 0
fi

git clone --depth 1 -b master https://github.com/openjdk/jdk28u openjdk