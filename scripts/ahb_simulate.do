#!/bin/tcsh
if !(${?DSN}) then
    echo "Please set DSN variable to design path!"
endif
if !(${?SIMULATOR}) then
    echo "Please set SIMULATOR variable to 'vcom' or 'ncvhdl'!"
endif
$SIMULATOR $DSN/src/ahb_package.vhd
$SIMULATOR $DSN/src/ahb_configure.vhd
$SIMULATOR $DSN/src/ahb_funct.vhd
$SIMULATOR $DSN/src/fifo.vhd
$SIMULATOR $DSN/src/slv_mem.vhd
$SIMULATOR $DSN/src/ahb_slave_wait.vhd 
$SIMULATOR $DSN/src/mst_wrap.vhd
$SIMULATOR $DSN/src/ahb_master.vhd
$SIMULATOR $DSN/src/ahb_arbiter.vhd
$SIMULATOR $DSN/src/uut_stimulator.vhd
$SIMULATOR $DSN/src/ahb_components.vhd
$SIMULATOR $DSN/src/ahb_matrix.vhd
$SIMULATOR $DSN/src/ahb_system.vhd
$SIMULATOR $DSN/src/ahb_tb.vhd
if ($SIMULATOR == ncvhdl) then
    ncelab work.ahb_tb:rtl -access r
else
    vsim work.ahb_tb(rtl) -t 100 ps
endif
