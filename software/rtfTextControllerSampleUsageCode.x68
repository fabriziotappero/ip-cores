;------------------------------------------------------------------------------
; Code Sample from system bios ROM.
;------------------------------------------------------------------------------


TEXTSCR		EQU		0xFFD00000
COLORSCR	EQU		0xFFD10000
TEXTCTRL	EQU		0xFFDA0000
TEXT_COLS	EQU		0xFFDA0000
TEXT_ROWS	EQU		0xFFDA0002
TEXT_CURPOS	EQU		0xFFDA0016


;------------------------------------------------------------------------------
; Clear the screen and the screen color memory
; We clear the screen to give a visual indication that the system
; is working at all.
;------------------------------------------------------------------------------
;
ClearScreen:
	move.w	TEXT_COLS,d1	; calc number to clear
	mulu.w	TEXT_ROWS,d1
	move.w	#32,d0			; space character
	move.l	#TEXTSCR,a0		; text screen address
csj4:
	move.w	d0,(a0)+
	dbeq	d1,csj4

	move.w	TEXT_COLS,d1	; calc number to clear
	mulu.w	TEXT_ROWS,d1
	move.w	ScreenColor,d0		; a nice color blue, light blue
	move.l	#COLORSCR,a0		; text color address
csj3:
	move.w	d0,(a0)+
	dbeq	d1,csj3
	rts
	
;------------------------------------------------------------------------------
; Scroll text on the screen upwards
;------------------------------------------------------------------------------
;
ScrollUp:
	movem.l	d0/d1/d2/a0,-(a7)
	move.w	TEXT_COLS,d0		; calc number of chars to scroll
	mulu.w	TEXT_ROWS,d0
	sub.w	TEXT_COLS,d0		; one less row
	lea		TEXTSCR,a0
	move.w	TEXT_COLS,d2
	asl.w	#1,d2
scrup1:
	move.w	(a0,d2.w),(a0)+
	dbeq	d0,scrup1

	move.w	TEXT_ROWS,d1
	subi.w	#1,d1
	jsr		BlankLine
	movem.l	(a7)+,d0/d1/d2/a0
	rts

;------------------------------------------------------------------------------
; Blank out a line on the display
; line number to blank is in D1.W
;------------------------------------------------------------------------------
;
BlankLine:
	movem.l	d0/a0,-(a7)
	move.w	TEXT_COLS,d0
	mulu.w	d1,d0				; d0 = row * cols
	asl.w	#1,d0				; *2 for moving words, not bytes
	add.l	#TEXTSCR,d0			; add in screen base
	move.l	d0,a0
	move.w	TEXT_COLS,d0		; d0 = number of chars to blank out
blnkln1:
	move.w	#' ',(a0)+
	dbeq	d0,blnkln1
	movem.l	(a7)+,d0/a0
	rts	

