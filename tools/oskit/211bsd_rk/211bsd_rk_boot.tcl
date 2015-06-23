# $Id: 211bsd_rk_boot.tcl 622 2014-12-28 20:45:26Z mueller $
#
# Setup file for 211bsd RK05 based system
#
# Usage:
#   
# console_starter -d DL0 &
# console_starter -d DL1 &
# ti_w11 -xxx @211bsd_rk_boot.tcl        ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
puts [rlw]

# setup tt,lp (211bsd uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" {to7bit 1}
rw11::setup_lp 

# mount disks
cpu0rka0 att 211bsd_rk_root.dsk
cpu0rka1 att 211bsd_rk_swap.dsk
cpu0rka2 att 211bsd_rk_tmp.dsk
cpu0rka3 att 211bsd_rk_bin.dsk
cpu0rka4 att 211bsd_rk_usr.dsk

# and boot
rw11::cpumon
rw11::cpucons
cpu0 boot rka0
