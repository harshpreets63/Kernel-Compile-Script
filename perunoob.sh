#Kernel-Compiling-Script

#!/bin/bash
# Kernel Clonning Script
if [ -d "Anykernel" ]; then
 echo "AnyKernel Exist Skipping Download"
 else
git clone --depth=1 https://github.com/harshpreets63/AnyKernel3 Anykernel
fi
if [ -d "CLANG-13" ]; then
 echo "CLANG Exist Skipping Download"
 else
git clone --depth=1 https://github.com/kdrag0n/proton-clang CLANG-13
fi
if [ -d "scripts/ufdt/libufdt" ]; then
echo "LIBUFDT Exist Skipping Download"
else
git clone https://android.googlesource.com/platform/system/libufdt scripts/ufdt/libufdt
fi
KERNEL_DIR="$(pwd)"
FINAL_DIR="$KERNEL_DIR/Final"

export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST="Beast"
export KBUILD_BUILD_USER="Harsh"
MAKE="./makeparallel"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Set Date
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")

TC_DIR="$KERNEL_DIR"
MPATH="$TC_DIR/CLANG-13/bin/:$PATH"
rm -f out/arch/arm64/boot/Image.gz-dtb
make O=out vendor/violet-perf_defconfig
PATH="$MPATH" make -j16 O=out \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    LD=ld.lld \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        CC=clang \
        AR=llvm-ar \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip
        2>&1 | tee error.log


python2 scripts/ufdt/libufdt/utils/src/mkdtboimg.py create out/arch/arm64/boot/dtbo.img --page_size=4096 out/arch/arm64/boot/dts/qcom/sm6150-idp-overlay.dtbo
cp out/arch/arm64/boot/Image.gz-dtb $KERNEL_DIR/Anykernel
cp out/arch/arm64/boot/dtbo.img $KERNEL_DIR/Anykernel

if [ -f "$KERNEL_DIR/Anykernel/Image.gz-dtb" ]; then
    #zip -r9 $KERNEL_DIR/Anykernel/PeruNoob-$DATE.zip"* -x .git README.md *placeholder
    cd $KERNEL_DIR/Anykernel
    zip -r PeruNoob-$DATE.zip * -x .git README.md *.zip
cp  $KERNEL_DIR/Anykernel/PeruNoob-$DATE.zip $KERNEL_DIR/
rm  $KERNEL_DIR/Anykernel/Image.gz-dtb
rm  $KERNEL_DIR/Anykernel/PeruNoob-$DATE.zip

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"

    echo "Build success!"
    echo "Uploading Build"
    curl --upload-file $KERNEL_DIR/PeruNoob-"$DATE".zip https://transfer.sh/PeruNoob-"$DATE".zip
else
    echo "Build failed!"
   
fi
