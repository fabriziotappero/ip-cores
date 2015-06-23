UART		EQU		$CF00
XMIT_FUL	EQU		8

	cpu	rtf65002
	org $0FFFFE000		; 8kB ROM
start
	sei
	lda	#0x01			; turn on instruction cache
	trs	r1,cc			; transfer to cache control reg
	ldx	#$1000			; set stack pointer to word address $1000
	txs
	emm					; switch to emulation mode
;------------------------------------------------------------------------------
; 65C02 testing
;------------------------------------------------------------------------------
	cpu	W65C02			; tell assembler to use 6502 tables
	ldx	#$FF
	txs
	jsr		putmsg
	db		"C02 Testing Processor", 13, 10, 0
	bra		braok8
	jsr		putmsg
	db		"BRA:F", 13, 10, 0
braok8
	brl		brlok8
	jsr		putmsg
	db		"BRL:F", 13, 10, 0
brlok8
	sec
	bcs		bcsok8
	jsr		putmsg
	db		"BCS:F", 13, 10, 0
bcsok8
	clc
	bcc		bccok8
	jsr		putmsg
	db		"BCC:F", 13, 10, 0
bccok8
	ld		r1,#$00
	beq		beqok8
	jsr		putmsg
	db		"BEQ:F", 13, 10, 0
beqok8
	ld		r1,#$80000000
	bne		bneok8
	jsr		putmsg
	db		"BNE:F", 13, 10, 0
bneok8
	or		r1,r1,#$00
	bmi		bmiok8
	jsr		putmsg
	db		"BMI:F", 13, 10, 0
bmiok8
	eor		r1,r1,#$80000000
	bpl		bplok8
	jsr		putmsg
	db		"BPL:F", 13, 10, 0
bplok8
	ld		r1,#$7fffffff
	add		r1,r1,#$1		; should give signed overflow
	bvs		bvsok8
	jsr		putmsg
	db		"BVS:F", 13, 10, 0
bvsok8
	clv
	bvc		bvcok
	jsr		putmsg
	db		"BVC:F", 13, 10, 0
bvcok8

;--------------------------------------------------------------------------------------
; Native mode tests
;--------------------------------------------------------------------------------------

	nat					; switch to native mode
	cpu		rtf65002
	jsr		putmsg3
	db		"65k Testing Processor", 13, 10, 0

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; First thing to test is branches. If you can't branch reliably
; then the validity of the remaining tests are in question.
; Test branches and also simultaneously some other simple
; instructions.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	sei

	bra		braok
	jsr		putmsg3
	db		"BRA:F", 13, 10, 0
braok
	brl		brlok
	jsr		putmsg3
	db		"BRL:F", 13, 10, 0
brlok
	sec
	bcs		bcsok
	jsr		putmsg3
	db		"BCS:F", 13, 10, 0
bcsok
	clc
	bcc		bccok
	jsr		putmsg3
	db		"BCC:F", 13, 10, 0
bccok
	ld		r1,#$00
	beq		beqok
	jsr		putmsg3
	db		"BEQ:F", 13, 10, 0
beqok
	ld		r1,#$80000000
	bne		bneok
	jsr		putmsg3
	db		"BNE:F", 13, 10, 0
bneok
	or		r1,r1,#$00
	bmi		bmiok
	jsr		putmsg3
	db		"BMI:F", 13, 10, 0
bmiok
	eor		r1,r1,#$80000000
	bpl		bplok
	jsr		putmsg3
	db		"BPL:F", 13, 10, 0
bplok
	ld		r1,#$7fffffff
	add		r1,r1,#$1		; should give signed overflow
	bvs		bvsok
	jsr		putmsg3
	db		"BVS:F", 13, 10, 0
bvsok
	clv
	bvc		bvcok
	jsr		putmsg3
	db		"BVC:F", 13, 10, 0
bvcok

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Compare Instructions
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	jsr		putmsg3
	db		"test cmp/cpx/cpy", 13, 10, 0

	ld		r1,#27			; bit 7 = 0
	clc
	cmp		r1,#27
	bcs		cmperr
	bne		cmperr
	bmi		cmperr
	lda		#$A1000000
	cmp		r1,#20000000
	bpl		cmperr		; should be neg.
	sec
	lda		#10
	cmp		r1,#20			; should be a borrow here
	bcc		cmperr
	clv
	lda		#$80000000		; -128 - 32 = -160 should overflow
	cmp		r1,#$20000000		; compare doesn't affect overflow
	bvs		cmperr
	bvc		cmpok

