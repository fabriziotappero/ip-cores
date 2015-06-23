# script general de simulacion
# questa v6

vlib work

# libs

vcom -explicit  -93 "src/aes_lib.vhd"  
vcom -explicit	-93 "src/dual_mem.vhd"  
vcom -explicit  -93 "src/aes_enc.vhd"
vcom -explicit  -93 "src/tb_aes_enc.vhd"

# Sim

vsim -lib work -t 1ps tb_aes_enc

view wave
view source
view structure
view signals
add wave *

mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_1
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_2
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_3
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_4
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_5
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_6
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_7
mem load -infile mem/s_box.mem -format hex tb_aes_enc/uut/s_box_dual_8

mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_1
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_2
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_3
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_4
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_5
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_6
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_7
mem load -infile mem/gfmult_2.mem -format bin tb_aes_enc/uut/gf_mult_2_8

mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_1
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_2
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_3
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_4
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_5
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_6
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_7
mem load -infile mem/gfmult_3.mem -format bin tb_aes_enc/uut/gf_mult_3_8

add wave \
{sim:/tb_aes_enc/uut/sub_tmp_s } 
add wave \
{sim:/tb_aes_enc/uut/sub_tmp_mix }


run 50 us

add wave \
{sim:/tb_aes_enc/uut/key_reg } 