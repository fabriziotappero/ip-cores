# $Id: util.tcl 668 2015-04-25 14:31:19Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2015-04-25   668   1.0    Initial version
#

package provide ibd_ibmon 1.0

package require rutil
package require rlink

namespace eval ibd_ibmon {
  #
  # setup register descriptions for ibd_ibmon
  #
  regdsc CNTL {conena 5} {remena 4} {locena 3} {wena 2} {stop 1} {start 0}
  regdsc STAT {bsize 15 3} {wrap 0}
  regdsc ADDR {laddr 15 14} {waddr 1 2}
  #
  regdsc DAT3 {burst 15} {tout 14} {nak 13} {ack 12} \
              {busy 11} {we 9} {rmw 8} {ndlymsb 7 8}
  regdsc DAT2 {ndlylsb 15 6} {nbusy  9 10}
  regdsc DAT0 {be1 15} {be0 14} {racc 13} {addr 12 12} {cacc 0}
  #
  # 'pseudo register', describes 1st word in return list element of read proc
  #  all flag bits from DAT3 and DAT0
  regdsc FLAGS {burst 11} {tout 10} {nak 9} {ack 8} \
               {busy 7} {cacc 5} {racc 4} {rmw 3} {be1 2} {be0 1} {we 0} 
  #
  # setup: amap definitions for rbd_rbmon
  # 
  proc setup {{cpu "cpu0"} {base 0160000}} {
    $cpu imap -insert im.cntl  [expr {$base + 000}]
    $cpu imap -insert im.stat  [expr {$base + 002}]
    $cpu imap -insert im.hilim [expr {$base + 004}]
    $cpu imap -insert im.lolim [expr {$base + 006}]
    $cpu imap -insert im.addr  [expr {$base + 010}]
    $cpu imap -insert im.data  [expr {$base + 012}]
  }
  #
  # init: reset rbd_rbmon (stop, reset alim)
  # 
  proc init {{cpu "cpu0"}} {
    $cpu cp \
      -wibr im.cntl [regbld ibd_ibmon::CNTL stop] \
      -wibr im.hilim  0177776 \
      -wibr im.lolim  0160000 \
      -wibr im.addr 0x0000
  }
  #
  # start: start the rbmon
  #
  proc start {{cpu "cpu0"} {opts {}}} {
    array set defs { conena 1 remena 1 locena 1 wena 1 }
    array set defs $opts
    $cpu cp -wibr im.cntl [regbld ibd_ibmon::CNTL start \
                              [list   wena $defs(wena)] \
                              [list locena $defs(locena)] \
                              [list remena $defs(remena)] \
                              [list conena $defs(conena)] \
                             ]
  }
  #
  # stop: stop the rbmon
  #
  proc stop {{cpu "cpu0"}} {
    $cpu cp -wibr im.cntl [regbld ibd_ibmon::CNTL stop]
  }
  #
  # read: read nent last entries (by default all)
  #
  proc read {{cpu "cpu0"} {nent -1}} {
    $cpu cp -ribr im.addr raddr \
            -ribr im.stat rstat

    set bsize [regget ibd_ibmon::STAT(bsize) $rstat]
    set amax  [expr {( 512 << $bsize ) - 1}]
    if {$nent == -1} { set nent $amax }

    set laddr [regget ibd_ibmon::ADDR(laddr) $raddr]
    set nval  $laddr
    if {[regget ibd_ibmon::STAT(wrap) $rstat]} { set nval $amax }

    if {$nent > $nval} {set nent $nval}
    if {$nent == 0} { return {} }

    set caddr [expr {( $laddr - $nent ) & $amax}]
    $cpu cp -wibr im.addr [regbld ibd_ibmon::ADDR [list laddr $caddr]]

    set rval {}

    set nrest $nent
    while {$nrest > 0} {
      set nblk [expr {$nrest << 2}]
      if {$nblk > 256} {set nblk 256}
      set iaddr [$cpu imap im.data]
      $cpu cp -rbibr $iaddr $nblk rawdat

      foreach {d0 d1 d2 d3} $rawdat {
        set d3burst [regget ibd_ibmon::DAT3(burst) $d3]
        set d3tout  [regget ibd_ibmon::DAT3(tout)  $d3]
        set d3nak   [regget ibd_ibmon::DAT3(nak)   $d3]
        set d3ack   [regget ibd_ibmon::DAT3(ack)   $d3]
        set d3busy  [regget ibd_ibmon::DAT3(busy)  $d3]
        set d3we    [regget ibd_ibmon::DAT3(we)    $d3]
        set d3rmw   [regget ibd_ibmon::DAT3(rmw)   $d3]
        set d0be1   [regget ibd_ibmon::DAT0(be1)   $d0]
        set d0be0   [regget ibd_ibmon::DAT0(be0)   $d0]
        set d0racc  [regget ibd_ibmon::DAT0(racc)  $d0]
        set d0addr  [regget ibd_ibmon::DAT0(addr)  $d0]
        set d0cacc  [regget ibd_ibmon::DAT0(cacc)  $d0]

        set eflag   [regbld ibd_ibmon::FLAGS \
                       [list burst  $d3burst] \
                       [list tout   $d3tout]  \
                       [list nak    $d3nak]   \
                       [list ack    $d3ack]   \
                       [list busy   $d3busy]  \
                       [list cacc   $d0cacc]  \
                       [list racc   $d0racc]  \
                       [list rmw    $d3rmw]   \
                       [list be1    $d0be1]   \
                       [list be0    $d0be0]   \
                       [list we     $d3we]    \
                    ]

        set edelay [expr {( [regget ibd_ibmon::DAT3(ndlymsb) $d3] << 6 ) | 
                            [regget ibd_ibmon::DAT2(ndlylsb) $d2] }]
        set enbusy [regget ibd_ibmon::DAT2(nbusy) $d2]
        set edata  $d1
        set eaddr  [expr {0160000 | ($d0addr<<1)}]
        lappend rval [list $eflag $eaddr $edata $edelay $enbusy]
      }

      set nrest [expr {$nrest - ( $nblk >> 2 ) }]
    }

    $cpu cp -wibr im.addr $raddr

    return $rval
  }
  #
  # print: print ibmon data (optionally also read them)
  #
  proc print {{cpu "cpu0"} {mondat -1}} {

    if {[llength $mondat] == 1} {
      set ele [lindex $mondat 0]
      if {[llength $ele] == 1} {
        set nent [lindex $ele 0]
        set mondat [read $cpu $nent]
      }
    }

    set rval {}
    set edlymax 16383

    set eind [expr {1 - [llength $mondat] }]
    append rval \
      "  ind  addr         data  delay nbsy  btnab-crm10w  acc-mode"

    set mtout  [regbld ibd_ibmon::FLAGS tout ]
    set mnak   [regbld ibd_ibmon::FLAGS nak  ]
    set mack   [regbld ibd_ibmon::FLAGS ack  ]
    set mbusy  [regbld ibd_ibmon::FLAGS busy ]
    set mcacc  [regbld ibd_ibmon::FLAGS cacc ]
    set mracc  [regbld ibd_ibmon::FLAGS racc ]
    set mrmw   [regbld ibd_ibmon::FLAGS rmw  ]
    set mbe1   [regbld ibd_ibmon::FLAGS be1  ]
    set mbe0   [regbld ibd_ibmon::FLAGS be0  ]
    set mwe    [regbld ibd_ibmon::FLAGS we   ]

    foreach {ele} $mondat {
      foreach {eflag eaddr edata edly enbusy} $ele { break }

      set ftout  [expr {$eflag & $mtout} ]
      set fnak   [expr {$eflag & $mnak}  ]
      set fack   [expr {$eflag & $mack}  ]
      set fbusy  [expr {$eflag & $mbusy} ]
      set fcacc  [expr {$eflag & $mcacc} ]
      set fracc  [expr {$eflag & $mracc} ]
      set frmw   [expr {$eflag & $mrmw}  ]
      set fbe1   [expr {$eflag & $mbe1}  ]
      set fbe0   [expr {$eflag & $mbe0}  ]
      set fwe    [expr {$eflag & $mwe}   ]

      set prw    "r"
      set pmod   " "
      set pwe1   " "
      set pwe0   " "

      if {$fwe } { 
        set prw   "w"
        set pwe1  "0"
        set pwe0  "0"
        if {$fbe1} { set pwe1 "1"}
        if {$fbe0} { set pwe0 "1"}
      }
      if {$frmw} { set pmod "m"}

      set prmw   "$pmod$prw$pwe1$pwe0"
      set pacc   "loc"
      if {$fcacc} { set pacc "con"}
      if {$fracc} { set pacc "rem"}

      set pedly [expr {$edly!=$edlymax ? [format "%5d" $edly] : "   --"}]
      set ename  [format "%6.6o" $eaddr]
      set comment ""
      if {$fnak}   {append comment " NAK=1!"}
      if {$ftout}  {append comment " TOUT=1!"}
      if {[$cpu imap -testaddr $eaddr]} {set ename [$cpu imap -name $eaddr]}
      append rval [format \
      "\n%5d  %-10s %6.6o  %5s %4d  %s  %s %s  %s" \
        $eind $ename $edata $pedly $enbusy [pbvi b12 $eflag] \
        $prmw $pacc $comment]
      incr eind
    }

    return $rval
  }

