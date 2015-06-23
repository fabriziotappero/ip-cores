# $Id: rsx11mp-30_rp_boot.tcl 679 2015-05-13 17:38:46Z mueller $
#
# Setup file for RSX11-M+ V3.0 RP06 based system
#
# Usage:
#   
# console_starter -d DL0 &
# console_starter -d DL1 &
# ti_w11 -xxx @rsx11mp-30_rp_boot.tcl    ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
puts [rlw]

# setup tt,lp (211bsd uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" {to7bit 1}
rw11::setup_lp 

# mount disks
cpu0rpa0 set type rp06
cpu0rpa1 set type rp06

cpu0rpa0 att rsx11mp-30.dsk

# and boot
rw11::cpumon
rw11::cpucons
cpu0 boot rpa0
