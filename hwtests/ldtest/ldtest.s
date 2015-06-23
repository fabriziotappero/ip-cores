;
; ld.s -- test load instructions
;

	.set	io_base,0xF0300000

	add	$7,$0,'.'
	add	$3,$0,w1

t0:
	ldw	$2,$3,0
	add	$4,$0,0x68795E3C
	beq	$2,$4,t1
	add	$7,$0,'?'

t1:
	ldw	$2,$3,4
	add	$4,$0,0x6879DEBC
	beq	$2,$4,t2
	add	$7,$0,'?'

t2:
	ldh	$2,$3,2
	add	$4,$0,0x00005E3C
	beq	$2,$4,t3
	add	$7,$0,'?'

t3:
	ldh	$2,$3,6
	add	$4,$0,0xFFFFDEBC
	beq	$2,$4,t4
	add	$7,$0,'?'

t4:
	ldhu	$2,$3,2
	add	$4,$0,0x00005E3C
	beq	$2,$4,t5
	add	$7,$0,'?'

t5:
	ldhu	$2,$3,6
	add	$4,$0,0x0000DEBC
	beq	$2,$4,t6
	add	$7,$0,'?'

t6:
	ldb	$2,$3,3
	add	$4,$0,0x0000003C
	beq	$2,$4,t7
	add	$7,$0,'?'

t7:
	ldb	$2,$3,7
	add	$4,$0,0xFFFFFFBC
	beq	$2,$4,t8
	add	$7,$0,'?'

t8:
	ldbu	$2,$3,3
	add	$4,$0,0x0000003C
	beq	$2,$4,t9
	add	$7,$0,'?'

t9:
	ldbu	$2,$3,7
	add	$4,$0,0x000000BC
	beq	$2,$4,tx
	add	$7,$0,'?'

tx:
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

	.align	4
w1:	.word	0x68795E3C
w2:	.word	0x6879DEBC
