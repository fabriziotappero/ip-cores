; project	: copyBlaze 8 bit processor
; file name	: wb_timer.asm
; author	: abdAllah Meziti
; licence	: LGPL

; this programm test the wishbone copyBlaze instruction.
; it use this module : 
; 			wb_timer_08.vhd

		WB_TIMER_TRC0		.EQU	0x00
		WB_TIMER_COMPARE0	.EQU	0x04
		WB_TIMER_COUNTER0	.EQU	0x08
		WB_TIMER_TRC1		.EQU	0x0C
		WB_TIMER_COMPARE1	.EQU	0x10
		WB_TIMER_COUNTER1	.EQU	0x14
		
		wb_data_to_wb		.EQU   s0
		wb_data_from_wb		.EQU   s1

		;

		; ==========================================================
start:
		; ==========================================================
		; enable interrupts
		EINT                          ; ENABLE INTERRUPT
		;DINT                          ; DISABLE INTERRUPT

		; initialize the wb_timer registers
		LOAD		wb_data_to_wb,		0x80				; 
		WBWRSING	wb_data_to_wb,		WB_TIMER_COMPARE0	; COMPARE0 = 0x80

		LOAD		wb_data_to_wb,		0x0e				; 
		WBWRSING	wb_data_to_wb,		WB_TIMER_TRC0		; TRC0 = 0x0e : en0=1, ar0=1, irq0en=1


		; normale operations
		load	s0,	0x00
		call	FuncLoadAllRegister
		
loopMain:
		call	FuncIncrAllRegister
		JUMP	loopMain
		
end:		
		JUMP	end
		;

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
FuncIncrAllRegister:
;		ADD      s0, 0x01		;	s0++
;		ADD      s1, 0x01		;	s1++
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
		ret

;	*************************
;	Interrupt Service Routine
;	*************************
ISR:
		WBRDSING	wb_data_from_wb,	WB_TIMER_TRC0		; access on TCR0 (reset trig0)
		;LOAD      s1, 0x55
		
		RETI      ENABLE              ; RETURNI
;		RETI      DISABLE
;	*************************
;	End ISR Interrupt Handler
;	*************************

		.ORG	0x3FF
VECTOR:
		JUMP	ISR
