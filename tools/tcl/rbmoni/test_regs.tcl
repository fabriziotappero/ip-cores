# $Id: test_regs.tcl 661 2015-04-03 18:28:41Z mueller $
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
# 2015-04-03   661   2.1    drop estatdef (stat err check default now)
# 2014-12-27   622   2.0    rbd_rbmon reorganized, supports now 16 bit addresses
# 2011-03-27   374   1.0    Initial version
# 2011-03-13   369   0.1    First Draft
#

package provide rbmoni 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbmoni {
  #
  # Basic tests with rbtester registers
  #
  proc test_regs {} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbmoni::test_regs - start"
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: write/read cntl"
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL start] \
      -rreg rm.cntl -edata [regbld rbmoni::CNTL start] \
      -wreg rm.cntl [regbld rbmoni::CNTL stop] \
      -rreg rm.cntl -edata 0 \
      -wreg rm.cntl [regbld rbmoni::CNTL start wena] \
      -rreg rm.cntl -edata [regbld rbmoni::CNTL start wena] \
      -wreg rm.cntl [regbld rbmoni::CNTL stop] \
      -rreg rm.cntl -edata 0 
    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: read stat"
    rlc exec \
      -rreg rm.stat rstat
    set bsize [regget rbmoni::STAT(bsize) $rstat]
    set amax  [expr {( 512 << $bsize ) - 1}]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: write/read hilim/lolim"
    foreach {lolim hilim} {0xffff 0x0000 \
                           0x0000 0xfffb} {
      rlc exec \
        -wreg rm.lolim $lolim -wreg rm.hilim $hilim \
        -rreg rm.lolim -edata $lolim -rreg rm.hilim -edata $hilim
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 4: write/read addr"
    foreach {laddr waddr} [list 0x0000 0 0x0000 3 $amax 0 $amax 3] {
      set addr [regbld rbmoni::ADDR [list laddr $laddr] [list waddr $waddr]]
      rlc exec \
        -wreg rm.addr $addr \
        -rreg rm.addr -edata $addr
    }
    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: verify that cntl.go 0->1 clear addr"
    rlc exec \
      -wreg rm.cntl [regbld rbmoni::CNTL stop] \
      -rreg rm.cntl -edata 0x0 \
      -wreg rm.addr [regbld rbmoni::ADDR [list laddr $amax]] \
      -rreg rm.addr -edata [regbld rbmoni::ADDR [list laddr $amax]] \
      -wreg rm.cntl [regbld rbmoni::CNTL start] \
      -rreg rm.cntl -edata [regbld rbmoni::CNTL start] \
      -rreg rm.addr -edata 0x00 \
      -wreg rm.cntl [regbld rbmoni::CNTL stop] \
      -rreg rm.cntl -edata 0x0
    #
    #-------------------------------------------------------------------------
    rlc log "rbmoni::test_regs - cleanup"
    rbmoni::init
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
