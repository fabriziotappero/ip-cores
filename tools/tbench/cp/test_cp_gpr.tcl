# $Id: test_cp_gpr.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2013-03-31   502   1.0    Initial version
#
# Test that general purpose registers are writable and readable via cp
# check all 16 registers, especially that
#   set 0 and 1 are distinct
#   k,s,u mode sp are distinct
#

# ----------------------------------------------------------------------------
rlc log "test_cp_gpr: test cp access to general purpose registers ------------"
rlc log "  write set 0"
$cpu cp -wps 0000000
$cpu cp -wr0 0000001 \
        -wr1 0000101
$cpu cp -wr2 0000201 \
        -wr3 0000301
$cpu cp -wr4 0000401 \
        -wr5 0000501

rlc log "  write set 1"
$cpu cp -wps 0004000
$cpu cp -wr0 0010001 \
        -wr1 0010101
$cpu cp -wr2 0010201 \
        -wr3 0010301
$cpu cp -wr4 0010401 \
        -wr5 0010501

rlc log "  write all sp and pc"
$cpu cp -wps 0000000  -wsp 0000601;     # ksp
$cpu cp -wps 0040000  -wsp 0010601;     # ssp
$cpu cp -wps 0140000  -wsp 0020601;     # usp
$cpu cp -wps 0000000  -wpc 0000701;     # pc

rlc log "  read set 0"
$cpu cp -wps 0000000;                   # set 0
$cpu cp -rr0 -edata 0000001 \
        -rr1 -edata 0000101
$cpu cp -rr2 -edata 0000201 \
        -rr3 -edata 0000301
$cpu cp -rr4 -edata 0000401 \
        -rr5 -edata 0000501

rlc log "  read set 1"
$cpu cp -wps 0004000;                   # set 1
$cpu cp -rr0 -edata 0010001 \
        -rr1 -edata 0010101
$cpu cp -rr2 -edata 0010201 \
        -rr3 -edata 0010301
$cpu cp -rr4 -edata 0010401 \
        -rr5 -edata 0010501

rlc log "  read all sp and pc"
$cpu cp -wps 0000000  -rsp -edata 0000601;     # ksp
$cpu cp -wps 0040000  -rsp -edata 0010601;     # ssp
$cpu cp -wps 0140000  -rsp -edata 0020601;     # usp
$cpu cp -wps 0000000  -rpc -edata 0000701;     # pc
