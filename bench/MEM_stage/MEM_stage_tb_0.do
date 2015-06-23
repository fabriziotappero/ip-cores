quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/MEM_stage.v
vlog  +incdir+../rtl ../bench/MEM_stage/MEM_stage_tb_0.v

vsim -t 1ps -novopt -lib work MEM_stage_tb_0_v
view wave
add wave *
view structure
view signals
run -all
