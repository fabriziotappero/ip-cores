; 345678901234567890123456789012345678901234567890123456789012345678901234567890
; Copyright (c) 2010, Robert Hayes
; SKIPJACK ENCRYPT/DECRYPT for xgate RISC processor core
; Bob Hayes - August 7, 2010
;  Version 0.1 Basic SKIPJACK Encrypt and Decrypt modules for the Xgate
;   processor. These routines do the basic codebook encrypt and decrypt
;   functions, other modes of use such as output feedback,cipher feedback and
;   cipher block chaining can be added at the host code level or the routines
;   could be expanded to incorporate the required functionality.

; This implementation is believed to be compliant with the SKIPJACK algorithm
;  as described in "SKIPJACK and KEA Algorithm Specifications" Version 2.0
;  dated 29 May 1998, which is available from the National Institute for
;  Standards and Technology:
;	http://csrc.nist.gov/groups/STM/cavp/documents/skipjack/skipjack.pdf

;
; This source file is free software: you can redistribute it and/or modify
; it under the terms of the GNU Lesser General Public License as published
; by the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; Supplemental terms.
;     * Redistributions of source code must retain the above copyright
;       notice, this list of conditions and the following disclaimer.
;     * Neither the name of the <organization> nor the
;       names of its contributors may be used to endorse or promote products
;       derived from this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.


	CPU	XGATE

	ORG	$fe00
	DS.W	2 	; reserve two words at channel 0, always unused for thread
	; channel 1
	DC.W	SK_ENCRYPT	; point to start address
	DC.W	ROUND_E   	; point to initial variables (Loaded into R1)
	; channel 2
	DC.W	SK_DECRYPT	; point to start address
	DC.W	ROUND_D   	; point to initial variables (Loaded into R1)
	; channel 3
	DC.W	_ERROR		; point to start address
	DC.W	V_PTR   	; point to initial variables


	ORG	$2000	; Setup a data storage area

V_PTR	EQU	123


;-------------------------------------------------------------------------------
;   Constants used for offset caculations from R1 of SKIPJACK RAM variables.
;    These offsets are used by both encrypt and decrypt routines.
;-------------------------------------------------------------------------------
SK_ROUND	EQU	0
SK_W1		EQU	2
SK_W2		EQU	4
SK_W3		EQU	6
SK_W4		EQU	8
SK_KEY1		EQU	10
SK_KEY2		EQU	12
SK_KEY3		EQU	14
SK_KEY4		EQU	16
SK_KEY5		EQU	18
SK_KEY_P	EQU	20
SK_F_P		EQU	22

;-------------------------------------------------------------------------------
;   RAM Variables for Skipjack Encryption
;-------------------------------------------------------------------------------
ROUND_E  DC.W	$55aa					; R1+0
PT	 DC.B	$33,$22,$11,$00,$dd,$cc,$bb,$aa		; R1+2
KEYE_N	 DS.W	5					; R1+10
KEYE_PTR DS.W	1					; R1+20
F_PTR_E	 DC.W	F_TABLE					; R1+22

KEY	DC.B	$99,$00,$77,$88,$55,$66,$33,$44,$11,$22
; R1 can only be used to explictly address the first 32 bytes


;-------------------------------------------------------------------------------
;   Variables for Skipjack Decryption
;-------------------------------------------------------------------------------
	ALIGN	1
ROUND_D  DC.W	$55aa					; R1+0
CT	 DC.B	$25,$87,$ca,$e2,$7a,$12,$d3,$00		; R1+2
KEYD_N	 DS.W	5					; R1+10
KEYD_PTR DS.W	1					; R1+20
F_PTR_D	 DC.W	F_TABLE					; R1+22

KEYD	DC.B	$99,$00,$77,$88,$55,$66,$33,$44,$11,$22
; R1 can only be used to explictly address the first 32 bytes

	ALIGN	1

