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

	.export	enable
	.export	disable
	.export	getMask
	.export	setMask
	.export	getISR
	.export	setISR

	.code
_bcode:

	.data
_bdata:

	.bss
_bbss:

	.code

	; reset arrives here
reset:
	j	start

	; interrupts arrive here
intrpt:
	j	isr

	; user TLB misses arrive here
userMiss:
	j	userMiss

isr:
	add	$26,$29,$0	; sp -> $26
	add	$27,$1,$0	; $1 -> $27
	add	$29,$0,istack	; set stack
	sub	$29,$29,108
	stw	$2,$29,0	; save registers
	stw	$3,$29,4
	stw	$4,$29,8
	stw	$5,$29,12
	stw	$6,$29,16
	stw	$7,$29,20
	stw	$8,$29,24
	stw	$9,$29,28
	stw	$10,$29,32
	stw	$11,$29,36
	stw	$12,$29,40
	stw	$13,$29,44
	stw	$14,$29,48
	stw	$15,$29,52
	stw	$16,$29,56
	stw	$17,$29,60
	stw	$18,$29,64
	stw	$19,$29,68
	stw	$20,$29,72
	stw	$21,$29,76
	stw	$22,$29,80
	stw	$23,$29,84
	stw	$24,$29,88
	stw	$25,$29,92
	stw	$26,$29,96
	stw	$27,$29,100
	stw	$31,$29,104
	mvfs	$4,0		; $4 = IRQ number
	slr	$4,$4,16
	and	$4,$4,0x1F
	sll	$26,$4,2	; $26 = 4 * IRQ number
	ldw	$26,$26,irqsrv	; get addr of service routine
	jalr	$26		; call service routine
	beq	$2,$0,resume	; resume instruction if ISR returned 0
	add	$30,$30,4	; else skip offending instruction
resume:
	ldw	$2,$29,0
	ldw	$3,$29,4
	ldw	$4,$29,8
	ldw	$5,$29,12
	ldw	$6,$29,16
	ldw	$7,$29,20
	ldw	$8,$29,24
	ldw	$9,$29,28
	ldw	$10,$29,32
	ldw	$11,$29,36
	ldw	$12,$29,40
	ldw	$13,$29,44
	ldw	$14,$29,48
	ldw	$15,$29,52
	ldw	$16,$29,56
	ldw	$17,$29,60
	ldw	$18,$29,64
	ldw	$19,$29,68
	ldw	$20,$29,72
	ldw	$21,$29,76
	ldw	$22,$29,80
	ldw	$23,$29,84
	ldw	$24,$29,88
	ldw	$25,$29,92
	ldw	$26,$29,96
	ldw	$27,$29,100
	ldw	$31,$29,104
	add	$1,$27,$0	; $27 -> $1
	add	$29,$26,0	; $26 -> sp
	rfx			; return from exception

start:
	add	$8,$0,0xA8003FFF
	add	$9,$0,0xC0000000
	stw	$8,$9,0		; 0xC0000000: j 0xC0010000
	stw	$8,$9,4		; 0xC0000004: j 0xC0010004
	stw	$8,$9,8		; 0xC0000008: j 0xC0010008
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

enable:
	mvfs	$8,0
	or	$8,$8,1 << 23
	mvts	$8,0
	jr	$31

disable:
	mvfs	$8,0
	and	$8,$8,~(1 << 23)
	mvts	$8,0
	jr	$31

getMask:
	mvfs	$8,0
	and	$2,$8,0x0000FFFF
	jr	$31

setMask:
	mvfs	$8,0
	and	$8,$8,0xFFFF0000
	and	$4,$4,0x0000FFFF
	or	$8,$8,$4
	mvts	$8,0
	jr	$31

getISR:
	sll	$4,$4,2
	ldw	$2,$4,irqsrv
	jr	$31

setISR:
	sll	$4,$4,2
	stw	$5,$4,irqsrv
	jr	$31

	.data

; interrupt service routine table

	.align	4

irqsrv:
	.word	0		; 00: terminal 0 transmitter interrupt
	.word	0		; 01: terminal 0 receiver interrupt
	.word	0		; 02: terminal 1 transmitter interrupt
	.word	0		; 03: terminal 1 receiver interrupt
	.word	0		; 04: keyboard interrupt
	.word	0		; 05: unused
	.word	0		; 06: unused
	.word	0		; 07: unused
	.word	0		; 08: disk interrupt
	.word	0		; 09: unused
	.word	0		; 10: unused
	.word	0		; 11: unused
	.word	0		; 12: unused
	.word	0		; 13: unused
	.word	0		; 14: timer 0 interrupt
	.word	0		; 15: timer 1 interrupt
	.word	0		; 16: bus timeout exception
	.word	0		; 17: illegal instruction exception
	.word	0		; 18: privileged instruction exception
	.word	0		; 19: divide instruction exception
	.word	0		; 20: trap instruction exception
	.word	0		; 21: TLB miss exception
	.word	0		; 22: TLB write exception
	.word	0		; 23: TLB invalid exception
	.word	0		; 24: illegal address exception
	.word	0		; 25: privileged address exception
	.word	0		; 26: unused
	.word	0		; 27: unused
	.word	0		; 28: unused
	.word	0		; 29: unused
	.word	0		; 30: unused
	.word	0		; 31: unused

	.bss

	.align	4
	.space	0x800
stack:

	.align	4
	.space	0x800
istack:
