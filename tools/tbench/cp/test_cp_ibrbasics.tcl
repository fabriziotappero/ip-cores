# $Id: test_cp_ibrbasics.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-12-26   621   1.1    test membe
# 2014-03-02   552   1.0    Initial version
#
# Test very basic memory interface gymnastics
#  2. write/read IB space via bwm/brm (use MMU SAR SM I regs)
#

# ----------------------------------------------------------------------------
rlc log "test_cp_ibrbasics: Test very basic ibus interface gymnastics --------"

rlc log "  write/read ibus space (MMU SAR SM I regs) via bwm/brm"
$cpu cp -wal 0172240 \
        -bwm {012340 012342 012344}

$cpu cp -wal 0172240 \
        -brm 3 -edata {012340 012342 012344}

rlc log "  write/read ibus space (MMU SAR SM I regs) via wibr/ribr"
$cpu cp -ribr 0172240 -edata 012340 \
        -ribr 0172242 -edata 012342 \
        -ribr 0172244 -edata 012344
$cpu cp -wibr 0172240 022340 \
        -wibr 0172242 022342 \
        -wibr 0172244 022344
$cpu cp -ribr 0172240 -edata 022340 \
        -ribr 0172242 -edata 022342 \
        -ribr 0172244 -edata 022344

rlc log "  membe with wibr (non sticky)"
$cpu cp -wibr 0172240 0x0100 \
        -wibr 0172242 0x0302 \
        -wibr 0172244 0x0504
rlc log "    membe = 0 (no byte selected)"
$cpu cp -wmembe 0 \
        -wibr 0172242 0xffff \
        -rmembe -edata 0x03 \
        -ribr 0172242 -edata 0x0302
rlc log "    membe = 1 (lsb selected)"
$cpu cp -wmembe 0x01 \
        -wibr 0172242 0xffaa \
        -rmembe -edata 0x03 \
        -ribr 0172242 -edata 0x03aa
rlc log "    membe = 2 (msb selected)"
$cpu cp -wmembe 0x02 \
        -wibr 0172242 0xbbff \
        -rmembe -edata 0x03 \
        -ribr 0172242 -edata 0xbbaa

$cpu cp -ribr 0172240 -edata 0x0100 \
        -ribr 0172242 -edata 0xbbaa \
        -ribr 0172244 -edata 0x0504

rlc log "  membe with wibr (sticky)"
$cpu cp -wibr 0172240 0x1110 \
        -wibr 0172242 0x1312 \
        -wibr 0172244 0x1514

rlc log "    membe = 0 + stick (no byte selected)"
$cpu cp -wmembe 0 -stick \
        -wibr 0172242 0xffff \
        -rmembe -edata 0x04 \
        -ribr 0172242 -edata 0x1312

rlc log "    membe = 1 + stick (lsb selected)"
$cpu cp -wmembe 1 -stick \
        -wibr 0172240 0xffaa \
        -rmembe -edata 0x05 \
        -wibr 0172242 0xffbb \
        -rmembe -edata 0x05 \
        -wibr 0172244 0xffcc \
        -rmembe -edata 0x05
$cpu cp -ribr 0172240 -edata 0x11aa \
        -ribr 0172242 -edata 0x13bb \
        -ribr 0172244 -edata 0x15cc

rlc log "    membe = 2 + stick (msb selected)"
$cpu cp -wmembe 2 -stick \
        -wibr 0172240 0xccff \
        -rmembe -edata 0x06 \
        -wibr 0172242 0xbbff \
        -rmembe -edata 0x06 \
        -wibr 0172244 0xaaff \
        -rmembe -edata 0x06
$cpu cp -ribr 0172240 -edata 0xccaa \
        -ribr 0172242 -edata 0xbbbb \
        -ribr 0172244 -edata 0xaacc
rlc log "    membe = 3 again"
$cpu cp -wmembe 3 \
        -rmembe -edata 0x03

# --------------------------------------------------------------------
