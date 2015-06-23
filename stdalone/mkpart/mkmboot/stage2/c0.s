;
; c0.s -- startup code and begin-of-segment labels
;

	.import	main

	.import	_ecode
	.import	_edata
	.import	_ebss

	.export	_bcode
	.export	_bdata
	.export	_bbss

	.import	bootDisk
	.import	startSector
	.import	numSectors
	.import	entryPoint

	.code
_bcode:

start:
	add	$10,$0,_bdata		; copy data segment
	add	$8,$0,_edata
	sub	$9,$8,$10
	add	$9,$9,_ecode
	j	cpytest
cpyloop:
	ldw	$11,$9,0
	stw	$11,$8,0
cpytest:
	sub	$8,$8,4
	sub	$9,$9,4
	bgeu	$8,$10,cpyloop
	add	$8,$0,_bbss		; clear bss segment
	add	$9,$0,_ebss
	j	clrtest
clrloop:
	stw	$0,$8,0
	add	$8,$8,4
clrtest:
	bltu	$8,$9,clrloop
	add	$29,$0,0xC0020000	; setup stack
	stw	$16,$0,bootDisk		; make arguments available
	stw	$17,$0,startSector
	stw	$18,$0,numSectors
	jal	main			; call 'main' function
	ldw	$16,$0,bootDisk		; setup arguments for next stage
	ldw	$17,$0,startSector
	ldw	$18,$0,numSectors
	ldw	$31,$0,entryPoint	; jump to loaded program
	jr	$31

	.data
_bdata:

	.bss
_bbss:
