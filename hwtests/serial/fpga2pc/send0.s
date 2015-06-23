;
; send.s -- send stream of bytes
;

; $8  serial base address
; $9  temporary value
; $10 character
; $11 counter
; $31 return address

	.set	tba,0xF0300000

	add	$8,$0,tba
	add	$11,$0,0
loop:
	add	$10,$11,0
	and	$10,$10,0xFF
	jal	out
	add	$11,$11,1
	j	loop

out:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out
	stw	$10,$8,12
	jr	$31
