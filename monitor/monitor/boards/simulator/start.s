;
; start.s -- ECO32 ROM monitor startup and support routines
;

;	.set	CIO_CTL,0x00		; set console to keyboard/display
	.set	CIO_CTL,0x03		; set console to serial line 0

	.set	dmapaddr,0xC0000000	; base of directly mapped addresses
	.set	stacktop,0xC0010000	; monitor stack is at top of 64K

	.set	PSW,0			; reg # of PSW
	.set	V_SHIFT,27		; interrupt vector ctrl bit
	.set	V,1 << V_SHIFT

	.set	TLB_INDEX,1		; reg # of TLB Index
	.set	TLB_ENTRY_HI,2		; reg # of TLB EntryHi
	.set	TLB_ENTRY_LO,3		; reg # of TLB EntryLo
	.set	TLB_ENTRIES,32		; number of TLB entries
	.set	BAD_ADDRESS,4		; reg # of bad address reg
	.set	BAD_ACCESS,5		; reg # of bad access reg

	.set	USER_CONTEXT_SIZE,38*4	; size of user context

;***************************************************************

	.import	_ecode
	.import	_edata
	.import	_ebss

	.import	kbdinit
	.import	kbdinchk
	.import	kbdin

	.import	dspinit
	.import	dspoutchk
	.import	dspout

	.import	ser0init
	.import	ser0inchk
	.import	ser0in
	.import	ser0outchk
	.import	ser0out

	.import	ser1init
	.import	ser1inchk
	.import	ser1in
	.import	ser1outchk
	.import	ser1out

	.import	dskinitctl
	.import	dskcapctl
	.import	dskioctl

	.import	dskinitser
	.import	dskcapser
	.import	dskioser

	.import	main

	.export	_bcode
	.export	_bdata
	.export	_bbss

	.export	setcon
	.export	cinchk
	.export	cin
	.export	coutchk
	.export	cout
	.export	dskcap
	.export	dskio

	.export	getTLB_HI
	.export	getTLB_LO
	.export	setTLB

	.export	saveState
	.export	monitorReturn

	.import	userContext
	.export	resume

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

startup:
	j	start

interrupt:
	j	debug

userMiss:
	j	debug

monitor:
	j	debug

;***************************************************************

	.code
	.align	4

setcon:
	j	setcio

cinchk:
	j	cichk

cin:
	j	ci

coutchk:
	j	cochk

cout:
	j	co

dskcap:
	j	dcap

dskio:
	j	dio

reserved_11:
	j	reserved_11

reserved_12:
	j	reserved_12

reserved_13:
	j	reserved_13

reserved_14:
	j	reserved_14

reserved_15:
	j	reserved_15

;***************************************************************

	.code
	.align	4

start:
	; let irq/exc vectors point to RAM
	add	$8,$0,V
	mvts	$8,PSW

	; initialize TLB
	mvts	$0,TLB_ENTRY_LO		; invalidate all TLB entries
	add	$8,$0,dmapaddr		; by impossible virtual page number
	mvts	$8,TLB_ENTRY_HI
	add	$8,$0,$0
	add	$9,$0,TLB_ENTRIES
tlbloop:
	mvts	$8,TLB_INDEX
	tbwi
	add	$8,$8,1
	bne	$8,$9,tlbloop

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

	; initialize I/O
	add	$29,$0,stacktop		; setup monitor stack
	jal	kbdinit			; init keyboard
	jal	dspinit			; init display
	jal	ser0init		; init serial line 0
	jal	ser1init		; init serial line 1
	jal	dskinitctl		; init disk (controller)
	jal	dskinitser		; init disk (serial line)
	add	$4,$0,CIO_CTL		; set console
	jal	setcio

	; call main
	jal	main			; enter command loop

	; main should never return
	j	start			; just to be sure...

;***************************************************************

	.code
	.align	4

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

	.data
	.align	4

cioctl:
	.byte	0

	.code
	.align	4

	; void setcon(Byte ctl)
setcio:
	stb	$4,$0,cioctl
	j	$31

	; int cinchk(void)
cichk:
	ldbu	$8,$0,cioctl
	and	$8,$8,0x01
	bne	$8,$0,cichk1
	j	kbdinchk
cichk1:
	j	ser0inchk

	; char cin(void)
ci:
	ldbu	$8,$0,cioctl
	and	$8,$8,0x01
	bne	$8,$0,ci1
	j	kbdin
ci1:
	j	ser0in

	; int coutchk(void)
cochk:
	ldbu	$8,$0,cioctl
	and	$8,$8,0x02
	bne	$8,$0,cochk1
	j	dspoutchk
cochk1:
	j	ser0outchk

	; void cout(char c)
co:
	ldbu	$8,$0,cioctl
	and	$8,$8,0x02
	bne	$8,$0,co1
	j	dspout
co1:
	j	ser0out

;***************************************************************

	.code
	.align	4

	; int dskcap(int dskno)
dcap:
	bne	$4,$0,dcapser
	j	dskcapctl
dcapser:
	j	dskcapser

	; int dskio(int dskno, char cmd, int sct, Word addr, int nscts)
dio:
	bne	$4,$0,dioser
	add	$4,$5,$0
	add	$5,$6,$0
	add	$6,$7,$0
	ldw	$7,$29,16
	j	dskioctl
dioser:
	add	$4,$5,$0
	add	$5,$6,$0
	add	$6,$7,$0
	ldw	$7,$29,16
	j	dskioser

