#! /bin/tcsh -f
# By Jamil Khatib
# This file for compiling the tdm project files using Cadence nc-sim tool
# You need to create sim directory in the same level of the code directory 
# From OpenCores CVS
# You have to start the simulation in this directory
#$Log: not supported by cvs2svn $
#Revision 1.1  2001/05/24 22:48:56  jamil
#TDM Initial release
#
mkdir -p work
mkdir -p utility
mkdir -p hdlc
mkdir -p memLib
mkdir -p tdm

# Utility files
ncvhdl -work utility -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tools_pkg.vhd

#memLib
ncvhdl -work memLib -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/mem_pkg.vhd

ncvhdl -work memLib -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/spmem.vhd


#HDLC files
#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/libs/hdlc_components_pkg.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/RX/core/Rxcont.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/RX/core/Zero_detect.vhd


#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/RX/core/flag_detect.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/RX/core/RxChannel.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/TX/core/TXcont.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/TX/core/flag_ins.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/TX/core/zero_ins.vhd

#ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../../hdlc/code/TX/core/TxChannel.vhd

#ISDN files
#ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/ISDN_cont/core/ISDN_cont.vhd

#ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/libs/components_pkg.vhd

#ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/ISDN_cont/core/ISDN_cont_top.vhd


#ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/ISDN_cont/tb/ISDN_cont_tb.vhd


#TDM files
ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/core/tdm_cont.vhd

ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/libs/components_pkg.vhd

ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/tb/tdm_cont_tb.vhd


ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/core/RxTDMBuff.vhd

ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/core/TxTDMBuff.vhd

ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/core/tdm_wb_if.vhd

ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/core/tdm_core_top.vhd

ncvhdl -work tdm -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/tdm_cont/tb/tdm_cont_top_tb.vhd

#elaborating design
#ncelab -work work -cdslib ./cds.lib -logfile ncelab.log -errormax 15 -messages -status -v93 work.isdn_cont_tb:isdn_cont_tb
