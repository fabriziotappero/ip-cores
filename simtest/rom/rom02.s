;
; rom02.s -- terminal output, polled
;

	.set	tba,0xF0300000	; terminal base address

	add	$8,$0,tba	; set terminal base address
L1:
	add	$10,$0,'a'	; set char to ASCII 'a'
L2:
	ldw	$9,$8,8		; load transmitter status word into $9
	and	$9,$9,1		; extract LSB - 'transmitter ready'
	beq	$9,$0,L2	; loop while not ready
	stw	$10,$8,12	; load char into transmitter data register
	add	$10,$10,1	; next char
	sub	$9,$10,'z'+1	; check if above 'z'
	bne	$9,$0,L2	; no - loop
	j	L1		; else reset to 'a'
