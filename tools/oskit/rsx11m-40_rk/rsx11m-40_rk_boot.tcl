# $Id: rsx11m-40_rk_boot.tcl 622 2014-12-28 20:45:26Z mueller $
#
# Setup file for RSX11-M V4.0 RK05 based system
#
# Usage:
#   
# console_starter -d DL0 &
# console_starter -d DL1 &
# ti_w11 -xxx @rsx11m-40_rk_boot.tcl     ( -xxx depends on sim or fpga connect)
#

# setup w11 cpu
puts [rlw]

# setup tt,lp,pp (enable rx rate limiter on old DEC OS)
rw11::setup_tt "cpu0" {dlrlim 5}
rw11::setup_lp 
rw11::setup_pp

# mount disks
cpu0rka0 att RSX11M_V4.0_SYSTEM0.dsk
cpu0rka1 att RSX11M_V4.0_SYSTEM1.dsk
cpu0rka2 att RSX11M_USER.dsk

# and boot
rw11::cpumon
rw11::cpucons
cpu0 boot rka0
