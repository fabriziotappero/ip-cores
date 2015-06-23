
; ============================================================================
;        __
;   \\__/ o\    (C) 2013, 2014  Robert Finch, Stratford
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
; ReadTemp.asm                                                                         
; ============================================================================
;
;--------------------------------------------------------------------------
; ReadTemp
;    Read and display the temperature from a DS1626 temperature sensor
; device. RTF65002 source code.
;--------------------------------------------------------------------------
DS1626_CMD	=$FFDC0300
DS1626_DAT	=$FFDC0301
; Commands
START_CNV = $51;
STOP_CNV = $22;
READ_TEMP = $AA;
READ_CONFIG = $AC;
READ_TH = $A1;
READ_TL = $A2;
WRITE_TH = $01;
WRITE_TL = $02;
WRITE_CONFIG = $0C;
POR = $54;

public ReadTemp:
	lda		CONFIGREC	; Do we even have a temperature sensor ?
	bit		#$10
	beq		rdtmp3		; If not, output '0.000'
rdtmp1:
	; On power up the DS1626 interface circuit sends a power on reset (POR)
	; command to the DS1626. Waiting here makes sure this command has been
	; completed.
	jsr		rdt_busy_wait
	lda		#$0F			; 12 bits resolution, cpu mode, one-shot mode
	sta		DS1626_DAT
	lda		#WRITE_CONFIG	; write the desired config to the device
	sta		DS1626_CMD
	jsr		rdt_busy_wait
	lda		#10
	jsr		tSleep
	lda		#0
	sta		DS1626_DAT
	lda		#START_CNV		; issue a start conversion command
	sta		DS1626_CMD
	jsr		rdt_busy_wait
	lda		#10
	jsr		tSleep
	; Now poll the config register to determine when the conversion has completed.
rdtmp2:
	lda		#READ_CONFIG	; issue the READ_CONFIG command
	sta		DS1626_CMD
	jsr		rdt_busy_wait
	pha
	lda		#10				; Wait a bit before checking again. The conversion
	jsr		tSleep			; can take up to 1s to complete.
	pla
	bit		#$80			; test done bit
	beq		rdtmp2			; loop back if not done conversion
	lda		#0
	sta		DS1626_DAT		; issue a stop conversion command
	lda		#STOP_CNV
	sta		DS1626_CMD
	jsr		rdt_busy_wait
	lda		#10
	jsr		tSleep
	lda		#READ_TEMP		; issue the READ_TEMP command
	sta		DS1626_CMD
	jsr		rdt_busy_wait
	pha
	lda		#10
	jsr		tSleep
	pla
rdtmp4:
	jsr		CRLF
	and		#$FFF
	bit		#$800		; check for negative temperature
	beq		rdtmp7
	sub		r1,r0,r1	; negate the number
	and		#$FFF
	pha
	lda		#'-'		; output a minus sign
	jsr		DisplayChar
	pla
rdtmp7:
	pha					; save off value
	lsr		r1,r1,#4	; get rid of fractional portion
	and		#$7F		; strip off sign bit
	ldx		#3			; output the whole number part
	jsr		PRTNUM
	lda		#'.'		; followed by a decimal point
	jsr		DisplayChar
	pla					; get back temp value
	and		#$0F
	mul		r1,r1,#625	; 1/16th's per degree
	ldx		#1
	jsr		PRTNUM
;	pha					; save off fraction bits
;	div		r1,r1,#1000	; calculate the first digit
;	add		#'0'
;	jsr		DisplayChar	; output digit
;	pla					; get back fractions bits
;	pha					; and save again
;	div		r1,r1,#100	; shift over to second digit
;	mod		r1,r1,#10	; ignore high order bits
;	add		#'0'
;	jsr		DisplayChar	; display the digit
;	pla					; get back fraction
;	div		r1,r1,#10
;	mod		r1,r1,#10	; compute low order digit
;	add		#'0'
;	jsr		DisplayChar	; display low order digit
	jsr		CRLF
	rts
rdtmp3:
	lda		#0
	bra		rdtmp4

; Returns:
;	acc = value from data register
;
rdt_busy_wait:
	jsr		KeybdGetChar
	cmp		#CTRLC
	beq		Monitor
	lda		DS1626_DAT
	bit		#$8000
	bne		rdt_busy_wait
	rts

tSleep:
	ldx		Milliseconds
	txa
tSleep1:
	ldx		Milliseconds
	sub		r2,r2,r1
	cpx		#100
	blo		tSleep1
	rts

