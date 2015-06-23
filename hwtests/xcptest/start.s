;
; start.s -- startup and support routines
;

	.set	dmapaddr,0xC0000000	; base of directly mapped addresses
	.set	stacktop,0xC0400000	; monitor stack is at top of memory

	.set	PSW,0			; reg # of PSW
	.set	TLB_INDEX,1		; reg # of TLB Index
	.set	TLB_ENTRY_HI,2		; reg # of TLB EntryHi
	.set	TLB_ENTRY_LO,3		; reg # of TLB EntryLo
	.set	TLB_ENTRIES,32		; number of TLB entries
	.set	BAD_ADDRESS,4		; reg # of bad address reg

;***************************************************************

	.import	_ecode
	.import	_edata
	.import	_ebss

	.import	serinit
	.import	ser0in
	.import	ser0out

	.import	main
	.import	userMissTaken

	.export	_bcode
	.export	_bdata
	.export	_bbss

	.export	cin
	.export	cout

	.export	xtest1
	.export	xtest1x
	.export	xtest2
	.export	xtest2x
	.export	xtest3
	.export	xtest3x
	.export	xtest4
	.export	xtest4x
	.export	xtest5
	.export	xtest5x
	.export	xtest6
	.export	xtest6x
	.export	xtest7
	.export	xtest7x
	.export	xtest8
	.export	xtest8x
	.export	xtest9
	.export	xtest9x
	.export	xtest10
	.export	xtest10x
	.export	xtest11
	.export	xtest11x
	.export	xtest12
	.export	xtest12x
	.export	xtest13
	.export	xtest13x
	.export	xtest14
	.export	xtest14x
	.export	xtest15
	.export	xtest15x
	.export	xtest16
	.export	xtest16x
	.export	xtest17
	.export	xtest17x
	.export	xtest18
	.export	xtest18x
	.export	xtest19
	.export	xtest19x
	.export	xtest20
	.export	xtest20x
	.export	xtest21
	.export	xtest21x
	.export	xtest22
	.export	xtest22x
	.export	xtest23
	.export	xtest23x
	.export	xtest24
	.export	xtest24x
	.export	xtest25
	.export	xtest25x
	.export	xtest26
	.export	xtest26x
	.export	xtest27
	.export	xtest27x
	.export	xtest28
	.export	xtest28x
	.export	xtest29
	.export	xtest29x
	.export	xtest30
	.export	xtest30x
	.export	xtest31
	.export	xtest31x
	.export	xtest32
	.export	xtest32x
	.export	xtest33
	.export	xtest33x
	.export	xtest34
	.export	xtest34x
	.export	xtest35
	.export	xtest35x
	.export	xtest36
	.export	xtest36x
	.export	xtest37
	.export	xtest37x

	.export	getTLB_HI
	.export	getTLB_LO
	.export	setTLB

;***************************************************************

	.code
_bcode:

	.data
_bdata:

	.bss
_bbss:

;***************************************************************

	.code
	.align	4

reset:
	j	start

interrupt:
	j	isr

userMiss:
	j	umsr

;***************************************************************

	.code
	.align	4

cin:
	j	ser0in

cout:
	j	ser0out

;***************************************************************

	.code
	.align	4

start:
	; force CPU into a defined state
	mvts	$0,PSW			; disable interrupts and user mode

	; initialize TLB
	mvts	$0,TLB_ENTRY_LO		; invalidate all TLB entries
	add	$8,$0,dmapaddr		; by impossible virtual page number
	add	$9,$0,$0
	add	$10,$0,TLB_ENTRIES
tlbloop:
	mvts	$8,TLB_ENTRY_HI
	mvts	$9,TLB_INDEX
	tbwi
	add	$8,$8,0x1000		; all entries must be different
	add	$9,$9,1
	bne	$9,$10,tlbloop

	; copy data segment
	add	$10,$0,_bdata		; lowest dst addr to be written to
	add	$8,$0,_edata		; one above the top dst addr
	sub	$9,$8,$10		; $9 = size of data segment
	add	$9,$9,_ecode		; data is waiting right after code
	j	cpytest
