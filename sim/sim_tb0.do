##
quit -sim
vlib work
## CPU core entity
vcom -93 -explicit  ../vhdl/light8080.vhdl
## Utility package with object code loading function
vcom -93 -explicit  ../vhdl/soc/l80pkg.vhdl
## Object code for TB0
vcom -93 -explicit  ../sw/tb/tb0/obj_code_pkg.vhdl
## Test bench entity
vcom -93 -explicit  ../vhdl/test/light8080_tb.vhdl
vsim -t 1ps   -lib work light8080_tb
do sim_tb0_wave.do
