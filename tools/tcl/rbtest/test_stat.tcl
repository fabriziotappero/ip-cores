# $Id: test_stat.tcl 603 2014-11-09 22:50:26Z mueller $
#
# Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
  # Test with stat connectivity of the stat register.
  #
  proc test_stat {{statmsk 0x0}} {
    # quit if nothing to do...
    if {$statmsk == 0} {return 0}

    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbtest::test_stat - init: clear cntl"
    rlc exec -init te.cntl [regbld rbtest::INIT cntl]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: verify connection of cntl stat bits to stat return"
    for {set i 0} {$i < 4} {incr i} {
      set spat [expr {1 << $i}]
      if {[expr {$spat & $statmsk}]} {
        rlc exec \
          -wreg te.stat $spat \
          -rreg te.stat -edata $spat \
            -estat [regbld rlink::STAT [list stat $spat]]
      }
    }
    #
    #-------------------------------------------------------------------------
    rlc log "rbtest::test_stat - cleanup: clear cntl"
    rlc exec -init te.cntl [regbld rbtest::INIT cntl]
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
