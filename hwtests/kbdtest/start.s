;
; start.s -- startup and support routines
;

	.set	dmapaddr,0xC0000000	; base of directly mapped addresses
	.set	stacktop,0xC0400000	; monitor stack is at top of memory

	.set	ICNTXT_SIZE,34 * 4	; size of interrupt context

	.set	PSW,0			; reg # of PSW
	.set	V_SHIFT,27		; interrupt vector ctrl bit
	.set	V,1 << V_SHIFT
	.set	UM_SHIFT,26		; curr user mode ctrl bit
	.set	UM,1 << UM_SHIFT
	.set	PUM_SHIFT,25		; prev user mode ctrl bit
	.set	PUM,1 << PUM_SHIFT
	.set	OUM_SHIFT,24		; old user mode ctrl bit
	.set	OUM,1 << OUM_SHIFT
	.set	IE_SHIFT,23		; curr int enable ctrl bit
	.set	IE,1 << IE_SHIFT
	.set	PIE_SHIFT,22		; prev int enable ctrl bit
	.set	PIE,1 << PIE_SHIFT
	.set	OIE_SHIFT,21		; old int enable ctrl bit
	.set	OIE,1 << OIE_SHIFT

	.set	TLB_INDEX,1		; reg # of TLB Index
	.set	TLB_ENTRY_HI,2		; reg # of TLB EntryHi
	.set	TLB_ENTRY_LO,3		; reg # of TLB EntryLo
	.set	TLB_ENTRIES,32		; number of TLB entries

;***************************************************************

	.import	_ecode
	.import	_edata
	.import	_ebss

	.import	serinit
	.import	ser0in
	.import	ser0out

	.import	main

	.export	_bcode
	.export	_bdata
	.export	_bbss

	.export	cin
	.export	cout

	.export	getTLB_HI
	.export	getTLB_LO
	.export	setTLB
	.export	wrtRndTLB
	.export	probeTLB
	.export	wait

	.export	enable
	.export	disable
	.export	getMask
	.export	setMask
	.export	getISR
	.export	setISR

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
	j	userMiss

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

	; void wrtRndTLB(Word entryHi, Word entryLo)
wrtRndTLB:
	mvts	$4,TLB_ENTRY_HI
	mvts	$5,TLB_ENTRY_LO
	tbwr
	jr	$31

	; Word probeTLB(Word entryHi)
probeTLB:
	mvts	$4,TLB_ENTRY_HI
	tbs
	mvfs	$2,TLB_INDEX
	jr	$31

	; void wait(int n)
wait:
	j	wait2
wait1:
	add	$4,$4,$0
	sub	$4,$4,1
wait2:
	bne	$4,$0,wait1
	jr	$31

;***************************************************************

	.code
	.align	4

	; void enable(void)
enable:
	mvfs	$8,PSW
	or	$8,$8,IE
	mvts	$8,PSW
	jr	$31

	; void disable(void)
disable:
	mvfs	$8,PSW
	and	$8,$8,~IE
	mvts	$8,PSW
	jr	$31

	; U32 getMask(void)
getMask:
	mvfs	$8,PSW
	and	$2,$8,0x0000FFFF	; return lower 16 bits only
	jr	$31

	; U32 setMask(U32 mask)
setMask:
	mvfs	$8,PSW
	and	$2,$8,0x0000FFFF	; return lower 16 bits only
	and	$4,$4,0x0000FFFF	; use lower 16 bits only
	and	$8,$8,0xFFFF0000
	or	$8,$8,$4
	mvts	$8,PSW
	jr	$31

	; ISR getISR(int irq)
getISR:
	sll	$4,$4,2
	ldw	$2,$4,irqsrv
	jr	$31

	; ISR setISR(int irq, ISR isr)
setISR:
	sll	$4,$4,2
	ldw	$2,$4,irqsrv
	stw	$5,$4,irqsrv
	jr	$31

;***************************************************************

	.code
	.align	4

	; general interrupt service routine
	; only register $28 is available for bootstrapping
isr:
	.nosyn
	add	$28,$29,$0
	sub	$28,$28,ICNTXT_SIZE	; $28 points to interrupt context
	stw	$0,$28,0*4		; save registers
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
	mvfs	$8,TLB_ENTRY_HI		; save TLB EntryHi
	stw	$8,$28,32*4
	mvfs	$8,PSW			; save PSW
	stw	$8,$28,33*4
	add	$29,$28,$0		; $29 is required to hold sp
	.syn
	add	$5,$29,$0		; $5 = pointer to interrupt context
	slr	$4,$8,16		; $4 = IRQ number
	and	$4,$4,0x1F
	sll	$8,$4,2			; $8 = 4 * IRQ number
	ldw	$8,$8,irqsrv		; get addr of service routine
	jalr	$8			; call service routine
	.nosyn
	mvts	$0,PSW			; ISR may have enabled interrupts
	add	$28,$29,$0		; $28 points to interrupt context
	ldw	$8,$28,32*4		; restore TLB EntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$0,$28,0*4		; restore registers
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
	ldw	$28,$28,28*4
	ldw	$29,$28,29*4
	ldw	$30,$28,30*4
	ldw	$31,$28,31*4
	ldw	$28,$28,33*4		; restore PSW
	mvts	$28,PSW
	rfx				; done
	.syn

;***************************************************************

	.data
	.align	4

irqsrv:
	.word	0			; 00: terminal 0 transmitter interrupt
	.word	0			; 01: terminal 0 receiver interrupt
	.word	0			; 02: terminal 1 transmitter interrupt
	.word	0			; 03: terminal 1 receiver interrupt
	.word	0			; 04: keyboard interrupt
	.word	0			; 05: unused
	.word	0			; 06: unused
	.word	0			; 07: unused
	.word	0			; 08: disk interrupt
	.word	0			; 09: unused
	.word	0			; 10: unused
	.word	0			; 11: unused
	.word	0			; 12: unused
	.word	0			; 13: unused
	.word	0			; 14: timer 0 interrupt
	.word	0			; 15: timer 1 interrupt
	.word	0			; 16: bus timeout exception
	.word	0			; 17: illegal instruction exception
	.word	0			; 18: privileged instruction exception
	.word	0			; 19: divide instruction exception
	.word	0			; 20: trap instruction exception
	.word	0			; 21: TLB miss exception
	.word	0			; 22: TLB write exception
	.word	0			; 23: TLB invalid exception
	.word	0			; 24: illegal address exception
	.word	0			; 25: privileged address exception
	.word	0			; 26: unused
	.word	0			; 27: unused
	.word	0			; 28: unused
	.word	0			; 29: unused
	.word	0			; 30: unused
	.word	0			; 31: unused
