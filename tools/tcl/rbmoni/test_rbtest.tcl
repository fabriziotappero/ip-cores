# $Id: test_rbtest.tcl 661 2015-04-03 18:28:41Z mueller $
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
# 2015-04-03   661   2.1    drop estatdef; fix test 5 (wrong regs accessed)
# 2014-12-22   619   2.0    adopt to new rbd_rbmon and rlink v4
# 2011-03-27   374   1.0    Initial version
# 2011-03-13   369   0.1    First Draft
#

package provide rbmoni 1.0

package require rutiltpp
package require rutil
package require rlink
package require rbtest

namespace eval rbmoni {
  #
  # Basic tests with rbtester registers
  #
  proc test_rbtest {{print 0}} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbmoni::test_rbtest - init"
    rbmoni::init
    rbtest::init
    #
    set atecntl [rlc amap te.cntl]
    set atestat [rlc amap te.stat]
    set ateattn [rlc amap te.attn]
    set atencyc [rlc amap te.ncyc]
    set atedata [rlc amap te.data]
    set atedinc [rlc amap te.dinc]
    set atefifo [rlc amap te.fifo]
    set atelnak [rlc amap te.lnak]

    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: exercise monitor data access via data/addr regs"

    set vtestat 0xf
    set vtedata 0x1234

