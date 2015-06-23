# $Id: util.tcl 640 2015-02-01 09:56:53Z mueller $
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
# 2015-01-31   640   1.1    adopt to new register layout
# 2011-08-14   406   1.0.2  adopt to common register layout
# 2011-04-17   376   1.0.1  print: show also switch values; add proc disptest
# 2011-03-27   374   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide rbs3hio 1.0

package require rutil
package require rutiltpp

namespace eval rbs3hio {
  #
  # setup register descriptions for s3_humanio_rbus
  #
  regdsc STAT {hdig 14 3} {hled 11 4} {hbtn 7 4} {hswi 3 4}
  regdsc CNTL {dsp1en 4} {dsp0en 3} {dpen 2} {leden 1} {swien 0}

  #
  # setup: amap definitions for s3_humanio_rbus
  # 
  proc setup {{base 0xfef0}} {
    rlc amap -insert hi.stat [expr {$base + 0x00}]
    rlc amap -insert hi.cntl [expr {$base + 0x01}]
    rlc amap -insert hi.btn  [expr {$base + 0x02}]
    rlc amap -insert hi.swi  [expr {$base + 0x03}]
    rlc amap -insert hi.led  [expr {$base + 0x04}]
    rlc amap -insert hi.dp   [expr {$base + 0x05}]
    rlc amap -insert hi.dsp0 [expr {$base + 0x06}]
    rlc amap -insert hi.dsp1 [expr {$base + 0x07}]
  }

  #
  # init: reset s3_humanio_rbus (clear all enables)
  # 
  proc init {} {
    rlc exec -wreg hi.cntl 0x0000
  }

  #
  # print: show status
  # 
  proc print {} {
    set rval {}
    rlc exec \
      -rreg hi.stat r_stat \
      -rreg hi.cntl r_cntl \
      -rreg hi.btn  r_btn  \
      -rreg hi.swi  r_swi  \
      -rreg hi.led  r_led  \
      -rreg hi.dp   r_dp   \
      -rreg hi.dsp0 r_dsp0 \
      -rreg hi.dsp1 r_dsp1

    set ndig [expr {[regget rbs3hio::STAT(hdig) $r_stat] + 1}]
    set nled [expr {[regget rbs3hio::STAT(hled) $r_stat] + 1}]
    set nbtn [expr {[regget rbs3hio::STAT(hbtn) $r_stat] + 1}]
    set nswi [expr {[regget rbs3hio::STAT(hswi) $r_stat] + 1}]

    append rval [format "  stat: ndig:%d  nled:%d  nbtn:%d  nswi:%d" \
                 $ndig $nled $nbtn $nswi]
    append rval "\n  cntl: [regtxt rbs3hio::CNTL $r_cntl]"
    append rval "\n  btn:  [pbvi b$nbtn $r_btn]"
    append rval "\n  swi:  [pbvi b$nswi $r_swi]"
    append rval "\n  led:  [pbvi b$nled $r_led]"
    set r_dsp [expr {( $r_dsp1 << 16 ) + $r_dsp0}]
    set dspval ""
    for {set i [expr {$ndig - 1}]} {$i >= 0} {incr i -1} {
      set digval [expr {( $r_dsp >> ( 4 * $i ) ) & 0x0f}]
      set digdp  [expr {( $r_dp >> $i ) & 0x01}]
      append dspval [format "%x" $digval]
      if {$digdp} {append dspval "."} else {append dspval " "}
    }
    set ndspbit [expr {4 * $ndig}]
    append rval "\n  disp: [pbvi b$ndspbit $r_dsp] - [pbvi b$ndig $r_dp] -> \"$dspval\""
    return $rval
  }

  #
  # disptest: blink through the leds
  # 
  proc disptest {} {
    rlc exec -rreg hi.stat r_stat -rreg hi.cntl r_cntl

    set ndig [expr {[regget rbs3hio::STAT(hdig) $r_stat] + 1}]
    set nled [expr {[regget rbs3hio::STAT(hled) $r_stat] + 1}]
    set nbtn [expr {[regget rbs3hio::STAT(hbtn) $r_stat] + 1}]
    set nswi [expr {[regget rbs3hio::STAT(hswi) $r_stat] + 1}]

    set swien [regget rbs3hio::CNTL(swien) $r_cntl]
    rlc exec -wreg hi.cntl [regbld rbs3hio::CNTL dsp1en dsp0en dpen leden \
                              [list swien $swien]  ]

    rlc exec \
      -wreg hi.dsp1 0 \
      -wreg hi.dsp0 0 \
      -wreg hi.dp 0 \
      -wreg hi.led 0 

    puts "test LEDs + DSP0"
    
    foreach val {0x0000 0xaaaa 0x5555 0xffff 0x0000} {
      rlc exec \
        -wreg hi.led $val \
        -wreg hi.dsp0 $val
      after 250
    }

    puts "test LEDs + DSP0 + DP"

    for {set i 0} {$i <= 0xf} {incr i} {
      set val [expr {( $i << 12 ) | ( $i << 8 ) | ( $i << 4 ) | $i}]
      rlc exec \
        -wreg hi.led $val \
        -wreg hi.dsp0 $val \
        -wreg hi.dp $i
      after 250
    }

    rlc exec \
      -wreg hi.cntl $r_cntl \
      -wreg hi.dsp1 0 \
      -wreg hi.dsp0 0 \
      -wreg hi.dp 0 \
      -wreg hi.led 0 
  }
}
