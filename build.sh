#!/bin/bash
COMMIT=$(git rev-parse --verify --short=8 HEAD)
DATE=$(date '+%m%d%H%M')
VERSION=GHOST-R5T-$DATE-${COMMIT^^}
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
O=$(realpath ../out)
AK3=$(realpath ../AnyKernel3)
CONFIG=vendor/r5t_defconfig

regen_config() {
	make O=$O \
		ARCH=$ARCH \
		CROSS_COMPILE=$CROSS_COMPILE \
		LLVM=1 \
		LLVM_IAS=1 \
		$CONFIG
}

build_kernel() {
	regen_config
	make -j$(getconf _NPROCESSORS_ONLN) \
		O=$O \
		ARCH=$ARCH \
		CROSS_COMPILE=$CROSS_COMPILE \
		LLVM=1 \
		LLVM_IAS=1 \
		2>&1 | tee ../log-$DATE.txt
}

zip_kernel() {
	cd $AK3
	rm -f Image* dtb* modules/system/lib/modules/*.ko ../$VERSION.zip
	if [ "$(grep "^CONFIG_MODULES=" $O/.config | cut -d= -f2-)" == "y" ]; then
		find $O -type f -iname '*.ko' -exec cp {} modules/system/lib/modules/ \;
	fi
	if [ "$(grep "^CONFIG_BUILD_ARM64_DT_OVERLAY=" $O/.config | cut -d= -f2-)" == "y" ]; then
		cp $O/arch/$ARCH/boot/dtbo.img .
	fi
	cp $O/arch/$ARCH/boot/Image.gz-dtb .
	zip -r9 ../$VERSION.zip * -x .git* README.md placeholder
	realpath ../$VERSION.zip
}

if [ $CLANG_PATH ]; then
	export PATH=$CLANG_PATH/bin:$PATH
	clang -v 2>&1 | grep ' version ' | sed 's/[[:space:]]*$//'
fi

if [ "$1" == "c" ]; then
	rm -rf $O
elif [ "$1" == "r" ]; then
	regen_config
	cp $O/.config arch/$ARCH/configs/$CONFIG
	git diff arch/$ARCH/configs/$CONFIG
	exit
fi

build_kernel
if [ -d $AK3 ] && [ -f $O/arch/$ARCH/boot/Image.gz-dtb ]; then
	zip_kernel
fi
