# $Id: util.tcl 603 2014-11-09 22:50:26Z mueller $
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
# 2014-11-09   603   2.0    use rlink v4 address layout
# 2011-04-17   376   1.0.1  add proc scan_baud
# 2011-04-02   375   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide tst_rlink 1.0

package require rlink
package require rbtest
package require rbmoni
package require rbbram
package require rbs3hio
package require rbemon

namespace eval tst_rlink {
  #
  # setup: amap definitions for tst_rlink
  # 
  proc setup {} {
    rlc amap -clear;                    # clear first to allow re-run
    rlink::setup;
    rbtest::setup  0xffe0;
    rbmoni::setup  0xffe8;
    rbemon::setup  0xffd0;
    rbbram::setup  0xfe00;
    rlc amap -insert timer.1 0xfe11;
    rlc amap -insert timer.0 0xfe10;
    rbs3hio::setup 0xfef0;
  }

  #
  # init: reset tst_rlink design to initial state
  #
  proc init {} {
    rlink::init;                        # reset rlink
    rbtest::init;
    rbmoni::init;
    rbbram::init;
    rbemon::init;
    rbs3hio::init;
    rlink::init;                        # re-reset rlink
  }

  #
  # scan_baud: scan through baud rates, show uart clkdiv value
  #
  proc scan_baud {{bmax 500000}} {
    if {! [rlink::isopen]} {error "-E: rlink port not open"}
    set rlpath [rlc open]
    regexp -- {^term:(.*)\?} $rlpath dummy rldev
    if {$rldev eq ""} {error "-E: rlink not connected to a term: device"}

    set rval "   baud  hi.dsp   clkdiv  sysclk"
    set blist {9600 19200 38400 57600 115200 230400 460800
               500000 921600 1000000 2000000 3000000} 

    foreach baud $blist {
      if {$baud > $bmax} { break }
      rlc close
      rlc open "term:$rldev?baud=${baud};break"
      rlc exec -rreg hi.dsp hidsp
      set mhz [expr {double($baud*$hidsp) / 1.e6}]
      append rval [format "\n%7d  0x%4.4x   %6d  %6.2f" \
                     $baud $hidsp [expr {$hidsp + 1}] $mhz]
    }

    rlc close
    if {! [regexp -- {;break} $rlpath]} {append rlpath ";break"}
    rlc open "${rlpath}"
    return $rval
  }
}
