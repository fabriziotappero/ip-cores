;
; display.s -- a memory-mapped alphanumerical display
;

;***************************************************************

	.set	dspbase,0xF0100000	; display base address

	.export	dspinit			; initialize display
	.export	dspoutchk		; check for output possible
	.export	dspout			; do display output

;***************************************************************

	.code
	.align	4

	; initialize display
dspinit:
	sub	$29,$29,4
	stw	$31,$29,0
	jal	clrscr
	add	$8,$0,scrrow
	stw	$0,$8,0
	add	$8,$0,scrcol
	stw	$0,$8,0
	jal	calcp
	jal	stcrs
	ldw	$31,$29,0
	add	$29,$29,4
	jr	$31

	; check if a character can be written
dspoutchk:
	add	$2,$0,1
	jr	$31

	; output a character on the display
dspout:
	sub	$29,$29,8
	stw	$31,$29,4
	stw	$16,$29,0
	and	$16,$4,0xFF
	jal	rmcrs
	add	$8,$0,' '
	bltu	$16,$8,dspout2
	add	$8,$0,scrptr
	ldw	$9,$8,0
	or	$16,$16,0x07 << 8
	stw	$16,$9,0
	add	$9,$9,4
	stw	$9,$8,0
	add	$8,$0,scrcol
	ldw	$9,$8,0
	add	$9,$9,1
	stw	$9,$8,0
	add	$10,$0,80
	bne	$9,$10,dspout1
	jal	docr
	jal	dolf
dspout1:
	jal	stcrs
	ldw	$16,$29,0
	ldw	$31,$29,4
	add	$29,$29,8
	jr	$31

dspout2:
	add	$8,$0,0x0D
	bne	$16,$8,dspout3
	jal	docr
	j	dspout1

dspout3:
	add	$8,$0,0x0A
	bne	$16,$8,dspout4
	jal	dolf
	j	dspout1

dspout4:
	add	$8,$0,0x08
	bne	$16,$8,dspout5
	jal	dobs
	j	dspout1

dspout5:
	j	dspout1

	; do carriage return
docr:
	sub	$29,$29,4
	stw	$31,$29,0
	add	$8,$0,scrcol
	stw	$0,$8,0
	jal	calcp
	ldw	$31,$29,0
	add	$29,$29,4
	jr	$31

	; do linefeed
dolf:
	sub	$29,$29,4
	stw	$31,$29,0
	add	$8,$0,scrrow
	ldw	$9,$8,0
	add	$10,$0,29
	beq	$9,$10,dolf1
	add	$9,$9,1
	stw	$9,$8,0
	jal	calcp
	j	dolf2
dolf1:
	jal	scrscr
dolf2:
	ldw	$31,$29,0
	add	$29,$29,4
	jr	$31

	; do backspace
dobs:
	sub	$29,$29,4
	stw	$31,$29,0
	add	$8,$0,scrcol
	ldw	$9,$8,0
	beq	$9,$0,dobs1
	sub	$9,$9,1
	stw	$9,$8,0
	jal	calcp
dobs1:
	ldw	$31,$29,0
	add	$29,$29,4
	jr	$31

	; remove cursor
rmcrs:
	add	$8,$0,scrptr
	ldw	$8,$8,0
	add	$9,$0,scrchr
	ldw	$10,$9,0
	stw	$10,$8,0
	jr	$31

	; set cursor
stcrs:
	add	$8,$0,scrptr
	ldw	$8,$8,0
	add	$9,$0,scrchr
	ldw	$10,$8,0
	stw	$10,$9,0
	add	$10,$0,(0x87 << 8) | '_'
	stw	$10,$8,0
	jr	$31

	; calculate screen pointer based on row and column
calcp:
	add	$9,$0,dspbase
	add	$8,$0,scrrow
	ldw	$10,$8,0
	sll	$10,$10,7+2
	add	$9,$9,$10
	add	$8,$0,scrcol
	ldw	$10,$8,0
	sll	$10,$10,0+2
	add	$9,$9,$10
	add	$8,$0,scrptr
	stw	$9,$8,0
	jr	$31

	; clear screen
clrscr:
	add	$11,$0,(0x07 << 8) | ' '
	add	$8,$0,dspbase
	add	$9,$0,30
clrscr1:
	add	$10,$0,80
clrscr2:
	stw	$11,$8,0
	add	$8,$8,4
	sub	$10,$10,1
	bne	$10,$0,clrscr2
	add	$8,$8,(128-80)*4
	sub	$9,$9,1
	bne	$9,$0,clrscr1
	jr	$31

	; scroll screen
scrscr:
	add	$8,$0,dspbase
	add	$9,$0,29
scrscr1:
	add	$10,$0,80
scrscr2:
	ldw	$11,$8,128*4
	stw	$11,$8,0
	add	$8,$8,4
	sub	$10,$10,1
	bne	$10,$0,scrscr2
	add	$8,$8,(128-80)*4
	sub	$9,$9,1
	bne	$9,$0,scrscr1
	add	$11,$0,(0x07 << 8) | ' '
	add	$10,$0,80
scrscr3:
	stw	$11,$8,0
	add	$8,$8,4
	sub	$10,$10,1
	bne	$10,$0,scrscr3
	jr	$31

;***************************************************************

	.bss
	.align	4

scrptr:
	.word	0

scrrow:
	.word	0

scrcol:
	.word	0

scrchr:
	.word	0
