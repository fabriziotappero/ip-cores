##
quit -sim
vlib work
vcom -93 -explicit  ../vhdl/light8080.vhdl
vcom -93 -explicit  ../vhdl/test/light8080_tb1.vhdl
vsim -t 1ps -lib work light8080_tb1
set PrefSource(OpenOnBreak) 0
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
do tb1_modelsim_wave.do
