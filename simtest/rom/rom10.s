;
; rom10.s -- output to console using every possible attribute
;

; $8 row number
; $9 column number
; $10 temporary
; $11 attribute/character

	.set	dsp_base,0xF0100000

	add	$8,$0,0			; start with row = 0
	add	$9,$0,0			; start with col = 0
	add	$11,$0,0x0000+'A'	; char is always 'A'
next:
	; addr = dsp_base + (row * 128 + column) * 4
	sll	$10,$8,7
	add	$10,$10,$9
	sll	$10,$10,2
	stw	$11,$10,dsp_base	; write to display memory
	add	$11,$11,0x0100		; next attribute (bits 15:8)
	add	$9,$9,1			; next col
	add	$10,$0,16
	bne	$9,$10,next
	add	$9,$0,0			; reset col
	add	$8,$8,1			; next row
	add	$10,$0,16
	bne	$8,$10,next
stop:
	j	stop
