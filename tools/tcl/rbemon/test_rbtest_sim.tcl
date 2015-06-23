# $Id: test_rbtest_sim.tcl 516 2013-05-05 21:24:52Z mueller $
#
# Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2011-04-17   376   1.0    Initial version
#

package provide rbemon 1.0

package require rbtest

namespace eval rbemon {
  #
  # some simple tests against rbd_tester registers in sim mode
  #
  proc test_rbtest_sim {} {
    set esdval 0x00
    set esdmsk [regbld rlink::STAT {stat -1}]
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbemon::test_rbtest_sim - start"
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: write to te.data, verify that transitions seen"
    set bsize 25
    #
    rlc exec -wreg em.rdiv 0 -estat $esdval $esdmsk
    rlc log "    - data - 01 10 va00 va01 va02 va03 va04 va05 va06 va07 va08 va09"
    #
    # Note: avoid chars which will be escpaped, like 10000000, for this test
    #
    foreach {pat ena01 ena10 exp} \
      [list [bvi b 00000000] 1 1 [list 0 0 0 0 0 0 0 0 1 0]\
            [bvi b 00000001] 1 1 [list 1 1 0 0 0 0 0 0 1 0]\
            [bvi b 00000010] 1 1 [list 0 1 1 0 0 0 0 0 1 0]\
            [bvi b 00000100] 1 1 [list 0 0 1 1 0 0 0 0 1 0]\
            [bvi b 00001000] 1 1 [list 0 0 0 1 1 0 0 0 1 0]\
            [bvi b 00010000] 1 1 [list 0 0 0 0 1 1 0 0 1 0]\
            [bvi b 00100000] 1 1 [list 0 0 0 0 0 1 1 0 1 0]\
            [bvi b 01000000] 1 1 [list 0 0 0 0 0 0 1 1 1 0]\
            [bvi b 11111111] 1 1 [list 1 0 0 0 0 0 0 0 0 0]\
            [bvi b 11111110] 1 1 [list 0 1 0 0 0 0 0 0 0 0]\
            [bvi b 01010101] 1 1 [list 1 1 1 1 1 1 1 1 1 0]\
            [bvi b 00110011] 1 1 [list 1 0 1 0 1 0 1 0 1 0]\
            [bvi b 00000001] 0 1 [list 0 1 0 0 0 0 0 0 0 0]\
            [bvi b 00000001] 1 0 [list 1 0 0 0 0 0 0 0 1 0]\
            [bvi b 01010101] 0 1 [list 0 1 0 1 0 1 0 1 0 0]\
            [bvi b 01010101] 1 0 [list 1 0 1 0 1 0 1 0 1 0]\
       ] {
      set bdata {}
      for {set i 0} {$i < $bsize} {incr i} {
        lappend bdata [expr {( $pat << 8 ) | $pat}]
      }

      rbemon::clear
      rbemon::start $ena01 $ena10
      rlc exec -wblk te.data $bdata -estat $esdval $esdmsk
      rbemon::stop

      set edata [rbemon::read 10]

      set oline "    "
      set pafa  "OK"
      append oline [pbvi b8 $pat]
      append oline [format "  %d  %d" $ena01 $ena10]
      for {set i 0} {$i < 10} {incr i} {
        set ebin [lindex $edata $i]
        set eexp [lindex $exp   $i]
        append oline [format " %3d" $ebin]
        if {($eexp != 0 && $ebin <  2 * $bsize) || 
            ($eexp == 0 && $ebin >= 2 * $bsize)} {
          append oline "#"
          set pafa "FAIL"
          incr errcnt
        } else {
          append oline "!"
        }
      }
      append oline "  "
      append oline $pafa
      rlc log $oline
    }
    #
    #-------------------------------------------------------------------------
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
