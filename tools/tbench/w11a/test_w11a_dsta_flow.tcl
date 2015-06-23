# $Id: test_w11a_dsta_flow.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-07-27   575   1.0.2  drop tout value from asmwait, reply on asmwait_tout
# 2014-03-01   552   1.0.1  use stack:; check sp;
# 2013-03-31   502   1.0    Initial version
#
# Test dsta flow with jsr pc,... instructions
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_dsta_flow: test dsta flow with jsr pc,..."
rlc log "  (r0),(r0)+,@(r0)+,-(r0),@-(r0) (mode=1,2,3,4,5)"

# code register pre/post conditions beyond defaults
#   r0   #sub00   -> ..same
#   r1   #sub10   -> #sub10+2
#   r2   #psub2   -> #psub2+4
#   r3   #sub30+2 -> #sub30
#   r4   #psub4e  -> #psub4
#   r5   #data    -> #data+7*2*2
$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  jsr     pc,(r0)
100$:   jsr     pc,(r1)+
110$:   jsr     pc,@(r2)+
120$:   jsr     pc,@(r2)+
121$:   jsr     pc,-(r3)
130$:   jsr     pc,@-(r4)
140$:   jsr     pc,@-(r4)
141$:   halt
stop:
;
psub2:  .word   sub20, sub21
psub4:  .word   sub41, sub40
psub4e:
sub00:  mov     #100,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub10:  mov     #110,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub20:  mov     #120,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub21:  mov     #121,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub30:  mov     #130,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub40:  mov     #140,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub41:  mov     #141,(r5)+
        mov     (sp),(r5)+
        rts     pc
data:   .blkw   2*7.
        .word   177777
}

rw11::asmrun  $cpu sym [list r0 $sym(sub00) \
                             r1 $sym(sub10) \
                             r2 $sym(psub2) \
                             r3 [expr {$sym(sub30)+2}] \
                             r4 $sym(psub4e) \
                             r5 $sym(data) ]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 $sym(sub00) \
                         r1 [expr {$sym(sub10)+2}] \
                         r2 [expr {$sym(psub2)+4}]  \
                         r3 $sym(sub30) \
                         r4 $sym(psub4) \
                         r5 [expr {$sym(data) + 7*2*2}] \
                         sp $sym(stack) ]
rw11::asmtmem $cpu $sym(data) [list \
                                  0100 $sym(start:100$) \
                                  0110 $sym(start:110$) \
                                  0120 $sym(start:120$) \
                                  0121 $sym(start:121$) \
                                  0130 $sym(start:130$) \
                                  0140 $sym(start:140$) \
                                  0141 $sym(start:141$) \
                                  0177777 ]

# ----------------------------------------------------------------------------
rlc log "  nn(r0),@nn(r0),var,@var,@#var (mode=6,7,67,77,37)"

# code register pre/post conditions beyond defaults
#   r0   #sub00-020  -> ..same
#   r1   #psub10-040 -> ..same
#   r5   #data       -> #data+5*2*2
$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  jsr     pc,20(r0)
1100$:  jsr     pc,@40(r1)
1110$:  jsr     pc,sub20
1120$:  jsr     pc,@psub30
1130$:  jsr     pc,@#sub40
1140$:  halt
stop:
;
psub10: .word   sub10
psub30: .word   sub30
sub00:  mov     #1100,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub10:  mov     #1110,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub20:  mov     #1120,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub30:  mov     #1130,(r5)+
        mov     (sp),(r5)+
        rts     pc
sub40:  mov     #1140,(r5)+
        mov     (sp),(r5)+
        rts     pc
data:   .blkw   2*5.
        .word   177777
}

rw11::asmrun  $cpu sym [list r0 [expr {$sym(sub00)-020}] \
                             r1 [expr {$sym(psub10)-040}] \
                             r5 $sym(data) ]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 [expr {$sym(sub00)-020}] \
                         r1 [expr {$sym(psub10)-040}] \
                         r2 0 \
                         r3 0 \
                         r4 0 \
                         r5 [expr {$sym(data) + 5*2*2}] \
                         sp $sym(stack) ]
rw11::asmtmem $cpu $sym(data) [list \
                                  01100 $sym(start:1100$) \
                                  01110 $sym(start:1110$) \
                                  01120 $sym(start:1120$) \
                                  01130 $sym(start:1130$) \
                                  01140 $sym(start:1140$) \
                                  0177777 ]
