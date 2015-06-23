; basic test of OTIR block-transfer instruction
;
; initializes a memory region and then transfers that region
; to an accumulator

    .module otir

;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
_sim_ctl_port	=	0x0080
_msg_port	=	0x0081
_timeout_port	=	0x0082
_max_timeout_low	=	0x0083
_max_timeout_high	=	0x0084
_intr_cntdwn	=	0x0090
_cksum_value    =       0x0091
_cksum_accum    =       0x0092
_inc_on_read    =       0x0093

    .area INIT (ABS)
    .org  0

    jp      init


init:
	ld	b, #0		; keep track of # of jumps
	jr      target1

	;; test unqualified jumps
target6:
	inc	b
	ld	a, #6
	cp	b
	
	jp	z, section2
	jp	test_fail
	
target2:
	inc	b
	jr      target3
	
target5:
	inc	b
	jr      target6
	
target4:
	inc	b
	jr      target5
	
target3:
	inc	b
	jr      target4
	
target1:
	inc	b
	jr	target2

	;; tests C/NC jumps
section2:
	scf

	jr	nc, section2_fail
	jr	c, target7
	
target7:
	jr	c, target8
	jr	nc, section2_fail

target9:
	jr	nc, section3
section2_fail:	
	jp	test_fail
	
target8:
	ccf

	jr	c, test_fail
	jr	nc, target9

	;; tests Z/NZ jumps
section3:
	ld	a, #2
	ld	b, #1
	sub     b

	jr	z, section3_fail
	jr	nz, target10

section3_fail:	
	jp	test_fail

target11:
	sub	b
	jr	nz, section3_fail
	jr	z, target12
	jr	section3_fail
	
target10:
	jr	nz, target11
	jp	test_fail

target12:
	jp	test_pass

test_pass:	
    ;; finish simulation with test passed
    ld      a, #1
    out     (_sim_ctl_port), a
    ret

test_fail:
    ld      a, #2
    out     (_sim_ctl_port), a
    ret

reset_timeout:
    ld      a, #2
    out     (_timeout_port), a
    ret
    
    .org    0x8000

dbuf:
    .ds     256

