#!/bin/bash
#title           :install.sh
#description     :Installation of tools to compile sc16is7xx driver.
#source1         :http://www.blaess.fr/christophe/2014/03/06/compilation-native-de-modules-kernel-sur-raspberry-pi/
#source2         :https://www.raspberrypi.org/documentation/linux/kernel/building.md

sudo apt-get install bc git libncurses5-dev

# 1 download driver c source file and create Makefile
wget https://raw.githubusercontent.com/torvalds/linux/v4.2-rc3/drivers/tty/serial/sc16is7xx.c
cat <<\EOF > Makefile
ifneq (${KERNELRELEASE},)
	obj-m  = sc16is7xx.o
else
	KERNEL_DIR ?= /lib/modules/$(shell uname -r)/build
	MODULE_DIR := $(shell pwd)

.PHONY: all

all: modules

.PHONY:modules

modules:
	${MAKE} -C ${KERNEL_DIR} SUBDIRS=${MODULE_DIR}  modules

clean:
	rm -f *.o *.ko *.mod.c .*.o .*.ko .*.mod.c .*.cmd *~
	rm -f Module.symvers Module.markers modules.order
	rm -rf .tmp_versions
endif
EOF

# 2 download rpi linux sources
git clone --depth=1 https://github.com/raspberrypi/linux

# 3 Kernel configuration for RPI2/3
cd linux
KERNEL=kernel7
make bcm2709_defconfig


# Here is an optional graphical configuration of your kernel you can do your kernel lighter to compile
#make menuconfig

# 4 Compilation
make -j4 zImage modules dtbs

# 5 Modules tree creation
sudo make modules_install

# 6 Put the new kernel in place
sudo cp arch/arm/boot/dts/*.dtb /boot/
sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/
sudo scripts/mkknlimg arch/arm/boot/zImage /boot/$KERNEL.img

echo "Now you RPI have to reboot.\n"
echo "Please start 'module_setup.sh' after reboot"

sudo reboot
