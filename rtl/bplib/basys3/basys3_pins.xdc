# -*- tcl -*-
# $Id: basys3_pins.xdc 640 2015-02-01 09:56:53Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Pin locks for Basys 3 core functionality
#  - USB UART
#  - human I/O (switches, buttons, leds, display)
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-01-30   640   1.0    Initial version
#

# config setup --------------------------------------------------------------
set_property CFGBVS         VCCO [current_design]
set_property CONFIG_VOLTAGE  3.3 [current_design]

# clocks -- in bank 34 ------------------------------------------------------
set_property PACKAGE_PIN w5  [get_ports {I_CLK100}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_CLK100}]

#
# USB UART Interface -- in bank 16 ------------------------------------------
set_property PACKAGE_PIN b18 [get_ports {I_RXD}]
set_property PACKAGE_PIN a18 [get_ports {O_TXD}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_RXD O_TXD}]
set_property DRIVE 12   [get_ports {O_TXD}]
set_property SLEW SLOW  [get_ports {O_TXD}]

#
# switches -- in bank 14+34 -------------------------------------------------
set_property PACKAGE_PIN v17 [get_ports {I_SWI[0]}]
set_property PACKAGE_PIN v16 [get_ports {I_SWI[1]}]
set_property PACKAGE_PIN w16 [get_ports {I_SWI[2]}]
set_property PACKAGE_PIN w17 [get_ports {I_SWI[3]}]
set_property PACKAGE_PIN w15 [get_ports {I_SWI[4]}]
set_property PACKAGE_PIN v15 [get_ports {I_SWI[5]}]
set_property PACKAGE_PIN w14 [get_ports {I_SWI[6]}]
set_property PACKAGE_PIN w13 [get_ports {I_SWI[7]}]
set_property PACKAGE_PIN v2  [get_ports {I_SWI[8]}]
set_property PACKAGE_PIN t3  [get_ports {I_SWI[9]}]
set_property PACKAGE_PIN t2  [get_ports {I_SWI[10]}]
set_property PACKAGE_PIN r3  [get_ports {I_SWI[11]}]
set_property PACKAGE_PIN w2  [get_ports {I_SWI[12]}]
set_property PACKAGE_PIN u1  [get_ports {I_SWI[13]}]
set_property PACKAGE_PIN t1  [get_ports {I_SWI[14]}]
set_property PACKAGE_PIN r2  [get_ports {I_SWI[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_SWI[*]}]

#
# buttons -- in bank 14 -----------------------------------------------------
#   sequence: clockwise(U-R-D-L) - middle - reset
set_property PACKAGE_PIN t18 [get_ports {I_BTN[0]}]
set_property PACKAGE_PIN t17 [get_ports {I_BTN[1]}]
set_property PACKAGE_PIN u17 [get_ports {I_BTN[2]}]
set_property PACKAGE_PIN w19 [get_ports {I_BTN[3]}]
set_property PACKAGE_PIN u18 [get_ports {I_BTN[4]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_BTN[*]}]

#
# LEDs -- in bank 14+34+35 --------------------------------------------------
set_property PACKAGE_PIN u16 [get_ports {O_LED[0]}]
set_property PACKAGE_PIN e19 [get_ports {O_LED[1]}]
set_property PACKAGE_PIN u19 [get_ports {O_LED[2]}]
set_property PACKAGE_PIN v19 [get_ports {O_LED[3]}]
set_property PACKAGE_PIN w18 [get_ports {O_LED[4]}]
set_property PACKAGE_PIN u15 [get_ports {O_LED[5]}]
set_property PACKAGE_PIN u14 [get_ports {O_LED[6]}]
set_property PACKAGE_PIN v14 [get_ports {O_LED[7]}]
set_property PACKAGE_PIN v13 [get_ports {O_LED[8]}]
set_property PACKAGE_PIN v3  [get_ports {O_LED[9]}]
set_property PACKAGE_PIN w3  [get_ports {O_LED[10]}]
set_property PACKAGE_PIN u3  [get_ports {O_LED[11]}]
set_property PACKAGE_PIN p3  [get_ports {O_LED[12]}]
set_property PACKAGE_PIN n3  [get_ports {O_LED[13]}]
set_property PACKAGE_PIN p1  [get_ports {O_LED[14]}]
set_property PACKAGE_PIN l1  [get_ports {O_LED[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_LED[*]}]
set_property DRIVE 12            [get_ports {O_LED[*]}]
set_property SLEW SLOW           [get_ports {O_LED[*]}]

#
# 7 segment display -- in bank 34 -------------------------------------------
set_property PACKAGE_PIN u2  [get_ports {O_ANO_N[0]}]
set_property PACKAGE_PIN u4  [get_ports {O_ANO_N[1]}]
set_property PACKAGE_PIN v4  [get_ports {O_ANO_N[2]}]
set_property PACKAGE_PIN w4  [get_ports {O_ANO_N[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_ANO_N[*]}]
set_property DRIVE 12            [get_ports {O_ANO_N[*]}]
set_property SLEW SLOW           [get_ports {O_ANO_N[*]}]
#
set_property PACKAGE_PIN w7  [get_ports {O_SEG_N[0]}]
set_property PACKAGE_PIN w6  [get_ports {O_SEG_N[1]}]
set_property PACKAGE_PIN u8  [get_ports {O_SEG_N[2]}]
set_property PACKAGE_PIN v8  [get_ports {O_SEG_N[3]}]
set_property PACKAGE_PIN u5  [get_ports {O_SEG_N[4]}]
set_property PACKAGE_PIN v5  [get_ports {O_SEG_N[5]}]
set_property PACKAGE_PIN u7  [get_ports {O_SEG_N[6]}]
set_property PACKAGE_PIN v7  [get_ports {O_SEG_N[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_SEG_N[*]}]
set_property DRIVE 12            [get_ports {O_SEG_N[*]}]
set_property SLEW SLOW           [get_ports {O_SEG_N[*]}]

