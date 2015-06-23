; ============================================================================
; FAC1ToString.asm
;        __
;   \\__/ o\    (C) 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@finitron.ca
;       ||
;  
;
; This source file is free software: you can redistribute it and/or modify 
; it under the terms of the GNU Lesser General Public License as published 
; by the Free Software Foundation, either version 3 of the License, or     
; (at your option) any later version.                                      
;                                                                          
; This source file is distributed in the hope that it will be useful,      
; but WITHOUT ANY WARRANTY; without even the implied warranty of           
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
; GNU General Public License for more details.                             
;                                                                          
; You should have received a copy of the GNU General Public License        
; along with this program.  If not, see <http://www.gnu.org/licenses/>.    
;                                                                          
; ============================================================================
;
; This code is a heavily modified version of the floating point to string
; conversion routine which is a part of Lee Davison's EhBASIC.
;
Cvaral		= $95		; current var address low byte
Cvarah		= Cvaral+1	; current var address high byte
numexp		= $A8		; string to float number exponent count
expcnt		= $AA		; string to float exponent count
Sendl			= $BA	; BASIC pointer temp low byte
Sendh			= $BB	; BASIC pointer temp low byte

Decss		= $3A0		; number to decimal string start
Decssp1		= Decss+1	; number to decimal string start
FP_ADD		EQU		1
FP_SUB		EQU		2
FP_MUL		EQU		3
FP_DIV		EQU		4
FP_FIX2FLT	EQU		5
FP_FLT2FIX	EQU		6
FP_ABS		EQU		7
FP_NEG		EQU		16
FP_SWAP		EQU		17
FIXED_MUL	EQU		$83
FIXED_ADD	EQU		$81
FIXED_SUB	EQU		$82
;parameter FIXED_DIV = 8'h84;
;parameter FIXED_ABS = 8'h87;
;parameter FIXED_NEG = 8'h90;
FP_CMDREG	EQU		$FEA20E
FP_STATREG	EQU		$FEA20E
FAC1		EQU		$FEA200
FAC1_5		EQU		$FEA200
FAC1_4		EQU		$FEA202
FAC1_3		EQU		$FEA204
FAC1_2		EQU		$FEA206
FAC1_1		EQU		$FEA208
FAC1_msw	EQU		$FEA208
FAC1_e		EQU		$FEA20A
FAC2		EQU		$FEA210

	CPU		W65C816S
	NDX		16
	MEM		16
	

public FAC1ToString:

