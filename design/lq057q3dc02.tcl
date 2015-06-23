##############################################################################
# Copyright (C) 2007 Jonathon W. Donaldson
#                    jwdonal a t opencores DOT org
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
##############################################################################
#
# $Id: lq057q3dc02.tcl,v 1.2 2008-11-07 05:38:36 jwdonal Exp $
#
# Description:
#   Tcl script to run in the Xilinx Tcl shell or the ISE Tcl Console.  This
#   method is DEPRECATED.  Simply use the batch scripts found in the
#   'implement' directory for project management.  The GUI is nothing but
#   a memory hog - real men use scripts and plain text editors!!!
#
# Structure:
#   - xupv2p.ucf
#   - components.vhd
#   - lq057q3dc02_tb.vhd
#   - lq057q3dc02.vhd
#     - dcm_sys_to_lcd.xaw
#     - video_controller.vhd
#       - enab_control.vhd
#       - hsyncx_control.vhd
#       - vsyncx_control.vhd
#       - clk_lcd_cyc_cntr.vhd
#     - image_gen_bram.vhd
#       - image_gen_bram_red.xco
#       - image_gen_bram_green.xco
#       - image_gen_bram_blue.xco
#       
##############################################################################

# To run this script, `cd' to the directory containg this file
# using the Tcl shell/console.  Type "source <filename>" at Tcl prompt.
# This script is compatible with ISE 9.1.03i

#Go to project directory
cd ../ise_files

# set up the project
project new lq057q3dc02.ise
project set family Virtex2P
project set device XC2VP30
project set package FF896
project set speed -7
project set synthesis_tool "XST (VHDL/Verilog)"
project set generated_simulation_language "ModelSim-SE Mixed"

# Go back to user source directory
cd ../src

# Add source files
xfile add *.vhd *.ucf *.xco *.xaw

# Set Generate Programming File properties
project set "Unused IOB Pins" "Pull Up"
project set "FPGA Start-Up Clock" "JTAG Clock"
project set "Done (Output Events)" 6
project set "Enable Outputs (Output Events)" 3
project set "Release Write Enable (Output Events)" 5
project set "Release DLL (Output Events)" 4
