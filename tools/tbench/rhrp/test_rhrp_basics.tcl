# $Id: test_rhrp_basics.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-03-29   660   1.0    Initial version
#
# Test basic access 
#  1. ibus/rbus ack (for cs1:cs3) and no ack (cs3+2)
#  2. unit enable/disable and cs2.ned response
#  3. drive type logic
#  4. readability of all regs (enabled and diabled unit, check cs2.ned)

# ----------------------------------------------------------------------------
rlc log "test_rhrp_basics: basic access tests --------------------------------"
rlc log "  setup context"
package require ibd_rhrp
ibd_rhrp::setup

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

rlc log "  A1: test that cs1,cs3 give ack, cs3+2 gives no ack --------"

set iaddrfail [expr {[cpu0 imap rpa.cs3] + 2}]

rlc log "    A1.1: rem read cs1,cs3,cs3+1 -----------------------"

$cpu cp -ribr rpa.cs1 \
        -ribr rpa.cs3 \
        -ribr $iaddrfail -estaterr

rlc log "    A1.2: loc read cs1,cs3,cs3+1 -----------------------"

$cpu cp -rma  rpa.cs1 \
        -rma  rpa.cs3 \
        -rma $iaddrfail -estaterr

rlc log "  A2: test unit enable, dt and cs2.ned ----------------------"
rlc log "    A2.1: disable unit 0 -------------------------------"

# 
# select rem and loc unit 0; disable unit
$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 0] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 0}] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}]

rlc log "    A2.2: check dt read and cs2.ned --------------------"
set cs2ned [regbld ibd_rhrp::CS2 ned]
$cpu cp -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -rma  rpa.dt \
        -rma  rpa.cs2 -edata $cs2ned $cs2ned

rlc log "    A2.3: enable unit 0 as RP06; check cs2.ned, dt -----"

# check for cs2.ned=0 response on dt read (after cs1.tre=1)
# unit 0 selected rem and loc from previous section
$cpu cp -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1}] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06 \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -rma  rpa.dt  -edata $ibd_rhrp::DT_RP06 \
        -rma  rpa.cs2 -edata 0 $cs2ned

rlc log "  A3: set drive types, check proper dt response -------------"

#             dte                 dt
set tbl [list $ibd_rhrp::DTE_RP04 $ibd_rhrp::DT_RP04 \
              $ibd_rhrp::DTE_RP06 $ibd_rhrp::DT_RP06 \
              $ibd_rhrp::DTE_RM04 $ibd_rhrp::DT_RM04 \
              $ibd_rhrp::DTE_RM80 $ibd_rhrp::DT_RM80 \
              $ibd_rhrp::DTE_RM05 $ibd_rhrp::DT_RM05 \
              $ibd_rhrp::DTE_RP07 $ibd_rhrp::DT_RP07 ]

# unit 0 enabled and selected rem and loc from previous section
foreach {dte dt} $tbl {
  $cpu cp -wibr rpa.dt  $dte \
          -ribr rpa.dt  -edata $dte \
          -rma  rpa.dt  -edata $dt
}

rlc log "  A4: check unit selection and that units are distinct ------"

rlc log "    A4.1: setup units: 0: RP04 1:off 2:RP06 3:off ------"

#          unit dpr dte                 dt
set tbl [list 0  1  $ibd_rhrp::DTE_RP04 $ibd_rhrp::DT_RP04 \
              1  0  0                   0 \
              2  1  $ibd_rhrp::DTE_RP06 $ibd_rhrp::DT_RP06 \
              3  0  0                   0]

foreach {unit dpr dte dt} $tbl {
  $cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit $unit] \
          -wibr rpa.ds  [regbld ibd_rhrp::DS [list dpr $dpr]] \
          -wibr rpa.dt  $dte 
}

rlc log "    A4.2: readback dt rem and loc; check cs2.ned -------"