; The first chunk of code determines if the number is positive or negative
; and spits out the appropriate sign. Next it takes the absolute value of
; the accumulator so following code only has to deal with positive numbers.

	LDY	#$00			; set index = 1
	LDA	FAC1_msw		; test FAC1 sign (b15) (Can't use BIT)
	BPL	.0002		; branch if +ve
	LDA	#'-'			; else character = "-"
	STA	Decss,Y		; save leading character (" " or "-")
	LDA	#FP_NEG		; make the FAC positive
	JSR	FPCommandWait
	BRA	.0001
.0002:
	LDA	#$20			; character = " " (assume +ve)
	STA	Decss,Y
.0001:
	STY	Sendl			; save index

; This little bit of code check for a zero exponent which indicates a
; value of zero.

	LDA	FAC1_e		; get FAC1 exponent
	TAX
	BNE	LAB_2989		; branch if FAC1<>0
					; exponent was $00 so FAC1 is 0
	LDA	#'0'			; set character = "0"
	BRL	LAB_2A89		; save last character, [EOT] and exit

; This loop attempts to make small values more significant, so that there are
; fewer leading zeros in the value. (The exponent is decremented so that it
; corresponds). Because of the potential for extremely small values looping is
; limited. The problem is the 16 bit exponent can allow for much smaller
; values than an 8 bit exponent would and we don't want to loop for thousands
; of iterations in order to display a value that's almost zero.

					; FAC1 is some non zero value
LAB_2989
	STY	Sendl			; save off .Y
	LDY #1639			; max number of retries
	LDA	#$00			; clear (number exponent count)
	STA numexp
LOOP_MBMILLION:
	CPX	#$8000			; compare FAC1 exponent with $8000 (>1.00000)
	BCS	LAB_299A		; branch if FAC1=>1
					; FAC1<1
	PEA	A_MILLION		; multiply FAC * 1,000,000
	JSR	LOAD_FAC2		; 
	PLA					; get rid of parameter
	JSR	FMUL
	LDA numexp
	SEC
	SBC	#6				; set number exponent count (-6)
	STA numexp
	LDA FAC1_e
	TAX
	DEY
	BPL	LOOP_MBMILLION

LAB_299A
	LDY	Sendl		; get back .Y

; These two loops coerce the value of the FAC to be between 100,000 and
; 1,000,000. This gives a maximum of six digits before the decimal point
; in scientific notation.

; This loop divides by 10 until the value in the FAC is less than 1,000,000
;
LOOP_DB10:
	PEA	MAX_BEFORE_SCI	; set pointer low byte to 999999.4375 (max before sci note)
	JSR	LOAD_FAC2		; compare FAC1 with (AY)
	PLA					; get rid of parameter
	LDA FP_CMDREG
	BIT	#$08			; test equals bit
	BNE	LAB_29C3		; exit if FAC1 = (AY)
	BIT	#$04			; test greater than bit
	BEQ	LOOP_MB10		; go do *10 if FAC1 < (AY)

LAB_29B9
	JSR	DivideByTen		; divide by 10
	INC	numexp			; increment number exponent count
	BRA	LOOP_DB10		; go test again (branch always)

; This loop multiplies the value by 10 until it's greater than
; 100,000.
					; FAC1 < (AY)
LOOP_MB10
	PEA CONST_9375		; set pointer to 99999.9375
	JSR	LOAD_FAC2		; compare FAC1 with (AY)
	PLA					; get rid of parameter
	LDA FP_CMDREG
	BIT #$08
	BNE	LAB_29B2		; branch if FAC1 = (AY) (allow decimal places)
	BIT #$04
	BNE	LAB_29C0		; branch if FAC1 > (AY) (no decimal places)
					; FAC1 <= (AY)
LAB_29B2
	JSR	MultiplyByTen	; multiply by 10
	DEC	numexp		; decrement number exponent count
	BRA	LOOP_MB10		; go test again (branch always)

; now we have just the digits to do

LAB_29C0
;	JSR	AddPoint5		; add 0.5 to FAC1 (round FAC1)
LAB_29C3
;	JSR	FloatToFixed	; convert FAC1 floating-to-fixed
	LDX	#$01			; set default digits before dp = 1
	LDA	numexp		; get number exponent count
	CLC				; clear carry for add
	ADC	#$07			; up to 6 digits before point
	BMI	LAB_29D8		; if -ve then 1 digit before dp

	CMP	#$08			; A>=8 if n>=1E6
	BCS	LAB_29D9		; branch if >= $08

					; carry is clear
	TAX				; copy to A
	DEX				; take 1 from digit count
	LDA	#$02			;.set exponent adjust

LAB_29D8
	SEC				; set carry for subtract
LAB_29D9
	SBC	#$02			; -2
	STA	expcnt		;.save exponent adjust
	STX	numexp		; save digits before dp count
	TXA				; copy to A
	BEQ	LAB_29E4		; branch if no digits before dp

	BPL	LAB_29F7		; branch if digits before dp

LAB_29E4
	LDY	Sendl			; get output string index
	LDA	#'.'			; character "."
	INY				; increment index
	STA	Decss,Y		; save to output string
	TXA				;.
	BEQ	LAB_29F5		;.

	LDA	#'0'			; character "0"
	INY				; increment index
	STA	Decss,Y		; save to output string
LAB_29F5
	STY	Sendl			; save output string index

LAB_29F7
	LDX	#'0'			; holds onto the digit value

; Now loop subtracting 100,000 as many times as we can. The value was coerced
; to be between 100,000 and 1,000,000. Count the number of times subtraction
; can be done successfully.
;
LAB_29FB
	PEA CONST_100000
	JSR LOAD_FAC2	; load FAC2 with 100,000
	PLA				; get rid of parameter
	LDA FP_STATREG
	BIT #$04		; Is FAC1 > 100,000 ?
	BEQ	.0005		; branch if not
	LDA #FP_SWAP	; subtract is FAC2-FAC1!
	JSR FPCommandWait;
	LDA #FP_SUB		; subtract 100,000 from the mantissa.
	JSR FPCommandWait
	INX				; increment the value of the digit
	BRA	LAB_29FB	; try again
.0005:
	TXA
	LDY	Sendl			; get output string index
	INY				; increment output string index
	TXA
	STA	Decss,Y		; save to output string
	DEC	numexp		; decrement # of characters before the dp
	BNE	LAB_2A3B		; branch if still characters to do
				; else output the point
	LDA	#'.'			; character "."
	INY				; increment output string index
	STA	Decss,Y		; save to output string
LAB_2A3B
	STY	Sendl		; save output string index
	; We subtracted until the value was < 100,000 so multiply the
	; remainder upwards to get the next digit.
	JSR	MultiplyByTen	; If not, multiply by 10
	CPY #27			; converted (+/- . incl)
	BCC	LAB_29F7
					; now remove trailing zeroes
.RemoveTrailingZeros
	LDA	Decss,Y		; get character from output string
	AND	#$FF		; mask to a byte
	DEY				; decrement output string index
	CMP	#'0'			; compare with "0"
	BEQ	.RemoveTrailingZeros	; loop until non "0" character found

	CMP	#'.'			; compare with "."
	BEQ	LAB_2A58		; branch if was dp

					; restore last character
	INY				; increment output string index
LAB_2A58
	LDA	#'+'			; character "+"
	LDX	expcnt		; get exponent count
	LBEQ	LAB_2A8C		; if zero go set null terminator and exit

					; exponent isn't zero so write exponent
	BPL	LAB_2A68		; branch if exponent count +ve

	LDA	#$00			; clear A
	SEC				; set carry for subtract
	SBC	expcnt		; subtract exponent count adjust (convert -ve to +ve)
	TAX				; copy exponent count to X
	LDA	#'-'			; character "-"

; We must keep moving forwards through the string because the acc is storing
; two bytes.

LAB_2A68
	PHA
	LDA	#'E'			; character "E"
	STA	Decss+1,Y		; save exponent sign to output string
	PLA
	STA	Decss+2,Y		; save to output string
	TXA				; get exponent count back

; do highest exponent digit
	STZ Sendl
	LDX	#'0'-1		; one less than "0" character
	SEC				; set carry for subtract
.0001:				
	INX				; count how many times we can subtract 10,000
	SBC	#10000
	BCS .0001
	ADC #10000
	CPX #'0'
	BEQ .0005
	INC Sendl
	PHA
	TXA
	STA Decss+3,Y
	PLA
	INY
; do the next exponent digit
.0005:
	LDX #'0'-1
	SEC
.0002:
	INX
	SBC #1000
	BCS .0002
	ADC #1000
	LSR Sendl
	BCS .00010
	CPX #'0'
	BEQ .0006
.00010:
	INC Sendl
	PHA
	TXA
	STA Decss+3,Y
	PLA
	INY
; and the next
.0006:
	LDX	#'0'-1
	SEC
.0003:
	INX
	SBC #100
	BCS .0003
	ADC #100
	LSR Sendl
	BCS .00011
	CPX #'0'
	BEQ .0007
.00011:
	INC Sendl
	PHA
	TXA
	STA Decss+3,Y
	PLA
	INY

.0007:
	LDX #'0'-1
	SEC
.0004:
	INX
	SBC #10
	BCS .0004
	ADC #10
	LSR Sendl
	BCS .00012
	CPX #'0'
	BEQ .0008
.00012:
	INC Sendl
	PHA
	TXA
	STA Decss+3,Y
	PLA
	INY

.0008:
	ADC #'0'
	STA Decss+3,Y
	LDA	#$00			; set null terminator
	STA	Decss+4,Y		; save to output string
	RTS					; go set string pointer (AY) and exit (branch always)

LAB_2A89
	STA	Decss,Y		; save last character to output string
					; set null terminator and exit
LAB_2A8C
	LDA	#$00			; set null terminator
	STA	Decss+1,Y		; save after last character

LAB_2A91
;	LDA	#<Decssp1		; set result string low pointer
;	LDY	#>Decssp1		; set result string high pointer
	RTS

LAB_25FB:
	LDA		#FP_SWAP
	JSR		FPCommandWait
	LDY		#0
	TYX
.0002:
	LDA		(3,S),Y
	STA		FAC1,X
	INY
	INY
	INX
	INX
	CPX		#12
	BNE		.0002
	LDA		#FP_FIX2FLT
	JSR		FPCommandWait
FMUL:
	LDA		#FP_MUL
	JMP		FPCommandWait
	
LOAD_FAC2:
	PHX
	PHY
	LDY		#0
	TYX
.0002:
	LDA		(7,s),Y
	STA		FAC2,X
	INY
	INY
	INX
	INX
	CPX		#12
	BNE		.0002
	PLY
	PLX
	RTS
	
FloatToFixed:
	LDA		#FP_FLT2FIX
	JMP		FPCommandWait
	
AddPoint5:
	PEA		CONST_POINT5
	JSR		LOAD_FAC2
	PLA
	LDA		#FP_ADD
	JMP		FPCommandWait
	
MultiplyByTen:
	PEA		TEN_AS_FLOAT
	JSR		LOAD_FAC2
	PLA
	LDA		#FP_MUL
	JMP		FPCommandWait
	
public DivideByTen:
	PEA		TEN_AS_FLOAT
	JSR		LOAD_FAC2
	PLA
	JSR		SwapFACs
	LDA		#FP_DIV
	JMP		FPCommandWait
	
SwapFACs:
	LDA		#FP_SWAP

; Issue a command to the FP unit and wait for it to complete
;
public FPCommandWait:
	PHA
.0001:
	LDA		FP_STATREG	; get the status register
	BIT		#$80		; check for busy bit
	BNE		.0001		; if busy go back
	PLA					; to pop acc
	STA		FP_CMDREG	; store the command
	RTS

; Display the FAC1 as a hex number
;
public DispFAC1:
	LDA FAC1_e
	JSR DispWord
	LDA	FAC1_1
	JSR	DispWord
	LDA FAC1_2
	JSR	DispWord
	LDA FAC1_3
	JSR DispWord
	LDA FAC1_4
	JSR DispWord
	LDA FAC1_5
	JSR DispWord
	LDA #' '
	JSR OutChar
	RTS
;
; 1,000,000 as a floating point number
;
A_MILLION:	; $F4240
	dw		$0000
	dw		$0000
	dw		$0000
	dW		$0000
	dw		$7A12
	dw		$8013

CONST_100000:
	;186A0
	dw		$0000
	dw		$0000
	dw		$0000
	dw		$0000
	dw		$61A8
	dw		$8010
; The constant 999999.4375 as hex
; 01.11_1010_0001_0001_1111_1011_1000_00000000000000000000000000
MAX_BEFORE_SCI:
	dw  $0000
	dw  $0000
	dw	$0000
	dw	$FB80
	dw	$7A11
	dw	$8013

TEN_AS_FLOAT:
	dw	$0000
	dw	$0000
	dw	$0000
	dw	$0000
	dw	$5000
	dw	$8003

; 99999.9375
; 01.10_0001_1010_0111_1111_1100_000000000000000000000000000000
;
CONST_9375:
	dw	$0000
	dw	$0000
	dw	$0000
	dw	$FC00
	dw	$61A7
	dw	$8010

; 0.5
CONST_POINT5:
	dw	$0000
	dw	$0000
	dw	$0000
	dw	$0000
	dw	$4000
	dw	$7FFF

; This table is used in converting numbers to ASCII.

LAB_2A9A
LAB_2A9B = LAB_2A9A+1
LAB_2A9C = LAB_2A9B+1
;	.word	$FFFF,$F21F,$494C,$589C,$0000
;	.word	$0000,$0163,$4578,$5D8A,$0000
;	.word	$FFFF,$FFDC,$790D,$903F,$0000
;	.word	$0000,$0003,$8D7E,$A4C6,$8000
;	.word	$FFFF,$FFFF,$A50C,$EF85,$C000
;	.word	$0000,$0000,$0918,$4E72,$A000
;	.word	$FFFF,$FFFF,$FF17,$2B5A,$F000
;	.word	$0000,$0000,$0017,$4876,$E800
;	.word	$FFFF,$FFFF,$FFFD,$ABF4,$1C00
;	.word	$0000,$0000,$0000,$3B9A,$CA00
;	.word	$FFFF,$FFFF,$FFFF,$FF67,$6980
;	.word	$0000,$0000,$0000,$05F5,$E100		; 100000000
;	.word	$0000,$0000,$0098,$9680		; 10000000
;	.word   $4240,$000F,$0000,$0000,$0000,$804E		; 1000000
	.word	$86A0,$0001,$0000,$0000,$0000,$804E		; 100000
	.word	$2710,$0000,$0000,$0000,$0000,$804E		; 10000
	.word	$03E8,$0000,$0000,$0000,$0000,$804E		; 1000
	.word	$0064,$0000,$0000,$0000,$0000,$804E		; 100
FIXED10:
	.word	$000A,$0000,$0000,$0000,$0000,$804E		; 10
	.word	$0001,$0000,$0000,$0000,$0000,$804E		; 1

		 MEM	16
		 NDX	16
