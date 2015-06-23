# $Id: test_labo.tcl 662 2015-04-05 08:02:54Z mueller $
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
# 2015-04-03   662   1.0    Initial version
#

package provide rbtest 1.0

package require rutiltpp
package require rutil
package require rlink

namespace eval rbtest {
  #
  # Test labo with fifo
  #
  proc test_labo {} {
    #
    set errcnt 0
    rlc errcnt -clear
    #
    rlc log "rbtest::test_labo - init: clear cntl, data, and fifo"
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    #
    #-------------------------------------------------------------------------
    rlc log "  test 1: check that sucessfull blk's do not abort chain"

    # use data reg to monitor labo aborts
    rlc exec \
      -wreg te.data 0x0000 

    set blk0 {0x1111 0x2222}
    set blk1 {0x3333 0x4444}
    set blk  {0x1111 0x2222 0x3333 0x4444}
    rlc exec \
      -wblk te.fifo $blk0 \
      -labo -edata 0 \
      -wblk te.fifo $blk1 \
      -labo -edata 0 \
      -rblk te.fifo 4 -edata $blk \
      -labo -edata 0 \
      -wreg te.data 0x0001 

    # no labo above, so 0x01 written to data !
    rlc exec \
      -rreg te.data -edata 0x0001

    #
    #-------------------------------------------------------------------------
    rlc log "  test 2: check that failed rblk aborts chain"

    rlc exec \
      -wblk te.fifo $blk0 \
      -labo -edata 0 \
      -wblk te.fifo $blk1 \
      -labo -edata 0 \
      -wreg te.data 0x0010 \
      -rblk te.fifo 6 -edata $blk -edone 4 -estaterr \
      -labo -edata 1 \
      -wreg te.data 0x0011 \
      -rreg te.data -edata 0xffff \
      -wreg te.data 0x0012 

    # last labo aborted, so 0x10 written, but not 0x11 or 0x12
    rlc exec \
      -rreg te.data -edata 0x0010

    #
    #-------------------------------------------------------------------------
    rlc log "  test 3: check that failed wblk aborts chain"

    set blk {}
    for { set i 0 } { $i < 17 } { incr i } {
      lappend blk [expr {$i | ( $i << 8 ) }]
    }
    rlc exec \
      -wreg te.data 0x0020 \
      -wblk te.fifo $blk -edone 16 -estaterr \
      -labo -edata 1 \
      -wreg te.data 0x0021 \
      -rreg te.data -edata 0xffff \
      -wreg te.data 0x0022 

    # last labo aborted, so 0x20 written, but not 0x21
    rlc exec \
      -rreg te.data -edata 0x0020

    #
    #-------------------------------------------------------------------------
    rlc log "  test 4a: check that babo state kept over clists"

    rlc exec \
      -wreg te.data 0x0030 \
      -labo -edata 1 \
      -wreg te.data 0x0031 

    # no blk done, so labo state sicks, so 0x30 written, but not 0x31
    rlc exec \
      -rreg te.data -edata 0x0030

    #
    #-------------------------------------------------------------------------
    rlc log "  test 4b: check that babo readable from RLSTAT"

    # babo still set
    set babomsk [regbld rlink::RLSTAT babo]
    rlc exec \
      -rreg $rlink::ADDR_RLSTAT -edata $babomsk $babomsk

    #
    #-------------------------------------------------------------------------
    rlc log "  test 4c: check that babo reset by successful rblk"

    rlc exec \
      -wreg te.data 0x0040 \
      -rblk te.fifo 8 -edata [lrange $blk 0 7] \
      -rreg $rlink::ADDR_RLSTAT -edata 0x0 $babomsk \
      -rblk te.fifo 8 -edata [lrange $blk 8 15] \
      -rreg $rlink::ADDR_RLSTAT -edata 0x0 $babomsk \
      -rblk te.fifo 8 -edone 0 -estaterr \
      -rreg $rlink::ADDR_RLSTAT -edata $babomsk $babomsk \
      -labo -edata 1 \
      -wreg te.data 0x0041 

    # last rblk failed again so 0x40 written, but not 0x41
    rlc exec \
      -rreg te.data -edata 0x0040

    #
    #-------------------------------------------------------------------------
    rlc log "  test 4d: check that babo reset by successful wblk"

    set blk2 {0x5555 0x6666}
    rlc exec \
      -wblk te.fifo $blk2 \
      -rreg $rlink::ADDR_RLSTAT -edata 0x0 $babomsk 

    #
    #-------------------------------------------------------------------------
    rlc log "  test 5: check commands between blk and labo are accepted"

    # there are two words in fifo from previous test
    rlc exec \
      -wreg te.data 0x0050 \
      -rblk te.fifo 4 -edata $blk2 -edone 2 -estaterr \
      -rreg $rlink::ADDR_RLSTAT -edata $babomsk $babomsk \
      -wreg te.data 0x0051 \
      -labo -edata 1 \
      -wreg te.data 0x0052

    # last rblk failed so 0x50 written, also 0x51, but not 0x52
    rlc exec \
      -rreg te.data -edata 0x0051

    #
    #-------------------------------------------------------------------------
    rlc log "rbtest::test_fifo - cleanup: clear cntl, data, and fifo"
    rlc exec -init te.cntl [regbld rbtest::INIT fifo data cntl]
    #
    incr errcnt [rlc errcnt -clear]
    return $errcnt
  }
}
