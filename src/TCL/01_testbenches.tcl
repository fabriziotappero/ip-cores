# This is a Riviera TCL script
# run it from project root


# clear library
adel -lib work -all

# clear screen
clear

# grain
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/grain_datapath_fast.vhd
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/grain_datapath_slow.vhd
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/grain.vhd
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/test_sim/tb_grain.vhd


# grain128
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/grain128_datapath_fast.vhd
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/grain128_datapath_slow.vhd
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/grain128.vhd
acom  -quiet -work work -dbg -e 100 -2002  src/VHDL/test_sim/tb_grain128.vhd


# grain128 slow:
asim -g/FAST=false tb_grain128
wave -rec /DUT/* 
run 100 us


# grain128 fast
asim -g/FAST=true tb_grain128
wave -rec /DUT/* 
run 100 us


# grain slow:
asim -g/FAST=false tb_grain
wave -rec /DUT/* 
run 100 us

# grain fast
asim -g/FAST=true tb_grain
wave -rec /DUT/* 
run 100 us