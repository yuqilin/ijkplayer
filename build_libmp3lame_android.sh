#!/bin/sh

set -e

# ANDROID_NDK=/Users/liwenfeng/gsx/android_sdks/android-ndk-r13b
echo ANDROID_NDK=$ANDROID_NDK

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT=${BASE_DIR}/android/contrib/build

LAME_ROOT=${BASE_DIR}/extra/libmp3lame

cd $LAME_ROOT/jni

$ANDROID_NDK/ndk-build V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk clean
$ANDROID_NDK/ndk-build V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk LOCAL_ARM_MODE=arm

HEADER_FILES=" \
    $LAME_ROOT/include/lame.h"

ARCHS="armv7a"

for ARCH in $ARCHS; do
    mkdir -p $BUILD_ROOT/lame-$ARCH/include/lame
    mkdir -p $BUILD_ROOT/lame-$ARCH/lib
    cp -a $HEADER_FILES $BUILD_ROOT/lame-$ARCH/include/lame
done

# cp -a $LAME_ROOT/jni/obj/local/armeabi/libmp3lame.a $BUILD_ROOT/lame-armv5/lib
cp -a $LAME_ROOT/jni/obj/local/armeabi-v7a/libmp3lame.a $BUILD_ROOT/lame-armv7a/lib
# cp -a $LAME_ROOT/jni/obj/local/arm64-v8a/libmp3lame.a $BUILD_ROOT/lame-arm64/lib
