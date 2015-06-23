quit -sim
vlib work

vlog ./md5.v
vlog ./md5_tb.v

vsim -voptargs=+acc md5_tb

add wave -hex /md5_tb/*
add wave -hex /md5_tb/DUT/*

run 400ns
