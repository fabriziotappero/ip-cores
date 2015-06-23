;
; hello.s -- Hello, world!
;

	.set	tba,0xF0300000		; terminal base address
	.set	tos,0xC0020000		; top of stack

	; get some addresses listed in the load map
	.export	start
	.export	main
	.export	out
	.export	hello

	; minimal execution environment
start:
	add	$29,$0,tos		; setup stack
	jal	main			; do useful work
start1:
	j	start1			; halt by looping

	; main program
main:
	sub	$29,$29,8		; create stack frame
	stw	$31,$29,0		; save return register
	stw	$16,$29,4		; save register variable
	add	$16,$0,hello		; pointer to string
loop:
	ldbu	$4,$16,0		; get char
	beq	$4,$0,stop		; null - finished
	jal	out			; output char
	add	$16,$16,1		; bump pointer
	j	loop			; next char
stop:
	ldw	$31,$29,0		; restore return register
	ldw	$16,$29,4		; restore register variable
	add	$29,$29,8		; release stack frame
	jr	$31			; return

	; output a character to the terminal
out:
	add	$8,$0,tba		; set I/O base address
out1:
	ldw	$9,$8,8			; get xmtr status
	and	$9,$9,1			; xmtr ready?
	beq	$9,$0,out1		; no - wait
	stw	$4,$8,12		; send char
	jr	$31			; return

	; a very famous little string...
hello:
	.byte	0x0D, 0x0A
	.byte	"Hello, world!"
	.byte	0x0D, 0x0A
	.byte	0x0D, 0x0A, 0
