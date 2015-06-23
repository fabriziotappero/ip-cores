
vlib work

# libs

vcom -explicit	-93 "dual_mem.vhd"  
vcom -explicit  -93 "sha_fun.vhd"  
vcom -explicit  -93 "ff_bank.vhd"  
vcom -explicit  -93 "sh_reg.vhd"
vcom -explicit  -93 "msg_comp.vhd"
vcom -explicit  -93 "sha_256.vhd"
vcom -explicit  -93 "tb_sha_256.vhd"

# Sim

vsim -lib work -t 1ps tb_sha_256

view wave
view source
view structure
view signals
add wave *

mem load -infile mem/k.mem -format hex tb_sha_256/uut/k_mem

add wave \
{sim:/tb_sha_256/uut/k_mem/* } 

add wave \
{sim:/tb_sha_256/uut/state } 

add wave \
{sim:/tb_sha_256/uut/message_compression/t_1 } \
{sim:/tb_sha_256/uut/message_compression/t_2 } 
add wave \
{sim:/tb_sha_256/uut/message_compression/w_i } \
{sim:/tb_sha_256/uut/message_compression/k_i } 

run 16 us

