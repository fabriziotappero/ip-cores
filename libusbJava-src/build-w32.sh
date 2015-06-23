#!/bin/bash

export PATH=/drv_t1/mingw/w32/bin:$PATH
triple=i686-pc-mingw32
JAVAPREFIX=/usr/local/java
TARGET=libusbJava32.dll

$triple-gcc -m32 -shared -std=c99 -Wall -Wno-pointer-to-int-cast -D_JNI_IMPLEMENTATION_ -Wl,--kill-at \
    -I$JAVAPREFIX/include -I$JAVAPREFIX/include/win32 -I../libusb-win32 -L../libusb-win32/x86 LibusbJava.c -lusb0_x86 -o libusbJava32.dll
#    -I$JAVAPREFIX/include -I$JAVAPREFIX/include/win32 -I../libusb-win32 LibusbJava.c ../libusb-win32/libusb.a -o libusbJava.dll

$triple-strip $TARGET

chmod -x $TARGET

