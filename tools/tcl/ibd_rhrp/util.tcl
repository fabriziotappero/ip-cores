# $Id: util.tcl 678 2015-05-10 16:23:02Z mueller $
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
# 2015-03-21   659   1.0    Initial version
#

package provide ibd_rhrp 1.0

package require rlink
package require rw11

namespace eval ibd_rhrp {
  #
  # setup register descriptions for ibd_rhrp ---------------------------------
  #
  regdsc CS1 {sc 15} {tre 14} {dva 11} {bae 9 2} \
    {rdy 7} {ie 6} {func 5 5} {go 0}
  variable FUNC_NOOP   [bvi b5 "00000"]
  variable FUNC_UNL    [bvi b5 "00001"]
  variable FUNC_SEEK   [bvi b5 "00010"]
  variable FUNC_RECAL  [bvi b5 "00011"]
  variable FUNC_DCLR   [bvi b5 "00100"]
  variable FUNC_PORE   [bvi b5 "00101"]
  variable FUNC_OFFS   [bvi b5 "00110"]
  variable FUNC_RETC   [bvi b5 "00111"]
  variable FUNC_PRES   [bvi b5 "01000"]
  variable FUNC_PACK   [bvi b5 "01001"]
  variable FUNC_SEAR   [bvi b5 "01100"]
  variable FUNC_WCD    [bvi b5 "10100"]
  variable FUNC_WCHD   [bvi b5 "10101"]
  variable FUNC_WRITE  [bvi b5 "11000"]
  variable FUNC_WHD    [bvi b5 "11001"]
  variable FUNC_READ   [bvi b5 "11100"]
  variable FUNC_RHD    [bvi b5 "11101"]

  regdsc RCS1  {val 15 8} {func 5 5} {go 0}
  variable RFUNC_WUNIT [bvi b5 "00001"]
  variable RFUNC_CUNIT [bvi b5 "00010"]
  variable RFUNC_DONE  [bvi b5 "00011"]
  variable RFUNC_WIDLY [bvi b5 "00100"]

  regdsc DA  {ta 12 5 2d} {sa 5 6 2d}
  regdsc CS2 {wce 14} {ned 12} {nem 11} {pge 10} {or 7} {ir 6} \
    {clr 5} {pat 4} {bai 3} {unit 2 3 d}
  regdsc DS  {ata 15} {erp 14} {mol 12} {wrl 11} {lbt 10} {dpr 8} {dry 7} {vv 6}
  regdsc ER1 {uns 14} {iae 10} {aoe 9} {rmr 2} {ilf 0}
  regdsc AS  {u3 3} {u2 2} {u1 1} {u0 0}
  regdsc LA  {sc 11 6 2d}
  regdsc OF  {fmt 12} {eci 11} {hci 10} {odi 7} {off 6 7}

  variable DTE_RP04    [bvi b3 "000"]
  variable DTE_RP06    [bvi b3 "001"]
  variable DTE_RM04    [bvi b3 "100"]
  variable DTE_RM80    [bvi b3 "101"]
  variable DTE_RM05    [bvi b3 "110"]
  variable DTE_RP07    [bvi b3 "111"]

  variable DT_RP04    020020
  variable DT_RP06    020022
  variable DT_RM04    020024
  variable DT_RM80    020026
  variable DT_RM05    020027
  variable DT_RP07    020042

  regdsc SN  {d3 15 4 d} {d2 11 4 d} {d1 7 4 d} {d0 3 4 d}
  regdsc OF  {odi 7}
  regdsc DC  {dc 9 10 d}

  regdsc CS3 {ie 6}

  variable ANUM 6

  #
  # setup: create controller with default attributes -------------------------
  #
  proc setup {{cpu "cpu0"}} {
    return [rw11::setup_cntl $cpu "rhrp" "rpa"]
  }

