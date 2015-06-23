;*******************************************************************************
; M16C5x_Tst2.ASM
;
;	This is the source for the test program used to develop the PIC16C5x proce-
;	core. It has also been used to test the P16C5x version of the PIC16C5x core.
;
;	The first instruction of the program is expected to be placed in location 0.
;
;	The program tests most instructions, but not is a self-checking manner. In-
;	spection of the registers is the method used to verify that the cores are
;	operating correctly.
;
;*******************************************************************************

        LIST P=16F59, R=DEC

;-------------------------------------------------------------------------------
;   Set ScratchPadRam here.  If you are using a PIC16C5X device, use: 
;ScratchPadRam EQU     0x10
;   Otherwise, use:
;ScratchPadRam EQU     0x20
;-------------------------------------------------------------------------------

ScratchPadRam   EQU     0x0A

;-------------------------------------------------------------------------------
; Variables
;-------------------------------------------------------------------------------

INDF			EQU		0			; Indirect Register File Access Location
Tmr0			EQU		1			; Timer 0
PCL				EQU		2			; Low Byte Program Counter
Status			EQU		3			; Processor Status Register
FSR				EQU		4			; File Select Register
PortA			EQU		5			; I/O Port A Address
PortB			EQU		6			; I/O Port B Address
PortC			EQU		7			; I/O Port C Address

Cntr       		EQU     ScratchPadRam+0
MemStart		EQU		ScratchPadRam+1
Count			EQU		32-MemStart

DelayLoop		EQU		ScratchPadRam+0

;-------------------------------------------------------------------------------
; Set Reset/WDT Vector
;-------------------------------------------------------------------------------

                ORG     H'7FF'
       
                GOTO    Start

;-------------------------------------------------------------------------------
; Main Program
;-------------------------------------------------------------------------------

                ORG     H'000'

;-------------------------------------------------------------------------------
Start			BTFSS   Status,3	;; Test PD (STATUS.3), if 1, ~SLEEP restart
                GOTO    SleepRestart   	;; SLEEP restart, continue test program
                MOVLW   0x07    	;; load OPTION
                OPTION
                CLRW            	;; clear working register
                TRIS	PortA       ;; load W into port control registers
                TRIS	PortB
                TRIS	PortC
;
;               GOTO    Next   		;; Test GOTO
;
				GOTO	Next
;
                MOVLW   0xFF    	;; instruction should be skipped
;
Next        	CALL    Subroutine	;; Test CALL

                MOVWF   PCL    		;; Test Computed GOTO, Load PCL with W
                NOP             	;; No Operation

Subroutine		RETLW   Subroutine + 1	;; Test RETLW, return 0x0E in W

                MOVLW   MemStart	;; starting RAM + 1
                MOVWF   FSR    		;; indirect address register (FSR)
;-------------------------------------------------------------------------------
                MOVLW   Count    	;; internal RAM count - 1
                MOVWF   Cntr   		;; loop counter
                MOVLW	0xAA       	;; zero working register
;
Loop1			MOVWF   INDF    	;; clear RAM indirectly
                INCF    FSR,1  		;; increment FSR
                DECFSZ  Cntr,1  	;; decrement loop counter
                GOTO    Loop1  		;; loop until loop counter == 0
;
                MOVLW   MemStart   	;; starting RAM + 1
                MOVWF   FSR    		;; reload FSR
                MOVLW   (256 - Count)	;; set loop counter to 256 - 23
				MOVWF   Cntr
;
Loop2			COMF    INDF,1  	;; Complement Memory Pattern from Loop 1
				INCF	FSR,1		;; Increment Indirect Pointer to Memory
                INCFSZ  Cntr,1  	;; increment counter loop until 0
                GOTO    Loop2   	;; loop    
;
                CLRF    Cntr    	;; Clear Memory Location 0x08
