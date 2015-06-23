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


This program ( hexconv.cpp ) may be used to read in a .HEX program file
and outputs directives to the Xilinx build tools to initialise the program
ram correctly.

Usage :

hexconv sourcefile.hex                  outputs to screen

hexconv sourcefile.hex > temp.ucf       outputs to file temp.ucf

this will generate 16 x 6 statements like this :

INST PRAMS_0_INST INIT_00 = 00000000000000000000000000000000000000000000000000000000E9A7B9E4;

copy these to your RISC5X_XIL.UCF file. Job done.


The program source has a commented out section which will produce "attribute
init" statements which may be used in the VHDL code directly. Replace the prams
generate in RISC5X_XIL.vhd with the following. The advantage of this technique
is you can see the correct init's in the EDIF file, and if you have a block ram
simulation model that you can pass INIT generics to, then you can simulate it.

prams : if true generate
 attribute INIT_00 of inst0 : label is "00000000000000000000000000000000000000000000000000000000E9A7B9E4";
 <etc for all 16 x 6>
begin
  inst0 : ramb4_s2_s2
  port map (
    dob   => pdata(1 downto 0),
    dib   => "00",
    <etc>

    doa   => pram_dout(1 downto 0),
    dia   => pram_din(1 downto 0),
    <etc>
    );
  inst1 : ramb4_s2_s2
  port map (
    dob   => pdata(3 downto 2),
    <etc>

    doa   => pram_dout(3 downto 2),
    dia   => pram_din(3 downto 2),
    <etc>
    );
    <etc upto inst 5>
end generate;


Legal Stuff

This core is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

You are responsible for any legal issues arising from the use of this core.

The source files may be used and distributed without restriction provided that
all copyright statements are not removed from the files and that any derivative
work contains the original copyright notices and the associated disclaimer.

PIC is a trademark of Microchip Technology Inc.


Any questions or interest in customisation /locked / other cores (16x8x?) etc
feel free to mail.

mikej@opencores.org

Cheers

Mike.


