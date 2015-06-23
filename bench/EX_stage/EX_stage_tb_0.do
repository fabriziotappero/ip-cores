quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/EX_stage.v
vlog  +incdir+../rtl ../bench/EX_stage/EX_stage_tb_0.v

vsim -t 1ps -novopt -lib work EX_stage_tb_0_v
view wave
add wave *
view structure
view signals
run -all
