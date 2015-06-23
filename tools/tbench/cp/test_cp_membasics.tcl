# $Id: test_cp_membasics.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-03-02   552   1.0    Initial version
#
# Test very basic memory interface gymnastics
#  1. write/read address register
#  2. write/read memory via wm/wmi/rm/rmi (16 bit mode)
#  3. write/read memory via bwm/brm (16 bit mode)
#

# ----------------------------------------------------------------------------
rlc log "test_cp_membasics: Test very basic memory interface gymnastics ------"

# --------------------------------------------------------------------
rlc log "  write/read address register"

# test wal
$cpu cp -wal 002000 \
        -ral -edata 002000 \
        -rah -edata 000000

# test wah+wal
$cpu cp -wal 003000 \
        -wah 000001 \
        -ral -edata 003000 \
        -rah -edata 000001

# --------------------------------------------------------------------
rlc log "  write/read memory via wm/wmi/rm/rmi (16 bit mode)"

# simple write/read without increment
$cpu cp -wal 002000 \
        -wm  001100 \
        -ral -edata 002000 \
        -rah -edata 000000 \
        -rm  -edata 001100

# double write + single read, check overwrite
$cpu cp -wal 002000 \
        -wm  002200 \
        -wm  002210 \
        -ral -edata 002000 \
        -rah -edata 000000 \
        -rm  -edata 002210

# double write/read with increment
$cpu cp -wal 002100 \
        -wmi 003300 \
        -wmi 003310 \
        -wmi 003320 \
        -ral -edata 002106 \
        -rah -edata 000000

$cpu cp -wal 002100 \
        -rmi -edata 003300 \
        -rmi -edata 003310 \
        -rmi -edata 003320 \
        -ral -edata 002106 \
        -rah -edata 000000

# --------------------------------------------------------------------
rlc log "  write/read memory via bwm/brm (16 bit mode)"
$cpu cp -wal 02200 \
        -bwm {007700 007710 007720 007730}

$cpu cp -wal 02200 \
        -brm 4 -edata {007700 007710 007720 007730}
