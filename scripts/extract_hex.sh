#!/bin/bash
# The Potato Processor - A simple processor for FPGAs
# (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
# Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

# This script extracts the code and data sections from executables and
# produces hex files that can be used to initialize the instruction and
# data memories in the testbench.

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
	echo "exctract_hex <input elf file> <imem hex file> <dmem hex file>"
	exit 1
fi

if [ -z "$TOOLCHAIN_PREFIX" ]; then
	TOOLCHAIN_PREFIX=riscv64-unknown-elf
fi;

$TOOLCHAIN_PREFIX-objdump -d -w $1 | sed '1,5d' | awk '!/:$/ { print $2; }' | sed '/^$/d' > $2; \
test -z "$($TOOLCHAIN_PREFIX-readelf -l $1 | grep .data)" || \
	$TOOLCHAIN_PREFIX-objdump -s -j .data $1 | sed '1,4d' | \
	awk '!/:$/ { for (i = 2; i < 6; i++) print $i; }' | sed '/^$/d' > $3;

exit 0