;***************************************************************

	.code
	.align	4

	; Bool saveState(MonitorState *msp)
	; always return 'true' here
saveState:
	stw	$31,$4,0*4		; return address
	stw	$29,$4,1*4		; stack pointer
	stw	$16,$4,2*4		; local variables
	stw	$17,$4,3*4
	stw	$18,$4,4*4
	stw	$19,$4,5*4
	stw	$20,$4,6*4
	stw	$21,$4,7*4
	stw	$22,$4,8*4
	stw	$23,$4,9*4
	add	$2,$0,1
	jr	$31

	; load state when re-entering monitor
	; this appears as if returning from saveState
	; but the return value is 'false' here
loadState:
	ldw	$8,$0,monitorReturn
	beq	$8,$0,loadState		; fatal error: monitor state lost
	ldw	$31,$8,0*4		; return address
	ldw	$29,$8,1*4		; stack pointer
	ldw	$16,$8,2*4		; local variables
	ldw	$17,$8,3*4
	ldw	$18,$8,4*4
	ldw	$19,$8,5*4
	ldw	$20,$8,6*4
	ldw	$21,$8,7*4
	ldw	$22,$8,8*4
	ldw	$23,$8,9*4
	add	$2,$0,0
	jr	$31

	.bss
	.align	4

	; extern MonitorState *monitorReturn
monitorReturn:
	.space	4

	; extern UserContext userContext
userContext:
	.space	USER_CONTEXT_SIZE

;***************************************************************

	.code
	.align	4

	; void resume(void)
	; use userContext to load state
resume:
	mvts	$0,PSW
	add	$24,$0,userContext
	.nosyn
	ldw	$8,$24,33*4		; tlbIndex
	mvts	$8,TLB_INDEX
	ldw	$8,$24,34*4		; tlbEntryHi
	mvts	$8,TLB_ENTRY_HI
	ldw	$8,$24,35*4		; tlbEntryLo
	mvts	$8,TLB_ENTRY_LO
	ldw	$8,$24,36*4		; badAddress
	mvts	$8,BAD_ADDRESS
	ldw	$8,$24,37*4		; badAccess
	mvts	$8,BAD_ACCESS
	;ldw	$0,$24,0*4		; registers
	ldw	$1,$24,1*4
	ldw	$2,$24,2*4
	ldw	$3,$24,3*4
	ldw	$4,$24,4*4
	ldw	$5,$24,5*4
	ldw	$6,$24,6*4
	ldw	$7,$24,7*4
	ldw	$8,$24,8*4
	ldw	$9,$24,9*4
	ldw	$10,$24,10*4
	ldw	$11,$24,11*4
	ldw	$12,$24,12*4
	ldw	$13,$24,13*4
	ldw	$14,$24,14*4
	ldw	$15,$24,15*4
	ldw	$16,$24,16*4
	ldw	$17,$24,17*4
	ldw	$18,$24,18*4
	ldw	$19,$24,19*4
	ldw	$20,$24,20*4
	ldw	$21,$24,21*4
	ldw	$22,$24,22*4
	ldw	$23,$24,23*4
	;ldw	$24,$24,24*4
	ldw	$25,$24,25*4
	ldw	$26,$24,26*4
	ldw	$27,$24,27*4
	ldw	$28,$24,28*4
	ldw	$29,$24,29*4
	ldw	$30,$24,30*4
	ldw	$31,$24,31*4
	ldw	$24,$24,32*4		; psw
	mvts	$24,PSW
	rfx
	.syn

	; debug entry
	; use userContext to store state
debug:
	.nosyn
	ldhi	$24,userContext
	or	$24,$24,userContext
	stw	$0,$24,0*4		; registers
	stw	$1,$24,1*4
	stw	$2,$24,2*4
	stw	$3,$24,3*4
	stw	$4,$24,4*4
	stw	$5,$24,5*4
	stw	$6,$24,6*4
	stw	$7,$24,7*4
	stw	$8,$24,8*4
	stw	$9,$24,9*4
	stw	$10,$24,10*4
	stw	$11,$24,11*4
	stw	$12,$24,12*4
	stw	$13,$24,13*4
	stw	$14,$24,14*4
	stw	$15,$24,15*4
	stw	$16,$24,16*4
	stw	$17,$24,17*4
	stw	$18,$24,18*4
	stw	$19,$24,19*4
	stw	$20,$24,20*4
	stw	$21,$24,21*4
	stw	$22,$24,22*4
	stw	$23,$24,23*4
	stw	$24,$24,24*4
	stw	$25,$24,25*4
	stw	$26,$24,26*4
	stw	$27,$24,27*4
	stw	$28,$24,28*4
	stw	$29,$24,29*4
	stw	$30,$24,30*4
	stw	$31,$24,31*4
	mvfs	$8,PSW
	stw	$8,$24,32*4		; psw
	mvfs	$8,TLB_INDEX
	stw	$8,$24,33*4		; tlbIndex
	mvfs	$8,TLB_ENTRY_HI
	stw	$8,$24,34*4		; tlbEntryHi
	mvfs	$8,TLB_ENTRY_LO
	stw	$8,$24,35*4		; tlbEntryLo
	mvfs	$8,BAD_ADDRESS
	stw	$8,$24,36*4		; badAddress
	mvfs	$8,BAD_ACCESS
	stw	$8,$24,37*4		; badAccess
	.syn
	j	loadState
