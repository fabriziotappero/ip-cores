quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/alu.v
vlog  +incdir+../rtl ../bench/EX_stage/alu_tb_0.v

vsim -t 1ps -novopt -lib work alu_tb_0_v
view wave
add wave -radix unsigned /alu_tb_0_v/cmd
add wave -radix decimal /alu_tb_0_v/a
add wave -radix decimal /alu_tb_0_v/b
add wave -radix decimal /alu_tb_0_v/r
view structure
view signals
run -all
