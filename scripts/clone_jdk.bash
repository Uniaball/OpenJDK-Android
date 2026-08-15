#!/bin/bash
set -e

cd ${CURRENT_DIR}

echo "JAVA_VERSION=26, JAVA_TAG=${TARGET_JAVA_TAG:-}"

if [ -d "openjdk" ]; then
    echo "Deleting openjdk have been existed..."
    rm -rf openjdk
fi

if [[ -n "${TARGET_JAVA_TAG:-}" ]]; then
    TAG_NAME="26-${TARGET_JAVA_TAG}"
    echo "tag: ${TAG_NAME}"
    git clone --depth 1 -b ${TAG_NAME} https://github.com/openjdk/jdk26u openjdk
    exit 0
fi

git clone --depth 1 -b master https://github.com/openjdk/jdk26u openjdk