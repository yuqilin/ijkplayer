#! /usr/bin/env bash  
  
echo "===================="
echo "[*] compile libx264 "
echo "===================="
set -e

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
fi

#--------------------
# common defines
FF_ARCH=$1
if [ -z "$FF_ARCH" ]; then
    echo "You must specific an architecture 'arm, armv7a, x86, ...'.\n"
    exit 1
fi

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FF_BUILD_ROOT=`pwd`
FF_ANDROID_PLATFORM=android-14


FF_BUILD_NAME=
FF_SOURCE=
FF_CROSS_PREFIX=

FF_CFG_FLAGS=
FF_PLATFORM_CFG_FLAGS=

FF_EXTRA_CFLAGS=
FF_EXTRA_LDFLAGS=

#--------------------
echo ""
echo "--------------------"
echo "[*] make NDK standalone toolchain"
echo "--------------------"
. ./tools/do-detect-env.sh
FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG
FF_GCC_VER=$IJK_GCC_VER
FF_GCC_64_VER=$IJK_GCC_64_VER


# 指令集
#----- armv7a begin -----  
if [ "$FF_ARCH" = "armv7a" ]; then
    #设置源文件路径 
    FF_BUILD_NAME=libx264-armv7a
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    #设置编译器  
    FF_PREBUILT=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt  
    FF_CROSS_PREFIX=$FF_PREBUILT/darwin-x86_64/bin/arm-linux-androideabi-  
    #设置平台编译连接路径  
    FF_PLATFORM=$ANDROID_NDK/platforms/$FF_ANDROID_PLATFORM/arch-arm  
    FF_HOST=arm-linux 
    
    #设置编译输出文件路径
    FF_PREFIX=${BASE_DIR}/../build/$FF_BUILD_NAME
  
    # FF_CFG_CONF="$FF_CFG_CONF --disable-asm"  
  
elif [ "$FF_ARCH" = "armv5" ]; then
    #设置源文件路径 
    FF_BUILD_NAME=libx264-armv5
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    #设置编译器  
    FF_PREBUILT=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt  
    FF_CROSS_PREFIX=$FF_PREBUILT/darwin-x86_64/bin/arm-linux-androideabi-  
    #设置平台编译连接路径  
    FF_PLATFORM=$ANDROID_NDK/platforms/$FF_ANDROID_PLATFORM/arch-arm  
    FF_HOST=arm-linux  
  
    #设置编译输出文件路径
    FF_PREFIX=${BASE_DIR}/../build/$FF_BUILD_NAME
      
    # FF_CFG_CONF="build/$FF_BUILD_NAME"
  
elif [ "$FF_ARCH" = "arm64" ]; then 
    #设置源文件路径 
    FF_BUILD_NAME=libx264-arm64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
    
    #设置编译器  
    FF_PREBUILT=$ANDROID_NDK/toolchains/aarch64-linux-android-4.9/prebuilt  
    FF_CROSS_PREFIX=$FF_PREBUILT/darwin-x86_64/bin/aarch64-linux-android-  
    #设置平台编译连接路径  
    FF_ANDROID_PLATFORM=android-21  
    FF_PLATFORM=$ANDROID_NDK/platforms/$FF_ANDROID_PLATFORM/arch-arm64  
    FF_HOST=aarch64-linux
  
    #设置编译输出文件路径
    FF_PREFIX=${BASE_DIR}/../build/$FF_BUILD_NAME
  
elif [ "$FF_ARCH" = "x86" ]; then
    #设置源文件路径 
    FF_BUILD_NAME=libx264-x86
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
    
    #设置编译器  
    FF_PREBUILT=$ANDROID_NDK/toolchains/x86-4.9/prebuilt  
    FF_CROSS_PREFIX=$FF_PREBUILT/darwin-x86_64/bin/i686-linux-android-  
    #设置平台编译连接路径  
    FF_PLATFORM=$ANDROID_NDK/platforms/$FF_ANDROID_PLATFORM/arch-x86  
    FF_HOST=i686-linux  
  
    #设置编译输出文件路径
    FF_PREFIX=${BASE_DIR}/../build/$FF_BUILD_NAME
  
    # FF_CFG_CONF="$FF_CFG_CONF --disable-asm"
  
elif [ "$FF_ARCH" = "x86_64" ]; then  
    #设置源文件路径 
    FF_BUILD_NAME=libx264-x86_64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
    
    #设置编译器  
    FF_PREBUILT=$ANDROID_NDK/toolchains/x86_64-4.9/prebuilt  
    FF_CROSS_PREFIX=$FF_PREBUILT/darwin-x86_64/bin/x86_64-linux-android-  
    #设置平台编译连接路径  
    FF_ANDROID_PLATFORM=android-21  
    FF_PLATFORM=$ANDROID_NDK/platforms/$FF_ANDROID_PLATFORM/arch-x86_64  
    FF_HOST=x86_64-linux  
  
    #设置编译输出文件路径
    FF_PREFIX=${BASE_DIR}/../build/$FF_BUILD_NAME
      
    # FF_CFG_CONF="$FF_CFG_CONF --disable-asm"
  
else  
    echo "unknown architecture $FF_ARCH";  
    exit 1  
fi  
  
  
#进入libx264源码目录
cd $FF_SOURCE  

echo $FF_PREBUILT
echo $FF_PLATFORM
echo $FF_SOURCE
echo $FF_HOST
echo $FF_CROSS_PREFIX
  
#配置config参数  
FF_CFG_CONF="$FF_CFG_CONF --prefix=$FF_PREFIX"  
FF_CFG_CONF="$FF_CFG_CONF --disable-shared" 
# FF_CFG_CONF="$FF_CFG_CONF --disable-asm"  
FF_CFG_CONF="$FF_CFG_CONF --enable-static"  
FF_CFG_CONF="$FF_CFG_CONF --disable-cli"
  
FF_CFG_CONF="$FF_CFG_CONF --enable-pic"  
FF_CFG_CONF="$FF_CFG_CONF --enable-strip"  
  
# FF_CFG_CONF="$FF_CFG_CONF --disable-avs"  
# FF_CFG_CONF="$FF_CFG_CONF --disable-swscale"  
# FF_CFG_CONF="$FF_CFG_CONF --disable-lavf"  
# FF_CFG_CONF="$FF_CFG_CONF --disable-ffms"  
# FF_CFG_CONF="$FF_CFG_CONF --disable-gpac"  
# FF_CFG_CONF="$FF_CFG_CONF --disable-lsmash"  
  
FF_CFG_CONF="$FF_CFG_CONF --host=$FF_HOST"  
FF_CFG_CONF="$FF_CFG_CONF --cross-prefix=$FF_CROSS_PREFIX"  
FF_CFG_CONF="$FF_CFG_CONF --sysroot=$FF_PLATFORM"  

# 优化参数
OPTIMIZE_CFLAGS="-Os -fpic -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "

FF_CFG_CONF="$FF_CFG_CONF --extra-cflags=$OPTIMIZE_CFLAGS"

  
echo $FF_CFG_CONF
echo  
#配置   
./configure $FF_CFG_CONF  
#编译 
make clean 
make -j4
#安装  
make install  