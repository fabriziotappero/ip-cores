
; ============================================================================
;        __
;   \\__/ o\    (C) 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@opencores.org
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
UART		EQU		0xFFDC0A00
UART_LS		EQU		0xFFDC0A01
UART_MS		EQU		0xFFDC0A02
UART_IS		EQU		0xFFDC0A03
UART_IE		EQU		0xFFDC0A04
UART_MC		EQU		0xFFDC0A06
UART_CM1	EQU		0xFFDC0A09
UART_CM2	EQU		0xFFDC0A0A
UART_CM3	EQU		0xFFDC0A0B
txempty		EQU		0x40
rxfull		EQU		0x01

			bss
			org		0x01FBC000
Uart_rxfifo		fill.b	512,0
			org		0x7D0
Uart_rxhead		db		0
Uart_rxtail		db		0
Uart_ms			db		0
Uart_rxrts		db		0
Uart_rxdtr		db		0
Uart_rxxon		db		0
Uart_rxflow		db		0
Uart_fon		db		0
Uart_foff		db		0
Uart_txrts		db		0
Uart_txdtr		db		0
Uart_txxon		db		0
Uart_txxonoff	db		0

;==============================================================================
; Serial port
;==============================================================================
	code
;------------------------------------------------------------------------------
; Initialize the serial port
; r1 = low 28 bits = baud rate
; r2 = other settings
; The desired baud rate must fit in 28 bits or less.
;------------------------------------------------------------------------------
;
public SerialInit:
;	asl		r1,r1,#4			; * 16
;	shlui	r1,r1,#32			; * 2^32
;	inhu	r2,CR_CLOCK			; get clock frequency from config record
;	divu	r1,r1,r2			; / clock frequency

	lsr		r1,r1,#8			; drop the lowest 8 bits
	sta		UART_CM1			; set LSB
	lsr		r1,r1,#8
	sta		UART_CM2			; set middle bits
	lsr		r1,r1,#8
	sta		UART_CM3			; set MSB
	stz		Uart_rxhead			; reset buffer indexes
	stz		Uart_rxtail
	lda		#0x1f0
	sta		Uart_foff			; set threshold for XOFF
	lda		#0x010
	sta		Uart_fon			; set threshold for XON
	lda		#1
	sta		UART_IE				; enable receive interrupt only
	stz		Uart_rxrts			; no RTS/CTS signals available
	stz		Uart_txrts			; no RTS/CTS signals available
	stz		Uart_txdtr			; no DTR signals available
	stz		Uart_rxdtr			; no DTR signals available
	lda		#1
	sta		Uart_txxon			; for now
	lda		#1
	sta		SERIAL_SEMA
	rts

;---------------------------------------------------------------------------------
; Get character directly from serial port. Blocks until a character is available.
;---------------------------------------------------------------------------------
;
public SerialGetCharDirect:
sgc1:
	lda		UART_LS		; uart status
	and		#rxfull		; is there a char available ?
	beq		sgc1
	lda		UART
	rts

;------------------------------------------------
; Check for a character at the serial port
; returns r1 = 1 if char available, 0 otherwise
;------------------------------------------------
;
public SerialCheckForCharDirect:
	lda		UART_LS			; uart status
	and		#rxfull			; is there a char available ?
	rts

;-----------------------------------------
; Put character to serial port
; r1 = char to put
;-----------------------------------------
;
public SerialPutChar:
	phx
	phy
	push	r4
	push	r5

	ldx		UART_MC
	or		r2,r2,#3		; assert DTR / RTS
	stx		UART_MC
	ldx		Uart_txrts
	beq		spcb1
	ld		r4,Milliseconds
	ldy		#1000			; delay count (1 s)
spcb3:
	ldx		UART_MS
	and		r2,r2,#$10		; is CTS asserted ?
	bne		spcb1
	ld		r5,Milliseconds
	cmp		r4,r5
	beq		spcb3
	ld		r4,r5
	dey
	bne		spcb3
	bra		spcabort
spcb1:
	ldx		Uart_txdtr
	beq		spcb2
	ld		r4,Milliseconds
	ldy		#1000			; delay count
spcb4:
	ldx		UART_MS
	and		r2,r2,#$20		; is DSR asserted ?
	bne		spcb2
	ld		r5,Milliseconds
	cmp		r4,r5
	beq		spcb4
	ld		r4,r5
	dey
	bne		spcb4
	bra		spcabort
spcb2:	
	ldx		Uart_txxon
	beq		spcb5
spcb6:
	ldx		Uart_txxonoff
	beq		spcb5
	ld		r4,UART_MS
	and		r4,r4,#0x80			; DCD ?
	bne		spcb6
