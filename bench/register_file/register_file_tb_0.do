quit -sim
vlib work
vlog  +incdir+../rtl ../rtl/register_file.v
vlog  +incdir+../rtl ../bench/register_file/register_file_tb_0.v

vsim -t 1ps -novopt -lib work register_file_tb_0_v
view wave
add wave *
view structure
view signals
run -all
