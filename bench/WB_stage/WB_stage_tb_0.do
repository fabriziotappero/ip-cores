quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/WB_stage.v
vlog  +incdir+../rtl ../bench/WB_stage/WB_stage_tb_0.v

vsim -t 1ps -novopt -lib work WB_stage_tb_0_v
view wave
add wave *
view structure
view signals
run -all
