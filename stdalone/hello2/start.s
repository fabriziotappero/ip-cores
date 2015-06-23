;
; start.s -- startup code
;

	.import	main
	.import	_ecode
	.import	_edata
	.import	_ebss

	.export	_bcode
	.export	_bdata
	.export	_bbss

	.code
_bcode:

	.data
_bdata:

	.bss
_bbss:

	.code

start:
	mvfs	$8,0
	or	$8,$8,1 << 27	; let vector point to RAM
	mvts	$8,0
	add	$29,$0,stack	; set sp
	add	$10,$0,_bdata	; copy data segment
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
	add	$8,$0,_bbss	; clear bss
	add	$9,$0,_ebss
	j	clrtest
clrloop:
	stw	$0,$8,0
	add	$8,$8,4
clrtest:
	bltu	$8,$9,clrloop
	jal	main		; call 'main'
start1:
	j	start1		; loop

	.bss

	.align	4
	.space	0x800
stack:
