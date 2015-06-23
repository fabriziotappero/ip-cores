;
; rom09.s -- string output with timing loop
;

; $8  I/O base address
; $9  temporary value
; $10 character
; $11 pointer to string
; $12 timer base address
; $13 timer value
; $31 return address

	.set	oba,0xF0300000
	.set	tba,0xF0000000

	add	$8,$0,oba
	add	$12,$0,tba
	add	$11,$0,hello
loop:
	ldbu	$10,$11,0
stop:
	beq	$10,$0,stop
	jal	out
	add	$11,$11,1
	jal	timing
	j	loop

out:
	stw	$10,$8,12
	jr	$31

timing:
	ldw	$13,$12,8
	sub	$9,$13,0x03C00000
tim1:
	ldw	$13,$12,8
	bgtu	$13,$9,tim1
	jr	$31

hello:
	.byte	"Hello, world!", 0x0D, 0x0A, 0
