quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/data_mem.v
vlog  +incdir+../rtl ../bench/MEM_stage/data_mem_tb_0.v

vsim -t 1ps -novopt -lib work data_mem_tb_0_v
view wave
add wave *
view structure
view signals
run -all
