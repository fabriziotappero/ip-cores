;
; echo.s -- test the serial interface
;

	.set	sba,0xF0300000	; serial base address

	add	$8,$0,sba	; set serial base address
L1:
	ldw	$9,$8,0		; load receiver status into $9
	and	$9,$9,1		; check receiver ready
	beq	$9,$0,L1	; loop while not ready
	ldw	$10,$8,4	; load receiver data into $10
	add	$10,$10,0x5C
	and	$10,$10,0xFF
L2:
	ldw	$9,$8,8		; load transmitter status into $9
	and	$9,$9,1		; check transmitter ready
	beq	$9,$0,L2	; loop while not ready
	stw	$10,$8,12	; load char into transmitter data
	j	L1		; all over again
