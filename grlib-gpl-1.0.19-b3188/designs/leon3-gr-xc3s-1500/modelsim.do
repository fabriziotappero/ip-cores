vsim -quiet work.testbench
view wave
add wave sim:/testbench/cpu/l3/cpu__0/u0/rf0/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/m0/c0/icache0/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/m0/c0/dcache0/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/e1/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/e1/decoder_pipe/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/e1/iRF_stage/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/e1/iforward/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/e1/iexec_stage/*
add wave sim:/testbench/cpu/l3/cpu__0/u0/p0/mips/e1/ihazard_unit/*
run -all
