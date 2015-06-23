;
; irqtest.s -- test interrupts
;

	.set	stacktop,0xC0001000
	.set	tmr_base,0xF0000000
	.set	io_base,0xF0300000

reset:
	j	start

interrupt:
	j	tmrisr

userMiss:
	j	userMiss

start:
	add	$29,$0,stacktop
	add	$8,$0,tmr_base
	add	$9,$0,50000000		; divisor for 1 sec
	stw	$9,$8,4
	add	$9,$0,0x02
	stw	$9,$8,0
	add	$9,$0,0x00804000
	mvts	$9,0
	add	$7,$0,'a'-10
loop:
	j	loop

tmrisr:
	add	$7,$7,1
	add	$9,$0,'z'+1
	bne	$7,$9,noinit
	add	$7,$0,'a'
noinit:
	add	$4,$7,$0
	jal	out
	add	$8,$0,tmr_base
	add	$9,$0,0x02
	stw	$9,$8,0
	add	$4,$0,' '
	jal	out
	add	$4,$0,' '
	jal	out
	mvfs	$5,0
	add	$6,$0,'S'
	jal	show
	add	$4,$0,' '
	jal	out
	add	$4,$0,' '
	jal	out
	add	$5,$30,$0
	add	$6,$0,'R'
	jal	show
	add	$4,$0,0x0D
	jal	out
	add	$4,$0,0x0A
	jal	out
	rfx

show:
	sub	$29,$29,4
	stw	$31,$29,0
	add	$4,$6,$0
	jal	out
	add	$4,$0,' '
	jal	out
	add	$16,$0,32
digit:
	and	$17,$5,0x80000000
	bne	$17,$0,one
zero:
	add	$4,$0,'0'
	jal	out
	j	next
one:
	add	$4,$0,'1'
	jal	out
next:
	sll	$5,$5,1
	sub	$16,$16,1
	bne	$16,$0,digit
	ldw	$31,$29,0
	add	$29,$29,4
	jr	$31

out:
	add	$8,$0,io_base
out1:
	ldw	$9,$8,8
	and	$9,$9,1
	beq	$9,$0,out1
	stw	$4,$8,12
	jr	$31
