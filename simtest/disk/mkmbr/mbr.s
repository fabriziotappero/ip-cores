;
; mbr.s -- the master boot record
;

; $8  I/O base address
; $9  temporary value
; $10 character
; $11 pointer to string
; $29 stack pointer
; $31 return address

	.set	tba,0xF0300000	; terminal base address

start:
	sub	$29,$29,4	; save return register
	stw	$31,$29,0
	add	$8,$0,tba	; set I/O base address
	add	$11,$0,msg	; pointer to string
loop:
	ldbu	$10,$11,0	; get char
	beq	$10,$0,stop	; null - finished
	jal	out		; output char
	add	$11,$11,1	; bump pointer
	j	loop		; next char
stop:
	ldw	$31,$29,0	; restore return register
	add	$29,$29,4
	jr	$31		; return

out:
	ldw	$9,$8,8		; get status
	and	$9,$9,1		; xmtr ready?
	beq	$9,$0,out	; no - wait
	stw	$10,$8,12	; send char
	jr	$31		; return

msg:
	.byte	0x0D, 0x0A
	.byte	"Error: This is the default MBR, "
	.byte	"which cannot load anything."
	.byte	0x0D, 0x0A
	.byte	"Please replace the disk, or "
	.byte	"write an operating system onto it."
	.byte	0x0D, 0x0A
	.byte	0x0D, 0x0A, 0

	.locate	512-2
sign:
	.byte	0x55, 0xAA
