
This is a Mini-RISC CPU/Microcontroller that is mostly compatible with the
PIC 16C57 from Microchip.


Legal
=====

PIC, Microship, etc. are Trademarks of Microchip Technology Inc.

I have no idea if implementing this core will or will not violate
patents, copyrights or cause any other type of lawsuits.

I provide this core AS IS, without any warrenties. If you decide to
build this core, you are responsible for any legal resolutions, such
as patents and copyrights, and perhaps others ....

	This source file(s) may be used and distributed without
	restriction provided that this copyright statement is not
	removed from the file and that any derivative work contains
	the original copyright notice and the associated disclaimer.

	THIS SOURCE FILE(S) IS/ARE PROVIDED "AS IS" AND WITHOUT ANY
	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT
	LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND
	FITNESS FOR A PARTICULAR PURPOSE.


Motivation
==========

After seeing the "free_risc8" on the free-ip web site, I got excited
and downloaded the core. Pretty soon I found out that it had many
many errors and omissions from the original 16C57. So I started looking
at the code. This is when I realized it was very badly designed and
could not be made run faster. So, I sat down and wrote my own PIC IP
core last night. A lot of work was spend in writing test code to ensure
that it was 100% compatible from the software point of view.

- A PIC compatible Microcontroller that runs a lot faster
- Separate (External to the core) Program Memory
- Options to extend the core


Compatibility
=============

This design should be fully software compatible to the Microchip Implementation
of the PIC 16C57, except for the following extensions:

- Port A is full 8 bits wide
- Hardware stack is 4 level deep [original 2 levels] (can be easily expanded)
- Executions of instructions that modify the PC has become a lot more expensive
  due to the pipeline and execution of instructions on every cycle.
  Any instruction that writes to the PC (PC as destination (f), call, goto, retlw)
  now takes 4 cycles to execute (instead of 2 in the origianl implementation).
  The 4 'skip' instructions, remain as in the original implmentation: 1 cycle
  if not skipped, 2 cycles if skipped.
- Sampling of IO ports might be off
- Timer and watchdog might be off a few cycles


Performance
===========

- Single cycle instruction execution, except as noted above.
- Here are results of some sample implementations:
  - Xilinx Spartan 2e ((Device: xc2s50e-6): Fmax: 80Mhz, Utilization: 30%
  - Xilinx Spartan2 (Device: xc2s30-6-cs144): Fmax: 50Mhz, Utilization: 66%, Ports: Tsu: 2.2nS, Tcq: 7.7nS
  - Xilinx Virtex   (Device: xcv50-4-cs144) : Fmax: 40Mhz, Utilization: 35%, Ports: Tsu: 3.0nS, Tcq: 6.2nS
  - Xilinx VirtexE  (Device: xcv50e-8-cs144): Fmax: 66Mhz, Utilization: 35%, Ports: Tsu: 1.7nS, Tcq: 4.5nS
  Half of the cycle time is spend in routing delays. My guess is that by placing
  proper locatiuon contrains and guiding the back-end tools, a significant
  speed improvement can be achieved ....
- I estimat about 25K gates with the xilinx primitives, (excluding Register
  File and Programm Memory).

Implementing the core
=====================

The only file you should edit if you really want to implement this core, is the
'primitives.v' file. It contains all parts that can be optimized, depending on
the technology used. It includes memories, and arithmetic modules.
I added a primitives_xilinx,v file and xilinx_primitives.zip which contain
primitives for xilinx.
'risc_core.v' is the top level without program memory and tristate Io buffers for ports.
This is probably a good starting point if you want to instantiate the core in to a larger
design. If you just want a PIC clone, take a loot at 'risc_core_top.v', it was written
with Xilinx FPGAs in mind, but should be easily addaptred to other vendors FPGAs - just
replace the memory blocks ...

To-Do
=====

Things that need to be done

1) Write more test/compliance test vectors
   - Verify that all instructions after a goto/call/retlw/write to PCL are not executed
   - Verify ALU
   - Timer and Watchdog tests
   - Perhaps some other ereas ?

2) Extensions ?
   - I guess this is on a "as needed" basis
   - A friend suggested to add registers that can be shared by two or more cores in a MP type configuration

Author
======

I have been doing ASIC design, verification and synthesis for over 15 years.
This core is only a "mid-night hack", and should used with caution.

I'd also like to know if anyone will actually use this core. Please send me a
note if you will !

Rudolf Usselmann
russelmann@hotmail.com

Feel free to send me comments, suggestions and bug reports.

