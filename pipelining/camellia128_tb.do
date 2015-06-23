vcom -quiet sbox1.vhd
vcom -quiet sbox2.vhd
vcom -quiet sbox3.vhd
vcom -quiet sbox4.vhd
vcom -quiet f.vhd
vcom -quiet fl128.vhd
vcom -quiet 6round128.vhd
vcom -quiet keysched128.vhd
vcom -quiet camellia128.vhd
vcom -quiet camellia128_tb.vhd
vsim camellia128_tb
view wave
add wave -divider "camellia128"
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
run 150 ns
