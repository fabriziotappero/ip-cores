###############################################################################
# User Configuration
# Link Width   - x8
# Link Speed   - gen3
# Family       - virtex7
# Part         - xc7vx690t
# Package      - ffg1761
# Speed grade  - -2
# PCIe Block   - X0Y1
###############################################################################
#
#########################################################################################################################
# User Constraints
#########################################################################################################################

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################

#! file TEST.XDC
#! net constraints for TEST design

set_property IOSTANDARD LVCMOS18 [get_ports emcclk]
set_property PACKAGE_PIN AP37 [get_ports emcclk]

#XADC GPIO
set_property IOSTANDARD LVCMOS18 [get_ports emcclk_out]
set_property PACKAGE_PIN J42 [get_ports emcclk_out]


set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

#System Reset, User Reset, User Link Up, User Clk Heartbeat
set_property PACKAGE_PIN F42 [get_ports {leds[0]}]
set_property PACKAGE_PIN E42 [get_ports {leds[1]}]
set_property PACKAGE_PIN D42 [get_ports {leds[2]}]
set_property PACKAGE_PIN D41 [get_ports {leds[3]}]
set_property PACKAGE_PIN B42 [get_ports {leds[4]}]
set_property PACKAGE_PIN B41 [get_ports {leds[5]}]
set_property PACKAGE_PIN A41 [get_ports {leds[6]}]
set_property PACKAGE_PIN A40 [get_ports {leds[7]}]
#
set_property IOSTANDARD LVCMOS18 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {leds[7]}]

#########################################################################################################################
# End User Constraints
#########################################################################################################################
#
#
#
#########################################################################################################################
# PCIE Core Constraints
#########################################################################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#

set_property PACKAGE_PIN AN39 [get_ports sys_reset_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_reset_n]
set_property PULLUP true [get_ports sys_reset_n]

#
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#
set_property LOC IBUFDS_GTE2_X1Y10 [get_cells u1/u1/refclk_buff]

###############################################################################
# Timing Constraints
###############################################################################
create_clock -period 10.000 -name sys_clk [get_pins u1/u1/refclk_buff/O]

create_generated_clock -name clk_125mhz_x0y1 [get_pins u1/u1/pipe_clock0/mmcm0/CLKOUT0]
create_generated_clock -name clk_250mhz_x0y1 [get_pins u1/u1/pipe_clock0/mmcm0/CLKOUT1]
create_generated_clock -name userclk1 [get_pins u1/u1/pipe_clock0/mmcm0/CLKOUT2]
create_generated_clock -name userclk2 [get_pins u1/u1/pipe_clock0/mmcm0/CLKOUT3]

create_generated_clock -name clk_125mhz_mux_x0y1 -source [get_pins u1/u1/pipe_clock0/g0.pclk_i1/I0] -divide_by 1 [get_pins u1/u1/pipe_clock0/g0.pclk_i1/O]
create_generated_clock -name clk_250mhz_mux_x0y1 -source [get_pins u1/u1/pipe_clock0/g0.pclk_i1/I1] -divide_by 1 -add -master_clock clk_250mhz_x0y1 [get_pins u1/u1/pipe_clock0/g0.pclk_i1/O]
set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux_x0y1 -group clk_250mhz_mux_x0y1

set_false_path -to [get_pins u1/u1/pipe_clock0/g0.pclk_i1/S0]
set_false_path -to [get_pins u1/u1/pipe_clock0/g0.pclk_i1/S1]

###############################################################################
# Physical Constraints
###############################################################################

set_false_path -from [get_ports sys_reset_n]
set_false_path -reset_path -from [get_pins u1/u1/u1/inst/gt_top_i/pipe_wrapper_i/pipe_reset_i/cpllreset_reg/C]
###############################################################################
# End
###############################################################################









