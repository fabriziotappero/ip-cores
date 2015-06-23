#! /bin/tcsh -f
mkdir -p work
mkdir -p utility
mkdir -p hdlc
mkdir -p memLib

# Utility files
ncvhdl -work utility -cdslib ./cds.lib -logfile ncvhdl.log -errormax 15 -append_log -v93 -linedebug -messages -status ../code/tools_pkg.vhd


#memLib
ncvhdl -work memLib -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/spmem.vhd 

ncvhdl -work memLib -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/mem_pkg.vhd 



#HDLC files
ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/libs/PCK_CRC16_D8.vhd

ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/libs/hdlc_components_pkg.vhd

#Work files
#Rx
ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TOP/core/RxFCS.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TOP/core/RxBuff.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status  ../code/RX/core/Zero_detect.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status  ../code/RX/core/flag_detect.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/RX/core/Rxcont.vhd


ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status  ../code/RX/core/RxChannel.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TOP/core/RxSync.vhd


#Tx
ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TOP/core/TxFCS.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TOP/core/TxBuff.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TX/core/flag_ins.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TX/core/zero_ins.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TX/core/TXcont.vhd


ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TX/core/TxChannel.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status  ../code/TOP/core/TxSync.vhd



#WB and host
ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status  ../code/TOP/core/WB_IF.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ../code/TOP/core/hdlc.vhd

# Test bench
ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status  ../code/TOP/tb/hdlc_tb.vhd

#elaborating design
ncelab -work work -cdslib ./cds.lib -logfile ncelab.log -errormax 15 -messages -status -v93  work.hdlc_tb:hdlc_beh_tb 