cpyloop:
	ldw	$11,$9,0		; src addr in $9
	stw	$11,$8,0		; dst addr in $8
cpytest:
	sub	$8,$8,4			; downward
	sub	$9,$9,4
	bgeu	$8,$10,cpyloop

	; clear bss segment
	add	$8,$0,_bbss		; start with first word of bss
	add	$9,$0,_ebss		; this is one above the top
	j	clrtest
clrloop:
	stw	$0,$8,0			; dst addr in $8
	add	$8,$8,4			; upward
clrtest:
	bltu	$8,$9,clrloop

	; now do some useful work
	add	$29,$0,stacktop		; setup monitor stack
	jal	serinit			; init serial interface
	jal	main			; enter command loop

	; main should never return
	j	start			; just to be sure...

;***************************************************************

xtest1:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest1x:
	trap
	j	halt
	.syn

xtest2:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest2x:
	.word	0x1E << 26
	j	halt
	.syn

xtest3:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest3x:
	div	$5,$7,$0
	j	halt
	.syn

xtest4:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest4x:
	div	$5,$7,0
	j	halt
	.syn

xtest5:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest5x:
	divu	$5,$7,$0
	j	halt
	.syn

xtest6:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest6x:
	divu	$5,$7,0
	j	halt
	.syn

xtest7:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest7x:
	rem	$5,$7,$0
	j	halt
	.syn

xtest8:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest8x:
	rem	$5,$7,0
	j	halt
	.syn

xtest9:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest9x:
	remu	$5,$7,$0
	j	halt
	.syn

xtest10:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest10x:
	remu	$5,$7,0
	j	halt
	.syn

xtest11:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest11x:
	.set	xtest11x,0xFFFFFF10
	jr	$15
	j	halt
	.syn

xtest12:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest12x:
	ldw	$5,$15,0
	j	halt
	.syn

xtest13:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest13x:
	stw	$5,$15,0
	j	halt
	.syn

xtest14:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$16,$0,xtest14v		; switch to virtual addressing
	add	$8,$0,11
	mvts	$8,TLB_INDEX
	and	$8,$16,0x3FFFF000
	mvts	$8,TLB_ENTRY_HI
	and	$8,$16,0x3FFFF000
	or	$8,$8,3
	mvts	$8,TLB_ENTRY_LO
	tbwi
	mvfs	$8,TLB_INDEX		; we could cross a page boundary
	add	$8,$8,1
	mvts	$8,TLB_INDEX
	mvfs	$8,TLB_ENTRY_HI
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_HI
	mvfs	$8,TLB_ENTRY_LO
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_LO
	tbwi
	and	$16,$16,0x3FFFFFFF
	jr	$16
xtest14v:
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest14x:
	rfx
	j	halt
	.syn

xtest15:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$16,$0,xtest15v		; switch to virtual addressing
	add	$8,$0,11
	mvts	$8,TLB_INDEX
	and	$8,$16,0x3FFFF000
	mvts	$8,TLB_ENTRY_HI
	and	$8,$16,0x3FFFF000
	or	$8,$8,3
	mvts	$8,TLB_ENTRY_LO
	tbwi
	mvfs	$8,TLB_INDEX		; we could cross a page boundary
	add	$8,$8,1
	mvts	$8,TLB_INDEX
	mvfs	$8,TLB_ENTRY_HI
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_HI
	mvfs	$8,TLB_ENTRY_LO
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_LO
	tbwi
	and	$16,$16,0x3FFFFFFF
	jr	$16
xtest15v:
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest15x:
	mvts	$0,PSW
	j	halt
	.syn

