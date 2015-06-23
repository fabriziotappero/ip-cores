	.data
	
	.align	2
	.text

_start: /*Start of Program*/
	bra	init
	nop
	nop
	
write_a:
	movel	#0xFF010000, %a0
	bra	w_loop
	nop
	nop
write_b:
	movel	#0xFF020000, %a0
	bra	w_loop
	nop
	nop
w_loop:
	movew	%a0@, %d7
	andiw	#0x200, %d7
	bne	w_loop
	nop
	nop
	moveb	%d0, %a0@
	nop
	nop
	rts
	nop
	nop

read_a:
	movel	#0xFF010000, %a0
	bra	r_loop
	nop
	nop
read_b:
	movel	#0xFF020000, %a0
	bra	r_loop
	nop
	nop
r_loop:
	movew	%a0@, %d7
	moveb	%d7, %d0
	andiw	#0x100, %d7
	bne	r_loop
	nop
	nop
	rts
	nop
	nop

sign_on:/* Say K68 on Both UARTS */
	moveb	#0x4B, %d0
	bsr	write_a
	nop
	nop
	moveb	#0x36, %d0
	bsr	write_a
	nop
	nop
	moveb	#0x38, %d0
	bsr	write_a
	nop
	nop
	bsr	crlf
	nop
	nop
	rts
	nop
	nop

sign_ok:/* Say K68 on Both UARTS */
	moveb	#0x4F, %d0
	bsr	write_a
	nop
	nop
	moveb	#0x4B, %d0
	bsr	write_a
	nop
	nop
	bsr	crlf
	nop
	nop
	rts
	nop
	nop
	
crlf:
	moveb	#0x0D, %d0
	bsr	w_loop
	nop
	nop
	rts
	nop
	nop
	
init:	/* Allocate Stack, Init Uarts, Say Hello */
	movel	#0x80000400, %a7
	bsr	sign_on
	nop
	nop
	bsr	sign_ok
	nop
	nop
	bra	main
	nop
	nop

code:
	movew	#0x7F7F, %d1
	eorw	%d1, %d0
	nop
	nop
	rts
	nop
	nop
			
main:
	bsr	read_a
	nop
	nop
	bsr	code
	nop
	nop
	bsr	write_a
	nop
	nop
	bsr	crlf
	nop
	nop
	bra	main
	nop
	nop
