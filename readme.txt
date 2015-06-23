 ============================================
===          ARM4U Documentation          ===
=           By Jonathan Masur, 2014         ==
= Made in spring 2014 for OpenCores release ==
 ============================================

 ****************
** Introduction **
 ****************
 
ARM4U is a "softcore" processor that was created in the context of an university project in the processor architecture laboratory at Ecole Polytechnique Fédérale de Lausanne ( http://lap.epfl.ch )

We decided, one year after the complexion of the project, to release the processor on the site OpenCores ( http://www.opencores.org ) for free under the GPL licence in order to make the source code and documentations available to the general public. It comes as-it with ABSOLUTELY NO WARRANTY.

The ARM4U processor clones early ARM processors in functionality, it implements the almost full ARMv3 instruction set, and can be targeted by the GCC toolchain. It is free for use and distribute for anyone. However, if someone ever make a cool use of this processor, I would of course be very happy to know about it.
This documentation doesn't cover the ARM by itself, for most info about the inner working of the processor (instruction set, etc...) please consult documentation of the ARM processors. This doccumentation instead covers how to use the softcore and what are the difference between it and a genuine ARM.

 **************************************
** Internal workings of the processor **
 *************************************

The processor works with a classical 5-stage RISC pipeline (Fetch, Decode, Execute, Memory, Writeback).
Since a drawing is worth a thousand words, schematics of the processor are joined. PLEASE CONSULT THE SCHEMATICS FOR UNDERSTANDING THE INNER WORKING OF THE PROCESSOR.

The processor was not build for extreme performance, nor for extreme minimization of FPGA resources. Instead it was build with the 3 goals of : simplicity, pedagogy, but fully working and usable result.

The CPU communicates with the external world (memory, I/O, etc...) through the Altera Avalon bus. The CPU can be used as a QSys component, just like the NIOS II processor furnished by Altera. However, it should be relatively straightforward to adapt it to another bus. We managed to synthesize a 50 MHz version using a Cyclone IV FPGA. The resource usage was only slightly larger than a NIOS II/s (standard), but the frequency was lower. However, the ARM instructions are more dense and efficient overall, and we can expect comparable performance between both CPU. No benchmarks were made to proof that.

The instruction cache allows to fetch instructions while reading/writing to memory, and to fetch a new instruction each cycle (hopefully) even if the memory has a read/write latency (DRAM).
There is no cache coherency : an attempt to write self-modifying code will not work unless some additional circuitry is added done.

 *************************************
** Differences with an authentic ARM **
 *************************************

The ARM4U behaves identically to an ARM implementing the ARMv3 instruction set (ARM6 generation) except for the following differences :

- Abort mode and interrupt doesn't exist
- There is no support for coprocessor, and related instructions
- There is no 24-bit (ARMv2) compatibility mode
- The 'msr' instruction always affect all status flags (you can't limit it to a part of the flags, leaving other flags unaffected)
- When an interrupt occurs, the status flags takes an hard-coded values. For conditional flags, this shouldn't be a problem, the only major difference is that the 'F' flag is cleared when an IRQ triggers, in other words, FIQs are enabled whenever an IRQ happens
- R15 (PC+8) can be used as an input for every instructions, and will always produce correct results, even when doing so is forbidden on an authentic ARM
- 'mul' and 'mla' instructions can be used for all operands and will always produce correct results, even when doing so is forbidden on an authentic ARM
- 'mlas' instruction will affect the overflow and carry flags based on the addition operation
- 'swap' and 'swapb' instructions are absent

 **************
** Interrupts **
 **************

The following interrupts are supported

- Reset
- IRQ
- FIQ ("fast IRQ")
- Software interrupt ('swi' instruction)
- Undefined instruction trap (any instruction not implemented)

The vectors, register bank switching, PSW and PC saving words exactly the same as on an authentic ARM. Other kinds of interrupts (namely, "abort") aren't supported.

 *******************
** Compiling notes **
 *******************

1) With GCC
VERY IMPORTANT : Always use command line options --fix-v4bx and -march=armv3 when compiling code for the ARM4U with GCC !

When compiling C code, use -Xassembler --fix-v4bx instead of plain --fix-v4bx

According to our tests and experiences, the difference between this processor and a genuine ARMv3 instruction set is normally too subtle to make compiled C code fail, but the CPU comes with *absolutely no warranty*.

2) With other compiler/assembler
Consult your compiler's documentation and make sure that no "new" instructions from more recent instruction sets than ARMv3 are ever used. It's possible to simulate them with the undefined instruction trap, too.

3) A note about endianness :
This CPU has been made "little endian", in the sense that individual byte access to memory are made in that order on the bus. That would be trivial to change by affecting the "memory.vhd" file, lines 77-80.

However, because of conversion issues of .hex files between 32-bit .hex files and 8-bit .hex files inside the Altera Quartus program, we had to use -EB option as well, in order to make the generated binary code appear in big endian in the hex file. The processor itself is not big endian. As far as we know, the -EB option in GCC has only 2 effects :

1) The generated file (either binary, hex, or object file) is written in the corresponding order
2) A bit in object file's header is affected so that it prevents linking big and little endian object files together
The -EB file doesn't affect the compiled code itself in any way, as far as we know.

 ****************
** Test program **
 ****************

A test program using all ARM instructions is included as an example, it was used to debug and proof correct operation of the processor.

Unfortunately the processor doesn't come with any debugger, so FPGA usage is a bit painful, as the whole hardware has to be re-downloaded for each change in the program, and the only way to debug program is using output LEDs or anything similar.

 ***********
** Contact **
 ***********

Contact me at jmasur [at] bluewin [dot] ch if needed.