cmperr
	jsr		putmsg
	db		"CMP:F", 13, 10, 0

cmpok
	ldx		#27
	clc
	cpx		#27
	bcs		cpxerr
	bne		cpxerr
	bmi		cpxerr
	ldx		#$A1000000
	cpx		#20000000
	bpl		cpxerr
	ldx		#10
	cpx		#20			; should be a borrow here
	bcc		cpxerr
	clv
	ldx		#$80000000		; -128 - 32 = -160 should overflow
	cpx		#$20000000		; but cpx shouldn't change overflow
	bvs		cpxerr		
	bvc		cpxok

cpxerr
	jsr		putmsg
	db		"CPX:F", 13, 10, 0

cpxok
	ldy		#27
	clc
	cpy		#27
	bcs		cpyerr
	bne		cpyerr
	bmi		cpyerr
	ldy		#$B0000000
	cpy		#20000000
	bpl		cpyerr
	ldy		#10
	cpy		#20			; should be a borrow here
	bcc		cpyerr
	clv
	ldy		#$80000000		; -128 - 32 = -160 should overflow
	cpy		#$20000000		; but cpy shouldn't change overflow
	bvs		cpyerr		
	bvc		cpyok

cpyerr
	jsr		putmsg
	db		"CPY:F", 13, 10, 0

cpyok

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Accumulator ops
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	jsr		putmsg
	db		"Test Acc ops", 13, 10, 0
; OR
	clv
	clc
	lda		#0
	or		r1,r1,#0
	bne		oraerr
	bvs		oraerr
	bmi		oraerr
	bcs		oraerr
	sec
	or		r1,r1,#0
	bcc		oraerr
	or		r1,r1,#$55
	beq		oraerr
	cmp		r1,#$55
	bne		oraerr
	or		r1,r1,#$aa
	cmp		r1,#$ff
	bne		oraerr
	beq		oraok
	
oraerr
	jsr		putmsg
	db		"ORA:F", 13, 10, 0

oraok
; SUB
	lda		#27			; bit 7 = 0
	sec
	sub		r1,r1,#27
	bcs		sbcerr1
	bne		sbcerr3
	bmi		sbcerr2
	bvs		sbcerr4
	lda		#$A1000000
	sub		r1,r1,#$20000000
	bpl		sbcerr2		; should be neg.
	cmp		r1,#$81000000
	bne		sbcerr3
	sec
	lda		#10
	sub		r1,r1,#20			; should be a borrow here
	bcc		sbcerr1
	clv
	lda		#$80000000		; -128 - 32 = -160 should overflow
	sub		r1,r1,#$20000000		; 
	bvc		sbcerr4
	bvs		sbcok

sbcerr
	bsr		putmsg
	db		"SBC:F", 13, 10, 0
	jmp		sbcok

sbcerr1
	bsr		putmsg
	db		"SBC:C", 13, 10, 0
	jmp		sbcok

sbcerr2
	jsr		putmsg
	db		"SBC2:N", 13, 10, 0
	jmp		sbcok

sbcerr3
	jsr		putmsg
	db		"SBC3:Z", 13, 10, 0
	jmp		sbcok

sbcerr4
	jsr		putmsg
	db		"SBC:V", 13, 10, 0
	jmp		sbcok

sbcok


; BIT / AND

	clv
	lda		#$ffFFFFFF
	bit		r1,n5555
	bvc		biterr
	bmi		biterr
	bit		r1,nAAAA
	bvs		biterr
	bpl		biterr
	bmi		bitok

biterr
	jsr		putmsg
	db		"BIT:F", 13, 10, 0

bitok

; PLP

	lda		#$DFFFFFFF	; leave em bit clear
	pha
	plp
	bpl 	plperr
	bvc		plperr
	bne		plperr
	bcc		plperr
	bcs		plpok

plperr
	jsr		putmsg
	db		"PLP:F", 13, 10, 0

plpok

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Load
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	jsr		putmsg
	db		"Test lda/ldx/ldy", 13, 10, 0
	
