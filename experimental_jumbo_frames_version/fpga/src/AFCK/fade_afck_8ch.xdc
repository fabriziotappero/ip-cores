set_property IOSTANDARD LVCMOS15 [get_ports boot_clk]
set_property PACKAGE_PIN AF6 [get_ports boot_clk]

set_property IOSTANDARD LVCMOS25 [get_ports {hb_led[0]}]
set_property PACKAGE_PIN G23 [get_ports {hb_led[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hb_led[1]}]
set_property PACKAGE_PIN G25 [get_ports {hb_led[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {hb_led[2]}]
set_property PACKAGE_PIN F23 [get_ports {hb_led[2]}]

set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_sfp_disable[0]}]

#Clocks fed directly from FMC1 and FMC2 GBTCLK0/1
#set_property PACKAGE_PIN E8 [get_ports {gtx_refclk_p[0]}]
#set_property PACKAGE_PIN G8 [get_ports {gtx_refclk_p[1]}]

#Clock from clock matrix via LINK01 and LINK23
set_property PACKAGE_PIN C8 [get_ports {gtx_refclk_p[0]}]
set_property PACKAGE_PIN J8 [get_ports {gtx_refclk_p[1]}]

set_property PACKAGE_PIN AE16 [get_ports clk_updaten]
set_property IOSTANDARD LVCMOS18 [get_ports clk_updaten]

set_property PACKAGE_PIN Y20 [get_ports si570_oe]
set_property IOSTANDARD LVCMOS25 [get_ports si570_oe]

create_clock -period 50.000 -name boot_clk -waveform {0.000 25.000} [get_nets boot_clk]

create_clock -period 6.400 -name clk156 -waveform {0.000 3.200} [get_nets *156*]
create_clock -period 6.400 -name gtx_refclk -waveform {0.000 3.200} [get_ports {gtx_refclk_n gtx_refclk_p}]

set_property PACKAGE_PIN E19 [get_ports {gtx_sfp_disable[0]}]
set_property PACKAGE_PIN A23 [get_ports {gtx_sfp_disable[1]}]
set_property PACKAGE_PIN C29 [get_ports {gtx_sfp_disable[2]}]
set_property PACKAGE_PIN F28 [get_ports {gtx_sfp_disable[3]}]
set_property PACKAGE_PIN T25 [get_ports {gtx_sfp_disable[4]}]
set_property PACKAGE_PIN AA28 [get_ports {gtx_sfp_disable[5]}]
set_property PACKAGE_PIN Y30 [get_ports {gtx_sfp_disable[6]}]
set_property PACKAGE_PIN AK28 [get_ports {gtx_sfp_disable[7]}]

set_property PACKAGE_PIN H26 [get_ports {gtx_rate_sel[0]}]
set_property PACKAGE_PIN A26 [get_ports {gtx_rate_sel[1]}]
set_property PACKAGE_PIN E29 [get_ports {gtx_rate_sel[2]}]
set_property PACKAGE_PIN F30 [get_ports {gtx_rate_sel[3]}]
set_property PACKAGE_PIN AE30 [get_ports {gtx_rate_sel[4]}]
set_property PACKAGE_PIN W28 [get_ports {gtx_rate_sel[5]}]
set_property PACKAGE_PIN AG27 [get_ports {gtx_rate_sel[6]}]
set_property PACKAGE_PIN AB30 [get_ports {gtx_rate_sel[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gtx_rate_sel[7]}]

set_property PACKAGE_PIN A8 [get_ports {gtx10g_rxp[0]}]
set_property PACKAGE_PIN B6 [get_ports {gtx10g_rxp[1]}]
set_property PACKAGE_PIN D6 [get_ports {gtx10g_rxp[2]}]
set_property PACKAGE_PIN E4 [get_ports {gtx10g_rxp[3]}]
set_property PACKAGE_PIN F6 [get_ports {gtx10g_rxp[4]}]
set_property PACKAGE_PIN G4 [get_ports {gtx10g_rxp[5]}]
set_property PACKAGE_PIN H6 [get_ports {gtx10g_rxp[6]}]
set_property PACKAGE_PIN K6 [get_ports {gtx10g_rxp[7]}]

set_property IOSTANDARD LVCMOS25 [get_ports scl]
set_property IOSTANDARD LVCMOS25 [get_ports sda]
set_property PACKAGE_PIN K19 [get_ports scl]
set_property PACKAGE_PIN G19 [get_ports sda]


