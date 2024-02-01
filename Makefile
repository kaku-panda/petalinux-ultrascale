TARGET     = peta_proj

default:
	petalinux-create -t project -n ${TARGET} --template zynqMP
	cd ${TARGET}; petalinux-config --get-hw-description=../hw
BSP:
	petalinux-create -t project -n ${TARGET} -s bsp/*bsp
	cd ${TARGET}; petalinux-config --get-hw-description=../hw
kernel:
	cd ${TARGET}; petalinux-config -c kernel
rootfs:
	echo "CONFIG_kernel-module-hdmi" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	echo "CONFIG_ffmpeg" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	echo "CONFIG_libdrm" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	echo "CONFIG_libdrm-dev" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	echo "CONFIG_libdrm-tests" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	echo "CONFIG_libdrm-drivers" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	echo "CONFIG_libdrm-kms" >> ${TARGET}/project-spec/meta-user/conf/user-rootfsconfig
	mkdir -p ./${TARGET}/project-spec/meta-user/recipes-support/opencv
	cp config/opencv_%.bbappend ${TARGET}/project-spec/meta-user/recipes-support/opencv/opencv_%.bbappend
	cd ${TARGET}; petalinux-config -c rootfs
build:
	cp ./config/system-user.dtsi ${TARGET}/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi
	cd ${TARGET}; petalinux-build
gen:
	cd ${TARGET}; petalinux-package --force --boot --fsbl images/linux/zynqmp_fsbl.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --uboot
genall:
	ls hw | awk '{printf "mkdir -p ./boot-img/%s \ncp ./hw/%s/system.bit ${TARGET}/images/linux/system.bit \ncd ${TARGET} \npetalinux-package --force --boot --fsbl images/linux/zynqmp_fsbl.elf --pmufw images/linux/pmufw.elf --fpga images/linux/system.bit --uboot \ncd ..\ncp ./${TARGET}/images/linux/BOOT.BIN ${TARGET}/images/linux/image.ub ${TARGET}/images/linux/boot.scr ./boot-img/%s\n", $$0, $$0, $$0}' | sh
lib:
	rm -rf ./${TARGET}/images/linux/rootfs
	mkdir  ./${TARGET}/images/linux/rootfs
	tar -zxvf ./${TARGET}/images/linux/rootfs.tar.gz -C ./${TARGET}/images/linux/rootfs
	mkdir -p ./lib
	mkdir -p ./lib/opencv
	rm -rf ./lib/opencv/*
	mkdir  ./lib/opencv/share ./lib/opencv/include ./lib/opencv/lib ./lib/opencv/lib/pkgconfig ./lib/opencv/bin
	cp -r  ./${TARGET}/images/linux/rootfs/usr/share/OpenCV            ./lib/opencv/share
	cp -ar ./${TARGET}/images/linux/rootfs/usr/lib/libopencv*.so*      ./lib/opencv/lib
	cp -r  ./${TARGET}/images/linux/rootfs/usr/lib/pkgconfig/opencv.pc ./lib/opencv/lib/pkgconfig
	cp -r  ./${TARGET}/images/linux/rootfs/usr/include/opencv          ./lib/opencv/include
	cp -r  ./${TARGET}/images/linux/rootfs/usr/include/opencv2         ./lib/opencv/include
	cp -r  ./${TARGET}/images/linux/rootfs/usr/bin/opencv*             ./lib/opencv/bin
	mkdir -p ./lib/libdrm
	rm -rf ./lib/libdrm/*
	mkdir  -p ./lib/libdrm/share ./lib/libdrm/include ./lib/libdrm/lib ./lib/libdrm/lib/pkgconfig ./lib/libdrm/bin
	cp -r  ./${TARGET}/images/linux/rootfs/usr/share/libdrm             ./lib/libdrm/share
	cp -ar ./${TARGET}/images/linux/rootfs/usr/lib//libdrm*.so*          ./lib/libdrm/lib
	cp -r  ./${TARGET}/images/linux/rootfs/usr/lib/pkgconfig/libdrm*.pc ./lib/libdrm/lib/pkgconfig
	cp -r  ./${TARGET}/images/linux/rootfs/usr/include/libdrm           ./lib/libdrm/include
	cp -r  ./${TARGET}/images/linux/rootfs/usr/bin/modetest             ./lib/libdrm/bin/modetest
	cp -r  ./${TARGET}/images/linux/rootfs/lib/modules                  ./lib
copy:
	scp ./${TARGET}/images/linux/BOOT.BIN ${TARGET}/images/linux/image.ub ${TARGET}/images/linux/boot.scr zcu102:~/
sd:
	sudo mount /dev/sdb1 ~/mnt
	sudo cp ${TARGET}/images/linux/BOOT.BIN ${TARGET}/images/linux/image.ub ${TARGET}/images/linux/boot.scr ~/mnt
	sudo umount ~/mnt
clean:
	rm -rf ${TARGET}
