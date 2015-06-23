# $Id: uv5_rk_boot.tcl 622 2014-12-28 20:45:26Z mueller $
#
# Setup file for Unix V5 RK05 based system
#
# Usage:
#   
# console_starter -d DL0 &
# ti_w11 -xxx @uv5_boot.tcl              ( -xxx depends on sim or fpga connect)

# setup w11 cpu
puts [rlw]

# setup tt,lp (uses only 1 console; uses parity -> use 7 bit mode)
rw11::setup_tt "cpu0" {ndl 1 to7bit 1}
rw11::setup_lp 

# mount disks
cpu0rka0 att unix_v5_rk.dsk

# and boot
rw11::cpumon
rw11::cpucons
cpu0 boot rka0
