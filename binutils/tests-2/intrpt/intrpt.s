;
; intrpt.s -- a first attempt to utilize interrupts
;

	.set	stack,0xC0010000	; stack
	.set	timerbase,0xF0000000	; timer base address
	.set	termbase,0xF0300000	; terminal base address

reset:
	j	start		; reset arrives here

intrpt:
	j	isr		; interrupts arrive here

userMiss:
	j	userMiss	; user TLB miss exceptions arrive here

isr:
	mvfs	$26,0		; determine cause
	slr	$26,$26,14	; $26 = 4 * IRQ number
	and	$26,$26,0x1F << 2
	ldw	$26,$26,irqsrv	; get addr of service routine
	jr	$26		; jump to service routine

start:
	add	$29,$0,stack	; set sp
	add	$4,$0,runmsg	; pointer to string
	jal	msg		; show string
	add	$8,$0,timerbase	; program timer
	add	$9,$0,1000	; divisor = 1000
	stw	$9,$8,4
	add	$9,$0,2		; enable timer interrupts
	stw	$9,$8,0
	mvfs	$8,0
	or	$8,$8,1 << 14	; open timer IRQ mask bit
	or	$8,$8,1	<< 23	; enable processor interrupts
	or	$8,$8,1 << 27	; let vector point to RAM
	mvts	$8,0
start1:
	j	start1		; loop

tmrisr:
	add	$8,$0,0x02	; ien = 1, int = 0
	stw	$8,$0,timerbase
	j	shmsg

shmsg:
	mvfs	$8,0
	slr	$8,$8,14	; $8 = 4 * IRQ number
	and	$8,$8,0x1F << 2
	ldw	$4,$8,msgtbl	; get addr of message
	jal	msg		; show message
	rfx			; return from exception

msg:
	sub	$29,$29,8	; save registers
	stw	$31,$29,4
	stw	$16,$29,0
	add	$16,$4,$0	; get pointer
msg1:
	ldbu	$4,$16,0	; get char
	beq	$4,$0,msg2	; null - finished
	jal	out		; output char
	add	$16,$16,1	; bump pointer
	j	msg1		; next char
msg2:
	ldw	$16,$29,0	; restore registers
	ldw	$31,$29,4
	add	$29,$29,8
	jr	$31		; return

out:
	add	$8,$0,termbase	; set I/O base address
out1:
	ldw	$9,$8,8		; get status
	and	$9,$9,1		; xmtr ready?
	beq	$9,$0,out1	; no - wait
	stw	$4,$8,12	; send char
	jr	$31		; return

; service routine table

irqsrv:
	.word	shmsg		; 00: terminal 0 transmitter interrupt
	.word	shmsg		; 01: terminal 0 receiver interrupt
	.word	shmsg		; 02: terminal 1 transmitter interrupt
	.word	shmsg		; 03: terminal 1 receiver interrupt
	.word	shmsg		; 04: keyboard interrupt
	.word	shmsg		; 05: unused
	.word	shmsg		; 06: unused
	.word	shmsg		; 07: unused
	.word	shmsg		; 08: disk interrupt
	.word	shmsg		; 09: unused
	.word	shmsg		; 10: unused
	.word	shmsg		; 11: unused
	.word	shmsg		; 12: unused
	.word	shmsg		; 13: unused
	.word	tmrisr		; 14: timer interrupt
	.word	shmsg		; 15: unused
	.word	shmsg		; 16: bus timeout exception
	.word	shmsg		; 17: illegal instruction exception
	.word	shmsg		; 18: privileged instruction exception
	.word	shmsg		; 19: divide instruction exception
	.word	shmsg		; 20: trap instruction exception
	.word	shmsg		; 21: TLB miss exception
	.word	shmsg		; 22: TLB write exception
	.word	shmsg		; 23: TLB invalid exception
	.word	shmsg		; 24: illegal address exception
	.word	shmsg		; 25: privileged address exception
	.word	shmsg		; 26: unused
	.word	shmsg		; 27: unused
	.word	shmsg		; 28: unused
	.word	shmsg		; 29: unused
	.word	shmsg		; 30: unused
	.word	shmsg		; 31: unused

; message table

msgtbl:
	.word	xmtmsg		; 00: terminal 0 transmitter interrupt
	.word	rcvmsg		; 01: terminal 0 receiver interrupt
	.word	xmtmsg		; 02: terminal 1 transmitter interrupt
	.word	rcvmsg		; 03: terminal 1 receiver interrupt
	.word	kbdmsg		; 04: keyboard interrupt
	.word	uimsg		; 05: unused
	.word	uimsg		; 06: unused
	.word	uimsg		; 07: unused
	.word	dskmsg		; 08: disk interrupt
	.word	uimsg		; 09: unused
	.word	uimsg		; 10: unused
	.word	uimsg		; 11: unused
	.word	uimsg		; 12: unused
	.word	uimsg		; 13: unused
	.word	tmrmsg		; 14: timer interrupt
	.word	uimsg		; 15: unused
	.word	btmsg		; 16: bus timeout exception
	.word	iimsg		; 17: illegal instruction exception
	.word	pimsg		; 18: privileged instruction exception
	.word	dimsg		; 19: divide instruction exception
	.word	timsg		; 20: trap instruction exception
	.word	msmsg		; 21: TLB miss exception
	.word	wrmsg		; 22: TLB write exception
	.word	ivmsg		; 23: TLB invalid exception
	.word	iamsg		; 24: illegal address exception
	.word	pamsg		; 25: privileged address exception
	.word	uemsg		; 26: unused
	.word	uemsg		; 27: unused
	.word	uemsg		; 28: unused
	.word	uemsg		; 29: unused
	.word	uemsg		; 30: unused
	.word	uemsg		; 31: unused

; sign-on message

runmsg:
	.byte	"system running..."
	.byte	0x0D, 0x0A, 0

; interrupt messages

uimsg:
	.byte	"unknown interrupt"
	.byte	0x0D, 0x0A, 0

xmtmsg:
	.byte	"terminal transmitter interrupt"
	.byte	0x0D, 0x0A, 0

rcvmsg:
	.byte	"terminal receiver interrupt"
	.byte	0x0D, 0x0A, 0

kbdmsg:
	.byte	"keyboard interrupt"
	.byte	0x0D, 0x0A, 0

dskmsg:
	.byte	"disk interrupt"
	.byte	0x0D, 0x0A, 0

tmrmsg:
	.byte	"timer interrupt"
	.byte	0x0D, 0x0A, 0

; exception messages

uemsg:
	.byte	"unknown exception"
	.byte	0x0D, 0x0A, 0

btmsg:
	.byte	"bus timeout exception"
	.byte	0x0D, 0x0A, 0

iimsg:
	.byte	"illegal instruction exception"
	.byte	0x0D, 0x0A, 0

pimsg:
	.byte	"privileged instruction exception"
	.byte	0x0D, 0x0A, 0

dimsg:
	.byte	"divide instruction exception"
	.byte	0x0D, 0x0A, 0

timsg:
	.byte	"trap instruction exception"
	.byte	0x0D, 0x0A, 0

msmsg:
	.byte	"TLB miss exception"
	.byte	0x0D, 0x0A, 0

wrmsg:
	.byte	"TLB write exception"
	.byte	0x0D, 0x0A, 0

ivmsg:
	.byte	"TLB invalid exception"
	.byte	0x0D, 0x0A, 0

iamsg:
	.byte	"illegal address exception"
	.byte	0x0D, 0x0A, 0

pamsg:
	.byte	"privileged address exception"
	.byte	0x0D, 0x0A, 0
