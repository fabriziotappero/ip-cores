
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
; keyboard.asm                                                                         
; ============================================================================
;
DCMD_INITIALIZE		EQU		0
DCMD_MEDIA_CHK		EQU		1
DCMD_BUILD_BPB		EQU		2
DCMD_IOCTRL_READ	EQU		3
DCMD_READ			EQU		4
DCMD_PEEK			EQU		5
DCMD_INPUT_STATUS	EQU		6
DCMD_FLUSH_INPUT	EQU		7
DCMD_WRITE			EQU		8
DCMD_WRITE_VERIFY	EQU		9
DCMD_OUTPUT_STATUS	EQU		10
DCMD_FLUSH_OUTPUT	EQU		11
DCMD_IOCTRL_WRITE	EQU		12
DCMD_OPEN			EQU		13
DCMD_CLOSE			EQU		14
DCMD_IS_REMOVEABLE	EQU		15
DCMD_OUTPUT_UNTIL_BUSY	EQU	16
DCMD_IRQ			EQU		0xFFFFFFFD
DCMD_GETCHAR		EQU		32

DRSP_DONE			EQU		1

		cpu		RTF65002

		.code
;------------------------------------------------------------------------------
;	The keyboard interrupt is selectively disabled and enabled to protect
; the keyboard buffers structure. Other interrupts are still enabled.
;------------------------------------------------------------------------------

macro DisKeybd
	pha
	lda		#15
	sta		PIC+2
	pla
endm

macro EnKeybd
	pha
	lda		#15
	sta		PIC+3
	pla
endm

	align	4
	; Device driver struct
	dw		0xFFFFFFFF			; link to next device
	dw		0x00008001			; device attributes
	dw		KeybdStrategy		; strategy routine
	dw		KeybdIRQ			; interrupt routine
	dw		KeybdCmdProc		; command processor

	align	4
	dw	KeybdNop
	dw	KeybdInit
	dw	KeybdMediaChk
	dw	KeybdBuildBPB
	dw	KeybdGetChar			; GetChar()
	dw	KeybdCheckForKey		; PeekChar()
	dw	KeybdGetCharDirect		; unbuffered GetChar()
	dw	KeybdCheckForKeyDirect	; unbuffered PeekChar()
	dw	SendByteToKeybd			; KeybdPutChar
	dw	SetKeyboardEcho
	dw	KeybdSetpos				; set position

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
public KeybdDCB:
	align	4
	db	"KBD1        "	; name
	dw	4	; number of chars in name
	dw	1	; type
	dw	1	; nBPB
	dw	0	; last erc
	dw	0	; nBlocks
	dw	KeybdCmdProc
	dw	KeybdInit
	dw	KeybdStat
	dw	1	; reentrancy count (1 to 255 are valid)
	dw	0	; single user
	dw	0	; hJob
	dw	0	; OSD1
	dw	0	; OSD2
	dw	0	; OSD3
	dw	0	; OSD4
	dw	0	; OSD5
	dw	0	; OSD6

KeybdStrategy:
	rts
KeybdCmdProc:
	rts
KeybdStat:
	rts
KeybdBuildBPB:
	rts
KeybdSetpos:
	rts
KeybdNop:
	lda		#E_Ok
	rts

;------------------------------------------------------------------------------
; Setup keyboard
;
; Issues a 'reset keyboard' command to the keyboard, then selects scan code
; set #2 (the most common one). Also sets up the keyboard buffer and
; initializes the keyboard semaphore.
;------------------------------------------------------------------------------
;
message "KeybdSetup"
public KeybdSetup:
	lda		#1			; setup semaphore
	sta		keybd_sema
	lda		#32
	sta		LEDS
	ldx		#0

	; Set Keyboard IRQ vector	
	tsr		vbr,r2
	and		r2,#-2
	lda		#KeybdIRQ
	sta		448+15,x

	lda		#15				; enable kbd_irq
	sta		PIC+3

	jsr		KeybdInit

	lda		#1				; keyboard is device #1
	ldx		#KeybdDCB		; pointer to DCB
	ldy		#1				; number of DCB's to setup
	ld		r4,#1			; Flag: is okay to replace existing device
;	jsr		InitDevDrv
	stz		keybdInIRQ
	inc		keybdIsSetup	; set the setup flag
	rts

KeybdInit:
	lda		#33
	sta		LEDS
	lda		#$ff		; issue keyboard reset
	jsr		SendByteToKeybd
	lda		#38
	sta		LEDS
	lda		#4
;	jsr		Sleep
	lda		#1000000		; delay a bit
