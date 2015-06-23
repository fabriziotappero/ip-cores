# $Id: test_rhrp_int.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2015-05-04   674   1.1    w11a start/stop/suspend overhaul
# 2015-03-29   667   1.0    Initial version
#
# Test interrupt response 
#  A: 

# ----------------------------------------------------------------------------
rlc log "test_rhrp_int: test interrupt response ------------------------------"
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

# clear errors: cs1.tre=1 via unit 0
$cpu cp -wma  rpa.cs2 [regbld ibd_rhrp::CS2 {unit 0}] \
        -wma  rpa.cs1 [regbld ibd_rhrp::CS1 tre] \
        -wma  rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::FUNC_DCLR] \
        -wma  rpa.as  [regbld ibd_rhrp::AS u3 u2 u1 u0] \
        -rma  rpa.ds  -edata [regbld ibd_rhrp::DS dpr mol dry]

# load test code
$cpu ldasm -lst lst -sym sym {
        .include  |lib/defs_cpu.mac|
        .include  |lib/defs_rp.mac|
;
        .include  |lib/vec_cpucatch.mac|
; 
        . = 000254              ; setup RHRP interrupt vector
v..rp:  .word vh.rp
        .word cp.pr7
;
        . = 1000                ; data area
stack:  
ibuf:   .blkw  4.               ; input buffer
rint:   .word  0                ; reinterrupt
;
icnt:   .word  0                ; interrupt count
pcnt:   .word  0                ; poll count
obuf:   .blkw  6.               ; output buffer
fbuf:   .blkw  5.               ; final buffer
;
        . = 2000                ; code area
start:  spl     7               ; lock out interrupts
        clr     icnt            ; clear counters
        clr     pcnt
; 
        mov     #obuf,r0        ; clear obuf 
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     r5              ; r5 used to time int delay
; 
        mov     #ibuf,r0        ; setup regs from ibuf
        mov     (r0)+,@#rp.cs2  ;   cs2
        mov     (r0)+,@#rp.da   ;   da
        mov     (r0)+,@#rp.dc   ;   dc
        mov     (r0)+,@#rp.cs1  ;   cs1
        spl     0               ; allow interrupts
; 
        inc     r5              ; time int delay, up to 10 instructions
        inc     r5  
        inc     r5  
        inc     r5  
        inc     r5  
        inc     r5  
        inc     r5  
        inc     r5  
        inc     r5  
        inc     r5  
; 
poll:   inc     pcnt            ; count polls
        tstb    @#rp.cs1        ; check cs1 rdy
        bpl     poll            ; if rdy=0 keep polling
        tst     icnt            ; did we have an interrupt ?
        bne     1$              ; 
; 
        mov     #obuf,r0        ; store regs in obuf
        mov     @#rp.cs1,(r0)+  ;   cs1
        mov     @#rp.cs2,(r0)+  ;   cs2
        mov     @#rp.er1,(r0)+  ;   er1
        mov     @#rp.ds,(r0)+   ;   ds
        mov     @#rp.as,(r0)+   ;   as
; 
1$:     tst     rint            ; re-interrupt wanted ?
        bne     2$              ;
        mov     #377,@#rp.as    ; if not, cancel all attentions
        clr     rint
; 
2$:     bit     #rp.erp,@#rp.ds ; ds.erp = 1 ? any controller errors ?
        beq     3$
        mov     #<rp.fcl+rp.go>,@#rp.cs1 ; than do drive clear 
; 
3$:     bit     #rp.tre,@#rp.cs1 ; cs1.tre = 1 ? any transfer errors ?
        beq     4$
        mov     #rp.tre,@#rp.cs1 ; if yes, clear them with tre=1 write
; 
4$:     mov     #fbuf,r0        ; store final regs in fbuf
        mov     @#rp.cs1,(r0)+  ;   cs1
        mov     @#rp.cs2,(r0)+  ;   cs2
        mov     @#rp.er1,(r0)+  ;   er1
        mov     @#rp.ds,(r0)+   ;   ds
        mov     @#rp.as,(r0)+   ;   as

        halt                    ; halt if done
stop:
; 
        clr     pcnt            ; clear pcnt again
        mov     #obuf,r0        ; clear obuf again
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
        clr     (r0)+
; 
        mov     #rp.ie,@#rp.cs1 ; re-enable interrupt
        br      poll

; RHRP interrupt handler
vh.rp:  mov     #obuf,r0        ; store regs in obuf
        mov     @#rp.cs1,(r0)+  ;   cs1
        mov     @#rp.cs2,(r0)+  ;   cs2
        mov     @#rp.er1,(r0)+  ;   er1
        mov     @#rp.ds,(r0)+   ;   ds
        mov     @#rp.as,r1      ;   
        mov     r1,(r0)+        ;   as
        mov     r5,(r0)+        ;   int delay
; 
1$:     tst     icnt            ; test first interrupt
        beq     2$              ; if yes quit
        mov     r1,@#rp.as      ; if not, clear as
2$:     inc     icnt            ; count interrupts
        rti                     ; and return
}

