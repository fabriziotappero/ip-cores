; Source project: http://code.google.com/p/hmc-6502/
;
	.ORG $4000
start:
; EXPECTED FINAL RESULTS: $0210 = FF
; (any other number will be the 
;  test that failed)

; initialize:
	LDA #$00
	STA $0210
	; store each test's expected
	LDA #$55
	STA $0200
	LDA #$AA
	STA $0201
	LDA #$FF
	STA $0202
	LDA #$6E
	STA $0203
	LDA #$42
	STA $0204
	LDA #$33
	STA $0205
	LDA #$9D
	STA $0206
	LDA #$7F
	STA $0207
	LDA #$A5
	STA $0208
	LDA #$1F
	STA $0209
	LDA #$CE
	STA $020A
	LDA #$29
	STA $020B
	LDA #$42
	STA $020C
	LDA #$6C
	STA $020D
	LDA #$42
	STA $020E
	

; expected result: $022A = 0x55
test00:
   	LDA #85
	LDX #42
	LDY #115
	STA $81
	LDA #$01
	STA $61
	LDA #$7E
	LDA $81
	STA $0910
	LDA #$7E
	LDA $0910
	STA $56,X
	LDA #$7E
	LDA $56,X
	STY $60
	STA ($60),Y
	LDA #$7E
	LDA ($60),Y
	STA $07ff,X
	LDA #$7E
	LDA $07ff,X
	STA $07ff,Y
	LDA #$7E
	LDA $07ff,Y
	STA ($36,X)
	LDA #$7E
	LDA ($36,X)
	STX $50
	LDX $60
	LDY $50
	STX $0913
	LDX #$22
	LDX $0913
	STY $0914
	LDY #$99
	LDY $0914
	STY $2D,X
	STX $77,Y
	LDY #$99
	LDY $2D,X
	LDX #$22
	LDX $77,Y
	LDY #$99
	LDY $08A0,X
	LDX #$22
	LDX $08A1,Y
	STA $0200,X
	
; CHECK test00:
	LDA $022A
	CMP $0200
	BEQ test00pass
	JMP theend
test00pass:
	LDA #$FE
	STA $0210
	
	
; expected result: $A9 = 0xAA
test01:
	; imm
	LDA #85
	AND #83
	ORA #56
	EOR #17
	
	; zpg
	STA $99
	LDA #185
	STA $10
	LDA #231
	STA $11
	LDA #57
	STA $12
	LDA $99
	AND $10
	ORA $11
	EOR $12
	
	; zpx
	LDX #16
	STA $99
	LDA #188
	STA $20
	LDA #49
	STA $21
	LDA #23
	STA $22
	LDA $99
	AND $10,X
	ORA $11,X
	EOR $12,X
	
	; abs
	STA $99
	LDA #111
	STA $0110
	LDA #60
	STA $0111
	LDA #39
	STA $0112
	LDA $99
	AND $0110
	ORA $0111
	EOR $0112
	
	; abx
	STA $99
	LDA #138
	STA $0120
	LDA #71
	STA $0121
	LDA #143
	STA $0122
	LDA $99
	AND $0110,X
	ORA $0111,X
	EOR $0112,X
	
	; aby
	LDY #32
	STA $99
	LDA #115
	STA $0130
	LDA #42
	STA $0131
	LDA #241
	STA $0132
	LDA $99
	AND $0110,Y
	ORA $0111,Y
	EOR $0112,Y
	
	; idx
	STA $99
	LDA #112
	STA $30
	LDA #$01
	STA $31
	LDA #113
	STA $32
	LDA #$01
	STA $33
	LDA #114
	STA $34
        LDA #$01
        STA $35
	LDA #197
	STA $0170
	LDA #124
	STA $0171
	LDA #161
	STA $0172
	LDA $99
	AND ($20,X)
	ORA ($22,X)
	EOR ($24,X)
	
	; idy
	STA $99
	LDA #96
	STA $40
	LDA #$01
	STA $41
	LDA #97
	STA $42
	LDA #$01
	STA $43
	LDA #98
	STA $44
	LDA #$01
	STA $45
	LDA #55
	STA $0250
	LDA #35
	STA $0251
	LDA #157
	STA $0252
	LDA $99
	LDY #$F0
	AND ($40),Y
	ORA ($42),Y
	EOR ($44),Y
	
	STA $A9
	