kbdi5:
	dea
	sta		LEDS
	bne		kbdi5
	lda		#34
	sta		LEDS
	lda		#0xf0		; send scan code select
	jsr		SendByteToKeybd
	lda		#35
	sta		LEDS
	ldx		#0xFA
	jsr		WaitForKeybdAck
	cmp		#$FA
	bne		kbdi2
	lda		#36
	sta		LEDS
	lda		#2			; select scan code set#2
	jsr		SendByteToKeybd
	lda		#39
	sta		LEDS
kbdi2:
	rts
	
msgBadKeybd:
	db		"Keyboard not responding.",0

SendByteToKeybd:
	phx
	ldx		IOFocusNdx
	sta		KEYBD
	lda		#40
	sta		LEDS
	tsr		TICK,r3
kbdi4:						; wait for transmit complete
	tsr		TICK,r4
	sub		r4,r4,r3
	cmp		r4,#1000000
	bhi		kbdbad
	lda		#41
	sta		LEDS
	lda		KEYBD+3
	bit		#64
	beq		kbdi4
	bra		sbtk1
kbdbad:
	lda		#42
	sta		LEDS
	lda		JCB_KeybdBad,x
	bne		sbtk2
	lda		#1
	sta		JCB_KeybdBad,x
	lda		#43
	sta		LEDS
	lda		#msgBadKeybd
	jsr		DisplayStringCRLFB
sbtk1:
	lda		#44
	sta		LEDS
	plx
	rts
sbtk2:
	bra		sbtk1
	
; Wait for keyboard to respond with an ACK (FA)
;
WaitForKeybdAck:
	lda		#64
	sta		LEDS
	tsr		TICK,r3
wkbdack1:
	tsr		TICK,r4
	sub		r4,r4,r3
	cmp		r4,#1000000
	bhi		wkbdbad
	lda		#65
	sta		LEDS
	lda		KEYBD
	bit		#$8000
	beq		wkbdack1
;	lda		KEYBD+8
	and		#$ff
wkbdbad:
	rts

; Wait for keyboard to respond with an ACK (FA)
; This routine picks up the ack status left by the
; keyboard IRQ routine.
; r2 = 0xFA (could also be 0xEE for echo command)
;
WaitForKeybdAck2:
	phy
	ldy		IOFocusNdx
WaitForKeybdAck2a:
	lda		JCB_KeybdAck,y
	cmp		r1,r2
	bne		WaitForKeybdAck2a
	stz		JCB_KeybdAck,y
	ply
	rts

;------------------------------------------------------------------------------
; Code in the works.
;------------------------------------------------------------------------------
;
comment ~
public KeybdService:
	lda		#keybd_mbx
	jsr		AllocMbx
	jsr		KeybdSetup
kbds3:
	; Wait for a message to arrive at the service
	lda		keybd_mbx
	ldx		#-1				; wait forever
	jsr		WaitMsg
	cpx		#DCMD_IRQ
	beq		kbds1
	cpx		#DCMD_GETCHAR
	beq		kbds2
	cpx		#DCMD_INITIALIZE
	beq		kbds4
	bra		kbds3
kbds1:
	tyx		; D2 holds character
	jsr		IKeybdIRQ
	bra		kbds3
kbds2:
	; The mailbox number is the same as the TCB number
	tya
	jsr		IKeybdGetChar
	; Send a message back to the requester containing the key value.
	tax
	tya
	ldy		#0
	jsr		SendMsg	
	bra		kbds3		
kbds4:
	jsr		KeybdInit
	bra		kbds3
~
comment ~
public XKeybdIRQ:
	pha
	phx
	phy
	lda		keybd_mbx
	ldx		#DCMD_IRQ
	ldy		KEYBD				; get keyboard character
	ld		r0,KEYBD+1			; clear keyboard strobe (turns off the IRQ)
	cli
	jsr		PostMsg
	ply
	plx
	pla
	rti
~
;------------------------------------------------------------------------------
; KeybdIRQ
;
; Normal keyboard interrupt, the lowest priority interrupt in the system.
; Grab the character from the keyboard device and store it in a buffer.
; The buffer of the task with the input focus is updated.
; This IRQ has to check for the ALT-tab character and take care of
; switching the IO focus if detected. It can't be done in the KeybdGetChar
; because the app with the IO focus may not call that routine. We know for
; sure the interrupt routine will be called when a key is pressed. The
; mechanism used is to set a flag indicating a focus switch is required.
; The actual focus switch occurs when a selected to run. The reason the
; focus switch doesn't occur during the interrupt routine is that it takes
; a large number of clock cycles (the screen buffer is transferred).
;------------------------------------------------------------------------------
;
message "KeybdIRQ"

