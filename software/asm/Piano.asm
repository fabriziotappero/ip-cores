
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
; Piano.asm                                                                         
; ============================================================================
;
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; 
public Piano:
	jsr		RequestIOFocus
	lda		#15				; master volume to max
	sta		PSG+64
playnt:
	jsr		KeybdGetChar
	cmp		#CTRLC
	beq		PianoX
	cmp		#'a'
	beq		playnt1a
	cmp		#'b'
	beq		playnt1b
	cmp		#'c'
	beq		playnt1c
	cmp		#'d'
	beq		playnt1d
	cmp		#'e'
	beq		playnt1e
	cmp		#'f'
	beq		playnt1f
	cmp		#'g'
	beq		playnt1g
	bra		playnt
PianoX:
	jsr		ReleaseIOFocus
	rts

playnt1a:
	ld		r4,#7217
	bra		playnta
playnt1b:
	ld		r4,#8101
	bra		playnta
playnt1c:
	ld		r4,#4291
	bra		playnta
playnt1d:
	ld		r4,#4817
	bra		playnta
playnt1e:
	ld		r4,#5407
	bra		playnta
playnt1f:
	ld		r4,#5728
	bra		playnta
playnt1g:
	ld		r4,#6430
playnta
	lda		#1	; priority 1
	ldx		#0	; no flags
	ldy		#Tone
	ld		r5,#5			; associate with JCB #5
	int		#4
	db		1				; start task
	bra		playnt

; The PSG supports four voices, so we use all the voices in succession.
; The Tone task is reentrant. Multiple copies of the tone task may be
; playing tones at the same time.
;
Tone:
	pha
	phx
	inc		tone_cnt
	ldx		tone_cnt
	and		r2,r2,#3
	asl		r2,r2,#2		; PSG has groups of four registers
	sta		PSGFREQ0,x
	; decay  (16.384 ms)2
	; attack (8.192 ms)1
	; release (1.024 s)A
	; sustain level C
	lda		#0xCA12
	sta		PSGADSR0,x
	lda		#0x1104			; gate, output enable, triangle waveform
	sta		PSGCTRL0,x
	lda		#20				; delay about 100ms
	int		#4
	db		5				; Sleep
;	jsr		Delay10
	lda		#0x0104			; gate off, output enable, triangle waveform
	sta		PSGCTRL0,x
	lda		#20				; delay about 100ms
	int		#4
	db		5				; Sleep
; 	jsr		Delay10
	lda		#0x0000			; gate off, output enable off, no waveform
	sta		PSGCTRL0,x
	plx
	pla
	rts

; This routine used when Sleep() didn't work.
Delay10:
	lda		#500000
dly10a:
	dea
	bne		dly10a
	rts
