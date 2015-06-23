# $Id: test_rhrp_regs.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-03-29   660   1.0    Initial version
#
# Test register response 
#  A: test ba, bae, cs1.bae, wc and db  (cntl regs)
#  B: test da, dc (and cc for RP typ)
#  C: test of,mr1,mr2(for RM typ); test NI regs: er2,er3,ec1,ec2
#  D: test hr (for RM typ); ensure unit distinct
#  E: test cs2.clr
#  F: test er1

# ----------------------------------------------------------------------------
rlc log "test_rhrp_regs: test register response ------------------------------"
rlc log "  setup context; unit 0:RP06, 1:RM05, 2: RP07, 3: off"
package require ibd_rhrp
ibd_rhrp::setup

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# configure drives
$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 0] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1}] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 1] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1}] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RM05 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 2] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1}] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP07 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 3] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 0}] 

# clear errors: cs1.tre=1 via unit 0
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre]

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test ba,bae and cs1.bae -------------------------------"
rlc log "    A1.1: loc write ba, read loc and rem ---------------"

$cpu cp -wma  rpa.ba  0xffff \
        -rma  rpa.ba  -edata 0xfffe \
        -ribr rpa.ba  -edata 0xfffe \
        -wma  rpa.ba  0x0 \
        -rma  rpa.ba  -edata 0x0 \
        -ribr rpa.ba  -edata 0x0 

rlc log "    A1.2: rem write ba, read loc and rem ---------------"

$cpu cp -wibr rpa.ba  0x12ef \
        -ribr rpa.ba  -edata 0x12ee \
        -rma  rpa.ba  -edata 0x12ee \
        -wibr rpa.ba  0x0 \
        -ribr rpa.ba  -edata 0x0 \
        -rma  rpa.ba  -edata 0x0 
        
rlc log "    A1.3: loc write bae, read l+r bae+cs1.bae ----------"

set cs1msk [regbld ibd_rhrp::CS1 {bae -1}]
foreach bae {077 071 000} {
  set cs1val [regbld ibd_rhrp::CS1 [list bae [expr {$bae & 03}]]]
  $cpu cp -wma  rpa.bae $bae \
          -rma  rpa.bae -edata $bae \
          -rma  rpa.cs1 -edata $cs1val $cs1msk \
          -ribr rpa.bae -edata $bae \
          -ribr rpa.cs1 -edata $cs1val $cs1msk
}

rlc log "    A1.4: rem write bae, read l+r bae+cs1.bae ----------"

foreach bae {077 071 000} {
  set cs1val [regbld ibd_rhrp::CS1 [list bae [expr {$bae & 03}]]]
  $cpu cp -wibr rpa.bae $bae \
          -ribr rpa.bae -edata $bae \
          -ribr rpa.cs1 -edata $cs1val $cs1msk \
          -rma  rpa.bae -edata $bae \
          -rma  rpa.cs1 -edata $cs1val $cs1msk
}

rlc log "    A1.5: loc write cs1.bae, read l+r bae+cs1.bae ------"

$cpu cp -wibr rpa.bae 070;      # set 3 lbs of bae

foreach cs1bae {03 01 00} {
  set cs1val [regbld ibd_rhrp::CS1 [list bae $cs1bae]]
  set bae    [expr {070 | $cs1bae}]
  $cpu cp -wma  rpa.cs1 $cs1val \
          -rma  rpa.bae -edata $bae \
          -rma  rpa.cs1 -edata $cs1val $cs1msk \
          -ribr rpa.bae -edata $bae \
          -ribr rpa.cs1 -edata $cs1val $cs1msk
}

# Note: cs1.bae can only be loc written ! 
#       No need to do this via rem, use bae !!
#       therefore no 'rem write cs1.bae' test

rlc log "    A1.6: loc write cs1.func, read loc, ensure distinct "

set funcu0  [regbld ibd_rhrp::CS1 {func 001}] 
set funcu1  [regbld ibd_rhrp::CS1 {func 025}]
set funcu2  [regbld ibd_rhrp::CS1 {func 037}]
set funcmsk [regbld ibd_rhrp::CS1 {func -1}]

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 $funcu0 \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.cs1 $funcu1 \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.cs1 $funcu2

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.cs1 -edata $funcu0 $funcmsk \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.cs1 -edata $funcu1 $funcmsk \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.cs1 -edata $funcu2 $funcmsk

# Note: rem read of cs1.func always gives func frozen a go for xfer function !
#       therefore no rem read cs1.func test here

rlc log "  A2: test wc; ensure wc,ba distinct ------------------------"
rlc log "    A2.1: loc write wc,ba, read loc and rem ------------"

foreach {wc ba} {0xdead 0x1234   0xbeaf 0x5678} {
  $cpu cp -wma  rpa.wc  $wc \
          -wma  rpa.ba  $ba \
          -rma  rpa.wc  -edata $wc \
          -rma  rpa.ba  -edata $ba \
          -ribr rpa.wc  -edata $wc \
          -ribr rpa.ba  -edata $ba 
}
        