;-------------------------------------------------------------------------------
				DECF    Cntr,1  	;; Decrement Memory Location 0x08
                ADDWF   Cntr,0  	;; Add Memory Location 0x08 to W, Store in W
                SUBWF   Cntr,1  	;; Subtract Memory Location 0x08
                RLF     Cntr,1  	;; Rotate Memory Location 0x08
                RRF     Cntr,1  	;; Rotate Memory Location
                MOVLW   0x69    	;; Load W with test pattern: W <= 0x69
                MOVWF   (MemStart - 1)    ;; Initialize Memory with test pattern
                SWAPF   Cntr,1  	;; Test SWAPF: (0x08) <= 0x96 
                IORWF   Cntr,1  	;; Test IORWF: (0x08) <= 0x69 | 0x96 
                ANDWF   Cntr,1  	;; Test ANDWF: (0x08) <= 0x69 & 0xFF
                XORWF   Cntr,1  	;; Test XORWF: (0x08) <= 0x69 ^ 0x69
                COMF    Cntr    	;; Test COMF:  (0x08) <= ~0x00  
                IORLW   0x96    	;; Test IORLW:      W <= 0x69 | 0x96
                ANDLW   0x69    	;; Test ANDLW:      W <= 0xFF & 0x69
                XORLW   0x69    	;; Test XORLW:      W <= 0x69 ^ 0x69
;                SLEEP           	;; Stop Execution of test program: HALT
				GOTO	PortTst
;-------------------------------------------------------------------------------
SleepRestart	CLRWDT          	;; Detected SLEEP restart, Clr WDT to reset PD
                BTFSC   Status,3  	;; Check STATUS.3, skip if ~PD clear
                GOTO    Continue   	;; ~PD is set, CLRWDT cleared PD
ErrorLoop       GOTO    ErrorLoop   ;; ERROR: hold here on error
;
Continue		MOVLW   0x10    	;; Load FSR with non-banked RAM address
                MOVWF   FSR    		;; Initialize FSR for Bit Processor Tests
                CLRF    INDF    	;; Clear non-banked RAM location using INDF
                BSF     Status,0  	;; Set   STATUS.0 (C) bit 
                BCF     Status,1  	;; Clear STATUS.1 (DC) bit
                BCF     Status,2  	;; Clear STATUS.2 (Z) bit
                MOVF    Status,0  	;; Load W with STATUS
                RRF     INDF,0  	;; Rotate Right RAM location: C <= 0,      W <= 0x80
                RLF     INDF,0  	;; Rotate Left  RAM location: C <= 0, (INDF) <= 0x00
                MOVWF   INDF    	;; Write result back to RAM: (INDF) <= 0x80
                MOVWF   Tmr0    	;; Write to TMR0, clear Prescaler
                GOTO    Start   	;; Restart Program
;-------------------------------------------------------------------------------
;PortTst
;
;                MOVLW   0xAA    	;; Load W with 0xAA
;                MOVWF   PortA    	;; WE_PortA
;                MOVWF   PortB    	;; WE_PortB
;                MOVWF   PortC    	;; WE_PortC
;                MOVF    PortA,0  	;; RE_PortA
;                MOVF    PortB,0  	;; RE_PortB
;                MOVF    PortC,0  	;; RE_PortC
;                COMF    PortA,1    ;; Complement PortA
;                COMF    PortB,1    ;; Complement PortB
;                COMF    PortC,1    ;; Complement PortC
;                CLRF    PortA    	;; Clear PortA
;                CLRF    PortB    	;; Clear PortB
;                CLRF    PortC    	;; Clear PortC
;                CLRW            	;; zero working register
;
;
PortTst			DECF	0x0C,1
				MOVF	0x0C,0
				MOVWF	PortA
;
				CALL	Delay
;
				GOTO	PortTst

;
;	Delay Subroutine
;
Delay			NOP
;
				MOVLW	0xEE
				MOVWF	0x0A
				MOVLW	0x01
				MOVWF	0x0B
;
DelayLp			DECFSZ	0x0A,1		;; Decrement Delay Low
				GOTO	DelayLp
				CLRWDT				;; Tickle WDT
				DECFSZ	0x0B,1		;; Decrement Delay High
				GOTO	DelayLp
;
				RETLW	0x00
;-------------------------------------------------------------------------------
				END

