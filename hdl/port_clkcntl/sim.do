quit -sim

vcom ./clockcntl.vhd
vlog ./port_clkcntl.v
vlog ./port_clkcntl_tb.v

vsim -voptargs=+acc port_clkcntl_tb

add wave -hex /port_clkcntl_tb/*
add wave -hex /port_clkcntl_tb/DUT/*
add wave -hex /port_clkcntl_tb/DUT/theclockcntl/*

run 400ns


