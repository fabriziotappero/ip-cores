source setup_rhumc.tcl
source leon3mp_dc.tcl
set_scan_configuration -style multiplexed_flip_flop
source timing.tcl
#ungroup -flatten -simple_names core0/ringosc0/drx
#ungroup -flatten -simple_names core0/leon3core0/grspw0_0/nrx_clkbuf_0

ungroup core0/ringosc0/drx  -flatten -simple_names
ungroup core0/leon3core0/dsu0/x0  -simple_names
ungroup core0/leon3core0/grspw0_0/ram0  -flatten -simple_names
#ungroup core0/leon3core0/grspw0_0/grspwc0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_0/nrx_clkbuf_0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_0/rx_clkbuf_0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_0/rx_ram0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_0/rx_ram1  -flatten -simple_names
ungroup core0/leon3core0/grspw0_0/tx_ram0  -flatten -simple_names

ungroup core0/leon3core0/grspw0_1/ram0  -flatten -simple_names
#ungroup core0/leon3core0/grspw0_1/grspwc0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_1/nrx_clkbuf_0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_1/rx_clkbuf_0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_1/rx_ram0  -flatten -simple_names
ungroup core0/leon3core0/grspw0_1/rx_ram1  -flatten -simple_names
ungroup core0/leon3core0/grspw0_1/tx_ram0  -flatten -simple_names

#ungroup core0/leon3core0/leon3ft0_0/tbmem0/ram0_0  -flatten -simple_names
#ungroup core0/leon3core0/leon3ft0_0/tbmem0/ram0_1  -flatten -simple_names

current_instance pads0
ungroup [find cell "*"] -flatten -simple_names
current_instance ..
set_dont_touch pads0

current_instance core0
#ungroup find(cell, {"clk*"} ) -flatten -simple_names
current_instance leon3core0
#group [find cell {apb* uart* timer* irq* ahb* rst0 dcom* grg* sr* dsu0 ahbjtag0 }]  -design_name amod -cell_name amod0
current_instance leon3ft0_0/p0
ungroup -all -flatten -simple_names
current_instance ../rf0
ungroup -all -flatten -simple_names
current_instance ../cmem0
ungroup -all -flatten -simple_names
current_instance ../fpu0
ungroup -all -flatten -simple_names
current_instance ../../ahbuart0
ungroup -all -flatten -simple_names

current_instance ../ftmctrl0
ungroup -all -flatten -simple_names
current_instance ..
ungroup ahbctrl0 -flatten -simple_names
ungroup apbctrl0 -flatten -simple_names

current_instance ../../..

set compile_auto_ungroup_override_wlm "true"
set compile_auto_ungroup_count_leaf_cells "true"
set compile_auto_ungroup_delay_num_cells 100
set compile_ultra_ungroup_small_hierarchies "false"
set compile_auto_ungroup_area_num_cells 100

set_max_area 0  
set_max_transition 1.0 leon3mp  

source scan.tcl
#compile_ultra -scan -no_boundary_optimization
compile_ultra -scan -retime

write -f ddc -hier leon3mp -output synopsys/leon3mp.ddc

report_timing
report_timing > synopsys/timing1.log
write_sdc synopsys/leon3mp.sdc
report_area
report_area -hierarchy > synopsys/area1.log
report_power
report_power > synopsys/pow1.log
report_power -hier > synopsys/pow1h.log

change_names -rules verilog -hierarchy
write -f verilog -hier leon3mp -output synopsys/leon3mp.v
#source timing3.tcl
source scan2.tcl

quit

