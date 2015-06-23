#!/bin/bash
#
# This script runs RTL simulation.
# Right now only Modelsim is supported.
#
# Author: Michael Geng
#

# Number of clock cycles you want to run the simulations
N_simulation_cycles=100

# data bus width
D_width=36

# address bus width
A_width=21

. modelsim.inc

if [ -z $MODEL_SIM ]; then
	echo "The environment variable MODEL_SIM must point to your Modelsim installation."
	exit 0
fi

vlib=$MODEL_SIM/win32pe/vlib
vcom=$MODEL_SIM/win32pe/vcom
vsim=$MODEL_SIM/win32pe/vsim

for tool in $vlib $vcom $vsim
do 
	check_executable $tool
done

touch modelsim.ini

mkdir -p ../out

# map libraries
map std      "$MODEL_SIM/std"
map ieee     "$MODEL_SIM/ieee"
map verilog  "$MODEL_SIM/verilog"
map RAM      ../out/RAM
map misc     ../out/misc
map samsung  ../out/samsung
map test_zbt ../out/test_zbt

# compile
vcom -work ../out/misc ../../../bench/vhdl/misc/math_pkg.vhd

vlog +define+hc25 -work ../out/samsung ../../../bench/verilog/samsung/k7n643645m_R03.v

vcom -work ../out/RAM ../../../rtl/vhdl/linked_list_mem_pkg.vhd
vcom -work ../out/RAM ../../../rtl/vhdl/ZBT_RAM_pkg.vhd
vcom -work ../out/RAM ../../../rtl/vhdl/ZBT_RAM.vhd

vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/patgen_pkg.vhd
vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/patgen_entity.vhd
vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/patgen_arch_random.vhd
vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/patgen_arch_deterministic.vhd
vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/testbench.vhd
vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/testbench_random_conf.vhd
vcom -work ../out/test_zbt ../../../bench/vhdl/zbt_ram/testbench_deterministic_conf.vhd

mkdir -p ../log

# simulate
echo "Simulate with deterministic pattern"
vsim -l ../log/zbt_deterministic.out -c -t 100ps -GD_width=$D_width -GA_width=$A_width \
	-GN_simulation_cycles=$N_simulation_cycles -do "run -all ; quit ;" test_zbt.deterministic_conf

echo "Simulate with random pattern"
vsim -l ../log/zbt_random.out -c -t 100ps -GD_width=$D_width -GA_width=$A_width \
	-GN_simulation_cycles=$N_simulation_cycles -do "run -all ; quit ;" test_zbt.random_conf
