# $Id: test_w11a_dstw_word_flow.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-07-27   575   1.0.2  drop tout value from asmwait, reply on asmwait_tout
# 2014-03-01   552   1.0.1  check that unused regs stay 0
# 2013-03-31   502   1.0    Initial version
#
# Test dstw flow with mov #nnn,... instructions for word access
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_dstw_word_flow: test dstw flow for word with mov #nnn,..."
rlc log "  r0,(r0),(r0)+,@(r0)+,-(r0),@-(r0) (mode=0,1,2,3,4,5)"

# code register pre/post conditions beyond defaults
#   r0           -> 0100
#   r1   #data1  -> ..same
#   r2   #data2  -> #data2+4
#   r3   #pdata3 -> #pdata3+4
#   r4   #data4e -> #data4e-4
#   r5   #pdat5e -> #pdat5e-4
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  mov     #100,r0
        mov     #110,(r1)
        mov     #120,(r2)+
        mov     #121,(r2)+
        mov     #130,@(r3)+
        mov     #131,@(r3)+
        mov     #141,-(r4)
        mov     #140,-(r4)
        mov     #151,@-(r5)
        mov     #150,@-(r5)
        halt
stop:
;
data1:  .word   0
data2:  .word   0,0
data3:  .word   0,0
data4:  .word   0,0
data4e:
data5:  .word   0,0
data5e:
pdata3: .word   data3,data3+2
pdata5: .word   data5,data5+2
pdat5e:
}

rw11::asmrun  $cpu sym [list r1 $sym(data1) \
                             r2 $sym(data2) \
                             r3 $sym(pdata3) \
                             r4 $sym(data4e) \
                             r5 $sym(pdat5e) ]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 0100 \
                         r1 $sym(data1) \
                         r2 [expr {$sym(data2)  + 4}] \
                         r3 [expr {$sym(pdata3) + 4}] \
                         r4 [expr {$sym(data4e) - 4}] \
                         r5 [expr {$sym(pdat5e) - 4}] ]
rw11::asmtmem $cpu $sym(data1) {0110 0120 0121 0130 0131 0140 0141 0150 0151}

# ----------------------------------------------------------------------------
rlc log "  nn(r0),@nn(r0),var,@var,@#var (mode=6,7,67,77,37)"

# code register pre/post conditions beyond defaults
#   r0   #data0-020  -> ..same
#   r1   #pdata0-040 -> ..same
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  mov     #200,20(r0)
        mov     #210,@40(r1)
        mov     #220,data2
        mov     #230,@pdata3
        mov     #240,@#data4
        halt
stop:
;
data0:  .word   0
data1:  .word   0
data2:  .word   0
data3:  .word   0
data4:  .word   0
data4e:
pdata1: .word   data1
pdata3: .word   data3
}

rw11::asmrun  $cpu sym [list r0 [expr {$sym(data0)-020}] \
                             r1 [expr {$sym(pdata1)-040}]  ]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 [expr {$sym(data0)-020}] \
                         r1 [expr {$sym(pdata1)-040}] \
                         r2 0 \
                         r3 0 \
                         r4 0 \
                         r5 0 ]
rw11::asmtmem $cpu $sym(data0) {0200 0210 0220 0230 0240}
