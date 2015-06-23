; ============================================================================
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
; This code calculates PI to 360 digits. It runs on a 65C816 processor. 
; The code was found at www.6502.org                                                           
; ============================================================================
;
P	EQU		2
Q	EQU		1193*2 + 2
R	EQU		Q + 2
SSS	EQU		R + 2

		jsr		INITSUB
		ldx		#359
		ldy		#1193
L1S:	
		phy
		pha
		phx
		stz		Q
;		txa
;		ldx		#5
;		wdm
;		xce
;		cpu		RTF65002
;		jsr		PRTNUM
;		clc
;		xce
;		cpu		W65C816S
;		rep		#$30
;		plx
;		phx
		tya
		tax
L2S:	
		txa

;		phx
;		ldx		#5
;		wdm
;		xce
;		cpu		RTF65002
;		jsr		PRTNUM
;		clc
;		xce
;		cpu		W65C816S
;		rep		#$30
;		plx
;		txa

		jsr		MULSUB
		sta		SSS
		lda		#10
		sta		Q
		jsr		ADJ1SUB
		lda		P-1,x
		jsr		UNADJ1SUB
		jsr		MULSUB
		clc
		adc		SSS
		sta		Q
		txa
		asl
		dea
		jsr		DIVSUB
		jsr		ADJ1SUB
		sta		P-1,x
		jsr		UNADJ1SUB
		dex
		bne		L2S
		lda		#10
		jsr		DIVSUB
		sta		P
		plx
		pla
		ldy		Q
		cpy		#10
		bcc		L3S
		ldy		#0
		ina
L3S:	
		cpx		#358
		bcc		L4S
		bne		L5S
		jsr		OUTPUTSUB
		lda		#46
L4S:	
		jsr		OUTPUTSUB
L5S:	
		tya
		eor		#48
		ply
		cpx		#358
		bcs		L6S
		dey
		dey
		dey
L6S:	
		dex
		beq		L7S
		jmp		L1S
L7S:
		jsr		OUTPUTSUB
		wdm
		xce
		cpu		RTF65002
		rts

		cpu		W65C816S
INITSUB:
		lda		#2
		ldx		#1192
IS1:
		jsr		ADJSUB
		sta		P,x
		jsr		UNADJSUB
		dex
		bpl		IS1
		rts

MULSUB:
		sta		R
		ldy		#16
M1S:	asl
		asl		Q
		bcc		M2S
		clc
		adc		R
M2S:	dey
		bne		M1S
		rts

DIVSUB:
		sta		R
		ldy		#16
		lda		#0
		asl		Q
D1S:	rol
		cmp		R
		bcc		D2S
		sbc		R
D2S:	rol		Q
		dey
		bne		D1S
		rts
		
ADJSUB:
		pha
		txa
		asl
		tax
		pla
		rts
UNADJSUB:	
		pha
		txa
		lsr
		tax
		pla
		rts
ADJ1SUB:
		pha
		txa
		asl
		tax
		pla
		dex
		rts
UNADJ1SUB:
		pha
		txa
		lsr
		tax
		pla
		inx
		rts

OUTPUTSUB:
	; switching back to '816 mode will force the registers to 8 bit, so we
	; have to save off their values, then restore them after the switch
		wdm		; switch to 32 bit mode
		xce
		cpu		RTF65002
		jsr		DisplayChar
		clc		; switch back to 816 mode
		xce
		cpu		W65C816S
		rts
