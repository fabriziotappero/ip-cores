##
quit -sim
vlib work
vcom -93 -explicit  ../vhdl/light8080.vhdl
vcom -93 -explicit  ../vhdl/soc/l80pkg.vhdl
vcom -93 -explicit  ../vhdl/soc/l80irq.vhdl
vcom -93 -explicit  ../vhdl/soc/uart.vhdl
vcom -93 -explicit  ../vhdl/soc/l80soc.vhdl
vcom -93 -explicit  ../sw/demos/hello/obj_code_pkg.vhdl
vcom -93 -explicit  ../vhdl/demos/c2sb/c2sb_soc.vhdl
vcom -93 -explicit  ../vhdl/demos/c2sb/c2sb_soc_tb.vhdl


vsim -t 1ps   -lib work c2sb_soc_tb
do sim_c2sb_wave.do
