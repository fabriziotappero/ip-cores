# $Id: cpucons.tcl 626 2015-01-03 14:41:37Z mueller $
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
# 2015-01-02   626   1.0.1  BUGFIX: proc "<": use \r to signal <ENTER>
# 2013-04-26   510   1.0    Initial version
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {

  #
  # cpumon: special command environment while cpu is running
  # 

  variable cpucons_done 0

  #
  # cpucons: setup special console shortcut commands
  # 
  proc cpucons {} {
    variable cpucons_done

    # quit if cpucons already done
    if {$cpucons_done} {
      return ""
    }

    namespace eval :: {

      #
      # '.' show current PC and PS
      # 
      proc "." {} {
        return [cpu0 show -pcps]
      }

      #
      # '?' show current PC and PS and R0-R6
      # 
      proc "?" {} {
        return [cpu0 show -r0ps]
      }

      #
      # '(' type some chars (no cr at end)
      # 
      proc "(" {args} {
        set str [join $args " "]
        cpu0tta0 type $str
        return ""
      }

      #
      # '<' type some chars (with cr at end)
      # 
      proc "<" {args} {
        set str [join $args " "]
        append str "\r"
        cpu0tta0 type $str
        return ""
      }

    }

      set cpucons_done 1
      return ""
  }

}