  #
  # rcs1_wunit: value for rem CS1 WUNIT function -----------------------------
  #
  proc rcs1_wunit {unit} {
    return [regbld ibd_rhrp::RCS1 [list val $unit] \
              [list func $ibd_rhrp::RFUNC_WUNIT] ]
  }

  #
  # cs1_func: value for loc CS1 function start -------------------------------
  #
  proc cs1_func {func {ie 0} {bae 0}} {
    return [regbld ibd_rhrp::CS1 [list bae $bae] [list ie $ie] \
                                 [list func $func] {go 1}]
  }

  #
  # rdump: register dump - rem view ------------------------------------------
  #
  proc rdump {{cpu "cpu0"} {unit 0}} {
    set rval {}
    $cpu cp -ribr "rpa.cs1" cs1 \
            -ribr "rpa.wc"  wc \
            -ribr "rpa.ba"  ba \
            -ribr "rpa.cs2" cs2 \
            -ribr "rpa.bae" bae \
            -ribr "rpa.cs3" cs3 

    if {$wc} {
      set fwc [format "%d" [expr {64 * 1024 - $wc}]]
    } else {
      set fwc "(0)"
    }

    append rval "Controller registers:"
    append rval [format "\n  cs1: %6.6o  %s" $cs1 [regtxt ibd_rhrp::CS1 $cs1]]
    append rval [format "\n  cs2: %6.6o  %s" $cs2 [regtxt ibd_rhrp::CS2 $cs2]]
    append rval [format "\n  cs3: %6.6o  %s" $cs3 [regtxt ibd_rhrp::CS3 $cs3]]
    append rval [format "\n  wc:  %6.6o  nw=%s" $wc $fwc]
    append rval [format "\n  ba:  %6.6o"     $ba]
    append rval [format "\n  bae: %6.6o  ea=%8.8o" $bae [expr {($bae<<16)|$ba}] ]

    $cpu cp -wibr "rpa.cs1" [rcs1_wunit $unit] \
            -ribr "rpa.da"  da  \
            -ribr "rpa.ds"  ds  \
            -ribr "rpa.er1" er1  \
            -ribr "rpa.as"  as  \
            -ribr "rpa.la"  la  \
            -ribr "rpa.mr1" mr1 \
            -ribr "rpa.dt"  dt  \
            -ribr "rpa.sn"  sn  \
            -ribr "rpa.of"  of  \
            -ribr "rpa.dc"  dc 

    append rval "\nUnit $unit registers:"
    append rval [format "\n  da:  %6.6o  %s" $da  [regtxt ibd_rhrp::DA  $da ]]
    append rval [format "\n  ds:  %6.6o  %s" $ds  [regtxt ibd_rhrp::DS  $ds ]]
    append rval [format "\n  er1: %6.6o  %s" $er1 [regtxt ibd_rhrp::ER1 $er1]]
    append rval [format "\n  as:  %6.6o  as:%s" $as  [pbvi b4 $as]]
    append rval [format "\n  la:  %6.6o  %s" $la  [regtxt ibd_rhrp::LA  $la ]]
    append rval [format "\n  mr1: %6.6o "    $mr1 ]
    append rval [format "\n  dt:  %6.6o "    $dt  ]
    set snd3  [regget ibd_rhrp::SN(d3) $sn]
    set snd2  [regget ibd_rhrp::SN(d2) $sn]
    set snd1  [regget ibd_rhrp::SN(d1) $sn]
    set snd0  [regget ibd_rhrp::SN(d0) $sn]
    set sntxt [format "%d%d%d%d" $snd3 $snd2 $snd1 $snd0]
    append rval [format "\n  sn:  %6.6o  sn=%s" $sn $sntxt]
    append rval [format "\n  of:  %6.6o  %s" $of  [regtxt ibd_rhrp::OF  $of ]]
    append rval [format "\n  dc:  %6.6o  dc:%s" $dc [format "%3d" $dc]]

    return $rval
  }
}
