;
; sregtest.s -- test special register transfer instructions
;

	.set	io_base,0xF0300000

	add	$7,$0,'.'

	add	$11,$0,0x1E67C536
	mvts	$11,1
	add	$12,$0,0xB45FCC78
	mvts	$12,2
	add	$13,$0,0x1FCB0BC5
	mvts	$13,3
	add	$14,$0,0x3AE82DD4
	mvts	$14,4

	mvfs	$8,1
	xor	$9,$8,$11
	and	$9,$9,0x0000001F
	beq	$9,$0,lbl1
	add	$7,$0,'?'
lbl1:

	mvfs	$8,2
	xor	$9,$8,$12
	and	$9,$9,0xFFFFF000
	beq	$9,$0,lbl2
	add	$7,$0,'?'
lbl2:

	mvfs	$8,3
	xor	$9,$8,$13
	and	$9,$9,0x3FFFF003
	beq	$9,$0,lbl3
	add	$7,$0,'?'
lbl3:

	mvfs	$8,4
	xor	$9,$8,$14
	and	$9,$9,0xFFFFFFFF
	beq	$9,$0,lbl4
	add	$7,$0,'?'
lbl4:

	jal	out
halt:
	j	halt

out:
	add	$8,$0,io_base
out1:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out1
	stw	$7,$8,12
	jr	$31