  #
  # raw_edata: prepare edata lists for raw data reads in tests
  #   args is list of {eflag eaddr edata enbusy} sublists

  proc raw_edata {edat emsk args} {
    upvar $edat uedat
    upvar $emsk uemsk
    set uedat {}
    set uemsk {}

    set m3 [rutil::com16 [regbld ibd_ibmon::DAT3 {ndlymsb -1}]]; # all but ndly
    set m2 [rutil::com16 [regbld ibd_ibmon::DAT2 {ndlylsb -1}]]; # all but ndly
    set m1 0xffff
    set m0 0xffff

    foreach line $args {
      foreach {eflags eaddr edata enbusy} $line { break }
      set d3 [regbld ibd_ibmon::DAT3 [list flags $eflags]]
      set d2 [regbld ibd_ibmon::DAT2 [list nbusy $enbusy]]
      if {$edata ne ""} {
        set m1 0xffff
        set d1 $edata
      } else {
        set m1 0x0000
        set d1 0x0000
      }
      set d0 $eaddr

      lappend uedat $d0 $d1 $d2 $d3
      lappend uemsk $m0 $m1 $m2 $m3
    }

    return ""
  }

  #
  # raw_check: check raw data against expect values prepared by raw_edata
  #
  proc raw_check {{cpu "cpu0"} edat emsk} {

    $cpu cp \
      -ribr  im.addr -edata [llength $edat] \
      -wibr  im.addr 0 \
      -rbibr im.data [llength $edat] -edata $edat $emsk \
      -ribr  im.addr -edata [llength $edat]
    return ""
  }
  
}
