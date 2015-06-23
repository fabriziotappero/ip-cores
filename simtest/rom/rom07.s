;
; rom07.s -- string output to output device
;

; $8  I/O base address
; $9  temporary value
; $10 character
; $11 pointer to string
; $31 return address

	.set	oba,0xFF000000

	add	$8,$0,oba
	add	$11,$0,hello
loop:
	ldbu	$10,$11,0
stop:
	beq	$10,$0,stop
	jal	out
	add	$11,$11,1
	j	loop

out:
	stw	$10,$8,0
	jr	$31

hello:
	.byte	"Hello, world!", 0x0D, 0x0A, 0
