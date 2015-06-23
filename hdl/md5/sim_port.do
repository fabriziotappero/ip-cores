quit -sim
vlib work

vlog ./md5.v
vlog ./port_md5.v
vlog ./port_md5_tb.v

vsim -voptargs=+acc port_md5_tb

add wave -hex /port_md5_tb/*
add wave -hex /port_md5_tb/DUT/*

run 2000ns