##puts $lst

# define tmpproc for readback checks
proc tmpproc_dotest {cpu symName opts} {
  upvar 1 $symName sym

  set tout 10.;                   # FIXME_code: parameter ??

# setup defs hash, first defaults, than write over concrete run values  
  array set defs { i.cs2    0 \
                   i.da     0 \
                   i.dc     0 \
                   i.cs1    0 \
                   i.idly   0 \
                   o.cs1    0 \
                   o.cs2    0 \
                   o.er1    0 \
                   o.ds     0 \
                   o.as     0 \
                   o.itim  10 \
                   o.icnt   0 \
                   o.pcnt   1 \
                   or.cs1   0 \
                   or.cs2   0 \
                   or.er1   0 \
                   or.ds    0 \
                   or.as    0 \
                   or.icnt  0 \
                   or.pcnt  1 \
                   do.rint  0 \
                   do.lam   0
                 }
  array set defs $opts

  # build ibuf
  set ibuf [list $defs(i.cs2) $defs(i.da) $defs(i.dc) $defs(i.cs1) \
              $defs(do.rint)] 

  # setup idly, write ibuf, setup stack, and start cpu at start:
  $cpu cp -wibr rpa.cs1 [regbld ibd_rhrp::RCS1 \
                           [list val $defs(i.idly)] \
                           [list func $ibd_rhrp::RFUNC_WIDLY] ] \
          -wal   $sym(ibuf) \
          -bwm   $ibuf \
          -wsp   $sym(stack) \
          -stapc $sym(start)

  # here do minimal lam handling (harvest + send DONE)
  if {$defs(do.lam)} {
    rlc wtlam $tout apat
    $cpu cp -attn \
            -wibr rpa.cs1 [ibd_rhrp::cs1_func $ibd_rhrp::RFUNC_DONE]
  }

  $cpu wtcpu -reset $tout

  # determine regs after cleanup
  set cs1msk [rutil::com16 [regbld ibd_rhrp::CS1 {func -1}]]
  set fcs2   [expr {$defs(o.cs2) & 0x00ff}]; # cs1.tre clears upper byte !
  set fer1   0
  if {!$defs(do.rint)} {        # no reinterrupt, ata clear by cpu
    set fcs1   [expr {$defs(o.cs1) & ~[regbld ibd_rhrp::CS1 sc tre {func -1}] }]
    set fds    [expr {$defs(o.ds) & ~[regbld ibd_rhrp::DS ata erp] }]
    set fas    0
  } else {                      # reinterrupt, ata still pending
    set fcs1   [expr {$defs(o.cs1) & ~[regbld ibd_rhrp::CS1 tre {func -1}] }]
    set fds    [expr {$defs(o.ds) & ~[regbld ibd_rhrp::DS erp] }]
    set fas    $defs(o.as)
  }
  $cpu cp -rpc   -edata $sym(stop) \
          -rsp   -edata $sym(stack) \
          -wal   $sym(icnt) \
          -rmi   -edata $defs(o.icnt) \
          -rmi    \
          -rmi   -edata $defs(o.cs1)  \
          -rmi   -edata $defs(o.cs2)  \
          -rmi   -edata $defs(o.er1)  \
          -rmi   -edata $defs(o.ds)   \
          -rmi   -edata $defs(o.as)   \
          -rmi   -edata $defs(o.itim) \
          -rmi   -edata $fcs1 $cs1msk \
          -rmi   -edata $fcs2 \
          -rmi   -edata $fer1 \
          -rmi   -edata $fds  \
          -rmi   -edata $fas

  if {!$defs(do.rint)} return "";

  $cpu cp -start

  $cpu wtcpu -reset $tout

  # determine regs after cleanup
  set fcs1   [expr {$defs(or.cs1) & ~[regbld ibd_rhrp::CS1 sc] }]
  set fcs2   $defs(or.cs2)
  set fer1   0
  set fds    [expr {$defs(or.ds) & ~[regbld ibd_rhrp::DS ata] }]
  set fas    0

  $cpu cp -rpc   -edata $sym(stop) \
          -rsp   -edata $sym(stack) \
          -wal   $sym(icnt) \
          -rmi   -edata $defs(or.icnt) \
          -rmi    \
          -rmi   -edata $defs(or.cs1) \
          -rmi   -edata $defs(or.cs2) \
          -rmi   -edata $defs(or.er1) \
          -rmi   -edata $defs(or.ds)  \
          -rmi   -edata $defs(or.as)  \
          -rmi   \
          -rmi   -edata $fcs1 \
          -rmi   -edata $fcs2 \
          -rmi   -edata $fer1 \
          -rmi   -edata $fds  \
          -rmi   -edata $fas  

  return ""
}

# discard pending attn to be on save side
rlc wtlam 0.
rlc exec -attn

# -- Section A ---------------------------------------------------------------
rlc log "  A -- function basics ----------------------------------------------"
rlc log "  A1: test rdy and ie logic ---------------------------------"
rlc log "    A1.1 set cs1.ie=1 alone -> no interrupt ------------"

