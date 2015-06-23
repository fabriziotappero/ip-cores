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
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_3
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_4
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_5
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_6
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_7
mem load -infile mem/s_box.mem -format hex tb_aes_fsm_enc/uut/aes_round_n/s_box_dual_8

mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_1
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_2
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_3
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_4
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_5
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_6
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_7
mem load -infile mem/gfmult_2.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_2_8

mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_1
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_2
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_3
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_4
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_5
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_6
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_7
mem load -infile mem/gfmult_3.mem -format bin tb_aes_fsm_enc/uut/aes_round_n/gf_mult_3_8

mem load -infile mem/key.mem -format hex tb_aes_fsm_enc/uut/sub_keys_dram

add wave \
{sim:/tb_aes_fsm_enc/uut/state } 
add wave \
{sim:/tb_aes_fsm_enc/uut/block_out_s } 

add wave \
{sim:/tb_aes_fsm_enc/uut/key_addr_1 } \
{sim:/tb_aes_fsm_enc/uut/key_data_1 } \
{sim:/tb_aes_fsm_enc/uut/key_data_2 } \
{sim:/tb_aes_fsm_enc/uut/count } 

add wave \
{sim:/tb_aes_fsm_enc/uut/clk_3 } 
add wave \
{sim:/tb_aes_fsm_enc/uut/clk_tmp } 

add wave \
{sim:/tb_aes_fsm_enc/uut/sub_key_s } 

add wave \
{sim:/tb_aes_fsm_enc/uut/pos_cnt } \
{sim:/tb_aes_fsm_enc/uut/neg_cnt } 

run 10 us

