# $Id: test_tm11_regs.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-05-17   683   1.0    Initial version
#
# Test register response 
#  A: register basics

# ----------------------------------------------------------------------------
rlc log "test_tm11_regs: test register response ------------------------------"
package require ibd_tm11
ibd_tm11::setup

rlc set statmask  $rw11::STAT_DEFMASK
rlc set statvalue 0

# -- Section A ---------------------------------------------------------------
rlc log "  A1: test read ---------------------------------------------"
rlc log "    A1.1: loc read sr,...,rl ---------------------------"

$cpu cp -rma  tma.sr  \
        -rma  tma.cr  \
        -rma  tma.bc  \
        -rma  tma.ba  \
        -rma  tma.db  \
        -rma  tma.rl

rlc log "    A1.2: rem read sr,...,rl ---------------------------"

$cpu cp -ribr tma.sr  \
        -ribr tma.cr  \
        -ribr tma.bc  \
        -ribr tma.ba  \
        -ribr tma.db  \
        -ribr tma.rl

rlc log "    A1.3: test that rl+2,+4 gives no ack (loc) ---------"

set iaddr2 [expr {[cpu0 imap tma.rl] + 2}]
set iaddr4 [expr {[cpu0 imap tma.rl] + 4}]

$cpu cp -ribr $iaddr2 -estaterr \
        -ribr $iaddr4 -estaterr

# -- Section B ---------------------------------------------------------------
rlc log "  B1: test sr setup -------------------------------------------------"

rlc log "    B1.1: rem write via rl -----------------------------"
# setup units with             eof=!u1 eot=!u0  onl=1  bot=u0  wrl=u1
set rsr0 [regbld ibd_tm11::RRL {eof 1} {eot 1} {onl 1} {bot 0} {wrl 0} {unit 0}]
set rsr1 [regbld ibd_tm11::RRL {eof 1} {eot 0} {onl 1} {bot 1} {wrl 0} {unit 1}]
set rsr2 [regbld ibd_tm11::RRL {eof 0} {eot 1} {onl 1} {bot 0} {wrl 1} {unit 2}]
set rsr3 [regbld ibd_tm11::RRL {eof 0} {eot 0} {onl 1} {bot 1} {wrl 1} {unit 3}]
# on readback SR has tur=1
set  sr0 [regbld ibd_tm11::SR  {eof 1} {eot 1} {onl 1} {bot 0} {wrl 0} {tur 1}]
set  sr1 [regbld ibd_tm11::SR  {eof 1} {eot 0} {onl 1} {bot 1} {wrl 0} {tur 1}]
set  sr2 [regbld ibd_tm11::SR  {eof 0} {eot 1} {onl 1} {bot 0} {wrl 1} {tur 1}]
set  sr3 [regbld ibd_tm11::SR  {eof 0} {eot 0} {onl 1} {bot 1} {wrl 1} {tur 1}]
set  sr7 [regbld ibd_tm11::SR  {tur 1}]

$cpu cp -wibr "tma.cr"  [ibd_tm11::rcr_wunit 0] \
        -wibr "tma.rl" $rsr0 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 1] \
        -wibr "tma.rl" $rsr1 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 2] \
        -wibr "tma.rl" $rsr2 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 3] \
        -wibr "tma.rl" $rsr3

rlc log "    B1.2: rem read via rl ------------------------------"

$cpu cp -wibr "tma.cr"  [ibd_tm11::rcr_wunit 0] \
        -ribr "tma.rl" -edata $rsr0 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 1] \
        -ribr "tma.rl" -edata $rsr1 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 2] \
        -ribr "tma.rl" -edata $rsr2 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 3] \
        -ribr "tma.rl" -edata $rsr3

rlc log "    B1.3: loc read via sr ------------------------------"

$cpu cp -wma  "tma.cr" [regbld ibd_tm11::CR {unit 0}]\
        -rma  "tma.sr" -edata $sr0 \
        -wma  "tma.cr" [regbld ibd_tm11::CR {unit 1}]\
        -rma  "tma.sr" -edata $sr1 \
        -wma  "tma.cr" [regbld ibd_tm11::CR {unit 2}]\
        -rma  "tma.sr" -edata $sr2 \
        -wma  "tma.cr" [regbld ibd_tm11::CR {unit 3}]\
        -rma  "tma.sr" -edata $sr3 

rlc log "    B1.4: ensure unit 4,..,7 signal offline ------------"

