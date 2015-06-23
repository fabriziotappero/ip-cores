# $Id: defs.tcl 621 2014-12-26 21:20:05Z mueller $
#
# Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
# 2014-03-07   553   1.0    Initial version (extracted from util.tcl)
#

package provide rw11 1.0

package require rlink
package require rwxxtpp

namespace eval rw11 {
  #
  # setup cp interface register descriptions for w11a -----------------------
  #
  regdsc CP_CNTL {func 3 0}
  regdsc CP_STAT {rust 7 4} {halt 3} {go 2} {merr 1} {err 0}
  regdsc CP_AH   {ubm 7} {p22 6} {addr 5 6}
  #
  # setup w11a register descriptions -----------------------------------------
  #
  # PSW - processor status word --------------------------------------
  set A_PSW 0177776
  regdsc PSW {cmode 15 2} {pmode 13 2} {rset 11} {pri 7 3} {tflag 3} {cc 3 4}
  #
  # SSR0 - MMU Segment Status Register #0 ----------------------------
  set A_SSR0     0177572
  regdsc SSR0 {abo_nonres 15} {abo_len 14}  {abo_rd 13} \
              {trap_mmu 12} {ena_trap 9} {inst_compl 7} \
              {mode 6 2} {dspace 4} {num 3 3} {ena 0}
  #
  # SSR1 - MMU Segment Status Register #1 ----------------------------
  set A_SSR1     0177574
  regdsc SSR1 {delta1 15 5} {rnum1 10 3} {delta0 7 5} {rnum0 2 3} 
  #
  # SSR2 - MMU Segment Status Register #2 ----------------------------
  set A_SSR2     0177576
  #
  # SSR3 - MMU Segment Status Register #3 ----------------------------
  set A_SSR3     0172516
  regdsc SSR3 {ena_ubm 5} {ena_22bit 4} {d_km 2} {d_sm 1} {d_um 0}
  #
  # SAR/SDR - MMU Address/Segment Descriptor Register ----------------
  set A_SDR_KM   0172300
  set A_SAR_KM   0172340
  set A_SDR_SM   0172200
  set A_SAR_SM   0172240
  set A_SDR_UM   0177600
  set A_SAR_UM   0177640
  regdsc SDR {slf 14 7} {aia  7} {aiw 6} {ed 3} {acf 2 3}
  #
  # PIRQ - Program Interrupt Requests -------------------------------
  set A_PIRQ     0177772
  regdsc PIRQ {pir 15 7} {piah 7 3} {pial 3 3}
  #
  # CPUERR - CPU Error Register -------------------------------------
  set A_CPUERR   0177766
  regdsc CPUERR {illhlt 7} {adderr 6} {nxm 5} {iobto 4} {ysv 3} {rsv 2}
  #
  # other w11a definitions ---------------------------------------------------
  # Interrupt vectors -----------------------------------------------
  #
  set V_004      0000004
  set V_010      0000010
  set V_BPT      0000014
  set V_IOT      0000020
  set V_PWR      0000024
  set V_EMT      0000030
  set V_TRAP     0000034
  set V_PIRQ     0000240
  set V_FPU      0000244
  set V_MMU      0000250

}
