	.data
	
	.align	2
	.text
_start: /*Start of Program*/
	bra	init
init:	/* Allocate Stack, Init Uarts, Say Hello */
	movel	#0x0000400, %a7
	bsr	init_uart
	bsr	sign_on
	bra	main
			
init_uart: /* Initialize Uarts */
	
	/* UART A BRG */
	movel	#0xFF010008, %a0
	moveb	#0x01, %a0@
	movel	#0xFF01000C, %a0
	moveb	#0x01, %a0@
	
	/* UART B BRG */
	movel	#0xFF020008, %a0
	moveb	#0x01, %a0@
	movel	#0xFF02000C, %a0
	moveb	#0x01, %a0@

	rts
	
stat_a:	/* Check UART A readable status */
	movel	#0xFF010004, %a0
	moveb	%a0@, %d0
	andib	#1, %d0
	rts
	
read_a: /* Read a byte from UART A */
	bsr	stat_a
	beq	read_a
	movel	#0xFF010000, %a0
	moveb	%a0@, %d1
	rts
	
write_a:/* Write a byte to UART A */
	movel	#0xFF010004, %a0
write_a_loop:		
	moveb	%a0@, %d0
	andib	#2, %d0
	bne	write_a_loop
	movel	#0xFF010000, %a0
	moveb	%d1, %a0@
	rts
		
stat_b:	/* Check UART B readable status */
	movel	#0xFF020004, %a0
	moveb	%a0@, %d0
	andib	#1, %d0
	rts
	
read_b: /* Read a byte from UART B */
	bsr	stat_b
	beq	read_b
	movel	#0xFF020000, %a0
	moveb	%a0@, %d1
	rts
		
write_b:/* Write a byte to UART B */
	movel	#0xFF020004, %a0
write_b_loop:		
	moveb	%a0@, %d0
	andib	#2, %d0
	beq	write_b_loop
	movel	#0xFF020000, %a0
	moveb	%d1, %a0@
	rts
			
sign_on:/* Say K68 on Both UARTS */
	moveb	#0x4B, %d1
	bsr	write_a
	bsr	write_b
	moveb	#0x36, %d1
	bsr	write_a
	bsr	write_b
	moveb	#0x68, %d1
	bsr	write_a
	bsr	write_b
	moveb	#0x0D, %d1
	bsr	write_a
	bsr	write_b
	rts

main:	/* Main Program Loop */

	/* Check for Data on A */
	bsr	stat_a
	beq	do_a
	bsr	stat_b
	beq	do_b
	bra	main

do_a:	/* Encrypt A and Write to B */
	bsr	read_a
	bsr	encrypt
	bsr	write_b
	rts	
		
do_b:	/* Decrypt B and Write to A */
	bsr	read_b
	bsr	decrypt
	bsr	write_a
	rts
	
decrypt:/* Decrypt Data using DES */
	rts

encrypt:/* Encrypt Data using DES */
	rts

pushkey:/* Initialize DES Private Key */
	rts	
	.end	
