#!/bin/bash
set -e
. setdevkitpath.sh

export FREETYPE_DIR="$PWD/freetype/build_android-$TARGET_SHORT"
export CUPS_DIR="$PWD/cups"

export BUILD_Compiler="clang"

export CFLAGS="-DANDROID -D__ANDROID__=1 -D__TERMUX__=1 -DLE_STANDALONE -Wno-int-conversion -Wno-error=implicit-function-declaration -Wno-unused-command-line-argument -Wno-exception-specification"

export CFLAGS+=" -march=armv8-a+simd"
export CFLAGS+=" -O3 -fomit-frame-pointer -fno-semantic-interposition -mllvm -hot-cold-split=true -fdata-sections -ffunction-sections -fmerge-all-constants -ftree-vectorize -fvectorize -fslp-vectorize -pipe -integrated-as"
export CFLAGS+=" -flto -Wl,--lto-O3 -fno-emulated-tls"
export CFLAGS+=" -mllvm -polly -mllvm -polly-vectorizer=stripmine -mllvm -polly-invariant-load-hoisting -mllvm -polly-run-inliner -mllvm -polly-run-dce -mllvm -polly-detect-keep-going -mllvm -polly-ast-use-context -mllvm -polly-parallel -mllvm -polly-omp-backend=LLVM"

export LDFLAGS+=" -fuse-ld=lld -Wl,--gc-sections -Wl,-O3 -Wl,--sort-common -Wl,--as-needed -l:libomp.a"
export LDFLAGS+=" -flto -Wl,--lto-O3 -Wl,-plugin-opt=-emulated-tls=0"
export LDFLAGS+=" -L$PWD/dummy_libs -Wl,-z,max-page-size=16384"

mkdir -p dummy_libs
ar cr dummy_libs/libpthread.a 2>/dev/null || true
ar cr dummy_libs/librt.a 2>/dev/null || true
ar cr dummy_libs/libthread_db.a 2>/dev/null || true

ln -s -f /usr/include/X11 "$ANDROID_INCLUDE/" 2>/dev/null || true
ln -s -f /usr/include/fontconfig "$ANDROID_INCLUDE/" 2>/dev/null || true
ln -s -f "$CUPS_DIR/cups" "$ANDROID_INCLUDE/" 2>/dev/null || true

CCACHE_WRAPPER_DIR="$PWD/ccache_wrappers"
mkdir -p "$CCACHE_WRAPPER_DIR"

REAL_CC="${CC#ccache }"
REAL_CXX="${CXX#ccache }"

cat > "$CCACHE_WRAPPER_DIR/$(basename "$REAL_CC")" << EOF
#!/bin/bash
exec ccache "$REAL_CC" "\$@"
EOF
chmod +x "$CCACHE_WRAPPER_DIR/$(basename "$REAL_CC")"

cat > "$CCACHE_WRAPPER_DIR/$(basename "$REAL_CXX")" << EOF
#!/bin/bash
exec ccache "$REAL_CXX" "\$@"
EOF
chmod +x "$CCACHE_WRAPPER_DIR/$(basename "$REAL_CXX")"

export CC="$CCACHE_WRAPPER_DIR/$(basename "$REAL_CC")"
export CXX="$CCACHE_WRAPPER_DIR/$(basename "$REAL_CXX")"

target_build_dir="build/${JVM_PLATFORM}-${TARGET_JDK}-${JVM_VARIANTS}-${JDK_DEBUG_LEVEL}"

cd openjdk

git reset --hard
git apply --reject --whitespace=fix ../patches/jdk27u_android.diff || echo "git apply failed (Android patch set)"

bash ./configure \
    --with-version-pre="-ea" \
    --with-version-opt="" \
    --with-boot-jdk-jvmargs="-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:ProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3 -XX:AllocatePrefetchStyle=1 -XX:+UseCriticalJavaThreadPriority -XX:+UseStringDeduplication -XX:+UseFastJNIAccessors -XX:+UseThreadPriorities" \
    --openjdk-target="$TARGET" \
    --with-extra-cflags="$CFLAGS" \
    --with-extra-cxxflags="$CFLAGS" \
    --with-extra-ldflags="$LDFLAGS" \
    --disable-precompiled-headers \
    --disable-warnings-as-errors \
    --enable-option-checking=fatal \
    --enable-headless-only=yes \
    --with-jvm-variants="$JVM_VARIANTS" \
    --with-jvm-features="-dtrace,-zero,-vm-structs,-epsilongc" \
    --enable-linktime-gc \
    --with-cups-include="$CUPS_DIR" \
    --with-devkit="$TOOLCHAIN" \
    --with-native-debug-symbols=external \
    --with-debug-level="$JDK_DEBUG_LEVEL" \
    --with-fontconfig-include="$ANDROID_INCLUDE" \
    --x-includes="$ANDROID_INCLUDE/X11" \
    --x-libraries="/usr/lib" \
    --with-toolchain-type="$BUILD_Compiler" \
    --with-freetype-include="$FREETYPE_DIR/include/freetype2" \
    --with-freetype-lib="$FREETYPE_DIR/lib" \
    OBJDUMP="$OBJDUMP" \
    STRIP="$STRIP" \
    NM="$NM" \
    AR="$AR" \
    BUILD_NM="$NM" \
    BUILD_AR="$AR" \
    BUILD_STRIP="$STRIP" \
    BUILD_OBJCOPY="$OBJCOPY" \
    BUILD_AS="$AS" \
    OBJCOPY="$OBJCOPY" \
    CXXFILT="$CXXFILT" \
    LD="$LD" \
    READELF="$TOOLCHAIN/bin/llvm-readelf" || error_code=$?

if [[ "$error_code" -ne 0 ]]; then
    echo "\n\nCONFIGURE ERROR $error_code , config.log:"
    cat config.log
    exit $error_code
fi

jobs=$(nproc 2>/dev/null || echo 4)
[[ "$TOO_MANY_CORES" == "1" ]] && jobs=6

echo "Running ${jobs} jobs to build the jdk"
cd "$target_build_dir"
make JOBS="$jobs" images || {
    echo "Build failure, exited with code $?. Trying again."
    make JOBS="$jobs" images
}