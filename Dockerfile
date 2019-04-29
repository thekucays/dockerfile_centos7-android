#!/bin/bash
#
# This script is designed to install the Android SDK on CentOS 7
# 
# Author: Maik Hinrichs <maik@mahiso.de>
#
# This is a fork of
#	http://linuxundich.de/static/android_sdk_installer.sh
#

INSTALLDIR=/opt/android-sdk

i=$(cat /proc/$PPID/cmdline)
if [[ $UID != 0 ]]; then
    echo "Please type sudo $0 $*to use this."
    exit 1
fi

#Download and install the Android SDK
if [ ! -d "$INSTALLDIR" ]; then
    for a in $( wget -qO- http://developer.android.com/sdk/index.html | egrep -o "http://dl.google.com[^\"']*linux.tgz" ); do
        wget $a && tar --wildcards --no-anchored -xvzf android-sdk_*-linux.tgz; mv android-sdk-linux $INSTALLDIR; chown -R root:root $INSTALLDIR; chmod 755 -R $INSTALLDIR; rm android-sdk_*-linux.tgz;
    done
else
     echo "Android SDK already installed to $INSTALLDIR.  Skipping."
fi

d=ia32-libs

#Determine if there is a 32 or 64-bit operating system installed and then install ia32-libs if necessary.

if [[ `getconf LONG_BIT` = "64" ]];
then
    echo "64-bit operating system detected.  Checking to see if $d is installed."

    if [[ $(dpkg-query -f'${Status}' --show $d 2>/dev/null) = *\ installed ]]; then
        echo "$d already installed."
    else
        echo "Installing now..."
	yum -y install glibc.i686 glibc-devel.i686 libstdc++.i686 zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 libXrender.i686 libXrandr.i686
    fi
else
    echo "32-bit operating system detected.  Skipping."
fi


# Check if the ADB environment is set up.
if grep -q $INSTALLDIR/platform-tools /etc/bashrc;
then
    echo "ADB environment already set up"
else
    echo "export PATH=\$PATH:$INSTALLDIR/platform-tools" >> /etc/bashrc
fi

# Set ddms symlink.
ln -sf $INSTALLDIR/tools/ddms /bin/ddms

# Create /etc/udev/rules.d/99-android.rules file
cat <<EOT >> /etc/udev/rules.d/99-android.rules 
# Acer
SUBSYSTEM=="usb", SYSFS{idVendor}=="0502", MODE="0666"
# ASUS
SUBSYSTEM=="usb", SYSFS{idVendor}=="0b05", MODE="0666"
# Dell
SUBSYSTEM=="usb", SYSFS{idVendor}=="413c", MODE="0666"
# Foxconn
SUBSYSTEM=="usb", SYSFS{idVendor}=="0489", MODE="0666"
# Garmin-Asus
SUBSYSTEM=="usb", SYSFS{idVendor}=="091E", MODE="0666"
# Google
SUBSYSTEM=="usb", SYSFS{idVendor}=="18d1", MODE="0666"
# HTC
SUBSYSTEM=="usb", SYSFS{idVendor}=="0bb4", MODE="0666"
# Huawei
SUBSYSTEM=="usb", SYSFS{idVendor}=="12d1", MODE="0666"
# K-Touch
SUBSYSTEM=="usb", SYSFS{idVendor}=="24e3", MODE="0666"
# KT Tech
SUBSYSTEM=="usb", SYSFS{idVendor}=="2116", MODE="0666"
# Kyocera
SUBSYSTEM=="usb", SYSFS{idVendor}=="0482", MODE="0666"
# Lenevo
SUBSYSTEM=="usb", SYSFS{idVendor}=="17EF", MODE="0666"
# LG
SUBSYSTEM=="usb", SYSFS{idVendor}=="1004", MODE="0666"
# Motorola
SUBSYSTEM=="usb", SYSFS{idVendor}=="22b8", MODE="0666"
# NEC
SUBSYSTEM=="usb", SYSFS{idVendor}=="0409", MODE="0666"
# Nook
SUBSYSTEM=="usb", SYSFS{idVendor}=="2080", MODE="0666"
# Nvidia
SUBSYSTEM=="usb", SYSFS{idVendor}=="0955", MODE="0666"
# OTGV
SUBSYSTEM=="usb", SYSFS{idVendor}=="2257", MODE="0666"
# Pantech
SUBSYSTEM=="usb", SYSFS{idVendor}=="10A9", MODE="0666"
# Philips
SUBSYSTEM=="usb", SYSFS{idVendor}=="0471", MODE="0666"
# PMC-Sierra
SUBSYSTEM=="usb", SYSFS{idVendor}=="04da", MODE="0666"
# Qualcomm
SUBSYSTEM=="usb", SYSFS{idVendor}=="05c6", MODE="0666"
# SK Telesys
SUBSYSTEM=="usb", SYSFS{idVendor}=="1f53", MODE="0666"
# Samsung
SUBSYSTEM=="usb", SYSFS{idVendor}=="04e8", MODE="0666"
# Sharp
SUBSYSTEM=="usb", SYSFS{idVendor}=="04dd", MODE="0666"
# Dony Ericsson
SUBSYSTEM=="usb", SYSFS{idVendor}=="0fce", MODE="0666"
# Toshiba
SUBSYSTEM=="usb", SYSFS{idVendor}=="0930", MODE="0666"
# ZTE
SUBSYSTEM=="usb", SYSFS{idVendor}=="19D2", MODE="0666"
EOT

chmod a+r /etc/udev/rules.d/99-android.rules

#Check if ADB is already installed
if [ ! -f "$INSTADIR/platform-tools/adb" ];
then
nohup $INSTALLDIR/tools/android update sdk > /dev/null 2>&1 &
echo "Please accept the licensing agreement for Android SDK Platform-tools."
else
echo "Android Debug Bridge already detected."
fi
exit