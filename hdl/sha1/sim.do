quit -sim
vlib work


vlog ./dffhr.v
vlog ./sha1_round.v
vlog ./sha1_exec.v
vlog ./port_sha1.v
vlog ./port_sha1_tb.v

vsim -voptargs=+acc port_sha1_tb

add wave -hex /port_sha1_tb/*
add wave -hex /port_sha1_tb/DUT/*

run 2000ns
