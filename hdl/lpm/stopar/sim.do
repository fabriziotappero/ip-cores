quit -sim
vlog lpm_stopar.v
vlog lpm_stopar_tb.v

vsim -L unisims_ver -voptargs=+acc lpm_stopar_tb

add wave -hex sim:/lpm_stopar_tb/*
run 200ns
