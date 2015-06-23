ghdl -i -v --ieee=standard -fexplicit --std=93c --warn-no-vital-generic --workdir=simu --work=work src/*.vhd testbench/fir_filter_stage_tb.vhd
ghdl -m -v --ieee=synopsys -fexplicit --std=93c --warn-no-vital-generic --workdir=simu --work=work fir_filter_stage_tb
ghdl -r -v fir_filter_stage_tb --stop-time=500ns --vcd=output.vcd
gtkwave output.vcd &
