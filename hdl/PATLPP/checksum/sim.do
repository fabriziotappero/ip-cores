quit -sim
vlog checksum.v
vlog checksum_tb.v

vsim -L unisims_ver -voptargs=+acc checksum_tb

add wave -hex sim:/checksum_tb/*
add wave -noupdate -divider {Checksum Unit}
add wave -hex sim:/checksum_tb/dut/*

run 300ns
