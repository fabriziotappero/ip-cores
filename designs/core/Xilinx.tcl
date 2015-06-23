project new work/xilinx/core
project set family virtex5
project set device xc5vlx30
project set package ff324
project set speed -1

lib_vhdl new mblite
xfile add ../../../../hw/core/*.vhd -lib_vhdl mblite
xfile add ../../../../hw/std/*.vhd -lib_vhdl mblite
xfile add ../../config_Pkg.vhd -lib_vhdl mblite
project close