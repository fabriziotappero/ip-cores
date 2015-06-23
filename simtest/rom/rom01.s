;
; rom01.s -- one example of each ECO32 instruction
;

	add	$5,$2,$13
	add	$5,$2,13
	sub	$5,$2,$13
	sub	$5,$2,13

	mul	$5,$2,$13
	mul	$5,$2,13
	mulu	$5,$2,$13
	mulu	$5,$2,13
	div	$5,$2,$13
	div	$5,$2,13
	divu	$5,$2,$13
	divu	$5,$2,13
	rem	$5,$2,$13
	rem	$5,$2,13
	remu	$5,$2,$13
	remu	$5,$2,13

	and	$5,$2,$13
	and	$5,$2,13
	or	$5,$2,$13
	or	$5,$2,13
	xor	$5,$2,$13
	xor	$5,$2,13
	xnor	$5,$2,$13
	xnor	$5,$2,13

	sll	$5,$2,$13
	sll	$5,$2,13
	slr	$5,$2,$13
	slr	$5,$2,13
	sar	$5,$2,$13
	sar	$5,$2,13

	ldhi	$5,L1

L1:
	beq	$5,$2,L1
	bne	$5,$2,L2
	ble	$5,$2,L1
	bleu	$5,$2,L2
	blt	$5,$2,L1
	bltu	$5,$2,L2
	bge	$5,$2,L1
	bgeu	$5,$2,L2
	bgt	$5,$2,L1
	bgtu	$5,$2,L2

	j	L1
	jr	$5
	jal	L2
	jalr	$5
L2:

	trap	0x1234DEAD
	rfx

	ldw	$5,$2,13
	ldh	$5,$2,13
	ldhu	$5,$2,-13
	ldb	$5,$2,13
	ldbu	$5,$2,-13

	stw	$5,$2,13
	sth	$5,$2,-13
	stb	$5,$2,13

	mvfs	$5,1
	mvts	$5,1
	tbs
	tbwr
	tbri
	tbwi
