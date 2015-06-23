# script general de simulacion
# questa v6

vlib work

# libs

vcom -explicit  -93 "src/dual_mem.vhd"
vcom -explicit  -93 "src/key_schedule.vhd"
vcom -explicit  -93 "src/tb_key_schedule.vhd"

# Sim

vsim -lib work -t 1ps tb_key_schedule

view wave
view source
view structure
view signals
add wave *

mem load -infile mem/s_box.mem -format hex tb_key_schedule/uut/s_box_dual_1
mem load -infile mem/s_box.mem -format hex tb_key_schedule/uut/s_box_dual_2

add wave \
{sim:/tb_key_schedule/uut/count_5 } 
add wave \
{sim:/tb_key_schedule/uut/count_10 } 

add wave \
{sim:/tb_key_schedule/uut/g_sub_0_s } 
add wave \
{sim:/tb_key_schedule/uut/g_sub_1_s } 
add wave \
{sim:/tb_key_schedule/uut/g_sub_2_s } 
add wave \
{sim:/tb_key_schedule/uut/g_sub_3_s } 

run 10 us
