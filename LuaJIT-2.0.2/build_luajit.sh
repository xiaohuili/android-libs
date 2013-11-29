#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
host_os=`uname -s | tr "[:upper:]" "[:lower:]"`

SRCDIR=$DIR
LIBDIR=$DIR/../../libs/
NDKFLAGS="-fexceptions -ffunction-sections -funwind-tables -no-canonical-prefixes -fomit-frame-pointer -fno-strict-aliasing -finline-limit=64 -Wa,--noexecstack -DNDEBUG -DANDROID"

cd "$SRCDIR"

NDK=$ANDROID_NDK_ROOT
NDKABI=9
NDKVER=$NDK/toolchains/arm-linux-androideabi-4.8
NDKP=$NDKVER/prebuilt/${host_os}-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
NDKARCH="$NDKFLAGS -march=armv5te -mtune=xscale -msoft-float -mthumb"

# Android/ARM, armeabi (ARMv5TE soft-float), Android 2.2+ (Froyo)
DESTDIR=$LIBDIR/armeabi
mkdir -p $DESTDIR
rm "$DESTDIR"/luajit.so
make clean
make amalg HOST_CC="gcc -m32" CROSS=$NDKP TARGET_SYS=Linux TARGET_FLAGS="$NDKF $NDKARCH"

if [ -f $SRCDIR/src/libluajit.so ]; then
    mv $SRCDIR/src/libluajit.so $DESTDIR/libluajit.so
fi;

# Android/ARM, armeabi-v7a (ARMv7 VFP), Android 4.0+ (ICS)
NDKARCH="$NDKFLAGS -march=armv7-a -msoft-float -mfpu=vfpv3-d16 -mthumb -Wl,--fix-cortex-a8"
DESTDIR=$LIBDIR/armeabi-v7a
mkdir -p $DESTDIR
rm "$DESTDIR"/luajit.so
make clean
make amalg HOST_CC="gcc -m32" CROSS=$NDKP TARGET_SYS=Linux TARGET_FLAGS="$NDKF $NDKARCH"

if [ -f $SRCDIR/src/libluajit.so ]; then
    mv $SRCDIR/src/libluajit.so $DESTDIR/libluajit.so
fi;

# Android/x86, x86 (i686 SSE3), Android 4.0+ (ICS)
NDKARCH="$NDKFLAGS -march=i686 -finline-limit=300"
NDKABI=14
DESTDIR=$LIBDIR/x86
NDKVER=$NDK/toolchains/x86-4.8
NDKP=$NDKVER/prebuilt/${host_os}-x86_64/bin/i686-linux-android-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-x86"
mkdir -p $DESTDIR
rm "$DESTDIR"/luajit.so
make clean
make amalg HOST_CC="gcc -m32" CROSS=$NDKP TARGET_SYS=Linux TARGET_FLAGS="$NDKF $NDKARCH"

if [ -f $SRCDIR/src/libluajit.so ]; then
    mv $SRCDIR/src/libluajit.so $DESTDIR/libluajit.so
fi;

make clean
