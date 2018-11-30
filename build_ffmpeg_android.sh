#! /bin/sh
#
# build_ffmpeg_android.sh
# 
# Created by yuqilin on 07/13/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

# set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_ROOT=$BASE_DIR/android/contrib/build

./init-android.sh

./build_libmp3lame_android.sh

./android/contrib/tools/build_x264_android.sh

echo "111111"
cd android/contrib

ARCHS="armv7a"
for ARCH in $ARCHS; do
    echo "222222"
    ./compile-ffmpeg.sh $ARCH
done
