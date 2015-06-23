vlib work
vlog  +incdir+../rtl ../rtl/ID_stage.v
vlog  +incdir+../rtl ../bench/ID_stage/ID_stage_tb_0.v

vsim -t 1ps -novopt -lib work ID_stage_tb_0_v
view wave
add wave *
add wave /ID_stage_tb_0_v/uut/instruction_reg
view structure
view signals
run -all