; CHECK test01
	LDA $A9
	CMP $0201
	BEQ test02
	LDA #$01
	STA $0210
	JMP theend
	
	
; expected result: $71 = 0xFF
test02:
	LDA #$FF
	LDX #$00
	
	STA $90
	INC $90
	INC $90
	LDA $90
	LDX $90
	
	STA $90,X
	INC $90,X
	LDA $90,X
	LDX $91
	
	STA $0190,X
	INC $0192
	LDA $0190,X
	LDX $0192
	
	STA $0190,X
	INC $0190,X
	LDA $0190,X
	LDX $0193
	
	STA $0170,X
	DEC $0170,X
	LDA $0170,X
	LDX $0174
	
	STA $0170,X
	DEC $0173
	LDA $0170,X
	LDX $0173

	STA $70,X
	DEC $70,X
	LDA $70,X
	LDX $72
	
	STA $70,X
	DEC $71
	DEC $71
	
; CHECK test02
	LDA $71
	CMP $0202
	BEQ test03
	LDA #$02
	STA $0210
	JMP theend
	
	
; expected result: $01DD = 0x6E
test03:
	LDA #$4B
	LSR A
	ASL A
	
	STA $50
	ASL $50
	ASL $50
	LSR $50
	LDA $50
	
	LDX $50
	ORA #$C9
	STA $60
	ASL $4C,X
	LSR $4C,X
	LSR $4C,X
	LDA $4C,X
	
	LDX $60
	ORA #$41
	STA $012E
	LSR $0100,X
	LSR $0100,X
	ASL $0100,X
	LDA $0100,X
	
	LDX $012E
	ORA #$81
	STA $0100,X
	LSR $0136
	LSR $0136
	ASL $0136
	LDA $0100,X
	
	; rol & ror
	
	ROL A
	ROL A
	ROR A
	STA $70
	
	LDX $70
	ORA #$03
	STA $0C,X
	ROL $C0
	ROR $C0
	ROR $C0
	LDA $0C,X
	
	LDX $C0
	STA $D0
	ROL $75,X
	ROL $75,X
	ROR $75,X
	LDA $D0
	
	LDX $D0
	STA $0100,X
	ROL $01B7
	ROL $01B7
	ROL $01B7
	ROR $01B7
	LDA $0100,X
	
	LDX $01B7
	STA $01DD
	ROL $0100,X
	ROR $0100,X
	ROR $0100,X
	
; CHECK test03
	LDA $01DD
	CMP $0203
	BEQ test04
	LDA #$03
	STA $0210
	JMP theend
	
	
; expected result: $40 = 0x42
test04:
	LDA #$E8 ;originally:#$7C
	STA $20
	LDA #$42 ;originally:#$02
	STA $21
	LDA #$00
	ORA #$03
	JMP jump1
	ORA #$FF ; not done
jump1:
	ORA #$30
	JSR subr
	ORA #$42
	JMP ($0020)
	ORA #$FF ; not done
subr:
	STA $30
	LDX $30
	LDA #$00
	RTS
final:
	STA $0D,X
	
; CHECK test04
	LDA $40
	CMP $0204
	BEQ test05
	LDA #$04
	STA $0210
	JMP theend
	

; expected result: $40 = 0x33
test05:
	LDA #$35
	
	TAX
	DEX
	DEX
	INX
	TXA
	
	TAY
	DEY
	DEY
	INY
	TYA
	
	TAX
	LDA #$20
	TXS
	LDX #$10
	TSX
	TXA
	
	STA $40
	
; CHECK test05
	LDA $40
	CMP $0205
	BEQ test06
	LDA #$05
	STA $0210
	JMP theend
	
	
; expected result: $30 = 9D
test06:

; RESET TO CARRY FLAG = 0
	ROL A

	LDA #$6A
	STA $50
	LDA #$6B
	STA $51
	LDA #$A1
	STA $60
	LDA #$A2
	STA $61
	
	LDA #$FF
	ADC #$FF
	ADC #$FF
	SBC #$AE
	
	STA $40
	LDX $40
	ADC $00,X
	SBC $01,X
		
	ADC $60
	SBC $61
	
	STA $0120
	LDA #$4D
	STA $0121
	LDA #$23
	ADC $0120
	SBC $0121
	
	STA $F0
	LDX $F0
	LDA #$64
	STA $0124
	LDA #$62
	STA $0125
	LDA #$26
	ADC $0100,X
	SBC $0101,X

	STA $F1
	LDY $F1
	LDA #$E5
	STA $0128
	LDA #$E9
	STA $0129
	LDA #$34
	ADC $0100,Y
	SBC $0101,Y
	
	STA $F2
	LDX $F2
	LDA #$20
	STA $70
	LDA #$01
	STA $71
	LDA #$24
	STA $72
	LDA #$01
	STA $73
	ADC ($41,X)
	SBC ($3F,X)
	
	STA $F3
	LDY $F3
	LDA #$DA
	STA $80
	LDA #$00
	STA $81
	LDA #$DC
	STA $82
	LDA #$00
	STA $83
	LDA #$AA
	ADC ($80),Y
	SBC ($82),Y
	STA $30
	
; CHECK test06
	LDA $30
	CMP $0206
	BEQ test07
	LDA #$06
	STA $0210
	JMP theend
	
	
; expected result: $15 = 0x7F
test07:
	; prepare memory	
	LDA #$00
	STA $34
	LDA #$FF
	STA $0130
	LDA #$99
	STA $019D
	LDA #$DB
	STA $0199
	LDA #$2F
	STA $32
	LDA #$32
	STA $4F
	LDA #$30
	STA $33
	LDA #$70
	STA $AF
	LDA #$18
	STA $30
	
	; imm
	CMP #$18
	BEQ beq1 ; taken
	AND #$00 ; not done
beq1:
	; zpg
	ORA #$01
	CMP $30
	BNE bne1 ; taken
	AND #$00 ; not done
bne1:
	; abs
	LDX #$00
	CMP $0130
	BEQ beq2 ; not taken
	STA $40
	LDX $40
beq2:
	; zpx
	CMP $27,X
	BNE bne2 ; not taken
	ORA #$84
	STA $41
	LDX $41
bne2:
	; abx
	AND #$DB
	CMP $0100,X
	BEQ beq3 ; taken
	AND #$00 ; not done
beq3:
	; aby
	STA $42
	LDY $42
	AND #$00
	CMP $0100,Y
	BNE bne3 ; taken
	ORA #$0F ; not done
bne3:
	; idx
	STA $43
	LDX $43
	ORA #$24
	CMP ($40,X)
	BEQ beq4 ; not taken
	ORA #$7F
beq4:
	; idy
	STA $44
	LDY $44 
	EOR #$0F
	CMP ($33),Y
	BNE bne4 ; not taken
	LDA $44
	STA $15
bne4:

; CHECK test07
	LDA $15
	CMP $0207
	BEQ test08
	LDA #$07
	STA $0210
	JMP theend


; expected result: $42 = 0xA5
test08:
	; prepare memory
	LDA #$A5
	STA $20
	STA $0120
	LDA #$5A
	STA $21
	
	; cpx imm...
	LDX #$A5
	CPX #$A5
	BEQ b1 ; taken
	LDX #$01 ; not done
b1:
	; cpx zpg...
	CPX $20
	BEQ b2 ; taken
	LDX #$02 ; not done
b2:
	; cpx abs...
	CPX $0120
	BEQ b3 ; taken
	LDX #$03 ; not done
b3:
	; cpy imm...
	STX $30
	LDY $30
	CPY #$A5
	BEQ b4 ; taken
	LDY #$04 ; not done
b4:
	; cpy zpg...
	CPY $20
	BEQ b5 ; taken
	LDY #$05 ; not done
b5:
	; cpy abs...
	CPY $0120
	BEQ b6 ; taken
	LDY #$06 ; not done
b6:	
	; bit zpg...
	STY $31
	LDA $31
	BIT $20
	BNE b7 ; taken
	LDA #$07 ; not done
b7:
	; bit abs...
	BIT $0120
	BNE b8 ; taken
	LDA #$08 ; not done
b8:
	BIT $21
	BNE b9 ; not taken
	STA $42	
b9:

; CHECK test08
	LDA $42
	CMP $0208
	BEQ test09
	LDA #$08
	STA $0210
	JMP theend


; expected result: $80 = 0x1F
test09:
	; prepare memory
	LDA #$54
	STA $32
	LDA #$B3
	STA $A1
	LDA #$87
	STA $43
	
	; BPL
	LDX #$A1
	BPL bpl1 ; not taken
	LDX #$32