spcb5:
	ld		r4,Milliseconds
	ldy		#1000				; wait up to 1s
spcb8:
	ldx		UART_LS
	and		r2,r2,#0x20			; tx not full ?
	bne		spcb7
	ld		r5,Milliseconds
	cmp		r4,r5
	beq		spcb8
	ld		r4,r5
	dey
	bne		spcb8
	bra		spcabort
spcb7:
	sta		UART
spcabort:
	pop		r5
	pop		r4
	ply
	plx
	rts

;-------------------------------------------------
; Compute number of characters in recieve buffer.
; r4 = number of chars
;-------------------------------------------------
CharsInRxBuf:
	ld		r4,Uart_rxhead
	ldx		Uart_rxtail
	sub		r4,r4,r2
	bpl		cirxb1
	ld		r4,#0x200
	add		r4,r4,r2
	ldx		Uart_rxhead
	sub		r4,r4,r2
cirxb1:
	rts

;----------------------------------------------
; Get character from rx fifo
; If the fifo is empty enough then send an XON
;----------------------------------------------
;
public SerialGetChar:
	phx
	phy
	push	r4

	ldy		Uart_rxhead
	ldx		Uart_rxtail
	cmp		r2,r3
	beq		sgcfifo1		; is there a char available ?
	lda		Uart_rxfifo,x	; get the char from the fifo into r1
	inx						; increment the fifo pointer
	and		r2,r2,#$1ff
	stx		Uart_rxtail
	ldx		Uart_rxflow		; using flow control ?
	beq		sgcfifo2
	ldy		Uart_fon		; enough space in Rx buffer ?
	jsr		CharsInRxBuf
	cmp		r4,r3
	bpl		sgcfifo2
	stz		Uart_rxflow		; flow off
	ld		r4,Uart_rxrts
	beq		sgcfifo3
	ld		r4,UART_MC		; set rts bit in MC
	or		r4,r4,#2
	st		r4,UART_MC
sgcfifo3:
	ld		r4,Uart_rxdtr
	beq		sgcfifo4
	ld		r4,UART_MC		; set DTR
	or		r4,r4,#1
	st		r4,UART_MC
sgcfifo4:
	ld		r4,Uart_rxxon
	beq		sgcfifo5
	ld		r4,#XON
	st		r4,UART
sgcfifo5:
sgcfifo2:					; return with char in r1
	pop		r4
	ply
	plx
	rts
sgcfifo1:
	lda		#-1				; no char available
	pop		r4
	ply
	plx
	rts


;-----------------------------------------
; Serial port IRQ
;-----------------------------------------
;
public SerialIRQ:
	pha
	phx
	phy
	push	r4

	lda		UART_IS			; get interrupt status
	bpl		sirq1			; no interrupt
	and		#0x7f			; switch on interrupt type
	cmp		#4
	beq		srxirq
	cmp		#$0C
	beq		stxirq
	cmp		#$10
	beq		smsirq
	; unknown IRQ type
sirq1:
	pop		r4
	ply
	plx
	pla
	rti


; Get the modem status and record it
smsirq:
	lda		UART_MS
	sta		Uart_ms
	bra		sirq1

stxirq:
	bra		sirq1

; Get a character from the uart and store it in the rx fifo
srxirq:
srxirq1:
	lda		UART				; get the char (clears interrupt)
	ldx		Uart_txxon
	beq		srxirq3
	cmp		#XOFF
	bne		srxirq2
	lda		#1
	sta		Uart_txxonoff
	bra		srxirq5
srxirq2:
	cmp		#XON
	bne		srxirq3
	stz		Uart_txxonoff
	bra		srxirq5
srxirq3:
	stz		Uart_txxonoff
	ldx		Uart_rxhead
	sta		Uart_rxfifo,x		; store in buffer
	inx
	and		r2,r2,#$1ff
	stx		Uart_rxhead
srxirq5:
	lda		UART_LS				; check for another ready character
	and		#rxfull
	bne		srxirq1
	lda		Uart_rxflow			; are we using flow controls?
	bne		srxirq8
	jsr		CharsInRxBuf
	lda		Uart_foff
	cmp		r4,r1
	bmi		srxirq8
	lda		#1
	sta		Uart_rxflow
	lda		Uart_rxrts
	beq		srxirq6
	lda		UART_MC
	and		#$FD			; turn off RTS
	sta		UART_MC
srxirq6:
	lda		Uart_rxdtr
	beq		srxirq7
	lda		UART_MC
	and		#$FE			; turn off DTR
	sta		UART_MC
srxirq7:
	lda		Uart_rxxon
	beq		srxirq8
	lda		#XOFF
	sta		UART
srxirq8:
	bra		sirq1