set dsmsk  [regbld ibd_rhrp::DS  dpr]
set cs2msk [regbld ibd_rhrp::CS2 ned {unit 3}]
foreach {unit dpr dte dt} $tbl {
  set dsval  [regbld ibd_rhrp::DS [list dpr $dpr]]
  set cs2val [regbld ibd_rhrp::CS2 [list ned [expr {1-$dpr}]] [list unit $unit]]
  $cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit $unit] \
          -ribr rpa.ds  -edata $dsval $dsmsk \
          -ribr rpa.dt  -edata $dte \
          -wma  rpa.cs2 [regbld ibd_rhrp::CS2 [list unit $unit]] \
          -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
          -rma  rpa.dt  -edata $dt \
          -rma  rpa.cs2 -edata $cs2val $cs2msk
}

rlc log "  A5: check cs2.ned for all regs on disabled unit -----------"

# use setting from last section: drive 0 on, drive 1 off
#             addr     mb
set tbl [list rpa.cs1  1 \
              rpa.wc   0 \
              rpa.ba   0 \
              rpa.da   1 \
              rpa.cs2  0 \
              rpa.ds   1 \
              rpa.er1  1 \
              rpa.as   1 \
              rpa.la   1 \
              rpa.db   0 \
              rpa.mr1  1 \
              rpa.dt   1 \
              rpa.sn   1 \
              rpa.of   1 \
              rpa.dc   1 \
              rpa.m13  1 \
              rpa.m14  1 \
              rpa.m15  1 \
              rpa.ec1  1 \
              rpa.ec2  1 \
              rpa.bae  0 \
              rpa.cs3  0 \
        ]

# Note: First unit 1 (enabled) selected, and cs1.tre=1 done
#       Than unit 1 (disabled) selected, and registered read
#       This ensures that cs2.ned is really cleared, because a cs1.tre=1
#       write while a disabled drive is selected will clear and set ned !!
set cs2msk [regbld ibd_rhrp::CS2 ned {unit -1}]
foreach {addr mb} $tbl {
  set cs2val [regbld ibd_rhrp::CS2 [list ned $mb] {unit 1}]
  $cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
          -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
          -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
          -rma  $addr \
          -rma  rpa.cs2 -edata $cs2val $cs2msk
}

rlc log "  A6: check cs2.ned for all regs on enable unit -------------"

# select drive 0 (on); cs1.tre=1; read all regs; check cs2 at end once (sticky)
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 [list unit 0]] \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -rma  rpa.cs1 \
        -rma  rpa.wc  \
        -rma  rpa.ba  \
        -rma  rpa.da  

$cpu cp -rma  rpa.cs2 \
        -rma  rpa.ds  \
        -rma  rpa.er1 \
        -rma  rpa.as  \
        -rma  rpa.la  \
        -rma  rpa.db  \
        -rma  rpa.mr1 

$cpu cp -rma  rpa.dt  \
        -rma  rpa.sn  \
        -rma  rpa.of  \
        -rma  rpa.dc  \
        -rma  rpa.m13 \
        -rma  rpa.m14 \
        -rma  rpa.m15 

$cpu cp -rma  rpa.ec1 \
        -rma  rpa.ec2 \
        -rma  rpa.bae \
        -rma  rpa.cs3 \
        -rma  rpa.cs2 -edata 0 [regbld ibd_rhrp::CS2 ned]

rlc log "  A7: check that unit 3-7 are loc selectable, but off -------"
rlc log "    A7.1: loc read dt for unit 3-7 ; check cs2.unit+ned"

set cs2msk [regbld ibd_rhrp::CS2 ned {unit -1}]
foreach {unit} {4 5 6 7} {
  set cs2val [regbld ibd_rhrp::CS2 ned [list unit $unit]] 
  $cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 [list unit $unit]] \
          -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
          -rma  rpa.dt  -edata 0 \
          -rma  rpa.cs2 -edata $cs2val $cs2msk
}

