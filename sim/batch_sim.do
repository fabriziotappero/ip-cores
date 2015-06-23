echo Batch script for simulating all test cases...
echo Simulating Altera implementation

echo Compiling Sources
vcom -work work -2002 -explicit -vopt ../vhdl/ternary_adder_altera.vhd
vcom -work work -2002 -explicit -vopt ../vhdl/tb_ternary_adder.vhd

set simtime 1us

do sim_single_inst.do


echo Simulating Xilinx implementation

echo Compiling Sources
vcom -work work -2002 -explicit -vopt ../vhdl/ternary_adder_xilinx.vhd
vcom -work work -2002 -explicit -vopt ../vhdl/tb_ternary_adder.vhd

do sim_single_inst.do

quit