; lda

	clc
	lda		#0
	bne		ldaerr
	bmi		ldaerr
	bcs		ldaerr
	lda		#$80000000
	beq		ldaerr
	bpl		ldaerr

	lda		#$00
	st		r1,$800
	bne		ldaerr
	bmi		ldaerr
	bcs		ldaerr
	
	lda		#-1
	lda		$800
	bne		ldaerr
	bmi		ldaerr
	bcs		ldaerr
	
	cmp		r1,#0
	bne		ldaerr
	
	sec
	lda		#-1
	st		r1,$800
	beq		ldaerr
	bpl		ldaerr
	bcc		ldaerr
	
	lda		#0
	lda		$800
	beq		ldaerr
	bpl		ldaerr
	bcc		ldaerr
	
	cmp		r1,#-1
	beq		ldaok

ldaerr
	jsr		putmsg
	db		"LDA:F", 13, 10, 0

ldaok


; ldx

	clc
	lda		#$80000000		; z = 0, n = 1
	ldx		#0
	bcs		ldxerr
	bne		ldxerr
	bmi		ldxerr

	stx		$800
	bne		ldxerr
	bmi		ldxerr
	bcs		ldxerr
	
	ldx		#-1
	ldx		$800
	bne		ldxerr
	bmi		ldxerr
	bcs		ldxerr
	
	cpx		#0
	bne		ldxerr
	
	sec
	ldx		#-1
	stx		$800
	beq		ldxerr
	bpl		ldxerr
	bcc		ldxerr
	
	ldx		#0
	ldx		$800
	beq		ldxerr
	bpl		ldxerr
	bcc		ldxerr
	
	cpx		#-1
	beq		ldxok

ldxerr
	jsr		putmsg
	db		"LDX:F", 13, 10, 0


; ldy

ldxok
	clc
	lda		#$80000000		; z = 0, n = 1
	ldy		#0
	bcs		ldyerr
	bne		ldyerr
	bmi		ldyerr

	sty		$800
	bne		ldyerr
	bmi		ldyerr
	bcs		ldyerr
	
	ldy		#-1
	ldy		$800
	bne		ldyerr
	bmi		ldyerr
	bcs		ldyerr
	
	cpy		#0
	bne		ldyerr
	
	sec
	ldy		#-1
	sty		$800
	beq		ldyerr
	bpl		ldyerr
	bcc		ldyerr
	
	ldy		#0
	ldy		$800
	beq		ldyerr
	bpl		ldyerr
	bcc		ldyerr
	
	cpy		#-1
	beq		ldyok

ldyerr
	jsr		putmsg
	db		"LDY:F", 13, 10, 0

ldyok
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Test register transfers
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	jsr		putmsg
	db		"Test tax/tay/txa/tya/tsx/txs", 13, 10, 0
	
; tax

	clc
	lda		#0
	ldx		#$80000000		; z = 0, n = 1
	tax
	bcs		taxerr
	bmi		taxerr
	bne		taxerr
	
	txa
	bne		taxerr

	lda		#-1
	sec
	ldx		#0
	tax
	bcc		taxerr
	bpl		taxerr
	beq		taxerr
	
	txa
	cmp		r1,#-1
	beq		taxok

taxerr
	jsr		putmsg
	db		"TAX:F", 13, 10, 0
taxok

; tay

	clc
	lda		#0
	ldy		#$80000000			; z = 0, n = 1
	tay
	bcs		tayerr
	bmi		tayerr
	bne		tayerr
	
	tya
	bne		tayerr

	lda		#-1
	sec
	ldy		#0
	tay
	bcc		tayerr
	bpl		tayerr
	beq		tayerr
	
	tya
	cmp		r1,#-1
	beq		tayok

tayerr
	jsr		putmsg
	db		"TAY:F", 13, 10, 0
tayok


; txs

	ldx		#15
	txs
	ldx		#87
	tsx
	cpx		#15
	beq		txsok
	ldx		#$1000
	txs
	jsr		putmsg
	db		"TSX:F", 13, 10, 0
txsok
	ldx		#87
	txa
	cmp		r1,#87
	beq		txaok
	jsr		putmsg
	db		"TXA:F", 13, 10, 0
txaok
	tay
	cpy		#87
	beq		tayok1
	jsr		putmsg
	db		"TAY:F", 13, 10, 0
tayok1
	tya
	beq		tyaerr
	bmi		tyaerr
	cmp		r1,#87
	beq		tyaok
tyaerr
	jsr		putmsg
	db		"TYA:F", 13, 10, 0
