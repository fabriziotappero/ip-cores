;
; rom06.s -- "crossed" echo with two terminals, polled
;

	.set	tba0,0xF0300000	; terminal base address 0
	.set	tba1,0xF0301000	; terminal base address 1

	add	$8,$0,tba0	; set $8 to terminal base address 0
	add	$9,$0,tba1	; set $9 to terminal base address 1
L1:
	ldw	$10,$8,0	; load receiver status into $10
	and	$10,$10,1	; check receiver ready
	beq	$10,$0,L3	; not ready - check other terminal
	ldw	$11,$8,4	; load receiver data into $11
L2:
	ldw	$10,$9,8	; load transmitter status into $10
	and	$10,$10,1	; check transmitter ready
	beq	$10,$0,L2	; loop while not ready
	stw	$11,$9,12	; load char into transmitter data
L3:
	ldw	$10,$9,0	; load receiver status into $10
	and	$10,$10,1	; check receiver ready
	beq	$10,$0,L1	; not ready - check other terminal
	ldw	$11,$9,4	; load receiver data into $11
L4:
	ldw	$10,$8,8	; load transmitter status into $10
	and	$10,$10,1	; check transmitter ready
	beq	$10,$0,L4	; loop while not ready
	stw	$11,$8,12	; load char into transmitter data
	j	L1		; all over again
