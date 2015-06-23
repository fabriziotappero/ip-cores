##
quit -sim
vlib work
vcom -93 -explicit  ../vhdl/light8080.vhdl
vcom -93 -explicit  ../vhdl/soc/l80pkg.vhdl
vcom -93 -explicit  ../vhdl/soc/l80irq.vhdl
vcom -93 -explicit  ../vhdl/soc/uart.vhdl
vcom -93 -explicit  ../vhdl/soc/l80soc.vhdl
vcom -93 -explicit  ../src/tb/soc_tb/obj_code_pkg.vhdl
vcom -93 -explicit  ../vhdl/test/l80soc_tb.vhdl


vsim -t 1ps   -lib work l80soc_tb
do sim_soc_tb_wave.do