tyaok

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Increment / Decrement
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	jsr		putmsg
	db		"Test inx/dex/iny/dey/ina/dea/inc/dec", 13, 10, 0

	ldx		#$FFFFFFFE
	clc
	lda		#0
	inx
	bcs		inxerr
	beq		inxerr
	bpl		inxerr
	
	cpx		#$ffFFFFFF
	bne		inxerr
	
	sec
	lda		#$80
	inx
	bcc		inxerr
	bne		inxerr
	bmi		inxerr
	
	cpx		#0
	bne		inxerr
	
	clc
;inxl1				; test loop
;	inx
;	bcs		inxerr
;	bne		inxl1
	
	sec
;inxl2
;	inx
;	bcc		inxerr
;	bne		inxl2
	
	beq		inxok
	
inxerr
	jsr		putmsg
	db		"INX:F", 13, 10, 0

inxok

;	dex

	ldx		#2
	clc
	lda		#0
	dex
	bcs		dexerr
	beq		dexerr
	bmi		dexerr
	
	cpx		#1
	bne		dexerr
	
	sec
	lda		#$80
	dex
	bcc		dexerr
	bne		dexerr
	bmi		dexerr
	
	cpx		#0
	bne		dexerr
	
	lda		#0
	dex
	beq		dexerr
	bpl		dexerr
	
	cpx		#$ffffffff
	bne		dexerr
	
	clc
;dexl1
;	dex
;	bcs		dexerr
;	bne		dexl1
	
;	sec
dexl2
;	dex
;	bcc		dexerr
;	bne		dexl2
	
	beq		dexok
	
dexerr
	jsr		putmsg
	db		"DEX:F", 13, 10, 0
	
dexok

; iny

	ldy		#$FFFFFFFE
	clc
	add		r1,r1,#0
	iny
	bcs		inyerr
	beq		inyerr
	bpl		inyerr
	
	cpy		#$ffffffff
	bne		inyerr
	
	sec
	lda		#$80
	iny
	bcc		inyerr
	bne		inyerr
	bmi		inyerr
	
	cpy		#0
	bne		inyerr
	
	clc
inyl1				; test loop
;	iny
;	bcs		inyerr
;	bne		inyl1
	
	sec
inyl2
;	iny
;	bcc		inyerr
;	bne		inyl2
	
	beq		inyok
	
inyerr
	jsr		putmsg
	db		"INY:F", 13, 10, 0


;	dey

inyok

	ldy		#2
	clc
	lda		#0
	dey
	bcs		deyerr
	beq		deyerr
	bmi		deyerr
	
	cpy		#1
	bne		deyerr
	
	sec
	lda		#$80
	dey
	bcc		deyerr
	bne		deyerr
	bmi		deyerr
	
	cpy		#0
	bne		deyerr
	
	lda		#0
	dey
	beq		deyerr
	bpl		deyerr
	
	cpy		#$ffffffff
	bne		deyerr
	
;	clc
deyl1
;	dey
;	bcs		deyerr
;	bne		deyl1
	
;	sec
deyl2
;	dey
;	bcc		deyerr
;	bne		deyl2
	
	bra		deyok
	
deyerr
	jsr		putmsg
	db		"DEY:F", 13, 10, 0
	
deyok


	lda		#1
	ina
	cmp		r1,#2
	beq		inaok
	
	jsr		putmsg
	db		"INA:F", 13, 10, 0

inaok
	
	lda		#2
	dea
	cmp		r1,#1
	beq		deaok
	
	jsr		putmsg
	db		"DEA:F", 13, 10, 0

deaok


	stp

putmsg
putmsg3
	plx				; pop the return address off the stack
pm5
	lb		r1,$0,x	; load byte into accumulator
	inx
	ora		#0		; test for end of string
	beq		pm6
	bsr		putSer
	bra		pm5
pm6
	jmp		(x)		; return to next code byte

; put character to serial port
; test and,bne,pha,pla,sta,lda,rts

putSer
	pha					; temporarily save character
ps1
	lb		r1,UART+1		; get serial port status
	and		#XMIT_FUL	; is it full ?
	bne		ps1			; If full then wait
	pla					; get back the char to write
	sb		r1,UART		; write it to the xmit register
	rts

nmirout
	rti

	align	4
n5555
	dw		$55555555
nAAAA
	dw		$AAAAAAAA
	
	dw		12
	dw		34

	org $0FFFFFFF4		; NMI vector
	dw	nmirout

	org	$0FFFFFFF8		; reset vector, native mode
	dw	start
