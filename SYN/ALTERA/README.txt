---------------------------------------------------------------
-- G.729A Codec self-test module synthesis script 
---------------------------------------------------------------

Tcl script g729a_selftest_syn.tcl creates a Quartus II project
synthesizing G.729A codec self-test module and mapping it to
the Cyclone III FPGA on the NEEK development board.

The script has been generated and tested using Quartus II ver.
9.1.

If the self-test module is succesfully synthesized, after
donwloading the resulting SOF file to the NEEK board, the board
LED's should be in the following state:
LED1 : on (test completed).
LED2 : on (test passed, no error).
LED3 : off (permanently tied to VCC, just a safety check).
LED4 : on (permanently tied to GND, just a safety check).

This directory includes all the design files required by the
project:

1) g729a_selftest_syn.tcl, tcl script creating self-test 
module project. This script uses relative path "..\..\VHDL"
(pointing to VHDL directory in this release) to access source 
files: modify this path if files are located elsewhere.

2) G729A_asip_romd.mif, G729A_asip_romd.mif, 
G729A_codec_sti_rom.mif and G729A_codec_sto_rom.mif, these are
memory initialization files (written in Altera MIF format) 
specifying data content for the various ROMs needed by the
self-test module. These files must reside in the project
directory for Quartus to find them.

3) G729A_codec_selftest.vhd, this file is a copy of the file
carrying the same name held in the VHDL directory, but with 
constant USE_ROM_MIF set to '1' in order to use ROM models
suitable for synthesis with Altera tools (e.g. using the MIF 
files of above).

4) g729a_syn.bdf, schematic file instantiating self-test module
and some inverter (required to change polarity to reset signal
and to signals driving LEDs on NEEK board). This schematic is
the project top-level module.

5) ext_clk.sdc, timing constraint file specifying input clock
parameters (for a matter of simplicity, self-test module is
directly connected to board oscillator 50MHz clock).

