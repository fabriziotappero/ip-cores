;
; jalrtest.s -- test the special case 'jalr $31'
;

; One of the following 4 possibilities is displayed:
;   0 = jump not executed, return address not stored in $31
;   1 = jump was executed, return address not stored in $31
;   2 = jump not executed, return address stored in $31
;   3 = jump was executed, return address stored in $31

	.set	io_base,0xF0300000

	add	$16,$0,x
	add	$31,$0,$16
	jalr	$31
	add	$4,$0,0
	j	y
x:
	add	$4,$0,1
y:
	beq	$31,$16,z
	add	$4,$4,2
z:
	add	$4,$4,0x30
	jal	out
halt:
	j	halt

out:
	add	$8,$0,io_base
out1:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out1
	stw	$4,$8,12
	jr	$31
