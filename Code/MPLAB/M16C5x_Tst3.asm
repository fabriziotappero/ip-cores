;*******************************************************************************
; M16C5x_Tst3.ASM
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

ScratchPadRAM   EQU     0x10

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

SPI_CR          EQU     0x0A        ; SPI Control Register Shadow/Working Copy
SPI_SR          EQU     0x0B        ; SPI Status Register Shadow/Working Copy
SPI_DIO_H       EQU     0x0C        ; 1st byte To/From from SPI Rcv FIFO
SPI_DIO_L       EQU     0x0D        ; 2nd byte To/From from SPI Rcv FIFO

DlyCntr         EQU     0x0F        ; General Purpose Delay Counter Register

;-------------------------------------------------------------------------------
; SPI Control Register Bit Map (M16C5x TRIS A register)
;-------------------------------------------------------------------------------

SPI_CR_REn      EQU     0           ; Enable MISO Data Capture
SPI_CR_SSel     EQU     1           ; Slv Select: 0 - Ext SEEPROM, 1 - SSP_UART
SPI_CR_MD0      EQU     2           ; SPI Md[1:0]: UART    - Mode 0 or Mode 3
SPI_CR_MD1      EQU     3           ;              SEEPROM - Mode 0 or Mode 3
SPI_CR_BR0      EQU     4           ; SPI Baud Rate: 0 - Clk/2, ... Clk/128
SPI_CR_BR1      EQU     5           ; Default: 110 - Clk/64
SPI_CR_BR2      EQU     6           ; Clk/2 29.4912 MHz
SPI_CR_DIR      EQU     7           ; SPI Shift Direction: 0 - MSB, 1 - LSB

;-------------------------------------------------------------------------------
; SPI Status Register Bit Map (M16C5x Port A input)
;-------------------------------------------------------------------------------

SPI_SR_TF_EF    EQU     0           ; SPI TF Empty Flag (All Data Transmitted)
SPI_SR_TF_FF    EQU     1           ; SPI TF Full Flag  (Possible Overrun Error)
SPI_SR_RF_EF    EQU     2           ; SPI RF Empty Flag (Data Available)
SPI_SR_RF_FF    EQU     3           ; SPI RF Full Flag  (Possible Overrun Error)
SPI_SR_DE       EQU     4           ; SSP UART RS-485 Drive Enable
SPI_SR_RTS      EQU     5           ; SSP UART Request-To-Send Modem Control Out
SPI_SR_CTS      EQU     6           ; SSP UART Clear-To-Send Modem Control Input
SPI_SR_IRQ      EQU     7           ; SSP UART Interrupt Request Output

;-------------------------------------------------------------------------------
; SSP UART Control Register (RA = 000) (16-bits Total) (Read-Write)
;-------------------------------------------------------------------------------

UART_CR_RA      EQU     3           ; Bits 7:5 SPI_DIO_H
UART_CR_WnR     EQU     1           ; Bit 4 SPI_DIO_H, Write if Set, elxe Read
UART_CR_MD      EQU     2           ; Bits 3:2 SPI_DIO_H, UART Mode: 232/485
UART_CR_RTSo    EQU     1           ; Bit 1 SPI_DIO_H, Request-To-Send Output
UART_CR_IE      EQU     1           ; Bit 0 SPI_DIO_H, Interrupt Enable
UART_CR_FMT     EQU     4           ; Bits 7:4 SPI_DIO_L, Serial Frame Format
UART_CR_BAUD    EQU     4           ; Bits 3:0 SPI_DIO_L, Serial Baud Rate

;-------------------------------------------------------------------------------
; SSP UART Status Register (RA = 001) (16-bits Total) (Read-Only)
;-------------------------------------------------------------------------------

UART_SR_RA      EQU     3           ; Bits 7:5 SPI_DIO_H
UART_SR_WnR     EQU     1           ; Bit 4 SPI_DIO_H, Ignored if Set
UART_SR_MD      EQU     2           ; Bits 4:2 SPI_DIO_H, UART Mode
UART_SR_RTSi    EQU     1           ; Bit 1 SPI_DIO_H, RTS signal level
UART_SR_CTSi    EQU     1           ; Bit 0 SPI_DIO_H, CTS signal level
UART_SR_RS      EQU     2           ; Bits 7:6 SPI_DIO_L, Rx FIFO State
UART_SR_TS      EQU     2           ; Bits 5:4 SPI_DIO_L, Tx FIFO State
UART_SR_iRTO    EQU     1           ; Bit 3 SPI_DIO_L, Rcv Timeout Interrupt
UART_SR_iRDA    EQU     1           ; Bit 2 SPI_DIO_L, Rcv Data Available
UART_SR_iTHE    EQU     1           ; Bit 1 SPI_DIO_L, Tx FIFO Half Empty
UART_SR_iTFE    EQU     1           ; Bit 0 SPI_DIO_L, Tx FIFO Empty

;-------------------------------------------------------------------------------
; SSP UART Transmit Data Register (RA = 010) (16-bits Total) (Write-Only)
;-------------------------------------------------------------------------------

