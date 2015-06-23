#! /bin/tcsh -f
mkdir -p work
mkdir -p utility
mkdir -p hdlc
mkdir -p memLib

# Utility files
ncvhdl -work utility -cdslib ./cds.lib -logfile ncvhdl.log -errormax 15 -append_log -v93 -linedebug -messages -status ./tools_pkg.vhd


#memLib
ncvhdl -work memLib -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./spmem.vhd 

ncvhdl -work memLib -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./mem_pkg.vhd 



#HDLC files
ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./PCK_CRC16_D8.vhd

ncvhdl -work hdlc -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./hdlc_components_pkg.vhd

#Work files
ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./RxFCS.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./RxBuff.vhd

ncvhdl -work work -cdslib ./cds.lib -logfile ncvhdl.log -append_log -errormax 15 -update -v93 -linedebug -messages -status ./RxTop_tb.vhd


#elaborating design
ncelab -work work -cdslib /home/jamil/Designs/hdlc/cds.lib -logfile ncelab.log -errormax 15 -messages -status -v93 -coverage work.rxtop_ent_tb:rxtop_beh_tb 