xtest16:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$16,$0,xtest16v		; switch to virtual addressing
	add	$8,$0,11
	mvts	$8,TLB_INDEX
	and	$8,$16,0x3FFFF000
	mvts	$8,TLB_ENTRY_HI
	and	$8,$16,0x3FFFF000
	or	$8,$8,3
	mvts	$8,TLB_ENTRY_LO
	tbwi
	mvfs	$8,TLB_INDEX		; we could cross a page boundary
	add	$8,$8,1
	mvts	$8,TLB_INDEX
	mvfs	$8,TLB_ENTRY_HI
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_HI
	mvfs	$8,TLB_ENTRY_LO
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_LO
	tbwi
	and	$16,$16,0x3FFFFFFF
	jr	$16
xtest16v:
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest16x:
	tbs
	j	halt
	.syn

xtest17:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$16,$0,xtest17v		; switch to virtual addressing
	add	$8,$0,11
	mvts	$8,TLB_INDEX
	and	$8,$16,0x3FFFF000
	mvts	$8,TLB_ENTRY_HI
	and	$8,$16,0x3FFFF000
	or	$8,$8,3
	mvts	$8,TLB_ENTRY_LO
	tbwi
	mvfs	$8,TLB_INDEX		; we could cross a page boundary
	add	$8,$8,1
	mvts	$8,TLB_INDEX
	mvfs	$8,TLB_ENTRY_HI
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_HI
	mvfs	$8,TLB_ENTRY_LO
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_LO
	tbwi
	and	$16,$16,0x3FFFFFFF
	jr	$16
xtest17v:
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest17x:
	.set	xtest17x,0xFFFFFF10
	jr	$15
	j	halt
	.syn

xtest18:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$16,$0,xtest18v		; switch to virtual addressing
	add	$8,$0,11
	mvts	$8,TLB_INDEX
	and	$8,$16,0x3FFFF000
	mvts	$8,TLB_ENTRY_HI
	and	$8,$16,0x3FFFF000
	or	$8,$8,3
	mvts	$8,TLB_ENTRY_LO
	tbwi
	mvfs	$8,TLB_INDEX		; we could cross a page boundary
	add	$8,$8,1
	mvts	$8,TLB_INDEX
	mvfs	$8,TLB_ENTRY_HI
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_HI
	mvfs	$8,TLB_ENTRY_LO
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_LO
	tbwi
	and	$16,$16,0x3FFFFFFF
	jr	$16
xtest18v:
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest18x:
	ldw	$5,$15,0
	j	halt
	.syn

xtest19:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$16,$0,xtest19v		; switch to virtual addressing
	add	$8,$0,11
	mvts	$8,TLB_INDEX
	and	$8,$16,0x3FFFF000
	mvts	$8,TLB_ENTRY_HI
	and	$8,$16,0x3FFFF000
	or	$8,$8,3
	mvts	$8,TLB_ENTRY_LO
	tbwi
	mvfs	$8,TLB_INDEX		; we could cross a page boundary
	add	$8,$8,1
	mvts	$8,TLB_INDEX
	mvfs	$8,TLB_ENTRY_HI
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_HI
	mvfs	$8,TLB_ENTRY_LO
	add	$8,$8,0x1000
	mvts	$8,TLB_ENTRY_LO
	tbwi
	and	$16,$16,0x3FFFFFFF
	jr	$16
xtest19v:
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest19x:
	stw	$5,$15,0
	j	halt
	.syn

xtest20:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest20x:
	.set	xtest20x,0x11111122
	jr	$17
	j	halt
	.syn

xtest21:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest21x:
	.set	xtest21x,0x00000021
	jr	$16
	j	halt
	.syn

xtest22:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest22x:
	ldw	$5,$15,2
	j	halt
	.syn

xtest23:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest23x:
	ldw	$5,$15,1
	j	halt
	.syn

xtest24:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest24x:
	ldh	$5,$15,1
	j	halt
	.syn

xtest25:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest25x:
	stw	$5,$15,2
	j	halt
	.syn

xtest26:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest26x:
	stw	$5,$15,1
	j	halt
	.syn

xtest27:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest27x:
	sth	$5,$15,1
	j	halt
	.syn

xtest28:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest28x:
	.set	xtest28x,0x33333314
	jr	$3
	j	halt
	.syn

