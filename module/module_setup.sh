#!/bin/bash
#title           :module_setup.sh
#description     :This script compile the sc16is7xx driver and insert it.
#source1		 :http://stackoverflow.com/questions/4356224/how-to-load-a-custom-module-at-the-boot-time-in-ubuntu
#source2		 :https://github.com/sonelu/poppy-experiments/blob/master/Hipi/sc16is762-spi-overlay.dts

sudo apt-get install device-tree-compiler

# 1 build the driver for you new kernel
make

# 2 create device tree configuration and install it
cat <<\EOF > sc16is750-spi-overlay.dts
// Definition for the SC16IS750 UART
/dts-v1/;
/plugin/;

/ {
	compatible = "brcm,bcm2709";

	fragment@0 {
		target = <&spi0>;
		__overlay__ {
			#address_cells = <1>;
			#size-cells = <0>;
			status = "okay";

			/* disable spidev */
			spidev@0 {
				status = "disabled";
			};

			spidev@1 {
				status = "disabled";
			};

			sc16is750: sc16is750@0 {
				compatible = "nxp,sc16is750";
				reg = <0>;
				clocks = <&sc16is750_clock>;
				interrupt-parent = <&gpio>;
				interrupts = <255 2>; /* high-to-low edge triggered */
				gpio-controller;
				#gpio-cells = <2>;
				spi-max-frequency = <4000000>;
			};
		};
	};

	fragment@1 {
		target = <&clocks>;
		__overlay__ {
			#address-cells = <1>;
			#size_cells = <0>;
			status = "okay";

			sc16is750_clock: sc16is750_clock@10 {
				compatible = "fixed-clock";
				reg = <10>;
				#clock-cells = <0>;
				clock-output-name = "sc16is750";
				clock-frequency = <0>;
			};
		};
	};

	fragment@2 {
		target = <&gpio>;
		__overlay__ {
			sc16is750_pins: sc16is750_pins {
				brcm,pins = <255>;
				brcm,function = <0>; /* in */
			};
		};
	};

	__overrides__ {
		clkrate = <&sc16is750_clock>,"clock-frequency:0";
		irqpin = <&sc16is750>, "interrupts:0", <&sc16is750_pins>,"brcm,pins:0";
	};
};
EOF
dtc -@ -I dts -O dtb -o sc16is750-spi-overlay.dtb sc16is750-spi-overlay.dts
sudo cp sc16is750-spi-overlay.dtb /boot/overlays/
echo "# spi => UART" | sudo tee -a /boot/config.txt
echo "dtoverlay=sc16is750-spi,clkrate=14745600,irqpin=25" | sudo tee -a /boot/config.txt

# 3 start the new module at boot
sudo cp sc16is7xx.ko /lib/modules/$(uname -r)/kernel/drivers/
echo 'sc16is7xx' | sudo tee -a /etc/modules
sudo depmod

sudo reboot