    # write/read te.stat and te.data with rbmoni on; check that 4 lines aquired
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL start] \
      -wreg te.stat $vtestat  \
      -wreg te.data $vtedata  \
      -rreg te.stat -edata $vtestat  \
      -rreg te.data -edata $vtedata  \
      -wreg rm.cntl [regbld rbmoni::CNTL stop] \
      -rreg rm.addr -edata [regbld rbmoni::ADDR {laddr 4}]

    if {$print} {puts [print]}
    rlc exec -wreg te.stat 0x0; # clear stat to simplify later stat tests

    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack we] $atestat $vtestat 0] \
      [list [regbld rbmoni::FLAGS ack we] $atedata $vtedata 0] \
      [list [regbld rbmoni::FLAGS ack]    $atestat $vtestat 0] \
      [list [regbld rbmoni::FLAGS ack]    $atedata $vtedata 0]

    #
    #-------------------------------------------------------------------------
    rlc log "  test 1a: read all in one rblk"
    rlc exec \
      -wreg rm.addr 0x0000 \
      -rblk rm.data 16 -edata $edat $emsk \
      -rreg rm.addr -edata 16

    #
    #-------------------------------------------------------------------------
    rlc log "  test 1b: random address with rreg"
    foreach addr {0x1 0x3 0x5 0x7 0x6 0x4 0x2 0x0 \
                  0x9 0xb 0xd 0xf 0xe 0xc 0xa 0x8} {
      rlc exec \
        -wreg rm.addr $addr \
        -rreg rm.data -edata [lindex $edat $addr] [lindex $emsk $addr] \
        -rreg rm.addr -edata [expr {$addr + 1}]
    }

    #
    #-------------------------------------------------------------------------
    rlc log "  test 1c: random address with rblk length 2"
    foreach addr {0x1 0x3 0x5 0x7 0x6 0x4 0x2 0x0 \
                  0x9 0xb 0xd     0xe 0xc 0xa 0x8} {
      rlc exec \
        -wreg rm.addr $addr \
        -rblk rm.data 2 -edata [lrange $edat $addr [expr {$addr + 1}] ] \
                               [lrange $emsk $addr [expr {$addr + 1}] ] \
        -rreg rm.addr -edata [expr {$addr + 2}]
    }

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2a: test rreg,wreg capture (ncyc=0); ack, we flags"
    set vtedata 0x4321
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack we] $atedata $vtedata 0] \
      [list [regbld rbmoni::FLAGS ack   ] $atedata $vtedata 0]
    #
    rbmoni::start
    rlc exec \
      -wreg te.data $vtedata \
      -rreg te.data -edata $vtedata
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2b: test rreg,wreg capture (ncyc=1,4); busy flag and nbusy"
    set nbusy_1  [regbld rbtest::CNTL {nbusy 1}]
    set nbusy_4  [regbld rbtest::CNTL {nbusy 4}]
    set vtedata  0xbeaf
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack      we] $atecntl $nbusy_1  0] \
      [list [regbld rbmoni::FLAGS ack busy we] $atedata $vtedata  1] \
      [list [regbld rbmoni::FLAGS ack      we] $atecntl $nbusy_4  0] \
      [list [regbld rbmoni::FLAGS ack busy   ] $atedata $vtedata  4] \
      [list [regbld rbmoni::FLAGS ack      we] $atecntl 0         0] 
    #
    rbmoni::start
    rlc exec \
      -wreg te.cntl $nbusy_1 \
      -wreg te.data $vtedata \
      -wreg te.cntl $nbusy_4 \
      -rreg te.data -edata $vtedata \
      -wreg te.cntl 0 
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2c: test rreg,wreg capture (timeout); busy,tout flag"
    set vtecntl  [regbld rbtest::CNTL {nbusy -1}]
    set vtedata  0xdead
    set nmax     [rbtest::nbusymax]
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack           we] $atecntl $vtecntl  0] \
      [list [regbld rbmoni::FLAGS ack busy tout we] $atedata $vtedata  $nmax] \
      [list [regbld rbmoni::FLAGS ack busy tout   ] $atedata 0x5555    $nmax] \
      [list [regbld rbmoni::FLAGS ack           we] $atecntl 0         0] 
    #
    rbmoni::start
    rlc exec \
      -wreg te.cntl $vtecntl \
      -wreg te.data $vtedata      -estat [regbld rlink::STAT rbtout] \
      -rreg te.data -edata 0x5555 -estat [regbld rlink::STAT rbtout] \
      -wreg te.cntl 0 
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2d: test rreg,wreg capture (prompt nak); nak flag"
    set vtelnak  0xdead
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS      nak we] $atelnak $vtelnak  0] \
      [list [regbld rbmoni::FLAGS      nak   ] $atelnak {}        0]
    #
    rbmoni::start
    rlc exec \
      -wreg te.lnak $vtelnak      -estat [regbld rlink::STAT rbnak] \
      -rreg te.lnak               -estat [regbld rlink::STAT rbnak] 
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2e: test rreg,wreg capture (delayed nak); nak flag"
    set vtecntl  [regbld rbtest::CNTL {nbusy 7}]
    set vtelnak  0xdead
   # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack          we] $atecntl $vtecntl  0] \
      [list [regbld rbmoni::FLAGS ack busy nak we] $atelnak $vtelnak  7] \
      [list [regbld rbmoni::FLAGS ack busy nak   ] $atelnak {}        7] \
      [list [regbld rbmoni::FLAGS ack          we] $atecntl 0         0] 
    #
    rbmoni::start
    rlc exec \
      -wreg te.cntl $vtecntl \
      -wreg te.lnak $vtelnak      -estat [regbld rlink::STAT rbnak] \
      -rreg te.lnak               -estat [regbld rlink::STAT rbnak] \
      -wreg te.cntl 0 
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2f: test rreg,wreg capture (prompt rbus err); err flag"
    set vtefifo  0x1357
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack     we] $atefifo $vtefifo  0] \
      [list [regbld rbmoni::FLAGS ack       ] $atefifo $vtefifo  0] \
      [list [regbld rbmoni::FLAGS ack err   ] $atefifo {}        0] 
    #
    rbmoni::start
    rlc exec \
      -wreg te.fifo $vtefifo \
      -rreg te.fifo -edata $vtefifo \
      -rreg te.fifo -estat [regbld rlink::STAT rberr]
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2g: test rreg,wreg capture (delayed rbus err); err flag"
    set vtecntl  [regbld rbtest::CNTL {nbusy 5}]
    set vtefifo  0x1357
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack          we] $atecntl $vtecntl  0] \
      [list [regbld rbmoni::FLAGS ack busy     we] $atefifo $vtefifo  5] \
      [list [regbld rbmoni::FLAGS ack busy       ] $atefifo $vtefifo  5] \
      [list [regbld rbmoni::FLAGS ack busy err   ] $atefifo {}        5] \
      [list [regbld rbmoni::FLAGS ack          we] $atecntl 0         0] 
    #
    rbmoni::start
    rlc exec \
      -wreg te.cntl $vtecntl \
      -wreg te.fifo $vtefifo \
      -rreg te.fifo -edata $vtefifo \
      -rreg te.fifo -estaterr \
      -wreg te.cntl 0x0
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk
    
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: test init capture; init flag"
    set vtecntl [regbld rbtest::CNTL {nbusy 2}]
    set vteinit [regbld rbtest::INIT cntl]
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack we     ] $atecntl $vtecntl 0] \
      [list [regbld rbmoni::FLAGS nak init   ] $atecntl $vteinit 0] \
      [list [regbld rbmoni::FLAGS ack        ] $atecntl 0        0]
    #
    rbmoni::start
    rlc exec \
      -wreg te.cntl $vtecntl \
      -init te.cntl $vteinit \
      -rreg te.cntl -edata 0
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk
    
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4: test rblk,wblk capture (ncyc=2 on read)"
    set vteinit  [regbld rbtest::INIT cntl]
    set nbusy_2  [regbld rbtest::CNTL {nbusy 2}]
    set vtefifo  {0xdead 0xbeaf 0x4711}
    # build expect list: list of {eflag eaddr edata enbusy} sublists
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS       nak    init] $atecntl $vteinit  0] \
      [list [regbld rbmoni::FLAGS       ack      we] $atefifo 0xdead    0] \
      [list [regbld rbmoni::FLAGS burst ack      we] $atefifo 0xbeaf    0] \
      [list [regbld rbmoni::FLAGS burst ack      we] $atefifo 0x4711    0] \
      [list [regbld rbmoni::FLAGS       ack      we] $atecntl $nbusy_2  0] \
      [list [regbld rbmoni::FLAGS       ack busy   ] $atefifo 0xdead    2] \
      [list [regbld rbmoni::FLAGS burst ack busy   ] $atefifo 0xbeaf    2] \
      [list [regbld rbmoni::FLAGS burst ack busy   ] $atefifo 0x4711    2] \
      [list [regbld rbmoni::FLAGS       nak    init] $atecntl $vteinit  0]
    #
    rbmoni::start
    rlc exec \
      -init te.cntl $vteinit \
      -wblk te.fifo $vtefifo \
      -wreg te.cntl $nbusy_2 \
      -rblk te.fifo [llength $vtefifo] -edata $vtefifo \
      -init te.cntl $vteinit 
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: test lolim,hilim"
    # set window to te.ncyc to te.dinc, thus exclude cntl,stat,attn,fifo,lnak
    rlc exec -wreg rm.lolim $atencyc \
             -wreg rm.hilim $atedinc

    # now access all regs (except attn,lnak), but only ncyc,data,dinc recorded
    raw_edata edat emsk \
      [list [regbld rbmoni::FLAGS ack   ] $atencyc 0x0001 0] \
      [list [regbld rbmoni::FLAGS ack we] $atedata 0x2345 0] \
      [list [regbld rbmoni::FLAGS ack   ] $atedinc 0x2345 0] \
      [list [regbld rbmoni::FLAGS ack   ] $atedata 0x2346 0]
    #
    rbmoni::start
    rlc exec -rreg te.cntl \
             -rreg te.stat \
             -rreg te.ncyc \
             -wreg te.data 0x2345 \
             -wreg te.fifo 0xbeaf \
             -rreg te.dinc -edata 0x2345 \
             -rreg te.fifo -edata 0xbeaf \
             -rreg te.data -edata 0x2346 
    rbmoni::stop
    if {$print} {puts [print]}
    raw_check $edat $emsk
    rbmoni::init

    #
    #-------------------------------------------------------------------------
    rlc log "rbmoni::test_rbtest - cleanup:"
    rbtest::init
    rbmoni::init
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
