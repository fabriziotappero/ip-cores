This directory contains a number of software demos, small programs meant to
demostrate usage of the light52 core.

All the demos use either the ASEM51 assembler or the SDCC compiler. Each demo
includes a DOS BAT make script or a makefile, plus a small readme file.

All the demos target the default MCU, for which support code is included in
directory 'common'.

Please see file /doc/quickstart.txt for instructions on building a demo on
actual hardware.

Software demos:
----------------

cpu_test:       Executes and tests all opcodes -- very basic, not exhaustive.
hello_asm:      'Hello World' in assembler.
hello_c:        'Hello World' in C. Demonstrates usage of SDCC with light52.
irq_test:       Basic test of interrupt handling.
dhrystone:


Support directories shared by all demos:
-----------------------------------------

include:        C and ASM include files, plus makefile include.
common:         C 'board support package' plus other common files.