# Note: no interrupt, so ie stays on !
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie] \
            o.icnt  0 \
            o.cs1   [regbld ibd_rhrp::CS1 dva rdy ie] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS mol dpr dry] \
            o.as    0 \
            o.itim  0              
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A1.2 set cs1.ie=1 with rdy=1 -> software interrupt -"

# Note: interrupt, so ie switched off again !
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 rdy ie] \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 dva rdy] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS mol dpr dry] \
            o.as    0 \
            o.itim  1
         ]

tmpproc_dotest $cpu sym $opts

rlc log "  A2: test state functions: iff no, as yes ------------------"
rlc log "    A2.1 noop function ---------------------------------"

set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie go] \
            o.cs1   [regbld ibd_rhrp::CS1 ie dva rdy] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS mol dpr dry] \
            o.as    0 \
            o.itim  0
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A2.2 pack acknowledge function (sets ds.vv=1) ------"

set rbcs1func [list func $ibd_rhrp::FUNC_PACK]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 $rbcs1func ie go] \
            o.cs1   [regbld ibd_rhrp::CS1 dva rdy ie $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS mol dpr dry vv] \
            o.as    0 \
            o.itim  0
         ]
tmpproc_dotest $cpu sym $opts

rlc log "  A3: test seek type functions: iff no, as yes --------------"

rlc log "    A3.1 seek function, ie=0, valid da,dc---------------"

# check that cs1.sc=1, ds.ata=1, and as.u0=1
set rbcs1func [list func $ibd_rhrp::FUNC_SEEK]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 $rbcs1func go] \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS ata mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  0
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A3.2 seek function, valid da,dc, idly=0 ------------"

# check re-interrupt too
set rbcs1func [list func $ibd_rhrp::FUNC_SEEK]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            i.dc    814 \
            i.idly  0 \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS ata mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  1 \
            do.rint 1 \
            or.icnt 2 \
            or.cs1  [regbld ibd_rhrp::CS1 sc dva rdy] \
            or.cs2  [regbld ibd_rhrp::CS2 or ir] \
            or.er1  0 \
            or.ds   [regbld ibd_rhrp::DS ata mol dpr dry vv] \
            or.as   [regbld ibd_rhrp::AS u0]            
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A3.3 seek function, invalid dc ---------------------"

set rbcs1func [list func $ibd_rhrp::FUNC_SEEK]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            i.dc    815 \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   [regbld ibd_rhrp::ER1 iae] \
            o.ds    [regbld ibd_rhrp::DS ata erp mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  1 
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A3.4 search function, valid da,dc, idly=0 ----------"

set rbcs1func [list func $ibd_rhrp::FUNC_SEAR]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            i.dc    0 \
            i.da    [regbld ibd_rhrp::DA {ta 0} {sa 21}] \
            i.idly  0 \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS ata mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  1
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A3.5 search function, valid da,dc, idly=2 ----------"

set rbcs1func [list func $ibd_rhrp::FUNC_SEAR]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            i.dc    0 \
            i.da    [regbld ibd_rhrp::DA {ta 0} {sa 21}] \
            i.idly  2 \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS ata mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  3
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A3.5 search function, valid da,dc, idly=8 ----------"

set rbcs1func [list func $ibd_rhrp::FUNC_SEAR]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            i.dc    0 \
            i.da    [regbld ibd_rhrp::DA {ta 0} {sa 21}] \
            i.idly  8 \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   0 \
            o.ds    [regbld ibd_rhrp::DS ata mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  9
         ]
tmpproc_dotest $cpu sym $opts

rlc log "    A3.5 search function, invalid sa, idly=8 -----------"
# Note: idly is 8, but error ata's come immediately !!

set rbcs1func [list func $ibd_rhrp::FUNC_SEAR]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            i.dc    0 \
            i.da    [regbld ibd_rhrp::DA {ta 0} {sa 22}] \
            i.idly  8 \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 sc dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.er1   [regbld ibd_rhrp::ER1 iae] \
            o.ds    [regbld ibd_rhrp::DS ata erp mol dpr dry vv] \
            o.as    [regbld ibd_rhrp::AS u0] \
            o.itim  1
         ]
tmpproc_dotest $cpu sym $opts

rlc log "  A4: test transfer functions: iff yes, as no ---------------"
rlc log "    A4.1 read function, valid da,dc --------------------"

set rbcs1func [list func $ibd_rhrp::FUNC_READ]
set opts [list \
            i.cs1   [regbld ibd_rhrp::CS1 ie $rbcs1func go] \
            o.icnt  1 \
            o.cs1   [regbld ibd_rhrp::CS1 dva rdy $rbcs1func] \
            o.cs2   [regbld ibd_rhrp::CS2 or ir] \
            o.ds    [regbld ibd_rhrp::DS mol dpr dry vv] \
            do.lam  1
         ]
tmpproc_dotest $cpu sym $opts

