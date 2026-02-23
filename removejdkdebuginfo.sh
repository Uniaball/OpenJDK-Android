#!/bin/bash
set -e

. setdevkitpath.sh

targetpath="openjdk/build/${JVM_PLATFORM}-${TARGET_JDK}-${JVM_VARIANTS}-${JDK_DEBUG_LEVEL}"

rm -rf dizout jdkout dSYM-temp
mkdir -p dizout dSYM-temp/{lib,bin}

cp "freetype/build_android-$TARGET_SHORT/lib/libfreetype.so" "$targetpath/images/jdk/lib/"

cp -r "$targetpath/images/jdk" jdkout

# For arm64, we need to include additional JVMCI modules
export EXTRA_JLINK_OPTION=",jdk.internal.vm.ci,jdk.internal.jvmstat,jdk.internal.ed,jdk.internal.le,jdk.internal.md,jdk.internal.opt"

export JLINK_STRIP_ARG="--strip-native-debug-symbols=exclude-debuginfo-files:objcopy=${OBJCOPY}"

"$targetpath/buildjdk/jdk/bin/jlink" \
    --module-path="jdkout/jmods" \
    --add-modules="java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.charsets,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.editpad,jdk.httpserver,jdk.jdwp.agent,jdk.jfr,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.xml.dom,jdk.zipfs,jdk.hotspot.agent,jdk.incubator.vector,jdk.attach,jdk.jartool,jdk.jcmd,jdk.jconsole,jdk.jdeps,jdk.jdi,jdk.jpackage,jdk.jlink,jdk.jshell,jdk.jstatd,jdk.javadoc,jdk.unsupported.desktop,java.smartcardio${EXTRA_JLINK_OPTION}" \
    --output jreout \
    $JLINK_STRIP_ARG \
    --no-man-pages \
    --no-header-files \
    --endian=little \
    --release-info="jdkout/release" \
    --compress=0

cp "freetype/build_android-$TARGET_SHORT/lib/libfreetype.so" jreout/lib/
cp "freetype/build_android-$TARGET_SHORT/lib/libfreetype.so" jdkout/lib/
cp "awt_xawt/${TARGET_JDK}/libawt_xawt.so" jreout/lib/
cp "awt_xawt/${TARGET_JDK}/libawt_xawt.so" jdkout/lib/

find jdkout -name "*.debuginfo" -exec mv {} dizout/ \;
find jdkout -name "*.dSYM" -exec rm -rf {} \;