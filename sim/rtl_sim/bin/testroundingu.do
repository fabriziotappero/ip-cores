# Author: Nikolaos Kavvadias (C) 2009, 2010, 2011
vlib work
vcom ../src/math_real.vhd
vcom ../src/fixed_float_types_custom.vhd
vcom ../src/fixed_pkg_c.vhd
vcom ../../../rtl/vhdl/fixed_extensions_pkg_sim.vhd
vcom ../../../gen/vhdl/testroundingu.vhd
vcom ../../../bench/vhdl/testrounding_tb.vhd
vsim testrounding_tb
vcd dumpports -file testrounding_fsmd.vcd /testrounding_tb/uut/* -unique
onbreak {quit -f}
run -all
exit -f
