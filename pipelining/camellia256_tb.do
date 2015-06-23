vcom -quiet sbox1.vhd
vcom -quiet sbox2.vhd
vcom -quiet sbox3.vhd
vcom -quiet sbox4.vhd
vcom -quiet f.vhd
vcom -quiet fl256.vhd
vcom -quiet 6round256.vhd
vcom -quiet keysched256.vhd
vcom -quiet camellia256.vhd
vcom -quiet camellia256_tb.vhd
vsim camellia256_tb
view wave
add wave -divider "camellia256"
add wave -HEX -ports /uut/*
add wave -divider "key"
add wave -HEX -ports /uut/key_sched/*
add wave -divider "six1"
add wave -HEX -ports /uut/six1/*
add wave -divider "fl1"
add wave -HEX -ports /uut/fl1/*
add wave -divider "six2"
add wave -HEX -ports /uut/six2/*
add wave -divider "fl2"
add wave -HEX -ports /uut/fl2/*
add wave -divider "six3"
add wave -HEX -ports /uut/six3/*
add wave -divider "fl3"
add wave -HEX -ports /uut/fl3/*
add wave -divider "six4"
add wave -HEX -ports /uut/six4/*
run 250 ns
