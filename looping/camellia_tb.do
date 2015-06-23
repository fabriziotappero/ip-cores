vcom -quiet sbox1.vhd
vcom -quiet sbox2.vhd
vcom -quiet sbox3.vhd
vcom -quiet sbox4.vhd
vcom -quiet f.vhd
vcom -quiet fl.vhd
vcom -quiet datapath.vhd
vcom -quiet control.vhd
vcom -quiet camellia.vhd
vcom -quiet camellia_tb.vhd
vsim camellia_tb
view wave
add wave -divider "camellia"
add wave -HEX -ports /uut/*
add wave -divider "control"
add wave -HEX -ports /uut/CTRL/*
add wave /uut/CTRL/PS
add wave -divider "keys"
add wave -HEX /uut/CTRL/reg_kl
add wave -HEX /uut/CTRL/reg_kr
add wave -HEX /uut/CTRL/reg_ka
add wave -HEX /uut/CTRL/reg_kb
add wave -HEX /uut/CTRL/reg_kl_s
add wave -HEX /uut/CTRL/reg_kr_s
add wave -HEX /uut/CTRL/reg_ka_s
add wave -HEX /uut/CTRL/reg_kb_s
add wave -divider "other regs"
add wave -HEX /uut/CTRL/reg_enc_dec
add wave -HEX /uut/CTRL/reg_k_len
add wave -divider "datapath"
add wave -HEX -ports /uut/DP/*
run 6 us
