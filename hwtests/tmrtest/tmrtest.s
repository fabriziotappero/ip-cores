;
; tmrtest.s -- test timer
;

	.set	tmr_base,0xF0000000
	.set	io_base,0xF0300000

	add	$8,$0,tmr_base
	add	$9,$0,50000000		; divisor for 1 sec
	stw	$9,$8,4
	add	$7,$0,'a'-10
again:
	jal	out
wait:
	add	$8,$0,tmr_base
	ldw	$9,$8,0
	and	$9,$9,1
	beq	$9,$0,wait
	stw	$0,$8,0
	add	$7,$7,1
	add	$9,$0,'z'+1
	bne	$7,$9,again
	add	$7,$0,'a'
	j	again

out:
	add	$8,$0,io_base
out1:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out1
	stw	$7,$8,12
	jr	$31