UART_TD_RA      EQU     3           ; Bits 7:5 SPI_DIO_H
UART_TD_WnR     EQU     1           ; Bit 4 SPI_DIO_H, Ignored if Not Set
UART_TD_TFC     EQU     1           ; Bit 3 SPI_DIO_H, Transmit FIFO Clear/Rst
UART_TD_RFC     EQU     1           ; Bit 2 SPI_DIO_H, Receive FIFO Clear/Reset
UART_TD_HLD     EQU     1           ; Bit 1 SPI_DIO_H, Transmit delayed until 0
UART_TD_Rsvd    EQU     1           ; Bit 0 SPI_DIO_H, Reserved
UART_TD_DO      EQU     8           ; Bits 7:0 SPI_DIO_L, Tx Data: 7 or 8 bits

;-------------------------------------------------------------------------------
; SSP UART Recieve Data Register (RA = 011) (16-bits Total) (Read-Only)
;-------------------------------------------------------------------------------

UART_RD_RA      EQU     3           ; Bits 7:5 SPI_DIO_H
UART_RD_WnR     EQU     1           ; Bit 4 SPI_DIO_H, Ignored if Set
UART_RD_TRDY    EQU     1           ; Bit 3 SPI_DIO_H, Transmit Ready
UART_RD_RRDY    EQU     1           ; Bit 2 SPI_DIO_H, Receive Ready
UART_RD_RTO     EQU     1           ; Bit 1 SPI_DIO_H, Receive Time Out Detected
UART_RD_RERR    EQU     1           ; Bit 0 SPI_DIO_H, Receive Error Dectected
UART_RD_DI      EQU     8           ; Bits 7:0 SPI_DIO_L, Rx Data: 7 or 8 bits

;-------------------------------------------------------------------------------
; Set Reset/WDT Vector
;-------------------------------------------------------------------------------

                ORG     0x7FF
       
                GOTO    Start

;-------------------------------------------------------------------------------
; Main Program
;-------------------------------------------------------------------------------

                ORG     0x000

;-------------------------------------------------------------------------------

Start           MOVLW   0xFF            ; Initialize TRIS A and TRIS B to all 1s
                TRIS    5
                TRIS    6
                
                MOVLW   0x0E            ; Load W with SPI CR Initial Value
                MOVWF   SPI_CR          ; Save copy of value
                TRIS    7               ; Initialize SPI CR
                
                MOVLW   0x08            ; Delay before using SPI I/F
                MOVWF   DlyCntr
SPI_Init_Dly    DECFSZ  DlyCntr,1
                GOTO    SPI_Init_Dly
                
                MOVLW   0x1B            ; UART CR (Hi): RS485 w/o Loop Back, IE
                MOVWF   PortC           ; Output to SPI and to UART
                MOVLW   0x00            ; UART CR (Lo) Set 8N1
                MOVWF   PortC

                MOVLW   0x30            ; UART BRR (Hi) PS[3:0]
                MOVWF   PortC           ; Output to SPI and to UART
                MOVLW   0xBF            ; UART BRR (Lo) Div[7:0]
                MOVWF   PortC

WaitLp1         BTFSS   PortA, SPI_SR_TF_EF ; Wait for UART UCR, BRR output
                GOTO    WaitLp1
                
Wr_UART_TD      MOVLW   0x50            ; UART TD (Hi) RA = 2, WnR = 1
                MOVWF   PortC           ; Output to SPI and to UART
                MOVLW   0x55            ; UART TD (Lo) 0x55 = "U"
                MOVWF   PortC           ; Output to SPI and to UART

WaitLp2         BTFSS   PortA, SPI_SR_TF_EF ; Wait for UART CR data to be sent
                GOTO    WaitLp2
                
                BSF     SPI_CR, SPI_CR_REn  ; Enable SPI IF Capture MISO data
                
                MOVF    SPI_CR,0        ; Load SPI CR Shadow
                TRIS    7               ; Enable SPI I/F Receive Function   
                
Rd_UART_SR      MOVLW   0x20            ; Read UART Status Register
                MOVWF   PortC
                CLRW
                MOVWF   PortC
                
WaitLp3         BTFSC   PortA, SPI_SR_RF_EF ; Wait for UART Return Data (Hi)
                GOTO    WaitLp3
                
                MOVF    PortC,0         ; Read SPI Receive FIFO
                MOVWF   SPI_DIO_H       ; Store UART SR (hi byte)
                
                
WaitLp4         BTFSC   PortA, SPI_SR_RF_EF ; Wait for UART Return Data (Hi)
                GOTO    WaitLp4
                
                MOVF    PortC,0         ; Read SPI Receive FIFO
                MOVWF   SPI_DIO_L       ; Store UART SR (hi byte)
                
                BTFSS   SPI_DIO_L,0     ; Test UART_SR_iTFE bit
                GOTO    Rd_UART_SR      ; Loop until UART TF Empty

                BCF     SPI_CR, SPI_CR_REn  ; Disable SPI IF Capture MISO data

                MOVF    SPI_CR,0        ; Load SPI CR Shadow
                TRIS    7               ; Disable SPI I/F Receive Function   

                GOTO    Wr_UART_TD      ; Loop Forever, send 0x55 continously

;-------------------------------------------------------------------------------
				
				END

