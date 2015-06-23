# -*- tcl -*-
# $Id: nexys4_pins.xdc 643 2015-02-07 17:41:53Z mueller $
#
# Pin locks for Nexys 4 core functionality
#  - USB UART
#  - human I/O (switches, buttons, leds, display)
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-02-06   643   1.3    factor out cram 
# 2015-02-01   641   1.2    separate I_BTNRST_N
# 2015-01-31   640   1.1    fix RTS/CTS
# 2013-10-12   539   1.0    Initial version (converted from ucf)
#

# config setup --------------------------------------------------------------
set_property CFGBVS         VCCO [current_design]
set_property CONFIG_VOLTAGE  3.3 [current_design]

# clocks -- in bank 35 ------------------------------------------------------
set_property PACKAGE_PIN e3 [get_ports {I_CLK100}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_CLK100}]

#
# USB UART Interface -- in bank 35 ------------------------------------------
set_property PACKAGE_PIN c4 [get_ports {I_RXD}]
set_property PACKAGE_PIN d4 [get_ports {O_TXD}]
set_property PACKAGE_PIN d3 [get_ports {O_RTS_N}]
set_property PACKAGE_PIN e5 [get_ports {I_CTS_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_RXD O_TXD O_RTS_N I_CTS_N}]
set_property DRIVE 12   [get_ports {O_TXD O_RTS_N}]
set_property SLEW SLOW  [get_ports {O_TXD O_RTS_N}]

#
# switches -- in bank 34 ----------------------------------------------------
set_property PACKAGE_PIN u9 [get_ports {I_SWI[0]}]
set_property PACKAGE_PIN u8 [get_ports {I_SWI[1]}]
set_property PACKAGE_PIN r7 [get_ports {I_SWI[2]}]
set_property PACKAGE_PIN r6 [get_ports {I_SWI[3]}]
set_property PACKAGE_PIN r5 [get_ports {I_SWI[4]}]
set_property PACKAGE_PIN v7 [get_ports {I_SWI[5]}]
set_property PACKAGE_PIN v6 [get_ports {I_SWI[6]}]
set_property PACKAGE_PIN v5 [get_ports {I_SWI[7]}]
set_property PACKAGE_PIN u4 [get_ports {I_SWI[8]}]
set_property PACKAGE_PIN v2 [get_ports {I_SWI[9]}]
set_property PACKAGE_PIN u2 [get_ports {I_SWI[10]}]
set_property PACKAGE_PIN t3 [get_ports {I_SWI[11]}]
set_property PACKAGE_PIN t1 [get_ports {I_SWI[12]}]
set_property PACKAGE_PIN r3 [get_ports {I_SWI[13]}]
set_property PACKAGE_PIN p3 [get_ports {I_SWI[14]}]
set_property PACKAGE_PIN p4 [get_ports {I_SWI[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_SWI[*]}]

#
# buttons -- in bank 15+14 --------------------------------------------------
#   sequence: clockwise(U-R-D-L) - middle - reset
set_property PACKAGE_PIN f15 [get_ports {I_BTN[0]}]
set_property PACKAGE_PIN r10 [get_ports {I_BTN[1]}]
set_property PACKAGE_PIN v10 [get_ports {I_BTN[2]}]
set_property PACKAGE_PIN t16 [get_ports {I_BTN[3]}]
set_property PACKAGE_PIN e16 [get_ports {I_BTN[4]}]
set_property PACKAGE_PIN c12 [get_ports {I_BTNRST_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {I_BTN[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_BTNRST_N}]

#
# LEDs -- in bank 34 --------------------------------------------------------
set_property PACKAGE_PIN t8 [get_ports {O_LED[0]}]
set_property PACKAGE_PIN v9 [get_ports {O_LED[1]}]
set_property PACKAGE_PIN r8 [get_ports {O_LED[2]}]
set_property PACKAGE_PIN t6 [get_ports {O_LED[3]}]
set_property PACKAGE_PIN t5 [get_ports {O_LED[4]}]
set_property PACKAGE_PIN t4 [get_ports {O_LED[5]}]
set_property PACKAGE_PIN u7 [get_ports {O_LED[6]}]
set_property PACKAGE_PIN u6 [get_ports {O_LED[7]}]
set_property PACKAGE_PIN v4 [get_ports {O_LED[8]}]
set_property PACKAGE_PIN u3 [get_ports {O_LED[9]}]
set_property PACKAGE_PIN v1 [get_ports {O_LED[10]}]
set_property PACKAGE_PIN r1 [get_ports {O_LED[11]}]
set_property PACKAGE_PIN p5 [get_ports {O_LED[12]}]
set_property PACKAGE_PIN u1 [get_ports {O_LED[13]}]
set_property PACKAGE_PIN r2 [get_ports {O_LED[14]}]
set_property PACKAGE_PIN p2 [get_ports {O_LED[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_LED[*]}]
set_property DRIVE 12            [get_ports {O_LED[*]}]
set_property SLEW SLOW           [get_ports {O_LED[*]}]

#
# RGB-LEDs -- in bank 15+34+35 ----------------------------------------------
set_property PACKAGE_PIN k5  [get_ports {O_RGBLED0[0]}]
set_property PACKAGE_PIN f13 [get_ports {O_RGBLED0[1]}]
set_property PACKAGE_PIN f6  [get_ports {O_RGBLED0[2]}]
set_property PACKAGE_PIN k6  [get_ports {O_RGBLED1[0]}]
set_property PACKAGE_PIN h6  [get_ports {O_RGBLED1[1]}]
set_property PACKAGE_PIN l16 [get_ports {O_RGBLED1[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property DRIVE 12            [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]
set_property SLEW SLOW           [get_ports {O_RGBLED0[*] O_RGBLED1[*]}]

#
# 7 segment display -- in bank 34 -------------------------------------------
set_property PACKAGE_PIN n6 [get_ports {O_ANO_N[0]}]
set_property PACKAGE_PIN m6 [get_ports {O_ANO_N[1]}]
set_property PACKAGE_PIN m3 [get_ports {O_ANO_N[2]}]
set_property PACKAGE_PIN n5 [get_ports {O_ANO_N[3]}]
set_property PACKAGE_PIN n2 [get_ports {O_ANO_N[4]}]
set_property PACKAGE_PIN n4 [get_ports {O_ANO_N[5]}]
set_property PACKAGE_PIN l1 [get_ports {O_ANO_N[6]}]
set_property PACKAGE_PIN m1 [get_ports {O_ANO_N[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_ANO_N[*]}]
set_property DRIVE 12            [get_ports {O_ANO_N[*]}]
set_property SLEW SLOW           [get_ports {O_ANO_N[*]}]
#
set_property PACKAGE_PIN l3 [get_ports {O_SEG_N[0]}]
set_property PACKAGE_PIN n1 [get_ports {O_SEG_N[1]}]
set_property PACKAGE_PIN l5 [get_ports {O_SEG_N[2]}]
set_property PACKAGE_PIN l4 [get_ports {O_SEG_N[3]}]
set_property PACKAGE_PIN k3 [get_ports {O_SEG_N[4]}]
set_property PACKAGE_PIN m2 [get_ports {O_SEG_N[5]}]
set_property PACKAGE_PIN l6 [get_ports {O_SEG_N[6]}]
set_property PACKAGE_PIN m4 [get_ports {O_SEG_N[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_SEG_N[*]}]
set_property DRIVE 12            [get_ports {O_SEG_N[*]}]
set_property SLEW SLOW           [get_ports {O_SEG_N[*]}]
#
