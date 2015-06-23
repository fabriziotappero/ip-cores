;
; rom08.s -- string output with delay loop
;

; $8  I/O base address
; $9  temporary value
; $10 character
; $11 pointer to string
; $31 return address

	.set	oba,0xF0300000

	add	$8,$0,oba
	add	$11,$0,hello
loop:
	ldbu	$10,$11,0
stop:
	beq	$10,$0,stop
	jal	out
	add	$11,$11,1
	jal	delay
	j	loop

out:
	stw	$10,$8,12
	jr	$31

delay:
	add	$9,$0,0x00200000
del1:
	sub	$9,$9,1
	bne	$9,$0,del1
	jr	$31

hello:
	.byte	"Hello, world!", 0x0D, 0x0A, 0
