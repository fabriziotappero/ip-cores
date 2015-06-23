##
quit -sim
vlib work
## CPU core entity
vcom -93 -explicit  ../vhdl/light8080.vhdl
## Utility package with object code loading function
vcom -93 -explicit  ../vhdl/soc/l80pkg.vhdl
## Object code for TB1
vcom -93 -explicit  ../sw/tb/tb1/obj_code_pkg.vhdl
## Test bench entity
vcom -93 -explicit  ../vhdl/test/light8080_tb.vhdl
## Set a few Modelsim options 
set PrefSource(OpenOnBreak) 0
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
vsim -t 1ps   -lib work light8080_tb
## Display a number of interesting signals in modelsim wave window
do sim_tb1_wave.do