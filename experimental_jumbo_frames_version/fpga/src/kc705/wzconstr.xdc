set_property PACKAGE_PIN H2 [get_ports gtx10g_txp]
set_property PACKAGE_PIN J8 [get_ports gtx_refclk_p]
set_property IOSTANDARD LVCMOS18 [get_ports clk_2]
set_property IOSTANDARD LVCMOS18 [get_ports resetdone]
set_property IOSTANDARD LVCMOS18 [get_ports start]
set_property IOSTANDARD LVCMOS18 [get_ports txusrclk2_out]
set_property IOSTANDARD LVCMOS18 [get_ports txusrclk_out]


set_property PACKAGE_PIN AG5 [get_ports start]
set_property PACKAGE_PIN AE20 [get_ports clk_2]
set_property PACKAGE_PIN AB8 [get_ports txusrclk2_out]
set_property PACKAGE_PIN AA8 [get_ports txusrclk_out]
set_property PACKAGE_PIN AC9 [get_ports resetdone]
set_property PACKAGE_PIN AB12 [get_ports rst_p]


set_property PACKAGE_PIN AB9 [get_ports core_ready]
set_property IOSTANDARD LVCMOS18 [get_ports core_ready]


set_property IOSTANDARD LVCMOS18 [get_ports rst_p]

create_clock -period 6.400 -name clk156 -waveform {0.000 3.200} [get_nets *156*]

create_clock -period 6.400 -name gtx_refclk -waveform {0.000 3.200} [get_ports {gtx_refclk_n gtx_refclk_p}]

set_property PACKAGE_PIN AE26 [get_ports trig_ack]

set_property IOSTANDARD LVCMOS18 [get_ports trig_ack]
set_property LOC BSCAN_X0Y0 [get_cells dbg_hub/inst/bscan_inst/SERIES7_BSCAN.bscan_inst]

set_property PACKAGE_PIN G19 [get_ports led5]
set_property IOSTANDARD LVCMOS18 [get_ports led5]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