rlc log "    A2.2: rem write wc,ba, read loc and rem ------------"

foreach {wc ba} {0x4321 0x3456   0x5432 0x1234} {
  $cpu cp -wibr rpa.wc  $wc \
          -wibr rpa.ba  $ba \
          -ribr rpa.wc  -edata $wc \
          -ribr rpa.ba  -edata $ba \
          -rma  rpa.wc  -edata $wc \
          -rma  rpa.ba  -edata $ba 
}
        
rlc log "  A3: test db; check cs2.or,ir; ensure ba,dt distinct --"

set cs2msk [regbld ibd_rhrp::CS2 or ir {unit -1}]
set cs2val [regbld ibd_rhrp::CS2 or ir {unit  0}]

# clear cs2 -> set unit 0; later check that or,ir set, and unit 0
# only loc tested; rem side irrelevant
foreach {db ba} {0xdead 0x1234   0xbeaf 0x5678} {
  $cpu cp -wma  rpa.cs2 0 \
          -wma  rpa.db  $db \
          -wma  rpa.ba  $ba \
          -rma  rpa.cs2 -edata $cs2val $cs2msk \
          -rma  rpa.db  -edata $db \
          -rma  rpa.ba  -edata $ba
}

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test da,dc; ensure unit distinct; check cc ------------"

# define tmpproc for readback checks
proc tmpproc_checkdadc {cpu tbl} {
  foreach {unit ta sa dc} $tbl {
    set da [regbld ibd_rhrp::DA [list ta $ta] [list sa $sa]]
    $cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 [list unit $unit]] \
            -rma  rpa.da  -edata $da \
            -rma  rpa.dc  -edata $dc \
            -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit $unit] \
            -ribr rpa.da  -edata $da \
            -ribr rpa.dc  -edata $dc
  }
}

rlc log "    B1.1: loc setup ------------------------------------"

#          unit   ta   sa     dc
#                 5b   6b    10b
set tbl {     0  007  006  00123 \
              1  013  031  00345 \
              2  037  077  01777
        }

foreach {unit ta sa dc} $tbl {
  $cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 [list unit $unit]] \
          -wma  rpa.da  [regbld ibd_rhrp::DA [list ta $ta] [list sa $sa]] \
          -wma  rpa.dc  $dc 
}

rlc log "    B1.2: loc+rem readback -----------------------------"
tmpproc_checkdadc $cpu $tbl

rlc log "    B1.3: check cc for unit 0 (RP06) -------------------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.m13 -edata 00123

rlc log "    B1.4: rem setup ------------------------------------"

#          unit   ta   sa     dc
#                 5b   6b    10b
set tbl {     0  005  004  00234 \
              1  020  077  00456 \
              2  032  023  01070
        }

foreach {unit ta sa dc} $tbl {
  $cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit $unit] \
          -wibr rpa.da  [regbld ibd_rhrp::DA [list ta $ta] [list sa $sa]] \
          -wibr rpa.dc  $dc 
}

rlc log "    B1.5: loc+rem readback -----------------------------"
tmpproc_checkdadc $cpu $tbl

rlc log "    B1.6: check cc for unit 0 (RP06) -------------------" 
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.m13 -edata 00234

# -- Section C ---------------------------------------------------------------
rlc log "  C1: test of,mr1,mr2(for RM typ); test NI regs: er2,er3,ec1,ec2"

# test fmt,eci,hci flags (NI, but stored), also off for RP
set of_0  [regbld ibd_rhrp::OF fmt {odi 1} {off -1}]
set of_1  [regbld ibd_rhrp::OF eci {odi 0}]
set of_2  [regbld ibd_rhrp::OF hci {odi 0}]

set mr1_0 0x7700
set mr1_1 0x7701
set mr1_2 0x7702

set mr2_1 0x6601
set mr2_2 0x6602

set da_0  [regbld ibd_rhrp::DA {ta 010} {sa 022}]
set da_1  [regbld ibd_rhrp::DA {ta 011} {sa 021}]
set da_2  [regbld ibd_rhrp::DA {ta 012} {sa 020}]

set dc_0  0x40
set dc_1  0x41
set dc_2  0x42

rlc log "    C1.1: loc write da,mr1,of,dc (mr2 for RM) ----------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.da  $da_0  \
        -wma  rpa.mr1 $mr1_0 \
        -wma  rpa.of  $of_0  \
        -wma  rpa.dc  $dc_0

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.da  $da_1  \
        -wma  rpa.mr1 $mr1_1 \
        -wma  rpa.of  $of_1  \
        -wma  rpa.dc  $dc_1  \
        -wma  rpa.m14 $mr2_1

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.da  $da_2  \
        -wma  rpa.mr1 $mr1_2 \
        -wma  rpa.of  $of_2  \
        -wma  rpa.dc  $dc_2  \
        -wma  rpa.m14 $mr2_2

