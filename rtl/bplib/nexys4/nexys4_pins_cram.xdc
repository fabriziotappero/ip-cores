# -*- tcl -*-
# $Id: nexys4_pins_cram.xdc 643 2015-02-07 17:41:53Z mueller $
#
# Pin locks for Nexys 4 cram
#
# Revision History: 
# Date         Rev Version  Comment
# 2015-02-06   643   1.0    Initial version (derived from nexys4_pins.xdc)
#

# CRAM -- in bank 14+15 -----------------------------------------------------
set_property PACKAGE_PIN l18 [get_ports {O_MEM_CE_N}]
set_property PACKAGE_PIN r11 [get_ports {O_MEM_WE_N}]
set_property PACKAGE_PIN h14 [get_ports {O_MEM_OE_N}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_MEM_CE_N O_MEM_WE_N O_MEM_OE_N}]
set_property DRIVE 12            [get_ports {O_MEM_CE_N O_MEM_WE_N O_MEM_OE_N}]
set_property SLEW FAST           [get_ports {O_MEM_CE_N O_MEM_WE_N O_MEM_OE_N}]
#
set_property PACKAGE_PIN j15 [get_ports {O_MEM_BE_N[0]}]
set_property PACKAGE_PIN j13 [get_ports {O_MEM_BE_N[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_MEM_BE_N[*]}]
set_property DRIVE 12            [get_ports {O_MEM_BE_N[*]}]
set_property SLEW FAST           [get_ports {O_MEM_BE_N[*]}]
#
set_property PACKAGE_PIN t13 [get_ports {O_MEM_ADV_N}]
set_property PACKAGE_PIN t15 [get_ports {O_MEM_CLK}]
set_property PACKAGE_PIN j14 [get_ports {O_MEM_CRE}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_MEM_ADV_N O_MEM_CLK O_MEM_CRE}]
set_property DRIVE 12            [get_ports {O_MEM_ADV_N O_MEM_CLK O_MEM_CRE}]
set_property SLEW FAST           [get_ports {O_MEM_ADV_N O_MEM_CLK O_MEM_CRE}]

#
set_property PACKAGE_PIN t14 [get_ports {I_MEM_WAIT}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_MEM_WAIT}]

#
set_property PACKAGE_PIN j18 [get_ports {O_MEM_ADDR[0]}]
set_property PACKAGE_PIN h17 [get_ports {O_MEM_ADDR[1]}]
set_property PACKAGE_PIN h15 [get_ports {O_MEM_ADDR[2]}]
set_property PACKAGE_PIN j17 [get_ports {O_MEM_ADDR[3]}]
set_property PACKAGE_PIN h16 [get_ports {O_MEM_ADDR[4]}]
set_property PACKAGE_PIN k15 [get_ports {O_MEM_ADDR[5]}]
set_property PACKAGE_PIN k13 [get_ports {O_MEM_ADDR[6]}]
set_property PACKAGE_PIN n15 [get_ports {O_MEM_ADDR[7]}]
set_property PACKAGE_PIN v16 [get_ports {O_MEM_ADDR[8]}]
set_property PACKAGE_PIN u14 [get_ports {O_MEM_ADDR[9]}]
set_property PACKAGE_PIN v14 [get_ports {O_MEM_ADDR[10]}]
set_property PACKAGE_PIN v12 [get_ports {O_MEM_ADDR[11]}]
set_property PACKAGE_PIN p14 [get_ports {O_MEM_ADDR[12]}]
set_property PACKAGE_PIN u16 [get_ports {O_MEM_ADDR[13]}]
set_property PACKAGE_PIN r15 [get_ports {O_MEM_ADDR[14]}]
set_property PACKAGE_PIN n14 [get_ports {O_MEM_ADDR[15]}]
set_property PACKAGE_PIN n16 [get_ports {O_MEM_ADDR[16]}]
set_property PACKAGE_PIN m13 [get_ports {O_MEM_ADDR[17]}]
set_property PACKAGE_PIN v17 [get_ports {O_MEM_ADDR[18]}]
set_property PACKAGE_PIN u17 [get_ports {O_MEM_ADDR[19]}]
set_property PACKAGE_PIN t10 [get_ports {O_MEM_ADDR[20]}]
set_property PACKAGE_PIN m16 [get_ports {O_MEM_ADDR[21]}]
set_property PACKAGE_PIN u13 [get_ports {O_MEM_ADDR[22]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_MEM_ADDR[*]}]
set_property DRIVE 8             [get_ports {O_MEM_ADDR[*]}]
set_property SLEW FAST           [get_ports {O_MEM_ADDR[*]}]

#
set_property PACKAGE_PIN r12 [get_ports {IO_MEM_DATA[0]}]
set_property PACKAGE_PIN t11 [get_ports {IO_MEM_DATA[1]}]
set_property PACKAGE_PIN u12 [get_ports {IO_MEM_DATA[2]}]
set_property PACKAGE_PIN r13 [get_ports {IO_MEM_DATA[3]}]
set_property PACKAGE_PIN u18 [get_ports {IO_MEM_DATA[4]}]
set_property PACKAGE_PIN r17 [get_ports {IO_MEM_DATA[5]}]
set_property PACKAGE_PIN t18 [get_ports {IO_MEM_DATA[6]}]
set_property PACKAGE_PIN r18 [get_ports {IO_MEM_DATA[7]}]
set_property PACKAGE_PIN f18 [get_ports {IO_MEM_DATA[8]}]
set_property PACKAGE_PIN g18 [get_ports {IO_MEM_DATA[9]}]
set_property PACKAGE_PIN g17 [get_ports {IO_MEM_DATA[10]}]
set_property PACKAGE_PIN m18 [get_ports {IO_MEM_DATA[11]}]
set_property PACKAGE_PIN m17 [get_ports {IO_MEM_DATA[12]}]
set_property PACKAGE_PIN p18 [get_ports {IO_MEM_DATA[13]}]
set_property PACKAGE_PIN n17 [get_ports {IO_MEM_DATA[14]}]
set_property PACKAGE_PIN p17 [get_ports {IO_MEM_DATA[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {IO_MEM_DATA[*]}]
set_property DRIVE 8             [get_ports {IO_MEM_DATA[*]}]
set_property SLEW SLOW           [get_ports {IO_MEM_DATA[*]}]
set_property KEEPER true         [get_ports {IO_MEM_DATA[*]}]
#
