quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/*.v
vlog  +incdir+../rtl ../bench/mips_16_core_top/mips_16_core_top_tb_0.v

vsim -t 1ps -novopt -lib work mips_16_core_top_tb_0_v
view wave
#add wave *
add wave /mips_16_core_top_tb_0_v/uut/*
add wave -radix unsigned /mips_16_core_top_tb_0_v/uut/ID_stage_inst/ir_op_code
add wave -radix unsigned /mips_16_core_top_tb_0_v/uut/ID_stage_inst/ir_dest
add wave -radix unsigned /mips_16_core_top_tb_0_v/uut/ID_stage_inst/ir_src1
add wave -radix unsigned /mips_16_core_top_tb_0_v/uut/ID_stage_inst/ir_src2
add wave -radix unsigned /mips_16_core_top_tb_0_v/uut/ID_stage_inst/ir_imm

view structure
view signals
run -all
