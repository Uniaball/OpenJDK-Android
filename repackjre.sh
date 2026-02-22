#!/bin/bash
set -e

in="$1"
out="$2"
work="$in/work"
work1="$in/work1"

mkdir -p "$work" "$work1" "$out"

copyjvmlib() {
  if [[ -d "lib/$1" ]]; then
    echo "Moving $1 VM for $2"
    mv "lib/$1" "$work1/lib/"
  fi
}

makearch() {
  echo "Making $2..."
  cd "$work"
  tar xf "$(find "$in" -name "jre27-$2-*release.tar.xz")" >/dev/null 2>&1
  mv bin "$work1/"
  mkdir -p "$work1/lib"
  mv lib/jexec "$work1/lib/"
  mv lib/jvm.cfg "$work1/lib/"
  copyjvmlib server "$2"
  copyjvmlib client "$2"
  find ./ -name '*.so' -exec mv {} "$work1/lib/" \;
  mv release "$work1/release"
  XZ_OPT="-6 --threads=0" tar cJf "bin-$2.tar.xz" -C "$work1" . >/dev/null
  mv "bin-$2.tar.xz" "$out/"
  rm -rf "$work"/* "$work1"/*
}

makeuni() {
  echo "Making universal..."
  cd "$work"
  tar xf "$(find "$in" -name "jre27-arm64-*release.tar.xz")" >/dev/null 2>&1
  rm -rf bin lib/server lib/jexec lib/jvm.cfg
  find ./ -name '*.so' -exec rm {} \;
  rm release
  XZ_OPT="-6 --threads=0" tar cJf universal.tar.xz * >/dev/null
  mv universal.tar.xz "$out/"
  rm -rf "$work"/*
}

makeuni
makearch aarch64 arm64

if [[ -n "$GITHUB_SHA" ]]; then
  echo "$GITHUB_SHA" > "$out/version"
else
  date +%Y%m%d > "$out/version"
fi