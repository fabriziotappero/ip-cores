--
-- Risc5x
-- www.OpenCores.Org - November 2001
--
--
-- This library is free software; you can distribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details.
--
-- A RISC CPU core.
--
-- (c) Mike Johnson 2001. All Rights Reserved.
-- mikej@opencores.org for support or any other issues.
--
-- Revision list
--
-- version 1.1 bug fix: Used wrong bank select bits in direct addressing mode
--                      INDF register returns 0 when indirectly read
--                      FSR bit 8 always set
--                      (cpu.vhd file changed)
--
-- version 1.0 initial opencores release
--

Risc5x is a small RISC CPU written in VHDL that is compatible with the 12 bit
opcode PIC family. Single cycle operation normally, two cycles when the program
counter is modified. Clock speeds of over 40Mhz are possible when using the
Xilinx Virtex optimisations.


Legal Stuff

This core is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

You are responsible for any legal issues arising from the use of this core.

The source files may be used and distributed without restriction provided that
all copyright statements are not removed from the files and that any derivative
work contains the original copyright notices and the associated disclaimer.

PIC is a trademark of Microchip Technology Inc.


Features

The core has a single pipeline stage and is run from a single clock, so
(ignoring program counter changes) a 40Mhz clock will give 40 MIPS processing
speed. Any instruction which modifies the program counter, for example a branch
or skip, will result in a pipeline stall and this will only cost one additional
clock cycle.

The CPU architecture chosen is not particularly FPGA friendly, for example
multiplexers are generally quite expensive. The maximum combinatorial path delay
is also long, so to ease the place and route tool's job the core is written at a
low level. It instantiates a number of library macros, for example a 4:1 mux.
Two versions of these are given, one is generic VHDL and the second is optimised
for Xilinx Virtex series (including sparten2's etc). A constraints file locates
the data path macros within the device and ensures an easy fit and high clock
speed.

Performance & Size

The core builds to around 110 Virtex CLBS (depending on synthesis).

>33 Mhz in a Virtex e - 6
>40 Mhz in a Virtex e - 8

There's some good free tools out there including a compiler, simulator and
assembler (gusim & guasm for example).


Synthesis & File description :

Read the files in the following order.

** PACKAGES **
pkg_xilinx_prims.vhd    (package containing low level Virtex blocks)
                         only required if using Virtex optimised macros)
pkg_prims.vhd           (package containing macro components)
pkg_risc5x.vhd          (package containing some useful functions)

** MACROS / RTL MODELS **

mux8.vhd                (8 to 1 muxer)
mux4.vhd                (4 to 1 muxer)
mux2.vhd                (2 to 1 muxer)
mux2_add_reg.vhd        (load or +1, used for program counter)
alubit.vhd              (ALU bit functions)
add_sub.vhd             (add or subtract)


IMPORTANT : Each of the macros has TWO ARCHITECTURES, the first (VIRTEX) is for
Virtex series devices ONLY, including Virtex, Virtexe, Sparten2, Sparten2e etc.
The second (RTL) is generic VHDL, and is surrounded by synthesis directives :

 --pragma translate_off
 --pragma translate_on

This makes the synthesis tool ignores the second architecture, but the simulator
does not, resulting in optimal synthesis and fast simulation.

If you do not wish to target Virtex series devices, YOU MUST remove the --pragma
directives, and (optionally) delete the VIRTEX architecture.


A PROBLEM :  Some of the macros have generic attributes passed to them to define
bus width etc. Unfortunately when the same macro is used twice with different
generics some synthesis tools do not build a second copy of the macro. The
easiest way round this is to generate EDIF's for each macro that is required,
and then save it with the 'expected name'.


For example if the Xilinx tools say they cannot find a mux4_9_0_FALSE then
you would edit the default generics in mux4.vhd to

entity MUX4 is
  generic (
    WIDTH         : in  natural := 9;
    SLICE         : in  natural := 0; -- 1 left, 0 right
    OP_REG        : in  boolean := FALSE
    );
  port (

 and build it to mux4_9_0_false.edf.

 You may need to build the files with *'s below :

  MUX2_8_1_FALSE.edf        default so ok
  MUX2_7_1_FALSE.edf        *


  MUX4_8_1_FALSE.edf        default so ok
  MUX4_8_0_FALSE.edf        *
  MUX4_9_0_FALSE.edf        *
  MUX4_11_0_FALSE.edf       *

  MUX8_8_FALSE.edf          default so ok

  ADD_SUB_8.edf             default so ok
  ALUBIT_8.edf              default so ok
  MUX2_ADD_REG_11.edf       default so ok

If you are using Exemplar then you can analyze the whole lot and it gets it
correct. The following works fine :

analyze mux2_add_reg.vhd
analyze mux2.vhd
analyze mux4.vhd
analyze mux8.vhd
analyze add_sub.vhd
analyze alubit.vhd
analyze idec.vhd
analyze alu.vhd
analyze regs.vhd
analyze cpu.vhd
analyze risc5x_xil.vhd
elaborate risc5x_xil

** CORE **

alu.vhd                 (ALU block)
idec.vhd                (instruction decode)
regs.vhd                (register file)
cpu.vhd                 (CPU top level)

regs.vhd also has two architectures, one optimised for Virtex and a generic one
as well. The generic version has a simulation model of a dual port ram,
which should be replaced be a synthesizable block.

** TOP LEVELS **
risc5x_xil.vhd          (xilinx chip complete with program ram)
OR
cpu_tb.vhd              (simulation model which loads a .hex program file)

** OTHER **
risc5x_xil.ucf          (xilinx constraints file)
jumptest.asm            (sanity test program)
jumptest.hex            (sanity test binary)

risc5x_xil.VHD is a synthesizable top level that instantiates some Xilinx block
rams. For simulation replace risc5x_xil.vhd with cpu_tb.vhd which has extra
debug.

Signal inst_string in cpu_tb shows the current instruction being
executed, and pc_t1 the address it came from. (t1 signifies one clock later than
the PC, due to the delay through the program memory)


Any questions or interest in customisation /locked / other cores (16x8x?) etc
feel free to mail.

mikej@opencores.org

Cheers

Mike.


