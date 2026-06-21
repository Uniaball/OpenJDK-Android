#!/bin/bash
set -e

. setdevkitpath.sh

if [[ ! -d freetype ]]; then
    git clone --depth 1 https://github.com/LWJGL-CI/freetype
else
    echo "freetype directory already exists, skipping clone."
fi

if [[ ! -d cups ]]; then
    git clone --depth 1 https://github.com/OpenPrinting/cups
else
    echo "cups directory already exists, skipping clone."
fi

if [[ ! -d libiconv ]]; then
    git clone --depth 1 https://github.com/aaaapai/libiconv
else
    echo "libiconv directory already exists, skipping clone."
fi