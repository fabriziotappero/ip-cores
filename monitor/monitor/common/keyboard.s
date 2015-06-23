;
; keyboard.s -- a PC keyboard as input device
;

;***************************************************************

	.set	kbdbase,0xF0200000	; keyboard base address

;	.import	cout
;	.import	byteout

	.import	xltbl1			; kbd translation table 1
	.import	xltbl2			; kbd translation table 2

	.export	kbdinit			; initialize keyboard
	.export	kbdinchk		; check if input available
	.export	kbdin			; do keyboard input

;***************************************************************

	.code
	.align	4

kbdinit:
	jr	$31

kbdinchk:
	add	$8,$0,kbdbase
	ldw	$2,$8,0
	and	$2,$2,1
	jr	$31

kbdin:
	sub	$29,$29,12
	stw	$31,$29,8
	stw	$16,$29,4
	stw	$17,$29,0
kbdin0:
	jal	kbdinp
	add	$16,$2,$0		; key 1 in $16
	add	$8,$0,0xF0
	bne	$16,$8,kbdin2
kbdin1:
	jal	kbdinp
	j	kbdin0
kbdin2:
	jal	kbdinp
	add	$17,$2,$0		; key 2 in $17
	beq	$17,$16,kbdin2
	add	$8,$0,0xF0
	beq	$17,$8,kbdin3
	j	kbdin5
kbdin3:
	jal	kbdinp
	bne	$2,$16,kbdin2
kbdin4:
	add	$4,$16,$0		; use key 1
	add	$5,$0,xltbl1		; with translation table 1
	jal	xlat
	j	kbdx
kbdin5:
	jal	kbdinp
	add	$8,$0,0xF0
	bne	$2,$8,kbdin5
kbdin6:
	jal	kbdinp
	beq	$2,$16,kbdin7
	beq	$2,$17,kbdin9
	j	kbdin5
kbdin7:
	jal	kbdinp
	add	$8,$0,0xF0
	bne	$2,$8,kbdin7
kbdin8:
	jal	kbdinp
	bne	$2,$17,kbdin7
	j	kbdin11
kbdin9:
	jal	kbdinp
	add	$8,$0,0xF0
	bne	$2,$8,kbdin9
kbdin10:
	jal	kbdinp
	bne	$2,$16,kbdin9
	j	kbdin11
kbdin11:
	add	$8,$0,0x12		; left shift key
	beq	$16,$8,kbdin12
	add	$8,$0,0x59		; right shift key
	beq	$16,$8,kbdin12
	add	$8,$0,0x14		; ctrl key
	beq	$16,$8,kbdin14
	j	kbdin13
kbdin12:
	add	$4,$17,$0		; use key 2
	add	$5,$0,xltbl2		; with translation table 2
	jal	xlat
	j	kbdx
kbdin13:
	add	$4,$16,$0		; use key 1
	add	$5,$0,xltbl1		; with translation table 1
	jal	xlat
	j	kbdx
kbdin14:
	add	$4,$17,$0		; use key 2
	add	$5,$0,xltbl1		; with translation table 1
	jal	xlat
	and	$2,$2,0xFF-0x60		; then reset bits 0x60
	j	kbdx
kbdx:
	ldw	$17,$29,0
	ldw	$16,$29,4
	ldw	$31,$29,8
	add	$29,$29,12
	jr	$31

kbdinp:
	add	$8,$0,kbdbase
kbdinp1:
	ldw	$9,$8,0
	and	$9,$9,1
	beq	$9,$0,kbdinp1		; wait until character ready
	ldw	$2,$8,4			; get character
	add	$9,$0,0xE0
	beq	$2,$9,kbdinp1		; ignore E0 prefix
	add	$9,$0,0xE1
	beq	$2,$9,kbdinp1		; as well as E1 prefix
	jr	$31

xlat:
	sub	$29,$29,8
	stw	$31,$29,4
	stw	$16,$29,0
	and	$16,$4,0xFF
	add	$8,$16,$5
	ldbu	$2,$8,0
	bne	$2,$0,xlat1
;	add	$4,$0,'<'
;	jal	cout
;	add	$4,$16,$0
;	jal	byteout
;	add	$4,$0,'>'
;	jal	cout
	add	$2,$16,$0
xlat1:
	ldw	$16,$29,0
	ldw	$31,$29,4
	add	$29,$29,8
	jr	$31