$cpu cp -wma  "tma.cr" [regbld ibd_tm11::CR {unit 4}]\
        -rma  "tma.sr" -edata $sr7 \
        -wma  "tma.cr" [regbld ibd_tm11::CR {unit 5}]\
        -rma  "tma.sr" -edata $sr7 \
        -wma  "tma.cr" [regbld ibd_tm11::CR {unit 6}]\
        -rma  "tma.sr" -edata $sr7 \
        -wma  "tma.cr" [regbld ibd_tm11::CR {unit 7}]\
        -rma  "tma.sr" -edata $sr7

rlc log "    B1.5: setup unit 0:3 as onl=1 bot=1 ----------------"

# use use ONL=1 BOT=1 for all units -> no error flags
set rsr0 [regbld ibd_tm11::RRL {onl 1} {bot 1} {unit 0}]
set rsr1 [regbld ibd_tm11::RRL {onl 1} {bot 1} {unit 1}]
set rsr2 [regbld ibd_tm11::RRL {onl 1} {bot 1} {unit 2}]
set rsr3 [regbld ibd_tm11::RRL {onl 1} {bot 1} {unit 3}]
# on readback SR has tur=1
set  sr0 [regbld ibd_tm11::SR  {onl 1} {bot 1} {tur 1}]
set  sr1 [regbld ibd_tm11::SR  {onl 1} {bot 1} {tur 1}]
set  sr2 [regbld ibd_tm11::SR  {onl 1} {bot 1} {tur 1}]
set  sr3 [regbld ibd_tm11::SR  {onl 1} {bot 1} {tur 1}]
$cpu cp -wibr "tma.cr"  [ibd_tm11::rcr_wunit 0] \
        -wibr "tma.rl" $rsr0 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 1] \
        -wibr "tma.rl" $rsr1 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 2] \
        -wibr "tma.rl" $rsr2 \
        -wibr "tma.cr"  [ibd_tm11::rcr_wunit 3] \
        -wibr "tma.rl" $rsr3

rlc log "    B2.1: loc write loc/rem read of cr -----------------"
# test all cr fields except ie and go (no interrupts and functions yet)
set crlist [list \
     [regbld ibd_tm11::CR {den 0} {pevn 0} {unit 0} {ea 0} {func 0}] \
     [regbld ibd_tm11::CR {den 3} {pevn 0} {unit 0} {ea 0} {func 0}] \
     [regbld ibd_tm11::CR {den 3} {pevn 1} {unit 0} {ea 0} {func 0}] \
     [regbld ibd_tm11::CR {den 3} {pevn 1} {unit 7} {ea 0} {func 0}] \
     [regbld ibd_tm11::CR {den 3} {pevn 1} {unit 3} {ea 3} {func 0}] \
     [regbld ibd_tm11::CR {den 3} {pevn 1} {unit 3} {ea 3} {func 7}] \
            ]
 
foreach cr $crlist {
  # on cr read here always rdy=1
  set crread [expr {$cr | [regbld ibd_tm11::CR {rdy 1}] } ]
  $cpu cp -wma  "tma.cr" $cr \
          -rma  "tma.cr" -edata $crread \
          -ribr "tma.cr" -edata $crread
}

rlc log "    B3.1: loc write loc/rem read for bc,ba -------------"
# Note: ba ignores bit 0, only word addresses
$cpu cp -wma  "tma.bc" 0x0010 \
        -wma  "tma.ba" 0x0020 \
        -rma  "tma.bc" -edata 0x0010 \
        -rma  "tma.ba" -edata 0x0020 \
        -ribr "tma.bc" -edata 0x0010 \
        -ribr "tma.ba" -edata 0x0020 
$cpu cp -wma  "tma.bc" 0x8888 \
        -wma  "tma.ba" 0x7777 \
        -rma  "tma.bc" -edata 0x8888 \
        -rma  "tma.ba" -edata 0x7776 \
        -ribr "tma.bc" -edata 0x8888 \
        -ribr "tma.ba" -edata 0x7776 

rlc log "    B3.2: rem write loc/rem read for bc,ba -------------"

$cpu cp -wibr "tma.bc" 0x1234 \
        -wibr "tma.ba" 0x4321 \
        -rma  "tma.bc" -edata 0x1234 \
        -rma  "tma.ba" -edata 0x4320 \
        -ribr "tma.bc" -edata 0x1234 \
        -ribr "tma.ba" -edata 0x4320 
$cpu cp -wibr "tma.bc" 0x0000 \
        -wibr "tma.ba" 0x0000 \
        -rma  "tma.bc" -edata 0x0000 \
        -rma  "tma.ba" -edata 0x0000 \
        -ribr "tma.bc" -edata 0x0000 \
        -ribr "tma.ba" -edata 0x0000 
