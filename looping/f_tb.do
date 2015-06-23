vcom -quiet sbox1.vhd
vcom -quiet sbox2.vhd
vcom -quiet sbox3.vhd
vcom -quiet sbox4.vhd
vcom -quiet f.vhd
vcom -quiet f_tb.vhd
vsim f_tb
view wave
add wave -HEX /uut/*
run 50 ns