xtest29:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest29x:
	ldw	$5,$3,0
	j	halt
	.syn

xtest30:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest30x:
	stw	$5,$3,0
	j	halt
	.syn

xtest31:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest31x:
	.set	xtest31x,0xBBBBBB1C
	jr	$11
	j	halt
	.syn

xtest32:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest32x:
	ldw	$5,$11,0
	j	halt
	.syn

xtest33:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest33x:
	stw	$5,$11,0
	j	halt
	.syn

xtest34:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$8,$0,11		; construct TLB entry
	mvts	$8,TLB_INDEX
	add	$8,$0,0xBBBBBB1C
	and	$8,$8,0xFFFFF000
	mvts	$8,TLB_ENTRY_HI
	add	$8,$0,0
	mvts	$8,TLB_ENTRY_LO
	tbwi
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
;xtest34x:
	.set	xtest34x,0xBBBBBB1C
	jr	$11
	j	halt
	.syn

xtest35:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$8,$0,11		; construct TLB entry
	mvts	$8,TLB_INDEX
	add	$8,$0,0xBBBBBB1C
	and	$8,$8,0xFFFFF000
	mvts	$8,TLB_ENTRY_HI
	add	$8,$0,0
	mvts	$8,TLB_ENTRY_LO
	tbwi
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest35x:
	ldw	$5,$11,0
	j	halt
	.syn

xtest36:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$8,$0,11		; construct TLB entry
	mvts	$8,TLB_INDEX
	add	$8,$0,0xBBBBBB1C
	and	$8,$8,0xFFFFF000
	mvts	$8,TLB_ENTRY_HI
	add	$8,$0,0
	mvts	$8,TLB_ENTRY_LO
	tbwi
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest36x:
	stw	$5,$11,0
	j	halt
	.syn

xtest37:
	mvts	$0,PSW
	add	$8,$0,returnState
	stw	$4,$8,0*4		; pointer to interrupt context
	stw	$31,$8,1*4		; return address
	stw	$29,$8,2*4		; stack pointer
	stw	$16,$8,3*4		; local variables
	stw	$17,$8,4*4
	stw	$18,$8,5*4
	stw	$19,$8,6*4
	stw	$20,$8,7*4
	stw	$21,$8,8*4
	stw	$22,$8,9*4
	stw	$23,$8,10*4
	add	$8,$0,11		; construct TLB entry
	mvts	$8,TLB_INDEX
	add	$8,$0,0xBBBBBB1C
	and	$8,$8,0xFFFFF000
	mvts	$8,TLB_ENTRY_HI
	add	$8,$0,1
	mvts	$8,TLB_ENTRY_LO
	tbwi
	.nosyn
	add	$28,$4,$0
	ldw	$8,$28,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$28,34*4		; tlbWntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$28,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$28,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	;ldw	$0,$28,0*4		; registers
	ldw	$1,$28,1*4
	ldw	$2,$28,2*4
	ldw	$3,$28,3*4
	ldw	$4,$28,4*4
	ldw	$5,$28,5*4
	ldw	$6,$28,6*4
	ldw	$7,$28,7*4
	ldw	$8,$28,8*4
	ldw	$9,$28,9*4
	ldw	$10,$28,10*4
	ldw	$11,$28,11*4
	ldw	$12,$28,12*4
	ldw	$13,$28,13*4
	ldw	$14,$28,14*4
	ldw	$15,$28,15*4
	ldw	$16,$28,16*4
	ldw	$17,$28,17*4
	ldw	$18,$28,18*4
	ldw	$19,$28,19*4
	ldw	$20,$28,20*4
	ldw	$21,$28,21*4
	ldw	$22,$28,22*4
	ldw	$23,$28,23*4
	ldw	$24,$28,24*4
	ldw	$25,$28,25*4
	ldw	$26,$28,26*4
	ldw	$27,$28,27*4
	;ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,32*4		; psw
	mvts	$28,PSW
xtest37x:
	stw	$5,$11,0
	j	halt
	.syn

	; last resort if the exception did not trigger
