;
; copy.s -- copy a program from ROM to RAM before executing it
;

	.set	dst,0xC0000000		; destination is start of RAM
	.set	len,0x0000FF00		; number of bytes to be copied

	.set	PSW,0			; reg # of PSW

reset:
	j	start

interrupt:
	j	interrupt		; we better have no interrupts

userMiss:
	j	userMiss		; and no user TLB misses

start:
	mvts	$0,PSW			; disable interrupts and user mode
	add	$8,$0,src
	add	$9,$0,dst
	add	$10,$9,len
loop:
	ldw	$11,$8,0		; copy word
	stw	$11,$9,0
	add	$8,$8,4			; bump pointers
	add	$9,$9,4
	bltu	$9,$10,loop		; more?
	add	$8,$0,dst		; start execution
	jr	$8

	; the program to be copied follows immediately
src:
