# $Id: cpumon.tcl 512 2013-04-28 07:44:02Z mueller $
#
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2013-04-26   510   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #
  # cpumon: special command environment while cpu is running
  # 

  variable cpumon_active 0
  variable cpumon_prompt ">"
  variable cpumon_attnhdl_added 0
  variable cpumon_eofchar_save {puts {}}

  proc cpumon {{prompt "cpumon> "} } {
    variable cpumon_active
    variable cpumon_prompt
    variable cpumon_attnhdl_added
    variable cpumon_eofchar_save
    global   tirri_interactive

    # quit if cpumon already active
    if {$cpumon_active} {
      error "cpumon already active"
    }

    # check that attn handler is installed
    if {!$cpumon_attnhdl_added} {
      rls attn -add 0x0001 { rw11::cpumon_attncpu }
      set cpumon_attnhdl_added 1
    }

    # redefine ti_rri prompt and eof handling
    if { $tirri_interactive } {
      # setup new prompt (save old one...)
      set cpumon_prompt $prompt
      rename ::tclreadline::prompt1 ::rw11::cpumon_prompt1_save
      namespace eval ::tclreadline {
        proc prompt1 {} {
          return $rw11::cpumon_prompt
        }
      }
      # disable ^D (and save old setting)
      set cpumon_eofchar_save [::tclreadline::readline eofchar]
      ::tclreadline::readline eofchar \
        {puts {^D disabled, use tirri_exit if you really want to bail-out}}
    }

    set cpumon_active 1
    return ""
  }

  #
  # cpumon_attncpu: cpu attn handler
  #
  proc cpumon_attncpu {} {
    variable cpumon_active
    variable cpumon_eofchar_save
    global tirri_interactive

    if {$cpumon_active} {
      puts "CPU down attention"
      puts [cpu0 show -r0ps]
      # restore ti_rri prompt and eof handling
      if { $tirri_interactive } {
        rename ::tclreadline::prompt1 {}
        rename ::rw11::cpumon_prompt1_save ::tclreadline::prompt1
        ::tclreadline::readline eofchar $cpumon_eofchar_save
      }
      set cpumon_active 0
    }
    return ""
  }

}