public IKeybdIRQ:
public KeybdIRQ:
	inc		keybdInIRQ
	cld
	pha
	phx
	phy
	push	r4

	lda		#15					; disable further keyboard interrupts
	sta		PIC+2
	ldx		KEYBD				; get keyboard character
	ld		r0,KEYBD+1			; clear keyboard strobe (turns off the IRQ)
	txy							; 
	cli							; global interrupt enable
	bit		r3,#$800			; test bit #11
	bne		KeybdIRQc			; ignore keyup messages for now
	ld		r4,IOFocusNdx		; get the job with the input focus
	bit		r3,#$200			; check for ALT-tab
	beq		KeybdIrq3
	and		r3,r3,#$FF
	cmp		r3,#TAB				; if we find an ALT-tab
	bne		KeybdIrq3
	inc		iof_switch
;	jsr		SwitchIOFocus
	bra		KeybdIRQc			; don't store off the ALT-tab character
KeybdIrq3:
	and		r3,r3,#$ff
	cmp		r3,#$FA
	bne		KeybdIrq1
	sty		JCB_KeybdAck,r4
	bra		KeybdIRQc
	; strip out non-key keyboard responses
KeybdIrq1:
	cmp		r3,#$AA				; self test pass
	beq		KeybdIRQd
	cmp		r3,#$EE				; echo response
	beq		KeybdIRQd
	cmp		r3,#$00				; keyboard error
	beq		KeybdIRQd
	cmp		r3,#$FF				; keyboard error
	beq		KeybdIRQd
	bit		r2,#$800			; test bit #11
	bne		KeybdIRQc			; ignore keyup messages for now
KeybdIrq2:
	lda		JCB_KeybdHead,r4			
	ina							; increment head pointer
	and		#$f					; limit
	ldy		JCB_KeybdTail,r4	; check for room in the keyboard buffer
	cmp		r1,r3
	beq		KeybdIRQc			; if no room, the newest char will be lost
	sta		JCB_KeybdHead,r4
	dea
	and		#$f
	stx		JCB_KeybdLocks,r4
	stx		keybdLock			; global keyboard lock status
	add		r1,r1,r4
	stx		JCB_KeybdBuffer,r1	; store character in buffer
KeybdIRQc:

	; support EhBASIC's IRQ functionality
	; code derived from minimon.asm
	lda		#15				; Keyboard is IRQ #15
	sta		IrqSource	
	lb		r1,IrqBase		; get the IRQ flag byte
	lsr		r2,r1
	or		r1,r1,r2
	and		#$E0
	sb		r1,IrqBase		; save the new IRQ flag byte
KeybdIRQd:
	lda		#15				; re-enable keyboard interrupts
	sta		PIC+3
	pop		r4
	ply
	plx
	pla
	dec		keybdInIRQ
	rti


public KeybdRstIRQ:
	jmp		start

;-----------------------------------------------------------------------------
; Media Check
;	A value of 1 is returned indicating that the media hasn't changed.
;-----------------------------------------------------------------------------
;
KeybdMediaChk:
	lda		#1
	rts

;-----------------------------------------------------------------------------
; r1 0=echo off, non-zero = echo on
;------------------------------------------------------------------------------
public SetKeyboardEcho:
	pha
	phx
	tax
	jsr		GetPtrCurrentJCB
	stx		JCB_KeybdEcho,r1
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Get character from keyboard buffer
; return character in acc or -1 if no
; characters available.
;------------------------------------------------------------------------------
;
message "KeybdGetChar"

comment ~
public KeybdGetChar:
	phx
	phy
	push	r4
	; Send a message to the keyboard service requesting a character.
	lda		keybd_mbx		;
	ldx		#DCMD_GETCHAR	; opcode
	ldy		RunningTCB		; response mailbox number
	jsr		SendMsg
	; Wait for a response message from the keyboard service.
	tya
	ldx		#-1
	jsr		WaitMsg
	txa
	pop		r4
	ply
	plx
	rts
~
;------------------------------------------------------------------------------
; KeybdGetChar
;
;	Get keyboard character from buffer for the current job.
;
; Registers Affected: r1, flags
; Parameters: none
; Returns:
;	r1 = keyboard character or -1 if no character is available.
;------------------------------------------------------------------------------
;
public KeybdGetChar:
	jsr		GetCurrentJob

