# $Id: util.tcl 661 2015-04-03 18:28:41Z mueller $
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
# 2015-03-28   660   1,0,4  add com8 and com16
# 2014-12-23   619   1.0.3  regget: add check for unknown field descriptor
# 2014-07-12   569   1.0.2  add sxt16 and sxt32
# 2013-05-09   517   1.0.1  add optlist2arr
# 2011-03-27   374   1.0    Initial version
# 2011-03-19   372   0.1    First draft
#

package provide rutil 1.0

package require rutiltpp

namespace eval rutil {
  #
  # optlist2arr: process options arguments given as key value list -----------
  #
  proc optlist2arr {outarrname refarrname optlist} {
    upvar $outarrname outarr
    upvar $refarrname refarr
    array set outarr [array get refarr]
    foreach {key value} $optlist {
      if {[info exists outarr($key)]} {
        set outarr($key) $value
      } else {
        error "key $key not valid in optlist"
      }
    }
    return ""
  }

  #
  # regdsc: setup a register descriptor --------------------------------------
  #
  proc regdsc {name args} {
    upvar $name rdsc
    set fbegmax -1
    set mskftot 0
    
    foreach arg $args {
      set nopt [llength $arg]
      if {$nopt < 2} { 
        error "wrong number of elements in field dsc \"$arg\"" 
      }
      set fnam [lindex $arg 0]
      set fbeg [lindex $arg 1]
      set flen [lindex $arg 2]
      if {$nopt < 3} { set flen 1 }
      set popt [lindex $arg 3]
      if {$nopt < 4} { set popt "b" }
      
      if {( $flen - 1 ) > $fbeg} {
        error "error in field dsc \"$arg\": length > start position" 
      }
      
      set mskb [expr {( 1 << $flen ) - 1}]
      set mskf [expr {$mskb << ( $fbeg - ( $flen - 1 ) )}]
      set rdsc($fnam) [list $fbeg $flen $mskb $mskf $popt]
      
      if {$fbegmax < $fbeg} {set fbegmax $fbeg}
      set mskftot [expr {$mskftot | $mskf}]
    }

    set rdsc(-n) [lsort -decreasing -command regdsc_sort \
                    [array names rdsc -regexp {^[^-]}] ]
    
    set rdsc(-w) [expr {$fbegmax + 1}]
    set rdsc(-m) $mskftot

    return ""
  }

  #
  # regdsc_print: print register descriptor ----------------------------------
  #
  proc regdsc_print {name} {
    upvar $name rdsc
    set rval ""
    if {! [info exists rdsc]} { 
      error "can't access \"$name\": variable doesn't exist" 
    }

    set rsize $rdsc(-w)

    append rval "     field   bits  bitmask"

    foreach fnam $rdsc(-n) {
      set fdsc  $rdsc($fnam)
      set fbeg  [lindex $fdsc 0]
      set flen  [lindex $fdsc 1]
      set fmskf [lindex $fdsc 3]
      set line "  "
      append line [format "%8s" $fnam]
      if {$flen > 1} {
        append line [format "  %2d:%2d" $fbeg [expr {$fbeg - $flen + 1}]]
      } else {
        append line [format "     %2d" $fbeg]
      }
      append line "  "
      append line [pbvi "b${rsize}" $fmskf]
      append rval "\n$line"
    }
    return $rval
  }

  proc regdsc_sort {a b} {
    upvar rdsc urdsc
    return [expr {[lindex $urdsc($a) 0] - [lindex $urdsc($b) 0] }]
  }

  #
  # regbld: build a register value from a list of fields ---------------------
  #
  proc regbld {name args} {
    upvar $name rdsc
    set rval 0
    foreach arg $args {
      if {[llength $arg] < 1 || [llength $arg] > 2} {
        error "error in field specifier \"$arg\": must be 'name [val]'"
      }
      set fnam [lindex $arg 0]
      if {! [info exists rdsc($fnam)] } {
        error "error in field specifier \"$arg\": field unknown"
      }
      set fbeg [lindex $rdsc($fnam) 0]
      set flen [lindex $rdsc($fnam) 1]
      
      if {[llength $arg] == 1} {
        if {$flen > 1} {
          error "error in field specifier \"$arg\": no value and flen>1"
        }
        set mskf [lindex $rdsc($fnam) 3]
        set rval [expr {$rval | $mskf}]

      } else {
        set fval [lindex $arg 1]
        set mskb [lindex $rdsc($fnam) 2]
        if {$fval >= 0} {
          if {$fval > $mskb} {
            error "error in field specifier \"$arg\": value > $mskb"
          }
        } else {
          if {$fval < [expr {- $mskb}]} {
            error "error in field specifier \"$arg\": value < [expr -$mskb]"
          }
          set fval [expr {$fval & $mskb}]
        }
        set rval [expr {$rval | $fval << ( $fbeg - ( $flen - 1 ) )}]
      }

    }
    return $rval
  }

  #
  # regget: extract field from a register value ------------------------------
  #
  proc regget {name val} {
    upvar $name fdsc
    if {! [info exists fdsc] } {
      error "register field descriptor \"$name\" unknown"
    }
    set fbeg [lindex $fdsc 0]
    set flen [lindex $fdsc 1]
    set mskb [lindex $fdsc 2]
    return [expr {( $val >> ( $fbeg - ( $flen - 1 ) ) ) & $mskb}]
  }

  #
  # regtxt: convert register value to a text string --------------------------
  #
  proc regtxt {name val} {
    upvar $name rdsc
    set rval ""

    foreach fnam $rdsc(-n) {
      set popt [lindex $rdsc($fnam) 4]
      set fval [regget rdsc($fnam) $val]
      if {$popt ne "-"} {
        if {$rval ne ""} {append rval " "}
        append rval "${fnam}:"
        if {$popt eq "b"} {
          set flen [lindex $rdsc($fnam) 1]
          append rval [pbvi b${flen} $fval]
        } else {
          append rval [format "%${popt}" $fval]
        }
      }
    }
    return $rval
  }

  #
  # errcnt2txt: returns "PASS" if 0 and "FAIL" otherwise ---------------------
  #
  proc errcnt2txt {errcnt} {
    if {$errcnt} {return "FAIL"}
    return "PASS"
  }

  #
  # sxt16: 16 bit sign extend ------------------------------------------------
  #
  proc sxt16 {val} {
    if {$val & 0x8000} {                    # bit 15 set ?
      set val [expr $val | ~ 077777];       # --> set bits 15 and higher
    }
    return $val
  }

  #
  # sxt32: 32 bit sign extend ------------------------------------------------
  #
  proc sxt32 {val} {
    if {$val & 0x80000000} {                # bit 31 set ?
      set val [expr $val | ~ 017777777777]; # --> set bits 31 and higher
    }
    return $val
  }

  #
  # com8: 8 bit complement ---------------------------------------------------
  #
  proc com8 {val} {
    return [expr (~$val) & 0xff]
  }

  #
  # com16: 16 bit complement ------------------------------------------------
  #
  proc com16 {val} {
    return [expr (~$val) & 0xffff]
  }

  #
  # ! export reg... procs to global scope ------------------------------------
  #

  namespace export regdsc
  namespace export regdsc_print
  namespace export regbld
  namespace export regget
  namespace export regtxt
}

namespace import rutil::regdsc
namespace import rutil::regdsc_print
namespace import rutil::regbld
namespace import rutil::regget
namespace import rutil::regtxt
