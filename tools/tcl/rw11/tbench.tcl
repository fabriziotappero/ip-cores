# $Id: tbench.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2015-05-17   683   2.2    support sub directories and return in tests
# 2015-05-09   676   2.1    use 'rlc log -bare' instead of 'puts'
# 2014-11-30   607   2.0    use new rlink v4 iface
# 2013-04-26   510   1.0    Initial version (extracted from util.tcl)
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #
  # tbench: driver for tbench scripts
  #
  proc tbench {tname} {
    set fname $tname
    set tbase "."
    if {[string match "@*" $tname]} {
      set fname [string range $tname 1 end]
    }
    if {![file exists $fname]} {set tbase "$::env(RETROBASE)/tools/tbench"}

    rlink::anena 1;             # enable attn notify
    set errcnt [tbench_list $tname $tbase]
    return $errcnt
  }

  #
  # tbench_file: execute list of tbench steps
  #
  proc tbench_list {tname tbase} {
    set errcnt 0

    set rname  $tname
    set islist 0
    if {[string match "@*" $tname]} {
      set islist 1
      set rname [string range $tname 1 end]
    }

    set dname [file dirname $rname]
    set fname [file tail    $rname]
    if {$dname ne "."} {
      set tbase [file join $tbase $dname]
    }

    if {![file readable "$tbase/$fname"]} {
      error "-E: file $tbase/$fname not found or readable"
    }

    if {$islist} {
      set fh [open "$tbase/$fname"]
      while {[gets $fh line] >= 0} {
        if {[string match "#*" $line]} {
          if {[string match "##*" $line]} { rlc log -bare $line }
        } elseif {[string match "@*" $line]} {
          incr errcnt [tbench_list $line $tbase]
        } else {
          incr errcnt [tbench_step $line $tbase]
        }
      }
      close $fh

    } else {
      incr errcnt [tbench_step $fname $tbase]
    }

    if {$islist} {
      rlc log -bare [format "%s: %s" $tname [rutil::errcnt2txt $errcnt]]
    }
    return $errcnt
  }

  #
  # tbench_step: execute single tbench step
  #
  proc tbench_step {fname tbase} {
    if {![file readable "$tbase/$fname"]} {
      error "-E: file $tbase/$fname not found or readable"
    }

    # cleanup any remaining temporary procs with names tmpproc_* 
    foreach pname [info procs tmpproc_*] { rename $pname "" }

    rlc errcnt -clear
    set cpu "cpu0"
    set ecode [catch "source $tbase/$fname" resmsg]
    set errcnt [rlc errcnt]

    switch $ecode {
      0  {}
      1  { puts "-E: test execution FAILED with error message:"
           if {[info exists errorInfo]} {puts $errorInfo} else {puts $resmsg}
           incr errcnt
         }
      2  { puts "-I: test ended by return: $resmsg"}
      default  {
           puts "-E: test execution FAILED with catch code $ecode"
           incr errcnt
         }
    }

    # remove temporary procs with names tmpproc_* 
    foreach pname [info procs tmpproc_*] { rename $pname "" }

    rlc log -bare [format "%s: %s" $fname [rutil::errcnt2txt $errcnt]]
    return $errcnt
  }

}
