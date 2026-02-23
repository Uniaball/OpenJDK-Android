#!/bin/bash
set -e

if [[ ! -d openjdk ]]; then
    git clone --depth 1 https://github.com/openjdk/jdk openjdk
else
    echo "openjdk directory already exists, skipping clone."
fi