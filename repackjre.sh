#!/bin/bash
set -e

IN_DIR="$1"
OUT_DIR="$2"

mkdir -p "$OUT_DIR"

TARBALL=$(find "$IN_DIR" -maxdepth 1 -name 'jre27-*.tar.xz' | head -1)
ARCH="arm64"

WORK_DIR="$IN_DIR/work"
WORK1_DIR="$IN_DIR/work1"
mkdir -p "$WORK_DIR" "$WORK1_DIR"
trap 'rm -rf "$WORK_DIR" "$WORK1_DIR"' EXIT

# universal part
cd "$WORK_DIR"
tar xf "$TARBALL"
rm -rf bin lib/server lib/jexec lib/jvm.cfg
find . -name '*.so' -delete
rm -f release
XZ_OPT="-6 --threads=0" tar cJf "$OUT_DIR/universal.tar.xz" *

# arch-specific part
rm -rf "$WORK_DIR"/*
cd "$WORK_DIR"
tar xf "$TARBALL"
mkdir -p "$WORK1_DIR/lib"
mv bin "$WORK1_DIR/"
[ -f lib/jexec ] && mv lib/jexec "$WORK1_DIR/lib/"
[ -f lib/jvm.cfg ] && mv lib/jvm.cfg "$WORK1_DIR/lib/"
for variant in server client; do
    [ -d "lib/$variant" ] && mv "lib/$variant" "$WORK1_DIR/lib/"
done
find . -name '*.so' -exec mv {} "$WORK1_DIR/lib/" \;
[ -f release ] && mv release "$WORK1_DIR/"
XZ_OPT="-6 --threads=0" tar cJf "$OUT_DIR/bin-$ARCH.tar.xz" -C "$WORK1_DIR" .

# version file
if [ -n "$GITHUB_SHA" ]; then
    echo "$GITHUB_SHA" > "$OUT_DIR/version"
else
    date +%Y%m%d > "$OUT_DIR/version"
fi