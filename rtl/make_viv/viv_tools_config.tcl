# $Id: viv_tools_config.tcl 646 2015-02-15 12:04:55Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-02-14   646   1.0    Initial version
#

#
# --------------------------------------------------------------------
#
proc rvtb_default_config {stem} {
  # open and connect to hardware server
  open_hw
  connect_hw_server

  # connect to target
  open_hw_target [lindex [get_hw_targets -of_objects [get_hw_servers localhost]] 0]

  # setup bitfile
  set_property PROGRAM.FILE "${stem}.bit" [lindex [get_hw_devices] 0]

  # and configure FPGA
  program_hw_devices [lindex [get_hw_devices] 0]

  return "";
}
