# $Id: test_all.tcl 618 2014-12-21 23:05:48Z mueller $
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
# 2014-11-09   603   2.0    use rlink v4 address layout and iface
# 2013-01-04   469   1.0.2  move rbemon tests from test_all to test_all_emon
# 2011-04-17   376   1.0.1  add rbemon::test_rbtest_sim  (if in sum mode)
# 2011-04-02   375   1.0    Initial version
# 2011-03-26   373   0.1    First draft
#

package provide tst_rlink 1.0

package require rbtest
package require rbmoni

namespace eval tst_rlink {
  #
  # Driver for all tst_rlink tests
  #
  proc test_all {} {
    #
    set errcnt 0
    incr errcnt [rbtest::test_all 0xf 0xfffc]
    incr errcnt [rbmoni::test_regs]
    incr errcnt [rbmoni::test_rbtest]

    puts "tst_rlink::test_all errcnt = $errcnt --> [rutil::errcnt2txt $errcnt]"

    return $errcnt
  }
  #
  # Driver for emon based tst_rlink tests
  #
  proc test_all_emon {} {
    #
    set errcnt 0
    incr errcnt [rbemon::test_regs]
    if {[rlink::issim]} {
      incr errcnt [rbemon::test_rbtest_sim]
    }

    puts "tst_rlink::test_all_emon errcnt = $errcnt --> [rutil::errcnt2txt $errcnt]"

    return $errcnt
  }
}
