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
	j	interrupt

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
