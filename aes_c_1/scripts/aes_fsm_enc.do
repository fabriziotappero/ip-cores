# script general de simulacion
# questa v6

vlib work

# libs


vcom -explicit  -93 "src/aes_lib.vhd"  
vcom -explicit	-93 "src/dual_mem.vhd"  
vcom -explicit  -93 "src/aes_enc.vhd"
vcom -explicit  -93 "src/aes_fsm_enc.vhd"
vcom -explicit  -93 "src/tb_aes_fsm_enc.vhd"

# Sim

vsim -lib work -t 1ps tb_aes_fsm_enc

view wave
view source
view structure
view signals
add wave *

mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_1
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_2

mem load -infile mem/key.mem -format hex tb_aes_fsm_enc/uut/sub_keys_dram

add wave \
{sim:/tb_aes_fsm_enc/uut/state } 
add wave \
{sim:/tb_aes_fsm_enc/uut/block_out_s } 
add wave \
{sim:/tb_aes_fsm_enc/uut/count } 
add wave \
{sim:/tb_aes_fsm_enc/uut/key_data_1 } \
{sim:/tb_aes_fsm_enc/uut/key_data_2 } 
add wave \
{sim:/tb_aes_fsm_enc/uut/aes_round_n/sub_key } 

run 10 us

