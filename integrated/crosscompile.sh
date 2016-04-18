#!/bin/bash
#title           :crosscompile.sh
#description     :This script compile rpi 2/3 imagee with the sc16is7xx driver.
#source1         :https://www.raspberrypi.org/documentation/linux/kernel/building.md
#source2         :http://stackoverflow.com/questions/11710022/adding-new-driver-code-to-linux-source-code


# 0 download and install toolchain


# **get sources**

# 1 download rpi linux
git clone --depth=1 https://github.com/raspberrypi/linux

# 2 download driver c source file and insert it on linux sources
cd linux/drivers/
mkdir sc16is7xx
cd sc16is7xx/
wget https://raw.githubusercontent.com/torvalds/linux/v4.2-rc3/drivers/tty/serial/sc16is7xx.c

cat <<\EOF > Makefile
obj-$(CONFIG_SC16IS7XX) += sc16is7xx.o
EOF

cat <<\EOF > Kconfig
config SC16IS7XX
tristate "sc16is7xx driver : SPI/I2C => UART"
depends on ARM
default y if ARM
help
  my driver module.
EOF

cd ..

cat <<\EOF >> Makefile
obj-$(CONFIG_SC16IS7XX)		+= sc16is7xx/
EOF

sed -i.bkp "/^endmenu/i #sc16is7xx driver\nsource \"drivers/sc16is7xx/Kconfig\"\n" Kconfig

cd ..

echo "CONFIG_SC16IS7XX=y" >> arch/arm/configs/bcm2709_defconfig

# 3 kernel configuration for pi2/3
cd linux
KERNEL=kernel7
make -j6 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig

# Here is an optional graphical configuration of your kernel
#make menuconfig

# 4 Compilation
make -j6 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
