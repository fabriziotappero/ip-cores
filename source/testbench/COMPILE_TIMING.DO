#-----------------------------------------------------------------------------#
#                                                                             #
#                         M A C R O    F I L E                                #
#                          COPYRIGHT (C) 2006                                 #
#                                                                             #
#-----------------------------------------------------------------------------#
#-
#- Title       : COMPILE_TIMING.DO
#- Design      : MDCT Core
#- Author      : Michal Krepa
#-
#-----------------------------------------------------------------------------
#-
#- File        : COMPILE_TIMING.DO
#- Created     : Sat April 12 2006
#-
#-----------------------------------------------------------------------------
#-
#-  Description : ModelSim macro for compilation (timing simulation)
#-
#-----------------------------------------------------------------------------

# SIMPRIM
set XILINX $env(XILINX)
vlib simprim
vmap simprim simprim

compxlib -s mti_se -arch all -l all -lib simprim
vlib work
vmap work work

vcom SOURCE/MDCT_PKG.vhd

vcom SYNTHESIS/PRECISION/PROJECT_1_IMPL_1/MDCT_OUT.VHD
vcom SOURCE/TESTBENCH/MDCTTB_PKG.VHD
vcom SOURCE/TESTBENCH/random1.VHD
vcom SOURCE/TESTBENCH/CLKGEN.VHD
vcom SOURCE/TESTBENCH/INPIMAGE.VHD
vcom SOURCE/TESTBENCH/MDCT_TB.VHD
