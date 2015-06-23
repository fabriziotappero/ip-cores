destroy .wave;
destroy .list;
vlib work;
vcom *.vhd *.vhdl;
vsim bench;
add wave -height 80 -scale .1 -format Analog-Step /bench/myfm/fmin
add wave -height 80 -scale .1 -format Analog-Step /bench/myfm/output_nco
add wave -height 80 -scale 1. -format Analog-Step /bench/myfm/phase_output 
add wave -height 80 -scale .0002 -format Analog-Step /bench/myfm/mynco/myaddacc/result
add wave -height 80 -scale .1 -format Analog-Step /bench/myfm/loop_out
add wave -height 80 -scale 1. -format Analog-Step /bench/myfm/dmout 
