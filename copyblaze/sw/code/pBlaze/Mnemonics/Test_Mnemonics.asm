;--------------------------------------------------------------------------------
;-- Company: 
;--
;-- File: Test_Mnemonics.asm
;--
;-- Description:
;--	projet bicoblaze
;--	Test of the mnemonics of the BicoBlaze3 processor
;--
;-- File history:
;-- v1.0: 11/10/11: Creation
;--
;-- Targeted device: ProAsic A3P250 VQFP100
;-- Author: AbdAllah Meziti
;--------------------------------------------------------------------------------

		LOAD      s0, 0x85	;	s0=85
		LOAD      s3, 0x42	;	s3=42
		LOAD      s7, s3	;	s7=42
		AND       s3, 0x23	;	s3=02
		AND       s7, s0	;	s7=00
		OR        s3, 0x69	;	s3=6B
		OR        s7, s0	;	s7=85
		XOR       s0, 0x42	;	s0=C7
		XOR       s0, s7	;	s0=42
		
		ADD       s0, 0x43	;	s0=85
		ADD       s0, s7	;	s0=0A (Carry=1)
		ADDC      s0, 0x42	;	s0=4D
		ADDC      s0, s7	;	s0=D2
		SUB       s0, 0xE5	;	s0=ED (Borrow=1)
		SUB       s0, s7	;	s0=68
		SUBC      s0, 0xA7	;	s0=C1 (Borrow=1)
		SUBC      s0, s7	;	s0=3B
		
		LOAD      s0, 0x43	;	s0=43
		SL0       s0		;	s0=86
		SLX       s0		;	s0=0C (Carry=1)
		SLA       s0		;	s0=19
		SL1       s0		;	s0=33
		LOAD      s0, 0xB0	;	s0=B0
		RL        s0		;	s0=61 (Carry=1)
		
		SRA       s0		;	s0=B0 (Carry=1)
		SR0       s0		;	s0=58
		SR1       s0		;	s0=AC
		SRX       s0		;	s0=D6
		LOAD      s0, 0xCD	;	s0=CD
		RR        s0		;	s0=E6
		
		OUT       s0, 0x30	;	OUT_PORT=s0=E6, PORT_ID=30
		OUT       s0, s7	;	OUT_PORT=s0=E6, PORT_ID=s7=85
		IN        s0, 0x20	;	s0=OUT_PORT=(see external value),	PORT_ID=20
		IN        s0, s7	;	s0=OUT_PORT=(see external value),	PORT_ID=s7=85

; one line macro for extra instructions
		INST      0x1234
					
		LOAD      s0, 0xB8	;	s0=B8
		COMP      s0, 0x42	;	C=0, Z=0
		COMP      s0, 0xB8	;	C=0, Z=1
		COMP      s0, 0xC9	;	C=1, Z=0
		
		LOAD      s1, 0x44	;	s1=44
		LOAD      s2, 0xB8	;	s2=B8
		LOAD      s3, 0xD9	;	s3=D9
		COMP      s0, s1	;	C=0, Z=0
		COMP      s0, s2	;	C=0, Z=1
		COMP      s0, s3	;	C=1, Z=0

		LOAD      s5, 0x3D	;	s5=3D
		TEST      s5, 0xFF	;	C=1
		TEST      s0, s1	;	(s0 and s1)
		
		LOAD      s1, 0x03	;	s1=03
		STORE     s0, 0x0A	;	Scratch(@0A)=s0=E6
		STORE     s0, s1	;	Scratch(@s1=03)=s0=E6
		FETCH     s4, 0x0A	;	s4=Scratch(@0A)=E6
		FETCH     s5, s1	;	s5=Scratch(@s1=03)=E6
		
		
		JUMP      JmpL1		; Validation
		INST      0xFFFF
		INST      0xFFFF
		INST      0xFFFF
		INST      0xFFFF

JmpL1:
		LOAD      s0, 0x03		;	s0=03
LoopL1:
		SUB       s0, 0x01		;	s0=s0-1
		JUMP      NZ, LoopL1	;	-- Validation

		JUMP      Z, JmpL2		;	-- Validation
		INST      0xFFFF
		INST      0xFFFF
		INST      0xFFFF
		INST      0xFFFF

JmpL2:
		LOAD      s0, 0x03		;	s0=03
LoopL2:
		SUB       s0, 0x01		;	s0=s0-1
		JUMP      NC, LoopL2	;	-- Validation
		
		JUMP      C, CalL1		;	-- Validation
		INST      0xFFFF
		INST      0xFFFF
		INST      0xFFFF
		INST      0xFFFF

