;
; serial.s -- the serial line interface
;

;***************************************************************

	.set	ser0base,0xF0300000	; serial line 0 base address
	.set	ser1base,0xF0301000	; serial line 1 base address

	.export	serinit			; initialize serial interface

	.export	ser0inchk		; line 0 input check
	.export	ser0in			; line 0 input
	.export	ser0outchk		; line 0 output check
	.export	ser0out			; line 0 output

	.export	ser1inchk		; line 1 input check
	.export	ser1in			; line 1 input
	.export	ser1outchk		; line 1 output check
	.export	ser1out			; line 1 output

;***************************************************************

	.code
	.align	4

serinit:
	jr	$31

;***************************************************************

	.code
	.align	4

ser0inchk:
	add	$8,$0,ser0base
	ldw	$2,$8,0
	and	$2,$2,1
	jr	$31

ser0in:
	add	$8,$0,ser0base
ser0in1:
	ldw	$9,$8,0
	and	$9,$9,1
	beq	$9,$0,ser0in1
	ldw	$2,$8,4
	jr	$31

ser0outchk:
	add	$8,$0,ser0base
	ldw	$2,$8,8
	and	$2,$2,1
	jr	$31

ser0out:
	add	$8,$0,ser0base
ser0out1:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,ser0out1
	stw	$4,$8,12
	jr	$31

;***************************************************************

	.code
	.align	4

ser1inchk:
	add	$8,$0,ser1base
	ldw	$2,$8,0
	and	$2,$2,1
	jr	$31

ser1in:
	add	$8,$0,ser1base
ser1in1:
	ldw	$9,$8,0
	and	$9,$9,1
	beq	$9,$0,ser1in1
	ldw	$2,$8,4
	jr	$31

ser1outchk:
	add	$8,$0,ser1base
	ldw	$2,$8,8
	and	$2,$2,1
	jr	$31

ser1out:
	add	$8,$0,ser1base
ser1out1:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,ser1out1
	stw	$4,$8,12
	jr	$31
