#!/bin/bash
#title           :install.sh
#description     :This script install toochain for RPI.
#source          :http://www.blaess.fr/christophe/2014/03/06/compilation-native-de-modules-k$

apt-get -y install bc git libncurses5-dev

git clone https://github.com/raspberrypi/tools

echo "export PATH=$PATH:$(pwd)/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin" >> ~/.bashrc
