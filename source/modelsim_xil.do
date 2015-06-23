destroy .wave;
destroy .list;
vlib work;
vcom fm_timesim.vhd bench_xil.vhdl input_fm_xil.vhdl;
vsim -t 1ps bench;
add wave /bench/clock;
add wave /bench/reset;
add wave -height 80 -scale .1 -format Analog-Step /bench/myfm/fmin
add wave -height 80 -scale 2. -format Analog-Step /bench/myfm/dmout 
