---------------------------------------------------------------
-- G.729A Codec Self-Test Module
---------------------------------------------------------------

This folder holds source VHDL files and memory intialization files for
G.729A codec core self-test module and simulation test-bench. Self-test
module is intendeded to provide end user with a simple way of verifying
core functionality.

Self-test module consists of:
1) Codec core instance.
2) Input data ROM.
3) (Expected) output data (to be compared with actual codec outputs) ROM.
4) Control logic managing codec operations, read operations from data
ROMs and results checking. This logic provides an example of how to
interface the codec core to user logic.

Self-test module has only four ports:
1) CLK_i, clock input.
2) RST_i, synchronous reset input (active high).
3) DONE_o, self-test completed output (active high).
4) PASS_o, selft-test passed (no error) output (active high).

File list:
G729A_asip_st_roms.vhd, ROM model with data content specified as VHDL constant.
G729A_codec_st_rom_pkg.vhd, VHDL package declaring ROM data content constant.
G729A_codec_selftest.vhd, self-test module VHDL code.
G729A_codec_selftest_TB.vhd, selt-test module simulation test-bench VHDL code.
G729A_codec_sti_rom.mif, input data ROM MIF file.
G729A_codec_sto_rom.mif, output/check data ROM MIF file.

Notes:
(1) By default, self-test module uses ROM models with data content
specified as VHDL constant (rathen than by MIF files). If you want to use
MIF files, edit G729A_codec_selftest_TB.vhd and set "USE_ROM_MIF" constant
value to '1'. WARNING: Simulation must be performed with USE_ROM_MIF = '0'!
(2) VHDL code of ROM model using MIF files is the same used for codec internal
ROMs of the same type, and therefore is not included here.

Self-test simulation runs for ~27ms, when this time has elapsed, both outputs
should be high, to flag test completion and succesful result.

See "SCRIPTS" folder for a sample Modelsim script compiling all required files,
adding relevant signals to waveform list and running self-test simulation.
This script can be used as starting point to build similar scripts for other
simulation tools.