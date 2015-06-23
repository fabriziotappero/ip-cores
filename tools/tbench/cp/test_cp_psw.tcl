# $Id: test_cp_psw.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-12-26   621   1.0.1  adopt to 4k word ibus window
# 2013-03-31   502   1.0    Initial version
#
# Test that psw is writable and readable via various ways
#  1. direct cp access
#  2. via 16bit memory addressing
#  3. via 22bit memory addressing
#  4. via ibr window
#
# This test not only verifies psw, but also all basic access methods
#

# ----------------------------------------------------------------------------
rlc log "test_cp_psw: test psw access via all methods ------------------------"
rlc log "  write/read via cp"
foreach w { 000000 000017 } {
  $cpu cp -wps $w \
          -rps -edata $w
}

rlc log "  write/read via 16bit cp addressing"
$cpu cp -wal 0177776
foreach w { 000000 000017 } {
  $cpu cp -wm  $w \
          -rm  -edata $w \
          -rps -edata $w
}

rlc log "  write/read via 22bit cp addressing"
$cpu cp -wal 0177776 -wah 000177
foreach w { 000000 000017 } {
  $cpu cp -wm  $w \
          -rm  -edata $w \
          -rps -edata $w
}

rlc log "  write/read via ibr window"
foreach w { 000000 000017 } {
  $cpu cp -wibr 0177776 $w \
          -ribr 0177776 -edata $w \
          -rps          -edata $w
}
