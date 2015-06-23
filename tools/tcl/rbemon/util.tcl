# $Id: util.tcl 643 2015-02-07 17:41:53Z mueller $
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
# 2015-02-07   642   1.1    add print()
# 2011-04-17   376   1.0.1  add proc read
# 2011-04-02   375   1.0    Initial version
#

package provide rbemon 1.0

package require rutil
package require rlink

namespace eval rbemon {
  #
  # setup register descriptions for rbd_eyemon
  #
  regdsc CNTL {ena01 3} {ena10 2} {clr 1} {go 0}
  regdsc RDIV {rdiv 7 8}
  regdsc ADDR {addr 9 10 "-"} {laddr 9 8} {waddr 0}
  #
  # setup: amap definitions for rbd_eyemon
  # 
  proc setup {{base 0xffd0}} {
    rlc amap -insert em.cntl [expr {$base + 0x00}]
    rlc amap -insert em.rdiv [expr {$base + 0x01}]
    rlc amap -insert em.addr [expr {$base + 0x02}]
    rlc amap -insert em.data [expr {$base + 0x03}]
  }
  #
  # init: reset rbd_eyemon (stop monitor, clear rdiv and addr)
  # 
  proc init {} {
    rlc exec \
      -wreg em.cntl 0x0000 \
      -wreg em.rdiv 0x0000 
  }
  #
  # clear: clear eyemon data
  #
  proc clear {} {
    set clrbit [regbld rbemon::CNTL clr]
    rlc exec -rreg em.cntl cur_cntl
    rlc exec -wreg em.cntl [expr {$cur_cntl | $clrbit}]
    set clrrun $clrbit
    set npoll 0
    while {$clrrun != 0} {
      rlc exec -rreg em.cntl cur_cntl
      set clrrun [expr {$cur_cntl & $clrbit}]
      incr npoll 1
      if {$npoll > 10} {
        error "-E: rbemon::clear failed, CNTL.clr didn't go back to 0"
      }
    }
    return ""
  }
  #
  # start: start the eyemon
  #
  proc start {{ena01 0} {ena10 0}} {
    if {$ena01 == 0 && $ena10 == 0} {
      set ena01 1
      set ena10 1
    }
    rlc exec -wreg em.cntl [regbld rbemon::CNTL go \
                    [list ena01 $ena01] [list ena10 $ena10] ]
  }
  #
  # stop: stop the eyemon
  #
  proc stop {} {
    rlc exec -wreg em.cntl 0x0000
  }
  #
  # read: read eyemon data
  #
  proc read {{nval 512}} {
    set addr 0
    set rval {}
    while {$nval > 0} {
      set nblk [expr {$nval << 1}]
      if {$nblk > 256} {set nblk 256}
      rlc exec \
        -wreg em.addr $addr \
        -rblk em.data $nblk rawdat
      foreach {dl dh} $rawdat {
        lappend rval [expr {( $dh << 16 ) | $dl}]
      }
      incr addr $nblk
      set nval [expr {$nval - ( $nblk >> 1 ) }]
    }
    return $rval
  }
  #
  # print: pretty print eyemon data
  #
  proc print {{nval 512}} {
    set edat [read $nval]
    set emax 0
    foreach {dat} $edat {
      if {$dat > $emax} {set emax $dat}
    }
    set lemax [expr {$emax > 0 ? log($emax) : 1.}]
    set rval " ind        data"
    set i 0
    foreach {dat} $edat {
      append rval [format "\n%4d : %9d :" $i $dat]
      set nh [expr {$dat > 0 ?  60. * log($dat) / $lemax : 0 }]
      for {set j 1} {$j < $nh} {incr j} { append rval "=" }
      incr i
    }
    return $rval
  }
}