rlc log "    C1.2: loc read da,mr1,of,dc (mr2 for RM) -----------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.da  -edata $da_0  \
        -rma  rpa.mr1 -edata $mr1_0 \
        -rma  rpa.of  -edata $of_0  \
        -rma  rpa.dc  -edata $dc_0

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.da  -edata $da_1  \
        -rma  rpa.mr1 -edata $mr1_1 \
        -rma  rpa.of  -edata $of_1  \
        -rma  rpa.dc  -edata $dc_1  \
        -rma  rpa.m14 -edata $mr2_1

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.da  -edata $da_2  \
        -rma  rpa.mr1 -edata $mr1_2 \
        -rma  rpa.of  -edata $of_2  \
        -rma  rpa.dc  -edata $dc_2  \
        -rma  rpa.m14 -edata $mr2_2

rlc log "    C2.1: loc write er2,er3,ec1,ec2 --------------------"

# unit 0: RP typ -> m14 is er2; m15 is er3
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.m14 0xaa00 \
        -wma  rpa.m15 0xaa10 \
        -wma  rpa.ec1 0xaa20 \
        -wma  rpa.ec1 0xaa30 

# unit 1+2: RM typ -> m15 is er2
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.m15 0xaa11 \
        -wma  rpa.ec1 0xaa21 \
        -wma  rpa.ec1 0xaa31 
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.m15 0xaa12 \
        -wma  rpa.ec1 0xaa22 \
        -wma  rpa.ec1 0xaa32 

rlc log "    C2.1: loc read er2,er3,ec1,ec2 (NI -> =0!) ---------"

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.m14 -edata 0x0 \
        -rma  rpa.m15 -edata 0x0 \
        -rma  rpa.ec1 -edata 0x0 \
        -rma  rpa.ec1 -edata 0x0 

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.m15 -edata 0x0 \
        -rma  rpa.ec1 -edata 0x0 \
        -rma  rpa.ec1 -edata 0x0 
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.m15 -edata 0x0 \
        -rma  rpa.ec1 -edata 0x0 \
        -rma  rpa.ec1 -edata 0x0 

# -- Section D ---------------------------------------------------------------
rlc log "  D1: test hr (for RM typ); ensure unit distinct ------------"

# test unit 1+2, they  are RM typ (RM05 and RP07)

set da [regbld ibd_rhrp::DA {ta 005} {sa 023}]; # some da
set dc 00456;                                   # some dc

rlc log "    D1.1: write da(1) and dc(2) ------------------------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.da  $da \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.da  $dc 

rlc log "    D1.2: check hr(1) and hr(2) ------------------------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.m13 -edata [rutil::com16 $da] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.m13 -edata [rutil::com16 $dc]
 
rlc log "    D1.3: write da(2) and dc(1) ------------------------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.da  $da \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.da  $dc 

rlc log "    D1.4: check hr(1) and hr(2) ------------------------"
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.m13 -edata [rutil::com16 $dc] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.m13 -edata [rutil::com16 $da]

# FIXME: add code to check hr response for all mb reg writes

# -- Section E ---------------------------------------------------------------
rlc log "  E1: test rem er1 write; clear via func=dclr ---------------"
rlc log "    E1.1: rem er1 set uns,iae,aoe,ilf; loc readback ----"

set er1msk [regbld ibd_rhrp::ER1 uns iae aoe ilf]

# use unit 1
$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 1] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}]

$cpu cp -rma  rpa.er1 -edata 0x0 \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 uns] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 uns] $er1msk \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 iae] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 uns iae] $er1msk \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 aoe] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 uns iae aoe] $er1msk \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 ilf] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 uns iae aoe ilf] $er1msk

rlc log "    E1.2: clear er1 via func=dclr ----------------------"

$cpu cp -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -rma  rpa.er1 -edata 0x0

rlc log "    E1.3: rem er1 set in different units ---------------"

$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 0] \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 iae] \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 1] \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 aoe] \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 2] \
        -wibr rpa.er1 [regbld ibd_rhrp::ER1 ilf]

rlc log "    E1.4: loc readback, show er1 is distinct -----------"

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 iae] $er1msk \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 aoe] $er1msk \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 ilf] $er1msk

rlc log "    E1.5: show func=dclr distinct ----------------------"

# clear unit 1, that that 1 clr and 0+2 untouched
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 iae] $er1msk \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 1}] \
        -rma  rpa.er1 -edata 0x0 \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 ilf] $er1msk

rlc log "    E1.6: clear er1 in remaining units -----------------"

# unit 0+2 still have er1 bits set from previous test
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -rma  rpa.er1 -edata 0x0 \
        -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 2}] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -rma  rpa.er1 -edata 0x0
