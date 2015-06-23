# $Id: test_attn.tcl 661 2015-04-03 18:28:41Z mueller $
#
# Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
#
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#
#  Revision History:
# Date         Rev Version  Comment
# 2015-04-03   661   2.1    drop estatdef (stat err check default now)
# 2014-11-09   603   2.0    use rlink v4 address layout and iface
# 2011-03-27   374   1.0    Initial version
# 2011-03-20   372   0.1    First Draft
#

package provide rbtest 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbtest {
  #
  # Test with stat connectivity of the cntl register.
  #
  proc test_attn {{attnmsk 0x0}} {
    # quit if nothing to do...
    if {$attnmsk == 0} {return 0}
    #
    set apats {}
    for {set i 0} {$i < 16} {incr i} {
      set apat [expr {1 << $i}]
      if {[expr {$apat & $attnmsk}]} {lappend apats $apat}
    }
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbtest::test_attn - init: clear regs and attn flags"
    rlc exec -init te.cntl [regbld rbtest::INIT cntl data fifo]
    rlc exec -attn

    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: verify connection of attn bits"
    foreach apat $apats {
      rlc exec \
        -wreg te.attn $apat \
        -rreg te.cntl -estat [regbld rlink::STAT attn] \
        -attn         -edata $apat \
        -rreg te.cntl -estat 0x0
    }

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: verify that attn flags accumulate"
    foreach apat $apats {
      rlc exec -wreg te.attn $apat 
    }
    rlc exec -attn -edata $attnmsk

    #
    #-------------------------------------------------------------------------
    #rlc log "  test 3: verify that <attn> comma is send"
    #set apat [lindex $apats 0]
    #rlc exec -init 0xff [regbld rlink::INIT anena] -estat $esdval $esdmsk 
    #rlc exec -wreg te.attn $apat -estat $esdval $esdmsk
    #rlc wtlam 1.
    #rlc exec -attn -edata $apat -estat $esdval $esdmsk

    #
    #-------------------------------------------------------------------------
    rlc log "rbtest::test_attn - cleanup: clear regs and attn flags"
    rlc exec -init te.cntl [regbld rbtest::INIT cntl data fifo]
    rlc exec -attn
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
