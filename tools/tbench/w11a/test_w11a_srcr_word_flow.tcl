# $Id: test_w11a_srcr_word_flow.tcl 683 2015-05-17 21:54:35Z mueller $
#
# Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# License disclaimer see LICENSE_gpl_v2.txt in $RETROBASE directory
#
# Revision History:
# Date         Rev Version  Comment
# 2014-07-27   575   1.0.2  drop tout value from asmwait, reply on asmwait_tout
# 2014-03-01   552   1.0.1  check sp
# 2013-03-31   502   1.0    Initial version
#
# Test srcr flow with mov ...,rx instructions for word access
#

# ----------------------------------------------------------------------------
rlc log "test_w11a_srcr_word_flow: test srcr flow for word with mov ...,rx"
rlc log "  r0 (mode=0)"

# code register pre/post conditions beyond defaults
#   r0   01234   -> ..same
#   r1           -> 01234
#   r2           -> #stack
#   r3           -> #start
$cpu ldasm -lst lst -sym sym {
        . = 1000
stack:
start:  mov     r0,r1
        mov     sp,r2
        mov     pc,r3
lpc:    halt
stop:
}

rw11::asmrun  $cpu sym [list r0 01234]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 01234 \
                          r1 01234 \
                          r2 $sym(stack) \
                          r3 $sym(lpc) \
                          r4 0 \
                          r5 0 \
                          sp $sym(stack) ]

# ----------------------------------------------------------------------------
rlc log "  (r0),(r0)+,-(r0) (mode=1,2,4)"

# code register pre/post conditions beyond defaults
#   r0   #data   -> ..same
#   r1           -> 01001
#   r2           -> 01001
#   r3           -> 01002
#   r4           -> 01002
#   r5           -> 01001
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  mov     (r0),r1
        mov     (r0)+,r2
        mov     (r0)+,r3
        mov     -(r0),r4
        mov     -(r0),r5
        halt
stop:
;
data:   .word   1001
        .word   1002
}

rw11::asmrun  $cpu sym [list r0 $sym(data)]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 $sym(data) \
                         r1 001001 \
                         r2 001001 \
                         r3 001002 \
                         r4 001002 \
                         r5 001001 ]

# ----------------------------------------------------------------------------
rlc log "  @(r0)+,@-(r0)  (mode=3,5)"

# code register pre/post conditions beyond defaults
#   r0   #pdata  -> ..same
#   r1           -> 02001
#   r2           -> 02002
#   r3           -> #pdata+4
#   r4           -> 02002
#   r5           -> 02001
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  mov     @(r0)+,r1
        mov     @(r0)+,r2
        mov     r0,r3
        mov     @-(r0),r4
        mov     @-(r0),r5
        halt
stop:
;
pdata:  .word   data0
        .word   data1
data0:  .word   2001
        .word   0
data1:  .word   2002
}

rw11::asmrun  $cpu sym [list r0 $sym(pdata)]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 $sym(pdata) \
                         r1 002001 \
                         r2 002002 \
                         r3 [expr {$sym(pdata)+4}] \
                         r4 002002 \
                         r5 002001 ]

# ----------------------------------------------------------------------------
rlc log "  nn(r0),@nn(r0)  (mode=6,7)"

# code register pre/post conditions beyond defaults
#   r0   #data   -> ..same
#   r1           -> 03001
#   r2           -> 03002
#   r3           -> 03003
#   r4           -> 03004
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  mov     2(r0),r1
        mov     @4(r0),r2
        mov     6(r0),r3
        mov     @10(r0),r4
        halt
stop:
;
data:   .word   177777
        .word   003001
        .word   data0
        .word   003003
        .word   data1

data0:  .word   003002
data1:  .word   003004
}

rw11::asmrun  $cpu sym [list r0 $sym(data)]
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 $sym(data) \
                         r1 003001 \
                         r2 003002 \
                         r3 003003 \
                         r4 003004 \
                         r5 0 ]

# ----------------------------------------------------------------------------
rlc log "  #nn,@#nn,var,@var  (mode=27,37,67,77)"

# code register pre/post conditions beyond defaults
#   r1           -> 04001
#   r2           -> 04002
#   r3           -> 04003
#   r4           -> 04004
$cpu ldasm -lst lst -sym sym {
        . = 1000
start:  mov     #004001,r1
        mov     @#data2,r2
        mov     data3,r3
        mov     @pdata4,r4
        halt
stop:
;
pdata4: .word   data4

data2:  .word   004002
data3:  .word   004003
data4:  .word   004004
}

rw11::asmrun  $cpu sym {}
rw11::asmwait $cpu sym 
rw11::asmtreg $cpu [list r0 0 \
                         r1 004001 \
                         r2 004002 \
                         r3 004003 \
                         r4 004004 \
                         r5 0 ]