;------------------------------------------------------------------------------
; Get keyboard character from buffer for the specified job. This entry point
; is meant to be called by the keyboard service.
;
; Registers Affected: r1, flags
; Parameters:
;	r1 = job number
; Returns:
;	r1 = keyboard character or -1 if no character is available.
;------------------------------------------------------------------------------
;
IKeybdGetChar:
	phx
	phy
	ld		r0,keybdIsSetup	; the system might call GetChar before the keyboard
	beq		.nochar			; is setup.
	tay
	cmp		r3,#NR_JCB
	bhs		.nochar
	mul		r3,r3,#JCB_Size		; convert handle to pointer
	add		r3,r3,#JCBs
	lda		#15					; disable keyboard interrupt
	sta		PIC+2
	ld		r0,keybdInIRQ
	bne		.nochari
	ldx		JCB_KeybdTail,y		; if keybdTail==keybdHead then there are no 
	lda		JCB_KeybdHead,y		; characters in the keyboard buffer
	cmp		r1,r2
	beq		.nochari
	phx
	add		r2,r2,r3
	lda		JCB_KeybdBuffer,x
	plx
	and		r1,r1,#$ff		; mask off control bits
	inx						; increment index
	and		r2,r2,#$0f
	stx		JCB_KeybdTail,y
	ldx		JCB_KeybdEcho,y
	php
	ldx		#15				; re-enable keyboard interrupt
	stx		PIC+3
	plp
	beq		.xit			; status from the ldx
	cmp		#CR
	bne		.dispchar
	jsr		CRLF			; convert CR keystroke into CRLF
	bra		.xit
.dispchar:
	jsr		DisplayChar
	bra		.xit
.nochari
	lda		#15				; re-enable keyboard interrupt
	sta		PIC+3
.nochar:
	lda		#-1
.xit:
	ply
	plx
	rts

;------------------------------------------------------------------------------
; Check if there is a keyboard character available in the keyboard buffer.
;
; Returns
; r1 = n, Z=0 if there is a key available, otherwise
; r1 = 0, Z=1 if there is not a key available
;------------------------------------------------------------------------------
;
message "KeybdCheckForKey"
public KeybdCheckForKey:
	phx
	phy
	ldx		#0
	ld		r0,keybdIsSetup
	beq		.nochar2
	jsr		GetPtrCurrentJCB
	tay
	lda		#15				; disable keyboard interrupt
	sta		PIC+2
	ld		r0,keybdInIRQ
	bne		.nochar
	ldx		JCB_KeybdTail,y
	sub		r2,r2,JCB_KeybdHead,y
.nochar
	lda		#15				; re-enable keyboard interrupt
	sta		PIC+3
.nochar2
	txa
	ply
	plx
	cmp		#0
	rts

;------------------------------------------------------------------------------
; Tests the keyboard port directly.
; Check if there is a keyboard character available. If so return true (1)
; otherwise return false (0) in r1.
;------------------------------------------------------------------------------
;
message "KeybdCheckForKeyDirect"
public KeybdCheckForKeyDirect:
	lda		KEYBD
	and		#$8000
	beq		kcfkd1
	lda		#1
kcfkd1
	rts

;------------------------------------------------------------------------------
; Get character directly from keyboard. This routine blocks until a key is
; available.
;------------------------------------------------------------------------------
;
public KeybdGetCharDirect:
	phx
kgc1:
	lda		KEYBD
	bit		#$8000
	beq		kgc1
	ld		r0,KEYBD+1		; clear keyboard strobe
	bit		#$800			; is it a keydown event ?
	bne		kgc1
;	bit		#$200				; check for ALT-tab
;	bne		kgc2
;	and		r2,r1,#$7f
;	cmp		r2,#TAB					; if we find an ALT-tab
;	bne		kgc2
;	jsr		SwitchIOFocus
;	bra		kgc1
;kgc2:
	and		#$ff			; remove strobe bit
	ldx		KeybdEcho		; is keyboard echo on ?
	beq		gk1
	cmp		#CR
	bne		gk2				; convert CR keystroke into CRLF
	jsr		CRLF
	bra		gk1
gk2:
	jsr		DisplayChar
gk1:
	plx
	rts


;------------------------------------------------------------------------------
; Keyboard LEDs task
;	This small task tracks the keyboard lock status keys and updates the 
; keyboard LEDs accordingly. This task runs every 100ms.
;------------------------------------------------------------------------------
;
public KeybdStatusLEDs:
ksl4:
	lda		#15				; disable keyboard interrupt
	sta		PIC+2
	ld		r0,keybdInIRQ
	bne		ksl5
	lda		#$ED
	jsr		SendByteToKeybd
	jsr		WaitForKeybdAck	; wait for a feedback char
	cmp		#$FA		; was it an acknowledge (should be)
	beq		ksl7
	lda		#15			; if not, re-enable keyboard, wait till next time
	sta		PIC+3
	bra		ksl5
ksl7:
	lda		#0
	ldx		keybdLock
	bit		r2,#4000	; bit 14 = scroll lock status
	beq		ksl1
	lda		#1
ksl1:
	bit		r2,#1000	; bit 12 = numlock status
	beq		ksl2
	or		r1,#2
ksl2:
	bit		r2,#2000	; bit 13 = capslock status
	beq		ksl3
	or		r1,#4
ksl3:
    jsr		SendByteToKeybd
    lda		#15			; re-enabled keyboard interrupt
    sta		PIC+3
ksl5:
	lda		#10
	jsr		Sleep
	bra		ksl4
