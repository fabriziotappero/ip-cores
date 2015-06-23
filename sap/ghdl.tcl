ghdl -i -v --ieee=standard -fexplicit --std=93c --warn-no-vital-generic --workdir=simu --work=work src/*.vhd testbench/MP_struct_TB.vhd
ghdl -m -v --ieee=synopsys -fexplicit --std=93c --warn-no-vital-generic --workdir=simu --work=work MP_struct_TB
ghdl -r -v MP_struct_TB --stop-time=30us --vcd=output.vcd
gtkwave output.vcd &
