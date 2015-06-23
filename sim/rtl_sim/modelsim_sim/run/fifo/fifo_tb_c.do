vlib work
# packages
vcom -93 ../../../../../bench/vhdl/images-body.vhd 
vcom -93 ../../../../../bench/vhdl/txt_util.vhd
# DUT
vcom -93 ../../../../../rtl/vhdl/gray_adder.vhd
vcom -93 ../../../../../rtl/vhdl/gray2bin.vhd
vcom -93 ../../../../../rtl/vhdl/bin2gray.vhd
vcom -93 ../../../../../rtl/vhdl/fifo_prog_flags.vhd
vcom -93 ../../../../../rtl/vhdl/ram.vhd
vcom -93 ../../../../../rtl/vhdl/fifo.vhd
# Testbench
vcom -93 ../../../../../bench/vhdl/fifo_tb.vhd