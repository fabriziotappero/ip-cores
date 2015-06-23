set_property PACKAGE_PIN C8 [get_ports gtx_refclk_p]
set_property IOSTANDARD LVCMOS25 [get_ports clk_2_p]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[0]}]


set_property PACKAGE_PIN J8 [get_ports clk_2_p]

create_clock -period 6.400 -name clk156 -waveform {0.000 3.200} [get_nets *156*]
create_clock -period 6.400 -name gtx_refclk -waveform {0.000 3.200} [get_ports {gtx_refclk_n gtx_refclk_p}]

set_property PACKAGE_PIN E19 [get_ports {gtx_sfp_disable[0]}]
set_property PACKAGE_PIN A23 [get_ports {gtx_sfp_disable[1]}]
set_property PACKAGE_PIN F28 [get_ports {gtx_sfp_disable[2]}]
set_property PACKAGE_PIN C29 [get_ports {gtx_sfp_disable[3]}]
set_property PACKAGE_PIN B6 [get_ports {gtx10g_rxp[0]}]
set_property PACKAGE_PIN A8 [get_ports {gtx10g_rxp[1]}]
set_property PACKAGE_PIN E4 [get_ports {gtx10g_rxp[2]}]
set_property PACKAGE_PIN D6 [get_ports {gtx10g_rxp[3]}]

set_property PACKAGE_PIN Y20 [get_ports si570_oe]
set_property IOSTANDARD LVCMOS25 [get_ports si570_oe]

set_property PACKAGE_PIN H26 [get_ports {gtx_rate_sel[0]}]
set_property PACKAGE_PIN A26 [get_ports {gtx_rate_sel[1]}]
set_property PACKAGE_PIN E29 [get_ports {gtx_rate_sel[2]}]
set_property PACKAGE_PIN F30 [get_ports {gtx_rate_sel[3]}]

set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[3]}]
