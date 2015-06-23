set_property PACKAGE_PIN J8 [get_ports gtx_refclk_p]
set_property IOSTANDARD LVCMOS25 [get_ports clk_2_p]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[0]}]


set_property PACKAGE_PIN C8 [get_ports clk_2_p]

create_clock -period 6.400 -name clk156 -waveform {0.000 3.200} [get_nets *156*]
create_clock -period 6.400 -name gtx_refclk -waveform {0.000 3.200} [get_ports {gtx_refclk_n gtx_refclk_p}]

set_property PACKAGE_PIN T25 [get_ports {gtx_sfp_disable[0]}]
set_property PACKAGE_PIN AA28 [get_ports {gtx_sfp_disable[1]}]
set_property PACKAGE_PIN Y30 [get_ports {gtx_sfp_disable[2]}]
set_property PACKAGE_PIN AK28 [get_ports {gtx_sfp_disable[3]}]
set_property PACKAGE_PIN F6 [get_ports {gtx10g_rxp[0]}]
set_property PACKAGE_PIN G4 [get_ports {gtx10g_rxp[1]}]
set_property PACKAGE_PIN H6 [get_ports {gtx10g_rxp[2]}]
set_property PACKAGE_PIN K6 [get_ports {gtx10g_rxp[3]}]

set_property PACKAGE_PIN Y20 [get_ports si570_oe]
set_property IOSTANDARD LVCMOS25 [get_ports si570_oe]

set_property PACKAGE_PIN AE30 [get_ports {gtx_rate_sel[0]}]
set_property PACKAGE_PIN W28 [get_ports {gtx_rate_sel[1]}]
set_property PACKAGE_PIN AG27 [get_ports {gtx_rate_sel[2]}]
set_property PACKAGE_PIN AB30 [get_ports {gtx_rate_sel[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[3]}]
