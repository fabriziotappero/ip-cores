#-----------------------------------------------------------------------------#
#                                                                             #
#                         M A C R O    F I L E                                #
#                          COPYRIGHT (C) 2006                                 #
#                                                                             #
#-----------------------------------------------------------------------------#
#-
#- Title       : MDCT_TB.DO
#- Design      : MDCT Core
#- Author      : Michal Krepa
#-
#------------------------------------------------------------------------------
#-
#- File        : MDCT_TB.DO
#- Created     : Sat Mar 5 2006
#-
#------------------------------------------------------------------------------
#-
#-  Description : ModelSim macro for compilation
#-
#------------------------------------------------------------------------------


set ROM_MODEL XILINX
#set ROM_MODEL GENERIC

vlib work
vmap work work

vcom SOURCE/MDCT_PKG.vhd
if {$ROM_MODEL=="XILINX"} {
  vcom -87 SOURCE/XILINX/ROME_XIL.VHD
  vcom -87 SOURCE/XILINX/ROME.VHD
  vcom -87 SOURCE/XILINX/ROMO_XIL.VHD
  vcom -87 SOURCE/XILINX/ROMO.VHD 
} else {
  vcom -87 SOURCE/ROME.VHD
  vcom -87 SOURCE/ROMO.VHD
}
vcom -87 SOURCE/RAM.VHD
vcom -87 SOURCE/DCT1D.VHD
vcom -87 SOURCE/DCT2D.VHD
vcom -87 SOURCE/DBUFCTL.VHD
vcom -87 SOURCE/MDCT.VHD
vcom -87 SOURCE/TESTBENCH/MDCTTB_PKG.VHD
vcom -87 SOURCE/TESTBENCH/random1.VHD
vcom -87 SOURCE/TESTBENCH/CLKGEN.VHD
vcom -93 SOURCE/TESTBENCH/INPIMAGE.VHD
vcom -87 SOURCE/TESTBENCH/MDCT_TB.VHD
