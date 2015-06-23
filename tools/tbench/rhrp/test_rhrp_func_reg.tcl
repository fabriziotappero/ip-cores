# $Id: test_rhrp_func_reg.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-03-29   660   1.0    Initial version
#
# Test functions - register level
#  A: 

# ----------------------------------------------------------------------------
rlc log "test_rhrp_func_reg: test functions - register level -----------------"
rlc log "  setup: unit 0:RP06(mol), 1:RM05(mol,wrl), 2: RP07(mol=0), 3: off"
package require ibd_rhrp
ibd_rhrp::setup

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# configure drives
$cpu cp -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 0] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1} mol] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP06 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 1] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1} mol wrl] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RM05 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 2] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 1}] \
        -wibr rpa.dt  $ibd_rhrp::DTE_RP07 \
        -wibr rpa.cs1 [ibd_rhrp::rcs1_wunit 3] \
        -wibr rpa.ds  [regbld ibd_rhrp::DS {dpr 0}] 

# setup system: select unit 0; clr errors (cs1.tre and func=dclr); clear ATs
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -wma  rpa.as  [regbld ibd_rhrp::AS u3 u2 u1 u0] \
        -rma  rpa.ds  -edata [regbld ibd_rhrp::DS dpr mol dry]
        
# -- Section A -- function basics --------------------------------------------
rlc log "  A -- function basics ----------------------------------------------"
rlc log "  A1: test cs1 func basics ----------------------------------"
rlc log "    A1.1a: func noop; check no as ----------------------"

set dsmsk [regbld ibd_rhrp::DS ata dpr]

$cpu cp -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_NOOP] \
        -rma  rpa.as  -edata 0x0 \
        -rma  rpa.ds  -edata [regbld ibd_rhrp::DS dpr] $dsmsk 

rlc log "    A2.1a: test invalid function (037) -----------------"

$cpu cp -wma  rpa.cs1 [ibd_rhrp::cs1_func 037] 

rlc log "    A2.1b: check as,er1.ilf,ds.ata; clear as; recheck --"

$cpu cp -rma  rpa.as  -edata [regbld ibd_rhrp::AS u0] \
        -rma  rpa.er1 -edata [regbld ibd_rhrp::ER1 ilf] \
        -rma  rpa.ds  -edata [regbld ibd_rhrp::DS ata dpr] $dsmsk \
        -wma  rpa.as  [regbld ibd_rhrp::AS u0] \
        -rma  rpa.as  -edata 0x0 \
        -rma  rpa.ds  -edata [regbld ibd_rhrp::DS dpr] $dsmsk 

rlc log "    A2.2a: func dclr; check no as and er1 clear --------"

$cpu cp -wma  rpa.as  [regbld ibd_rhrp::AS u3 u2 u1 u0] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -rma  rpa.as  -edata 0x0 \
        -rma  rpa.er1 -edata 0x0 

# -- Section B -- state functions --------------------------------------------
rlc log "  B -- state functions ----------------------------------------------"

# -- Section C -- seek functions ---------------------------------------------
rlc log "  C -- seek functions -----------------------------------------------"

# -- Section D -- transfer functions -----------------------------------------
rlc log "  D -- transfer functions -------------------------------------------"
rlc log "  D1: test func read sequence -------------------------------"
rlc log "  D1.1: issue func with ie=0 ---------------------------"

# discard pending attn to be on save side
rlc wtlam 0.
rlc exec -attn

set attnmsk [expr {1<<$ibd_rhrp::ANUM}]

set ba 0x1000
set wc [expr {0xffff & (-256)}]
set da [regbld ibd_rhrp::DA {ta 2} {sa 1}]
set dc 0x0003

$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -wma  rpa.ba  $ba \
        -wma  rpa.bae 0x0    \
        -wma  rpa.wc  $wc \
        -wma  rpa.da  $da    \
        -wma  rpa.dc  $dc \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_READ]

rlc log "  D1.2: loc status check: cs1.rdy=0, ds.dry=0 ----------"

$cpu cp -rma  rpa.cs1 -edata 0 [regbld ibd_rhrp::CS1 rdy] \
        -rma  rpa.ds  -edata 0 [regbld ibd_rhrp::DS  dry] 

rlc log "  D1.3: rem status check: attn + state -----------------"

rlc exec -attn -edata $attnmsk

# check rdy=0 ie=0 func=read
set cs1val [regbld ibd_rhrp::CS1 [list func $ibd_rhrp::FUNC_READ]]
set cs1msk [regbld ibd_rhrp::CS1 rdy ie {func -1}]
# expect ds mol=1 dpr=1 dry=0
set dsval  [regbld ibd_rhrp::DS mol dpr]

$cpu cp -wibr rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::RFUNC_CUNIT] \
        -ribr rpa.cs1 -edata $cs1val $cs1msk \
        -ribr rpa.ba  -edata $ba \
        -ribr rpa.bae -edata 0x0 \
        -ribr rpa.wc  -edata $wc \
        -ribr rpa.da  -edata $da \
        -ribr rpa.dc  -edata $dc \
        -ribr rpa.ds  -edata $dsval

rlc log "  D1.4: rem send response ------------------------------"

set ba [expr {0xffff & (-$wc)}]
set da [regbld ibd_rhrp::DA {ta 2} {sa 2}]

$cpu cp -wibr rpa.ba  $ba \
        -wibr rpa.wc  0x0 \
        -wibr rpa.da  $da \
        -wibr rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::RFUNC_DONE]

rlc log "  D1.5: loc check: cs1.rdy=1, ds.dry=1 -----------------"

# expect cs1 sc=0 tre=0 dva=1 rdy=1 ie=0 func=read go=0
set cs1val [regbld ibd_rhrp::CS1 dva rdy [list func $ibd_rhrp::FUNC_READ]]
# expect ds ata=0 mol=1 dpr=1 dry=1
set dsval  [regbld ibd_rhrp::DS mol dpr dry]

$cpu cp -rma  rpa.cs1 -edata $cs1val \
        -rma  rpa.ba  -edata $ba \
        -rma  rpa.wc  -edata 0x0 \
        -rma  rpa.da  -edata $da \
        -rma  rpa.ds  -edata $dsval
