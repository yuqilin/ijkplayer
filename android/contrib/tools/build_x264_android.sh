set -e

# ANDROID_NDK=~/tools/android-ndk-r10d
# ANDROID_NDK=/Users/yuqilin/tools/adt-bundle-mac-x86_64-20140702/sdk/ndk-bundle
#############################
# check Android NDK
#############################
if [ -z "${ANDROID_NDK}" -a -z "${NDK_PATH}" ]; then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+     You have to export your ANDROID_NDK or NDK_PATH at first.    +"
    echo "+     They should point to your NDK directories.                   +"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
    exit 1
fi
if [ -z "${ANDROID_NDK}" -a -n "${NDK_PATH}" ]; then
    ANDROID_NDK=${NDK_PATH}
fi
echo "ANDROID_NDK=${ANDROID_NDK}"

UNAME_S=$(uname -s)
UNAME_SM=$(uname -sm)
echo "build on $UNAME_SM"

info() {
    local green='\033[32m'
    local normal='\033[0m'
    echo "[${green}info${normal}] $1"
}

spushd() {
    pushd "$1" 2>&1> /dev/null
}

spopd() {
    popd 2>&1> /dev/null
}

# try to detect NDK version
# ANDROID_NDK_REL=$(grep -o '^r[0-9]*.*' $ANDROID_NDK/RELEASE.TXT 2>/dev/null|cut -b2-)
# case "$ANDROID_NDK_REL" in
#     9*|10*)
#         # we don't use 4.4.3 because it doesn't handle threads correctly.
#         if test -d ${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.8
#         # if gcc 4.8 is present, it's there for all the archs (x86, mips, arm)
#         then
#             echo "NDKr$ANDROID_NDK_REL detected"
#         else
#             echo "You need the NDKr9 or later"
#             exit 1
#         fi
#     ;;
#     *)
#         echo "You need the NDKr9 or later"
#         exit 1
#     ;;
# esac

# check make flags
MAKEFLAGS=
if which nproc >/dev/null
then
    MAKEFLAGS=-j`nproc`
elif [ "${UNAME_S}" == "Darwin" ] && which sysctl >/dev/null
then
    MAKEFLAGS=-j`sysctl -n machdep.cpu.thread_count`
fi
info "MAKEFLAGS=$MAKEFLAGS"

#--------------------
# common defines
#--------------------
BASE_DIR=$(cd "$(dirname "$0")"; pwd)
BUILD_ROOT=${BASE_DIR}/../build
# BUILD_ROOT=$(cd "$(dirname "$0")"; pwd)/build_out
# THIRD_PARTY=${BUILD_ROOT}/../../../thirdparty

# mkdir -p "${BUILD_ROOT}"

X264_VERSION=
# X264_ROOT=${BASE_DIR}/../../../extra/libx264

ANDROID_PLATFORM=android-9
GCC_VER=4.9
GCC_64_VER=4.9

BUILD_NAME=

build_x264() {
    echo "--------------------"
    info "build x264 for arch ${TARGET_ARCH}"
    echo "--------------------"

    X264_ARCH_SRC=${BASE_DIR}/../$BUILD_NAME
    # echo X264_ARCH_SRC=$X264_ARCH_SRC
    # mkdir -p ${X264_ARCH_SRC}
    # cp -a ${X264_ROOT}/* ${X264_ARCH_SRC}

    spushd ${X264_ARCH_SRC}

    echo "--------------------"
    info "configure x264"
    echo "--------------------"

    ./configure \
        --prefix=${PREFIX} \
        --cross-prefix=${TARGET_HOST}- \
        --sysroot=${PLATFORM_SYSROOT} \
        --host=${TARGET_HOST_CPU} \
        --extra-cflags="-O2 -g -DANDROID -D__ANDROID__ -DHAVE_PTHREAD -DHAVE_SYS_UIO_H=1 ${EXTRA_CFLAGS} -I${PREFIX}/include" \
        --extra-ldflags="-Wl,-rpath-link=${PLATFORM_SYSROOT}/usr/lib ${EXTRA_LDFLAGS} -L${PLATFORM_SYSROOT}/usr/lib -nostdlib -lc -lm -ldl -llog -lgcc -L${PREFIX}/lib" \
        --enable-static \
        --disable-cli \
        --enable-pic \
        $FF_CFG_FLAGS

    echo "--------------------"
    info "compile x264"
    echo "--------------------"

    make $MAKEFLAGS
    make install

    info "build x264 OK"

    spopd

}

TARGET_ARCHS="armeabi-v7a"
PATH_BAKUP=$PATH

for TARGET_ARCH in $TARGET_ARCHS
do
    # common for archs
    # PREFIX="${BUILD_ROOT}/${TARGET_ARCH}/install"

    # diff for archs
    if [ "${TARGET_ARCH}" = "armeabi" ]; then
        BUILD_NAME=libx264-armv5
        ANDROID_PLATFORM=android-9
        ARCH=arm
        TARGET_HOST=arm-linux-androideabi
        TARGET_HOST_CPU=armv6-linux
        PLATFORM_SYSROOT=${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-arm

        NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
        info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

        #"-marm -march=armv6 -mfloat-abi=softfp -mfpu=vfp"
        EXTRA_CFLAGS=""
        EXTRA_LDFLAGS=

    elif [ "$TARGET_ARCH" = "armeabi-v7a" ]; then
        BUILD_NAME=libx264-armv7a
        ANDROID_PLATFORM=android-9
        ARCH=arm
        TARGET_HOST=arm-linux-androideabi
        TARGET_HOST_CPU=armv7-linux
        PLATFORM_SYSROOT=${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-arm

        NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
        info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

        EXTRA_CFLAGS="-march=armv7-a -fomit-frame-pointer -mfloat-abi=softfp -mfpu=neon"
        EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
        FF_CFG_FLAGS=

    elif [ "$TARGET_ARCH" = "arm64-v8a" ]; then
        BUILD_NAME=libx264-arm64
        ANDROID_PLATFORM=android-21
        ARCH=aarch64
        TARGET_HOST=aarch64-linux-android
        TARGET_HOST_CPU=aarch64-linux
        PLATFORM_SYSROOT=${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-arm64

        NDK_TOOLCHAIN_PREBUILT=`echo ${ANDROID_NDK}/toolchains/${TARGET_HOST}-${GCC_64_VER}/prebuilt/\`uname|tr A-Z a-z\`-*`
        info "NDK_TOOLCHAIN_PREBUILT=$NDK_TOOLCHAIN_PREBUILT"

        EXTRA_CFLAGS=""
        EXTRA_LDFLAGS=
        FF_CFG_FLAGS=

    fi

    export PATH=${NDK_TOOLCHAIN_PREBUILT}/bin:${PATH_BAKUP}
    info "PATH=$PATH"

    info "PLATFORM_SYSROOT=$PLATFORM_SYSROOT"

    export CC="${TARGET_HOST}-gcc --sysroot=${PLATFORM_SYSROOT}"
    export CXX="${TARGET_HOST}-g++ --sysroot=${PLATFORM_SYSROOT}"
    export AS="${TARGET_HOST}-gcc"
    export LD="${TARGET_HOST}-ld"
    export AR="${TARGET_HOST}-ar"
    export RANLIB="${TARGET_HOST}-ranlib"
    export STRIP="${TARGET_HOST}-strip"

    PREFIX=${BUILD_ROOT}/$BUILD_NAME

    build_x264
done
