# $Id: viv_tools_model.tcl 646 2015-02-15 12:04:55Z mueller $
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
proc rvtb_default_model {stem mode} {

  switch $mode {
    ssim {
      open_checkpoint "${stem}_syn.dcp"
      write_vhdl -mode funcsim -force "${stem}_ssim.vhd"
    }

    osim {
      open_checkpoint "${stem}_opt.dcp"
      write_vhdl -mode funcsim -force "${stem}_osim.vhd"
    }

    tsim {
      open_checkpoint "${stem}_rou.dcp"
      write_verilog -mode timesim -force -sdf_anno true "${stem}_tsim.v"
      write_sdf     -mode timesim -force "${stem}_tsim.sdf"
    }

    default {
      error "-E: bad mode: $mode";
    }
  }
  return "";
}
