# assumed to run from /<project directory>/sim
vlib work

vcom -reportprogress 300 -work work ../vhdl/light52_pkg.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_ucode_pkg.vhdl
vcom -reportprogress 300 -work work ../test/dhrystone/obj_code_pkg.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_muldiv.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_alu.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_cpu.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_uart.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_timer.vhdl
vcom -reportprogress 300 -work work ../vhdl/light52_mcu.vhdl
vcom -reportprogress 300 -work work ../vhdl/demos/c2sb/c2sb_soc.vhdl

vcom -reportprogress 300 -work work ../vhdl/tb/txt_util.vhdl
vcom -reportprogress 300 -work work ../vhdl/tb/light52_tb_pkg.vhdl
vcom -reportprogress 300 -work work ../vhdl/demos/c2sb/c2sb_soc_tb.vhdl

vsim -t ps work.c2sb_soc_tb(testbench)
do ./light52_c2sb_tb_wave.do
set PrefMain(font) {Courier 9 roman normal}
