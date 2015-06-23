;
; receive.s -- receive & check a stream of bytes
;

; $8  serial base address
; $9  temporary value
; $10 current character
; $11 previous character
; $12 counter
; $13 error
; $31 return address

	.set	tba,0xF0300000

	add	$8,$0,tba
	add	$12,$0,100000
	add	$13,$0,0
	jal	in
	add	$11,$10,0
	sub	$12,$12,1
loop:
	add	$11,$11,1
	and	$11,$11,0xFF
	jal	in
	beq	$10,$11,chrok
	add	$13,$13,1
chrok:
	sub	$12,$12,1
	bne	$12,$0,loop
	bne	$13,$0,error
	add	$13,$0,'.'
	jal	out
	j	halt
error:
	add	$13,$0,'?'
	jal	out
	j	halt

halt:
	j	halt

in:
	ldw	$9,$8,0
	and	$9,$9,1
	beq	$9,$0,in
	ldw	$10,$8,4
	jr	$31

out:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out
	stw	$13,$8,12
	jr	$31
