#!/bin/csh -f

if ( $OSTYPE == "linux" ) then
	echo OSTYPE is linux
	vsim work.test \
	-pli ./c/convert_hex2ver/libvpi_modeltech.so \
	-pli ./c/pan/libvpi_modeltech.so \
	-i -t ps -do ./do/$2.do -wav ./wav/$1.wlf -l ./log/$1.log
else if ($OSTYPE == "posix") then
	echo OS is Windows_NT
	vsim work.test \
	-pli ./c/convert_hex2ver/libvpi_modeltech.dll \
	-pli ./c/pan/libvpi_modeltech.dll \
	-i -t ps -do ./do/$2.do -wav ./wav/$1.wlf -l ./log/$1.log
else
	echo OSTYPE-OS is unknow
endif

