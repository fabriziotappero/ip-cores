# comp.do
# ModelSim do-script for compiling design and testbench
vlib work
vcom -novopt -work work \
     ../../../examples/vhdl/rtl_example/dut_example.vhd \
     ../../../src/vhdl/txt_util.vhd \
     ../../../src/vhdl/pltbutils_user_cfg_pkg.vhd \
     ../../../src/vhdl/pltbutils_func_pkg.vhd \
     ../../../src/vhdl/pltbutils_comp.vhd \
     ../../../src/vhdl/pltbutils_comp_pkg.vhd \
     ../../../examples/vhdl/tb_example2/tc_example2.vhd \
     $1 \
     ../../../examples/vhdl/tb_example2/tb_example2.vhd
     