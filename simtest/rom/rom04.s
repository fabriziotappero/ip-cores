;
; rom04.s -- Hello, world!
;

; $8  I/O base address
; $9  temporary value
; $10 character
; $11 pointer to string
; $31 return address

	.set	tba,0xF0300000

	add	$8,$0,tba
	add	$11,$0,hello
loop:
	ldbu	$10,$11,0
stop:
	beq	$10,$0,stop
	jal	out
	add	$11,$11,1
	j	loop

out:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out
	stw	$10,$8,12
	jr	$31

hello:
	.byte	"Hello, world!", 0x0D, 0x0A, 0
