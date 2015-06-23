# By Jamil Khatib
# This file for compiling the tdm project files using Cadence nc-sim tool
# You need to create sim directory in the same level of the code directory 
# From OpenCores CVS
# You have to start the simulation in this directory
#$Log: not supported by cvs2svn $
vlib work
vlib utility
vlib hdlc
vlib memLib
vlib tdm

# Utility files

#memLib


#HDLC files
vcom -work hdlc  ../../hdlc/code/libs/hdlc_components_pkg.vhd

vcom -work hdlc  ../../hdlc/code/RX/core/Rxcont.vhd

vcom -work hdlc  ../../hdlc/code/RX/core/Zero_detect.vhd


vcom -work hdlc  ../../hdlc/code/RX/core/flag_detect.vhd

vcom -work hdlc  ../../hdlc/code/RX/core/RxChannel.vhd

vcom -work hdlc  ../../hdlc/code/TX/core/TXcont.vhd

vcom -work hdlc  ../../hdlc/code/TX/core/flag_ins.vhd

vcom -work hdlc  ../../hdlc/code/TX/core/zero_ins.vhd

vcom -work hdlc  ../../hdlc/code/TX/core/TxChannel.vhd

#ISDN files
vcom -work work  ../code/ISDN_cont/core/ISDN_cont.vhd

vcom -work tdm  ../code/libs/components_pkg.vhd

vcom -work work  ../code/ISDN_cont/core/ISDN_cont_top.vhd


vcom -work work  ../code/ISDN_cont/tb/ISDN_cont_tb.vhd


#elaborating design
#ncelab -work work -cdslib ./cds.lib -logfile ncelab.log -errormax 15 -messages -status -v93 work.isdn_cont_tb:isdn_cont_tb