CalL1:		
		LOAD      s0, 0x03		;	s0=03
		CALL      Function		;	-- Validation
		LOAD      s1, 0x03		;	s1=03
		LOAD      s2, 0x03		;	s2=03
		LOAD      s3, 0x03		;	s3=03
		LOAD      s4, 0x03		;	s4=03

;		CALL      NZ, Function	;	-- Validation
;		CALL      Z,  Function
;		CALL      NC, Function
		CALL      C,  Function

		load	s0,	0xBB
		call	FuncLoadAllRegister

		EINT                          ; ENABLE INTERRUPT
;		DINT                          ; DISABLE INTERRUPT

		; clear all register
		load	s0,	0x00
		call	FuncLoadAllRegister

; End LOOP
EndLoop:	
;		JUMP      EndLoop		;	-- Validation

		ADD      s0, 0x01		;	s0++
		ADD      s1, 0x01		;	s1++
		ADD      s2, 0x01		;	s2++
		ADD      s3, 0x01		;	s3++
		ADD      s4, 0x01		;	s4++
		ADD      s5, 0x01		;	s5++
		ADD      s6, 0x01		;	s6++
		ADD      s7, 0x01		;	s7++
		ADD      s8, 0x01		;	s8++
		ADD      s9, 0x01		;	s9++
		ADD      sA, 0x01		;	sA++
		ADD      sB, 0x01		;	sB++
		ADD      sC, 0x01		;	sC++
		ADD      sD, 0x01		;	sD++
		ADD      sE, 0x01		;	sE++
		ADD      sF, 0x01		;	sF++

		JUMP      EndLoop		;	-- Validation

; =====================================================================
; END OF PROGRAM
; =====================================================================

; ****************************************
; Function
; ****************************************
Function:
		LOAD      s1, 0x55		;	s1=55
		LOAD      s2, 0x55		;	s2=55
		LOAD      s3, 0x55		;	s3=55
		LOAD      s4, 0x55		;	s4=55

		RET						;	-- Validation

;		RET       NZ			;	-- Validation
;		RET       Z				;	-- Validation

;		RET       NC			;	-- Validation
;		RET       C				;	-- Validation


; ****************************************
; Load All the register with the s0 value.
; ****************************************
FuncLoadAllRegister:
;		LOAD      s0, s0		;	s0=s0
		LOAD      s1, s0		;	s1=s0
		LOAD      s2, s0		;	s2=s0
		LOAD      s3, s0		;	s3=s0
		LOAD      s4, s0		;	s4=s0
		LOAD      s5, s0		;	s5=s0
		LOAD      s6, s0		;	s6=s0
		LOAD      s7, s0		;	s7=s0
		LOAD      s8, s0		;	s8=s0
		LOAD      s9, s0		;	s9=s0
		LOAD      sA, s0		;	sA=s0
		LOAD      sB, s0		;	sB=s0
		LOAD      sC, s0		;	sC=s0
		LOAD      sD, s0		;	sD=s0
		LOAD      sE, s0		;	sE=s0
		LOAD      sF, s0		;	sF=s0
		ret
; ****************************************
; Decrement All the register by 1.
; ****************************************
FuncDecreAllRegister:
		SUB      s0, 0x02		;	s0--
		SUB      s1, 0x02		;	s1--
		SUB      s2, 0x02		;	s2--
		SUB      s3, 0x02		;	s3--
		SUB      s4, 0x02		;	s4--
		SUB      s5, 0x02		;	s5--
		SUB      s6, 0x02		;	s6--
		SUB      s7, 0x02		;	s7--
		SUB      s8, 0x02		;	s8--
		SUB      s9, 0x02		;	s9--
		SUB      sA, 0x02		;	sA--
		SUB      sB, 0x02		;	sB--
		SUB      sC, 0x02		;	sC--
		SUB      sD, 0x02		;	sD--
		SUB      sE, 0x02		;	sE--
		SUB      sF, 0x02		;	sF--
		ret

;	*************************
;	Interrupt Service Routine
;	*************************
ISR:
;		load	s0,	0xAA
		call	FuncDecreAllRegister ; ISR

;		RETI      ENABLE              ; RETURNI
		RETI      DISABLE
;	*************************
;	End ISR Interrupt Handler
;	*************************

		.ORG	0x3FF
VECTOR:
		JUMP	ISR
