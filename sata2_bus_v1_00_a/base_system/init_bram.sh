#!/bin/bash

export PATH=$PATH:$XILINX_EDK/gnu/microblaze/lin/bin/

mb-gcc -O2 sata_test/sata_test.c  -o sata_test/executable.elf \
	    -mno-xl-soft-mul -mxl-pattern-compare -mcpu=v7.20.d   -g    -I./microblaze_0/include/  -L./microblaze_0/lib/  \

data2mem -bm implementation/system_bd -bt implementation/system.bit  -bd sata_test/executable.elf tag microblaze_0  -o b implementation/download.bit
