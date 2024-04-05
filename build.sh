#!/bin/bash
DATE=$(date '+%m%d%H%M')
VERSION=GHOST-R5T-$DATE
AK3=$(realpath ../AnyKernel3)
O=$(realpath ../out)
DEFCONFIG=vendor/r5t_defconfig
FLAGS_ARRAY=(
	O=$O
	ARCH=arm64
	CROSS_COMPILE=aarch64-linux-android-
	CLANG_TRIPLE=aarch64-linux-gnu-
	LLVM=1
	LLVM_IAS=1
)

build_kernel() {
	rm -rf $O/arch/arm64/boot/
	make ${FLAGS_ARRAY[@]} $DEFCONFIG
	$(which time) -f "\nTotal build time: %E\n" make -j$(nproc --all) \
		${FLAGS_ARRAY[@]} 2>&1 | tee ../log-$DATE.txt
}

zip_kernel() {
	cd $AK3
	rm -f Image* dtb* modules/system/lib/modules/*.ko ../$VERSION.zip
	[ "$(grep "^CONFIG_MODULES=" $O/.config | cut -d= -f2-)" == "y" ] &&
		find $O -type f -iname '*.ko' -exec cp {} modules/system/lib/modules/ \;
	cp $O/arch/arm64/boot/Image.gz-dtb $O/arch/arm64/boot/dtbo.img .
	echo $(git rev-parse --verify HEAD) > HEAD
	zip -r9 ../$VERSION.zip * -x .git* README.md placeholder
	realpath ../$VERSION.zip
}

[ $CLANG_PATH ] && export PATH="$(realpath $CLANG_PATH)/bin:$PATH"
clang -v 2>&1 | grep ' version ' | sed 's/[[:space:]]*$//'
[ "$1" == "c" ] && rm -rf $O
[ "$1" == "r" ] && make ${FLAGS_ARRAY[@]} $DEFCONFIG &&
	cp $O/.config arch/arm64/configs/$DEFCONFIG &&
	git status arch/arm64/configs/$DEFCONFIG && exit
build_kernel
[ -d $AK3 ] && [ -f $O/arch/arm64/boot/Image.gz-dtb ] && zip_kernel
