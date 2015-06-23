#vdel -all -lib work
vmap unisims /opt/Xilinx/10.1/modelsim/verilog/unisims
vlib work
vlog -work work -lint ../rtl/vdu.v vdu_tb.v ../rtl/ram2k_b16_attr.v ../rtl/ram2k_b16.v ../rtl/char_rom_b16.v
vlog -work work /opt/Xilinx/10.1/ISE/verilog/src/glbl.v
vsim -L /opt/Xilinx/10.1/modelsim/verilog/unisims -novopt -t ns work.vdu_tb work.glbl
add wave -radix hexadecimal /vdu_tb/vdu0/*
