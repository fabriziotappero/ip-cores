quit -sim

vlib work

vlog C:/Xilinx/11.1/ISE/verilog/src/glbl.v
vlog ./port_fifo.v
vlog ./port_fifo_tb.v

vsim -L unisims_ver -L unimacro_ver -voptargs=+acc port_fifo_tb glbl

add wave -hex /port_fifo_tb/*
add wave -hex /port_fifo_tb/DUT/*

run 400ns


