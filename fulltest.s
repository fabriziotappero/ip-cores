	nop
	lda	#13
	sta	first
	ldb	#5
	add
	sta	second
	lda	second
	neg
	sta	third
	ldb	third
	add
	sta	fourth
	jmp	24
	jmp	NEXT
NEXT	lda	#1
	ldb	#1
	addc
	sta	fifth
	jmp	GO
	jmp 	250
GO	lda	#255
	ror
	sta	sixth
	ldb	#1
	add
	and
	sta	seventh
	ldb	#0
	lda	#1
	add
	sta	eigth
	ldb	#255
	jmpz	250
	lda	#1
	ldb	#1
	exor
	ldb	#3
	or
	sta	nineth
	lda	#1
	sra
	sta	tenth
	lda	tenth
	nop
	ldb	tenth
	exor
	ldb	#1
	add
	sta	el
	lda	#0
	neg
	ldb	#0
	and
	ldb	#0
	or
	lda	#0
	ldb	#0
	add
	ror
	sra
	addc
	lda	#0
	sta	zero
	lda	zero
	ldb	zero
	jmpz	JUMPING
	nop
JUMPING	jmpc	AGAIN
	nop
AGAIN	lda	#255
	ldb	#1
	add
	jmpc	FIN
	nop
FIN	lda	#1
	ldb	#1
	lda	#0
	jmpz 	250
	nop
	nop
	111
	123
	9
	8
	134
	233
	162
	165
	67
	71

.mem 228
zero	db 0

.mem 230
first	db 0
second	db 0
third	db 0
fourth	db 0
fifth	db 0
sixth	db 0
seventh	db 0
eighth	db 0
ninth	db 0
tenth	db 0
el	db 0