bpl1:
	LDY $00,X
	BPL bpl2 ; taken
	LDA #$05 ; not done
	LDX $A1 ; not done
bpl2:

	; BMI
	BMI bmi1 ; not taken
	SBC #$03
bmi1:
	BMI bmi2 ; taken
	LDA #$41 ; not done
bmi2:

	; BVC
	EOR #$30
	STA $32
	ADC $00,X
	BVC bvc1 ; not taken
	LDA #$03
bvc1:
	STA $54
	LDX $00,Y
	ADC $51,X
	BVC bvc2 ; taken
	LDA #$E5 ; not done
bvc2:

	; BVS
	ADC $40,X
	BVS bvs1 ; not taken
	STA $0001,Y
	ADC $55
bvs1:
	BVS bvs2 ; taken
	LDA #$00
bvs2:

	; BCC
	ADC #$F0
	BCC bcc1 ; not taken
	STA $60
	ADC $43
bcc1:
	BCC bcc2 ; taken
	LDA #$FF
bcc2:

	; BCS
	ADC $54
	BCS bcs1 ; not taken
	ADC #$87
	LDX $60
bcs1:	
	BCS bcs2 ; taken
	LDA #$00 ; not done
bcs2:
	STA $73,X
	
; CHECK test09
	LDA $80
	CMP $0209
	BEQ test10
	LDA #$09
	STA $0210
	JMP theend

	
; expected result: $30 = 0xCE
test10:

; RESET TO CARRY = 0 & OVERFLOW = 0
	ADC #$00

	LDA #$99
	ADC #$87
	CLC
	NOP
	BCC t10bcc1 ; taken
	ADC #$60 ; not done
	ADC #$93 ; not done
t10bcc1:
	SEC
	NOP
	BCC t10bcc2 ; not taken
	CLV
t10bcc2:
	BVC t10bvc1 ; taken
	LDA #$00 ; not done
t10bvc1: 
	ADC #$AD
	NOP
	STA $30
	
; CHECK test10
	LDA $30
	CMP $020A
	BEQ test11
	LDA #$0A
	STA $0210
	JMP theend
	
	
; expected result: $30 = 0x29
test11:

; RESET TO CARRY = 0 & ZERO = 0
	ADC #$01
	
	LDA #$27
	ADC #$01
	SEC
	PHP
	CLC
	PLP
	ADC #$00
	PHA
	LDA #$00
	PLA
	STA $30
	
; CHECK test11
	LDA $30
	CMP $020B
	BEQ test12
	LDA #$0B
	STA $0210
	JMP theend
	
	
; expected result: $33 = 0x42
test12:
	CLC
	LDA #$42
	BCC runstuff
	STA $33
	BCS t12end
runstuff:
	LDA #$45
	PHA
	LDA #$61
	PHA
	SEC
	PHP
	CLC
	RTI
t12end:

; CHECK test12
	LDA $33
	CMP $020C
	BEQ test13
	LDA #$0C
	STA $0210
	JMP theend
	
	
; expected result: $21 = 0x6C (simulator)
;                  $21 = 0x0C (ours)
test13:

; RESET TO CARRY = 0 & ZERO = 0
	ADC #$01
	
	SEI
	SED
	PHP
	PLA
	STA $20
	CLI
	CLD
	PHP
	PLA
	ADC $20
	STA $21

; CHECK test13
	LDA $21
	CMP $020D
	BEQ test14
	LDA #$0D
	STA $0210
	JMP theend


; expect result: $60 = 0x42
test14:
	; !!! NOTICE: BRK doesn't work in this
	; simulator, so commented instructions 
	; are what should be executed...
	;JMP pass_intrp
	LDA #$41
	STA $60
	;RTI
	;pass_intrp:
	;LDA #$FF
	;STA $60
	;BRK (two bytes)
	INC $60
	
; CHECK test14
	LDA $60
	CMP $020E
	BEQ suiteafinal
	LDA #$0E
	STA $0210
	JMP theend

suiteafinal:
	; IF $0210 == 0xFE, INCREMENT
	; (checking that it didn't 
	;  happen to wander off and 
	;  not run our instructions
	;  to say which tests failed...)
	LDA #$FE
	CMP $0210
	BNE theend
	INC $0210
theend:
	JMP theend
