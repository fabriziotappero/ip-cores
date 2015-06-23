##
quit -sim
vlib work
vcom -93 -explicit  ../vhdl/light8080.vhdl
vcom -93 -explicit  ../vhdl/test/light8080_tb0.vhdl
vsim -t 1ps   -lib work light8080_tb0
do tb0_modelsim_wave.do
