# $Id: 211bsd_rl_boot.tcl 633 2015-01-11 22:58:48Z mueller $
#
# Setup file for 211bsd RL02 based system
#
# Usage:
#   
# console_starter -d DL0 &
# console_starter -d DL1 &
# ti_w11 -xxx @211bsd_rl_boot.tcl        ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
puts [rlw]

# setup tt,lp (211bsd uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" {to7bit 1}
rw11::setup_lp 

# mount disks
cpu0rla0 att 211bsd_rl_root.dsk
cpu0rla1 att 211bsd_rl_usr.dsk

# and boot
rw11::cpumon
rw11::cpucons
cpu0 boot rla0
