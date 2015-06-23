This is a minimalistic bootloader meant to run from BRAM.

Upon reset, it will read file '/code.bin' from the DE-1 board SD card, load it
at address 0x00000000 and then jump to that address.

Any program meant to be bootloaded in this way has to be compiled with link 
script 'xram.lds', and the binary renamed 'code.bin'. See the 'Adventure' demo
(makefile target 'sd') for an example.

In this directory you'll find a copy of the Adventure binary called 'code.bin'
that you can use to try the bootloader. Just put it in the root directory of 
a FAT32 SD card and load this demo (and hope the card format is understood by
the FAT library...).

This program is built around elm-chan's FAT32 library, which has been ported
to the ION SoC using a bitbanged interface. This should be easy to port to other
boards.

The binary will be truncated to 256KB.

Uses serial port console at 19200/8/N/1.


Run 'make demo' and synthesize as instructed for the 'Hello World' demo.


This program is meant to be synthesized and used as a bootloader for 
demonstration or development, running from BRAM. It is too large to be run from
BRAM in a real application; it should be modified to run from flash instead --
or you might use another bootloader, assuming you get it to compile and run
on the MIPS-I core...

This demo is not meant to be simulated in Modelsim or in software, no support
is provided for that.