;-------------------------------------------------------------------------------
;   Place where undefined interrupts go
;-------------------------------------------------------------------------------
_ERROR
        LDL	R2,#$04    ; Sent Message to Testbench Error Register
	LDH     R2,#$80
	LDL     R3,#$ff
	STB     R3,(R2,#0)

        SIF
	RTS


;-------------------------------------------------------------------------------
;   Skipjack Encryption
;-------------------------------------------------------------------------------
SK_ENCRYPT
;--- Only used for testbench, Delete for production release --------------------
	LDL	R2,#$00    ; Sent Message to Testbench Check Point Register
	LDH     R2,#$80
	LDL     R3,#$01
	STB     R3,(R2,#0)
	STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register
;-------------------------------------------------------------------------------

	; Copy and invert key so we can use the native XNOR functions
	;  Because this is only required to be done once the Host may implement
	;  the key inversion and then this code could be deleted.
	LDL     R3,#KEY
	LDH     R3,#KEY>>8   ; R3 is address of KEY

	LDW	R6,(R3,#0)
	COM	R6
	STW	R6,(R1,#SK_KEY1)
	LDW	R6,(R3,#2)
	COM	R6
	STW	R6,(R1,#SK_KEY2)
	LDW	R6,(R3,#4)
	COM	R6
	STW	R6,(R1,#SK_KEY3)
	LDW	R6,(R3,#6)
	COM	R6
	STW	R6,(R1,#SK_KEY4)
	LDW	R6,(R3,#8)
	COM	R6
	STW	R6,(R1,#SK_KEY5)

; The following code to initialize the F Table pointer could be done by the host
;  to save a few cycles of execution since it is only needed to be done once.
	LDL     R5,#F_TABLE
	LDH     R5,#F_TABLE>>8   	; R5 is address of F Table Pointer
	STW	R5,(R1,#SK_F_P)		; Save F Table Pointer

; Start of the SKIPJACK encrypt code
	AND	R3,R3,R0		; Clear R3
	STW	R3,(R1,#SK_ROUND)	; Save initial Round Counter
	LDL	R3,#SK_KEY1		; Set the initial Key counter value
	STW	R3,(R1,#SK_KEY_P)	; Save Key counter initial value

SKE_LOOP:
	LDW	R3,(R1,#SK_KEY_P)	; Get Key Counter value
	LDW	R7,(R1,R3+)		; Get word of Key
	CMPL	R3,#(SK_KEY5+2)		; Check for rollover
	BNE	SKE_K1_OK		; Branch if rollover
	LDL	R3,#SK_KEY1		; Set the initial Key counter value

SKE_K1_OK:
	STW	R3,(R1,#SK_KEY_P)	; Save Key Pointer
	LDW	R5,(R1,#SK_F_P)		; Get F Table Base Address
	LDL	R4,#$70			; Set Bitfield extract field
	LDW	R6,(R1,#SK_W1)		; Get W1
	TFR	R2,PC	   		; Subroutine Call
	BRA	CALC_G

	LDW	R3,(R1,#SK_KEY_P)	; Get Key Counter
	LDW	R7,(R1,R3+)		; Get word of Key
	CMPL	R3,#(SK_KEY5+2)		; Check for rollover
	BNE	SKE_K2_OK		; Branch if not rollover
	LDL	R3,#SK_KEY1		; Set the initial Key counter value

SKE_K2_OK:
	STW	R3,(R1,#SK_KEY_P)	; Save Key Pointer
	TFR	R2,PC	   		; Subroutine Call
	BRA	CALC_G

	LDW	R3,(R1,#SK_ROUND)	; Load Round Counter
	BITL	R3,#8			;
	BNE	SKE_RUL_B		; Do rule B when bit 3 of round counter is set

SKE_RUL_A:
	ADDL	R3,#1			; Update the Round Counter
	LDW	R5,(R1,#SK_W4)		; Get W4
	XNOR	R5,R6,R5
	XNOR	R5,R5,R3		; XOR the Round counter
	LDW	R7,(R1,#SK_W2)		; Load W2=NEXT_W3
	BRA	SKE_SHIFT		; R5=NEXT_W1, R6=NEXT_W2, R7=NEXT_W3

SKE_RUL_B:
	ADDL	R3,#1			; Update Round Counter
	LDW	R7,(R1,#SK_W1)		; Get W1
	XNOR	R7,R7,R3		; XNOR W1 and Round Counter
	LDW	R5,(R1,#SK_W2)		; Load W2
	XNOR	R7,R5,R7		; XNOR previous result with W2
	LDW	R5,(R1,#SK_W4)		; Load W4=NEXT_W1

SKE_SHIFT:
	STW	R3,(R1,#SK_ROUND)	; Save the Round Counter
	STW	R5,(R1,#SK_W1)		; Store New W1
	STW	R6,(R1,#SK_W2)		; Store New W2
	LDW	R6,(R1,#SK_W3)		; Load W3
	STW	R6,(R1,#SK_W4)		; Store New W4
	STW	R7,(R1,#SK_W3)		; Store New W3

	CMPL	R3,#31			; Check for last round
BRKP_3	BLS	SKE_LOOP


;--- Only used for testbench, Delete for production release --------------------
	LDL	R2,#$00    ; Sent Message to Testbench Check Point Register
	LDH     R2,#$80
	LDL     R3,#$02
	STB     R3,(R2,#0)
;-------------------------------------------------------------------------------

	SIF
	RTS


CALC_G
	BFEXT	R3,R6,R4	; Copy low byte of W1 to R3
	BFINSX	R3,R7,R4	; XNOR the low byte of W1 with the low byte of KEY_N
	ADD	R3,R3,R5	; Caculate full F Table byte address
	LDB	R3,(R3,#0)	; Get F Table output
	ROL	R6,#8		; Move the high byte of W1 to the low byte of R6
	BFINSX	R6,R3,R4	; XNOR the high byte of W1 with the F table output
	BFINS	R3,R6,R4	; Copy low byte
	ROL	R6,#8		; Put low byte of W1 back to the low byte of R6

	ROL	R7,#8		; Move the high byte of KEY_N to the low byte of R7
	BFINSX	R3,R7,R4	; XNOR temp with the high byte of KEY_N

	ANDH	R3,#0		; Clear R3 high byte
	ADD	R3,R3,R5	; Caculate full F Table byte address
	LDB	R3,(R3,#0)	; Get F Table output
	BFINSX	R6,R3,R4	; XNOR the low byte of W1 with the F table output

	JAL	R2		; Jump to return address


;-------------------------------------------------------------------------------
;   Skipjack Decryption
;-------------------------------------------------------------------------------
SK_DECRYPT
;--- Only used for testbench, Delete for production release --------------------
	LDL	R2,#$00    ; Sent Message to Testbench Check Point Register
	LDH     R2,#$80
	LDL     R3,#$02
	STB     R3,(R2,#0)
	STB     R3,(R2,#2) ; Send Message to clear Testbench interrupt register
;-------------------------------------------------------------------------------

	; Copy and invert key so we can use the native XNOR functions
	;  Because this is only required to be done once the Host may implement
	;  the key inversion and then this code could be deleted.
	LDL     R3,#KEYD
	LDH     R3,#KEYD>>8   ; R3 is address of KEY

	LDW	R6,(R3,#0)
	COM	R6
	STW	R6,(R1,#SK_KEY1)
	LDW	R6,(R3,#2)
	COM	R6
	STW	R6,(R1,#SK_KEY2)
	LDW	R6,(R3,#4)
	COM	R6
	STW	R6,(R1,#SK_KEY3)
	LDW	R6,(R3,#6)
	COM	R6
	STW	R6,(R1,#SK_KEY4)
	LDW	R6,(R3,#8)
	COM	R6
	STW	R6,(R1,#SK_KEY5)

; The following code to initialize the F Table pointer could be done by the host
;  to save a few cycles of execution since it is only needed to be done once.
	LDL     R5,#F_TABLE
	LDH     R5,#F_TABLE>>8   	; R5 is address of F Table Pointer
	STW	R5,(R1,#SK_F_P)		; Save F Table Pointer

; Start of the SKIPJACK decrypt code
	LDL	R3,#32			;
	STW	R3,(R1,#SK_ROUND)	; Save initial Round Counter
	LDL	R3,#SK_KEY5		; Set the initial Key counter value
	STW	R3,(R1,#SK_KEY_P)	; Save Key counter initial value

SKD_LOOP:
	LDW	R3,(R1,#SK_KEY_P)	; Get Key Counter value
	LDW	R7,(R1,-R3)		; Get word of Key
	CMPL	R3,#(SK_KEY1)		; Check for rollover
	BNE	SKD_K1_OK		; Branch if rollover
	LDL	R3,#(SK_KEY5+2)		; Set the initial Key counter value

SKD_K1_OK:
	STW	R3,(R1,#SK_KEY_P)	; Save Key Pointer
	LDW	R5,(R1,#SK_F_P)		; Get F Table Base Address
	LDL	R4,#$70			; Set Bitfield extract field
	LDW	R6,(R1,#SK_W2)		; Get W2
	TFR	R2,PC	   		; Subroutine Call
	BRA	CALC_GN

	LDW	R3,(R1,#SK_KEY_P)	; Get Key Counter
	LDW	R7,(R1,-R3)		; Get word of Key
	CMPL	R3,#(SK_KEY1)		; Check for rollover
	BNE	SKD_K2_OK		; Branch if not rollover
	LDL	R3,#(SK_KEY5+2)		; Set the initial Key counter value

SKD_K2_OK:
	STW	R3,(R1,#SK_KEY_P)	; Save Key Pointer
	TFR	R2,PC	   		; Subroutine Call
	BRA	CALC_GN			; Return with the new W1 in R6

	LDW	R3,(R1,#SK_ROUND)	; Load Round Counter
	MOV	R4,R3			; Copy R3 to R4
	SUBL	R4,#1			; New Round Counter used to pick Rule A or B
	BITL	R4,#8			;
	BNE	SKD_RUL_B		; Do rule B when bit 3 of round counter is set

SKD_RUL_A:
	LDW	R5,(R1,#SK_W2)		; Get W2
	LDW	R2,(R1,#SK_W1)		; Get W1
	XNOR	R5,R2,R5
	XNOR	R5,R5,R3		; XOR the Round counter
	LDW	R7,(R1,#SK_W3)		; Load R7=NEXT_W2
	BRA	SKD_SHIFT		; R6=NEXT_W1, R7=NEXT_W2, R5=NEXT_W4

SKD_RUL_B:
	LDW	R5,(R1,#SK_W3)		; Get W3
	XNOR	R7,R6,R3		; XNOR G and Round Counter
	XNOR	R7,R7,R5		; XNOR W3 R7=NEXT_W2
	LDW	R5,(R1,#SK_W1)		; Load R5=NEXT_W4

SKD_SHIFT:
	STW	R4,(R1,#SK_ROUND)	; Save the Round Counter
	STW	R6,(R1,#SK_W1)		; Store New W1
	LDW	R6,(R1,#SK_W4)		; Load W4
	STW	R6,(R1,#SK_W3)		; Store New W3
	STW	R7,(R1,#SK_W2)		; Store New W2
	STW	R5,(R1,#SK_W4)		; Store New W4

	CMPL	R4,#1
BRKP_1	BHS	SKD_LOOP


;--- Only used for testbench, Delete for production release --------------------
	LDL	R2,#$00    ; Sent Message to Testbench Check Point Register
	LDH     R2,#$80
	LDL     R3,#$02
	STB     R3,(R2,#0)
;-------------------------------------------------------------------------------
	SIF
	RTS


CALC_GN
BRKP_2	ROL	R7,#8		; Flip bytes of KEY_N
	ROL	R6,#8		; Flip bytes of W2
	BFEXT	R3,R6,R4	; Copy high byte of W2 to R3
	BFINSX	R3,R7,R4	; XNOR the high byte of W2 with the high byte of KEY_N
	ADD	R3,R3,R5	; Caculate full F Table byte address
	LDB	R3,(R3,#0)	; Get F Table output
	ROL	R6,#8		; Swap the bytes of W2 back to starting place
	BFINSX	R6,R3,R4	; XNOR the low byte of W2 with the F table output

	ROL	R7,#8		; Flip bytes of KEY_N back to starting place
	BFEXT	R3,R6,R4	; Copy low byte of W2 to R3
	BFINSX	R3,R7,R4	; XNOR W2 final with the low byte of KEY_N

	ADD	R3,R3,R5	; Caculate full F Table byte address
	LDB	R3,(R3,#0)	; Get F Table output
	ROL	R6,#8		; Put high byte of W2 to the low byte of R6
	BFINSX	R6,R3,R4	; XNOR the high byte of W2 with the F table output
	ROL	R6,#8		; Put high byte of W2 back to the high byte of R6

	JAL	R2		; Jump to return address

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

; Note locations in the $8000 range are used by the testbench

	ORG	$8040

; These memory locations are read by the testbench debugger to trigger
;  register captures when the saved address if used
BREAK_CAPT_0	DC.W	SKD_K1_OK
BREAK_CAPT_1	DC.W	BRKP_1
BREAK_CAPT_2	DC.W	BRKP_2
BREAK_CAPT_3	DC.W	$0000
BREAK_CAPT_4	DC.W	SKE_LOOP
BREAK_CAPT_5	DC.W	BRKP_3
BREAK_CAPT_6	DC.W	SKD_LOOP
BREAK_CAPT_7	DC.W	BRKP_1

	ORG	$9000

; This is the inverted F Table that is used by the G Function
F_TABLE:
        DC.B      $5C,$28,$F6,$7C,$07,$B7,$09,$0B
        DC.B      $4C,$DE,$EA,$87,$66,$4E,$50,$06
        DC.B      $18,$D2,$B2,$75,$31,$B3,$35,$D1
        DC.B      $AD,$6A,$26,$E1,$B1,$C7,$BB,$D7
        DC.B      $F5,$20,$FD,$5F,$E8,$0E,$9F,$97
        DC.B      $ED,$48,$85,$3C,$16,$05,$C2,$AC
        DC.B      $69,$7B,$94,$45,$0D,$9C,$65,$E6
        DC.B      $83,$51,$1A,$0A,$08,$E9,$95,$5D
        DC.B      $C6,$49,$84,$F0,$3E,$6C,$7E,$E4
        DC.B      $11,$4B,$E5,$15,$2F,$6E,$D0,$47
        DC.B      $AA,$46,$25,$7A,$C0,$BE,$40,$1F
        DC.B      $A5,$A7,$7F,$A0,$99,$F4,$27,$6F
        DC.B      $CA,$2A,$3F,$58,$CC,$F9,$9A,$96
        DC.B      $BA,$FF,$6B,$A9,$92,$67,$64,$89
        DC.B      $68,$03,$4D,$3D,$4F,$01,$24,$DF
        DC.B      $1E,$14,$29,$1B,$22,$B8,$B5,$E2
        DC.B      $BD,$12,$61,$91,$B6,$C3,$32,$BC
        DC.B      $D8,$2D,$F8,$2B,$21,$38,$98,$E7
        DC.B      $76,$34,$CF,$E0,$72,$39,$70,$55
        DC.B      $37,$8B,$23,$36,$A2,$A3,$CE,$5B
        DC.B      $8F,$77,$9E,$D3,$60,$F2,$D4,$78
        DC.B      $AF,$7D,$AB,$9B,$D9,$82,$FC,$BF
        DC.B      $CB,$B4,$E3,$8C,$2E,$3B,$02,$C4
        DC.B      $33,$04,$80,$54,$19,$C1,$A4,$5A
        DC.B      $52,$FB,$DC,$63,$EB,$AE,$DD,$0F
        DC.B      $D6,$86,$8E,$81,$00,$73,$F1,$1D
        DC.B      $F3,$10,$43,$8D,$8A,$90,$C8,$5E
        DC.B      $13,$2C,$71,$9D,$74,$79,$EF,$17
        DC.B      $F7,$88,$EE,$41,$6D,$B0,$DB,$3A
        DC.B      $CD,$C9,$62,$30,$0C,$59,$44,$53
        DC.B      $A1,$93,$56,$EC,$A8,$DA,$4A,$1C
        DC.B      $42,$57,$C5,$FE,$FA,$A6,$D5,$B9

;-------------------------------------------------------------------------------
; This is the un-inverted F Table and it is included for reference only
;  Not required
        DC.B      $a3,$d7,$09,$83,$f8,$48,$f6,$f4
        DC.B      $b3,$21,$15,$78,$99,$b1,$af,$f9
        DC.B      $e7,$2d,$4d,$8a,$ce,$4c,$ca,$2e
        DC.B      $52,$95,$d9,$1e,$4e,$38,$44,$28
        DC.B      $0a,$df,$02,$a0,$17,$f1,$60,$68
        DC.B      $12,$b7,$7a,$c3,$e9,$fa,$3d,$53
        DC.B      $96,$84,$6b,$ba,$f2,$63,$9a,$19
        DC.B      $7c,$ae,$e5,$f5,$f7,$16,$6a,$a2
        DC.B      $39,$b6,$7b,$0f,$c1,$93,$81,$1b
        DC.B      $ee,$b4,$1a,$ea,$d0,$91,$2f,$b8
        DC.B      $55,$b9,$da,$85,$3f,$41,$bf,$e0
        DC.B      $5a,$58,$80,$5f,$66,$0b,$d8,$90
        DC.B      $35,$d5,$c0,$a7,$33,$06,$65,$69
        DC.B      $45,$00,$94,$56,$6d,$98,$9b,$76
        DC.B      $97,$fc,$b2,$c2,$b0,$fe,$db,$20
        DC.B      $e1,$eb,$d6,$e4,$dd,$47,$4a,$1d
        DC.B      $42,$ed,$9e,$6e,$49,$3c,$cd,$43
        DC.B      $27,$d2,$07,$d4,$de,$c7,$67,$18
        DC.B      $89,$cb,$30,$1f,$8d,$c6,$8f,$aa
        DC.B      $c8,$74,$dc,$c9,$5d,$5c,$31,$a4
        DC.B      $70,$88,$61,$2c,$9f,$0d,$2b,$87
        DC.B      $50,$82,$54,$64,$26,$7d,$03,$40
        DC.B      $34,$4b,$1c,$73,$d1,$c4,$fd,$3b
        DC.B      $cc,$fb,$7f,$ab,$e6,$3e,$5b,$a5
        DC.B      $ad,$04,$23,$9c,$14,$51,$22,$f0
        DC.B      $29,$79,$71,$7e,$ff,$8c,$0e,$e2
        DC.B      $0c,$ef,$bc,$72,$75,$6f,$37,$a1
        DC.B      $ec,$d3,$8e,$62,$8b,$86,$10,$e8
        DC.B      $08,$77,$11,$be,$92,$4f,$24,$c5
        DC.B      $32,$36,$9d,$cf,$f3,$a6,$bb,$ac
        DC.B      $5e,$6c,$a9,$13,$57,$25,$b5,$e3
        DC.B      $bd,$a8,$3a,$01,$05,$59,$2a,$46
;-------------------------------------------------------------------------------


_BENCH	DS.W	8


