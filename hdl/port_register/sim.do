quit -sim

vlog ./port_register.v
vlog ./port_register_tb.v

vsim -voptargs=+acc port_register_tb

add wave -hex /port_register_tb/*
add wave -hex /port_register_tb/DUT/*

run 400ns


