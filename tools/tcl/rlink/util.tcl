# $Id: util.tcl 661 2015-04-03 18:28:41Z mueller $
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
# 2014-12-21   617   2.0.1  add rbtout definition in STAT
# 2014-12-07   609   2.0    use new rlink v4 iface; remove SINIT again
# 2014-08-09   580   1.0.2  add run_rri
# 2011-08-06   403   1.0.1  add SINT and SINIT defs for serport init
# 2011-03-26   373   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide rlink 1.0

package require rutil 1.0

namespace eval rlink {
  regdsc STAT   {stat 7 4} {attn 3} {rbtout 2} {rbnak 1} {rberr 0}
  variable STAT_DEFMASK [regbld rlink::STAT rbtout rbnak rberr]

  regdsc RLCNTL {anena 15} {atoena 14} {atoval 7 8}
  regdsc RLSTAT {lcmd 15 8} {babo 7} {rbsize 2 3}

  # 'pseudo register', describes 3rd word in return list element for -rlist
  regdsc FLAGS {vol 16} \
    {chkdata 13} {chkstat 12} \
    {errcrc 11} {errcmd 10}  {errmiss 9} {errnak 8} \
    {resend 7} {recov 6} {pktend 5} {pktbeg 4} \
    {done 2} {send 1} {init 0} 

  # define rlink core regs addresses (are system constants)
  variable ADDR_RLCNTL 0xffff
  variable ADDR_RLSTAT 0xfffe
  variable ADDR_RLID1  0xfffd
  variable ADDR_RLID0  0xfffc

  #
  # setup: amap definitions for core config regs
  # 
  proc setup {} {
    rlc amap -insert rl.cntl $rlink::ADDR_RLCNTL
    rlc amap -insert rl.stat $rlink::ADDR_RLSTAT
    rlc amap -insert rl.id1  $rlink::ADDR_RLID1
    rlc amap -insert rl.id0  $rlink::ADDR_RLID0
  }
  #
  # init: reset rlink: disable enables; clear attn register
  #
  proc init {} {
    rlc exec \
      -wreg $rlink::ADDR_RLCNTL 0 \
      -attn
    return ""
  }
  #
  # anena: enable/disable attn notify messages
  #
  proc anena {{ena 0}} {
    rlc exec \
      -wreg $rlink::ADDR_RLCNTL [regbld rlink::RLCNTL [list anena $ena]]
  }
  #
  # isopen: returns 1 if open and 0 if close
  #
  proc isopen {} {
    if {[rlc open] eq ""} { return 0 }
    return 1
  }
  #
  # isfifo: returns 1 if open and fifo, 0 otherwise
  #
  proc isfifo {} {
    set name [rlc open]
    if {$name ne "" && [regexp -- {^fifo:} $name]} { return 1 }
    return 0
  }
  #
  # issim: returns 1 if open and in simulation mode, 0 otherwise
  #
  proc issim {} {
    if {![info exists rlink::sim_mode]} { return 0}
    return $rlink::sim_mode
  }

  #
  # run_rri: execute rri type command file
  #
  proc run_rri {fname} {
    rlc errcnt -clear
    set code [exec ticonv_rri $fname]
    eval $code
    set errcnt [rlc errcnt]
    if { $errcnt } {
      puts [format "run_rri: FAIL after %d errors" $errcnt]
    }
    return $errcnt
  }

}