halt:
	j	halt

;***************************************************************

	; Word getTLB_HI(int index)
getTLB_HI:
	mvts	$4,TLB_INDEX
	tbri
	mvfs	$2,TLB_ENTRY_HI
	jr	$31

	; Word getTLB_LO(int index)
getTLB_LO:
	mvts	$4,TLB_INDEX
	tbri
	mvfs	$2,TLB_ENTRY_LO
	jr	$31

	; void setTLB(int index, Word entryHi, Word entryLo)
setTLB:
	mvts	$4,TLB_INDEX
	mvts	$5,TLB_ENTRY_HI
	mvts	$6,TLB_ENTRY_LO
	tbwi
	jr	$31

;***************************************************************

	; general interrupt entry
isr:
	.nosyn
	ldhi	$28,userMissTaken	; remember entry point
	or	$28,$28,userMissTaken
	stw	$0,$28,0
	j	common

	; TLB user miss entry
umsr:
	.nosyn
	ldhi	$28,userMissTaken	; remember entry point
	or	$28,$28,userMissTaken
	stw	$28,$28,0
	j	common

common:
	ldhi	$28,returnState
	or	$28,$28,returnState
	ldw	$28,$28,0		; pointer to interrupt context
	stw	$0,$28,0*4		; registers
	stw	$1,$28,1*4
	stw	$2,$28,2*4
	stw	$3,$28,3*4
	stw	$4,$28,4*4
	stw	$5,$28,5*4
	stw	$6,$28,6*4
	stw	$7,$28,7*4
	stw	$8,$28,8*4
	stw	$9,$28,9*4
	stw	$10,$28,10*4
	stw	$11,$28,11*4
	stw	$12,$28,12*4
	stw	$13,$28,13*4
	stw	$14,$28,14*4
	stw	$15,$28,15*4
	stw	$16,$28,16*4
	stw	$17,$28,17*4
	stw	$18,$28,18*4
	stw	$19,$28,19*4
	stw	$20,$28,20*4
	stw	$21,$28,21*4
	stw	$22,$28,22*4
	stw	$23,$28,23*4
	stw	$24,$28,24*4
	stw	$25,$28,25*4
	stw	$26,$28,26*4
	stw	$27,$28,27*4
	stw	$28,$28,28*4
	stw	$29,$28,29*4
	stw	$30,$28,30*4
	stw	$31,$28,31*4
	mvfs	$8,PSW
	stw	$8,$28,32*4		; psw
	mvfs	$8,TLB_INDEX
	stw	$8,$28,33*4		; tlbIndex
	mvfs	$8,TLB_ENTRY_HI
	stw	$8,$28,34*4		; tlbEntryHi
	mvfs	$8,TLB_ENTRY_LO
	stw	$8,$28,35*4		; tlbEntryLo
	mvfs	$8,BAD_ADDRESS
	stw	$8,$28,36*4		; badAddress
	.syn
	add	$8,$0,returnState
	ldw	$4,$8,0*4		; pointer to interrupt context
	ldw	$31,$8,1*4		; return address
	ldw	$29,$8,2*4		; stack pointer
	ldw	$16,$8,3*4		; local variables
	ldw	$17,$8,4*4
	ldw	$18,$8,5*4
	ldw	$19,$8,6*4
	ldw	$20,$8,7*4
	ldw	$21,$8,8*4
	ldw	$22,$8,9*4
	ldw	$23,$8,10*4
	jr	$31

	.bss
	.align	4

	; monitor state
	; stored when leaving to execute a user program
	; loaded when re-entering the monitor
returnState:
	.word	0		; pointer to interrupt context
	.word	0		; $31 (return address)
	.word	0		; $29 (stack pointer)
	.word	0		; $16 (local variable)
	.word	0		; $17 (local variable)
	.word	0		; $18 (local variable)
	.word	0		; $19 (local variable)
	.word	0		; $20 (local variable)
	.word	0		; $21 (local variable)
	.word	0		; $22 (local variable)
	.word	0		; $23 (local variable)
