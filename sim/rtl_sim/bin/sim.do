vlib work

vlog ../../../rtl/verilog/vc.v
vlog ../../../bench/versatile_counter_tb.v

vsim -voptargs=+acc work.lfsr_tb

do ../bin/wave.do

run 10 us

