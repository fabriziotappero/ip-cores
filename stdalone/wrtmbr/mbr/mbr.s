;
; mbr.s -- the master boot record
;

	.set	tba,0xF0300000		; terminal base address
	.set	tos,0xC0011000		; top of stack

start:
	add	$29,$0,tos		; set stackpointer
	jal	msgout			; output message
stop:
	j	stop			; halt by looping

msgout:
	sub	$29,$29,8		; allocate stack frame
	stw	$31,$29,0		; save return register
	stw	$16,$29,4		; save local variable
	add	$16,$0,msg		; pointer to string
loop:
	ldbu	$4,$16,0		; get char
	beq	$4,$0,exit		; null - finished
	jal	out			; output char
	add	$16,$16,1		; bump pointer
	j	loop			; next char
exit:
	ldw	$31,$29,0		; restore return register
	ldw	$16,$29,4		; restore local variable
	add	$29,$29,8		; release stack frame
	jr	$31			; return

out:
	add	$8,$0,tba		; set I/O base address
out1:
	ldw	$9,$8,8			; get xmtr status
	and	$9,$9,1			; xmtr ready?
	beq	$9,$0,out1		; no - wait
	stw	$4,$8,12		; send char
	jr	$31			; return

msg:
	.byte	0x0D, 0x0A
	.byte	"Error: This is the default MBR, "
	.byte	"which cannot load anything."
	.byte	0x0D, 0x0A
	.byte	"Please replace the disk, or "
	.byte	"write an operating system onto it."
	.byte	0x0D, 0x0A
	.byte	"Execution halted."
	.byte	0x0D, 0x0A
	.byte	0x0D, 0x0A, 0

	.locate	512-2
sign:
	.byte	0x55, 0xAA
