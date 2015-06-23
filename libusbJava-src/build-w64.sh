#!/bin/bash

export PATH=/drv_t1/mingw/w64/bin:$PATH
triple=x86_64-w64-mingw32
JAVAPREFIX=/usr/local/java
TARGET=libusbJava64.dll

$triple-gcc -m64 -shared -std=c99 -Wall -Wno-pointer-to-int-cast -D_JNI_IMPLEMENTATION_ -Wl,--kill-at \
    -I$JAVAPREFIX/include -I$JAVAPREFIX/include/win32 -I../libusb-win32 -L../libusb-win32/amd64 LibusbJava.c -lusb0 -o $TARGET

$triple-strip $TARGET

chmod -x $TARGET

