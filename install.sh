#!/bin/sh

function mktool() {
if [ ! -e configure ]; then
	if [ ! -x ./autogen.sh ]; then
		chmod a+x ./autogen.sh
		chmod a+x ./cleanup.sh
	fi
	./autogen.sh
	if [ $? -ne 0 ]; then
		exit 1
	fi
	./configure $1
	if [ $? -ne 0 ]; then
		exit 1
	fi
fi
make
sudo make install
}

DIR_UTLS=$( cd "$( dirname "$0" )" && pwd )
DIR_TEST=`pwd`
DIR_DRV=$DIR_TEST/drivers/usb/usbip
DIR_TOOL=$DIR_TEST/tools/usb/usbip
DIR_EX=$DIR_TEST/tools/usb/usbip/api-example
DIR_LIBUSB_TOOL=$DIR_TEST/tools/usb/usbip/libusb
KERNEL=`uname -r`
DIR_KERNEL=/lib/modules/$KERNEL/build
DIR_UAPI_INC=/usr/include/linux

sudo cp $DIR_TEST/include/uapi/linux/usbip_ux.h $DIR_KERNEL/include/uapi/linux/

sudo cp $DIR_TEST/include/uapi/linux/usbip_ux.h $DIR_UAPI_INC/

sudo cp $DIR_TEST/include/uapi/linux/usbip_api.h $DIR_UAPI_INC/

pushd .
cd $DIR_DRV
make
popd

pushd .
cd $DIR_TOOL
mktool
popd

if [ -e $DIR_LIBUSB_TOOL ]; then
pushd .
cd $DIR_LIBUSB_TOOL
mktool "--with-dummy-driver"
popd
fi

if [ -e $DIR_EX ]; then
pushd .
cd $DIR_EX
mktool
popd
fi