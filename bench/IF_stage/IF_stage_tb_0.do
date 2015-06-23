vlib work
##vlog  +incdir+F:/Projects/My_MIPS/mips_16/rtl ../rtl/*.v
vlog  +incdir+../rtl ../rtl/IF_stage.v
vlog  +incdir+../rtl ../rtl/instruction_mem.v
vlog  +incdir+../rtl ../bench/IF_stage/IF_stage_tb_0.v

vsim -t 1ps -novopt -L xilinxcorelib_ver -L unisims_ver -lib work IF_stage_tb_0_v
view wave
add wave *
## add wave /glbl/GSR
## do {dds_tb_v.udo}
view structure
view signals
run -all
