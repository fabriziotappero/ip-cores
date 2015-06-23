;****************************************************************;
;                                                                ;
;		Tiny BASIC for the Raptor64                              ;
;                                                                ;
; Derived from a 68000 derivative of Palo Alto Tiny BASIC as     ;
; published in the May 1976 issue of Dr. Dobb's Journal.         ;
; Adapted to the 68000 by:                                       ;
;	Gordon brndly						                         ;
;	12147 - 51 Street					                         ;
;	Edmonton AB  T5W 3G8					                     ;
;	Canada							                             ;
;	(updated mailing address for 1996)			                 ;
;                                                                ;
; Adapted to the RTF65002 by:                                    ;
;    Robert Finch                                                ;
;    Ontario, Canada                                             ;
;	 robfinch<remove>@opencores.org	                             ;  
;****************************************************************;
;    Copyright (C) 2012 by Robert Finch. This program may be	 ;
;    freely distributed for personal use only. All commercial	 ;
;		       rights are reserved.			                     ;
;****************************************************************;
;
; Register Usage
; r8 = text pointer (global usage)
; r3,r4 = inputs parameters to subroutines
; r2 = return value
;
;* Vers. 1.0  1984/7/17	- Original version by Gordon brndly
;*	1.1  1984/12/9	- Addition of '0x' print term by Marvin Lipford
;*	1.2  1985/4/9	- Bug fix in multiply routine by Rick Murray

;
; Standard jump table. You can change these addresses if you are
; customizing this interpreter for a different environment.
;
CR	EQU	0x0D		;ASCII equates
LF	EQU	0x0A
TAB	EQU	0x09
CTRLC	EQU	0x03
CTRLH	EQU	0x08
CTRLI	EQU	0x09
CTRLJ	EQU	0x0A
CTRLK	EQU	0x0B
CTRLM   EQU 0x0D
CTRLS	EQU	0x13
CTRLX	EQU	0x18
XON		EQU	0x11
XOFF	EQU	0x13

CursorFlash	EQU		0x7C4
IRQFlag		EQU		0x7C6

OUTPTR		EQU		0x778
INPPTR		EQU		0x779
FILENAME	EQU		0x6C0
FILEBUF		EQU		0x01F60000
OSSP		EQU		0x700
TXTUNF		EQU		0x701
VARBGN		EQU		0x702
LOPVAR		EQU		0x703
STKGOS		EQU		0x704
CURRNT		EQU		0x705
BUFFER		EQU		0x706
BUFLEN		EQU		84
LOPPT		EQU		0x760
LOPLN		EQU		0x761
LOPINC		EQU		0x762
LOPLMT		EQU		0x763
NUMWKA		EQU		0x764
STKINP		EQU		0x774
STKBOT		EQU		0x775
usrJmp		EQU		0x776
IRQROUT		EQU		0x777



		cpu	rtf65002
		code
		org		$FFFFEC80
GOSTART:	
		jmp	CSTART	;	Cold Start entry point
GOWARM:	
		jmp	WSTART	;	Warm Start entry point
GOOUT:	
		jmp	OUTC	;	Jump to character-out routine
GOIN:	
		jmp	INCH	;Jump to character-in routine
GOAUXO:	
		jmp	AUXOUT	;	Jump to auxiliary-out routine
GOAUXI:	
		jmp	AUXIN	;	Jump to auxiliary-in routine
GOBYE:	
		jmp	BYEBYE	;	Jump to monitor, DOS, etc.
;
; Modifiable system constants:
;
		align	4
;THRD_AREA	dw	0x04000000	; threading switch area 0x04000000-0x40FFFFF
;bitmap dw	0x00100000	; bitmap graphics memory 0x04100000-0x417FFFF
TXTBGN	dw	0x01800000	;TXT		;beginning of program memory
ENDMEM	dw	0x018EFFFF	;	end of available memory
STACKOFFS	dw	0x018FFFFF	; stack offset - leave a little room for the BIOS stacks
;
; The main interpreter starts here:
;
; Usage
; r1 = temp
; r8 = text buffer pointer
; r12 = end of text in text buffer
;
	align	4
message "CSTART"
public CSTART:
	; First save off the link register and OS sp value
	tsx
	stx		OSSP
	ldx		STACKOFFS>>2	; initialize stack pointer
	txs
	jsr		RequestIOFocus
	jsr		HomeCursor
	lda		#0				; turn off keyboard echoing
	jsr		SetKeyboardEcho
	stz		CursorFlash
	ldx		#0x10000020	; black chars, yellow background
;	stx		charToPrint
	jsr		ClearScreen
	lda		#msgInit	;	tell who we are
	jsr		PRMESG
	lda		TXTBGN>>2	;	init. end-of-program pointer
	sta		TXTUNF
	lda		ENDMEM>>2	;	get address of end of memory
	sub		#4096	; 	reserve 4K for the stack
	sta		STKBOT
	sub		#16384 ;   1000 vars
	sta     VARBGN
	jsr     clearVars   ; clear the variable area
	stz		IRQROUT
	lda     VARBGN   ; calculate number of bytes free
	ldy		TXTUNF
	sub     r1,r1,r3
	ldx		#12		; max 12 digits
	jsr  	PRTNUM
	lda		#msgBytesFree
	jsr		PRMESG
WSTART:
	stz		LOPVAR   ; initialize internal variables
	stz		STKGOS
	stz		CURRNT	;	current line number pointer = 0
	ldx		ENDMEM>>2	;	init S.P. again, just in case
	txs
	lda		#msgReady	;	display "Ready"
	jsr		PRMESG
ST3:
	lda		#'>'		; Prompt with a '>' and
	jsr		GETLN		; read a line.
	jsr		TOUPBUF 	; convert to upper case
	ld		r12,r8		; save pointer to end of line
	ld		r8,#BUFFER	; point to the beginning of line
	jsr		TSTNUM		; is there a number there?
	jsr		IGNBLK		; skip trailing blanks
; does line no. exist? (or nonzero?)
	cpx		#0
	beq		DIRECT		; if not, it's a direct statement
	cmp		#$FFFF		; see if line no. is <= 16 bits
	bcc		ST2
	beq		ST2
	lda		#msgLineRange	; if not, we've overflowed
	jmp		ERROR
ST2:
    ; ugliness - store a character at potentially an
    ; odd address (unaligned).
    tax					; r2 = line number
	dec		r8
    stx		(r8)		;
	jsr		FNDLN		; find this line in save area
	ld		r13,r9		; save possible line pointer
	cmp		#0
	beq		ST4			; if not found, insert
	; here we found the line, so we're replacing the line
	; in the text area
	; first step - delete the line
	lda		#0
	jsr		FNDNXT		; find the next line (into r9)
	cmp		#0
	bne		ST7
	cmp		r9,TXTUNF
	beq		ST6			; no more lines
	bcs		ST6
	cmp		r9,r0
	beq		ST6
ST7:
	ld		r1,r9		; r1 = pointer to next line
	ld		r2,r13		; pointer to line to be deleted
	ldy		TXTUNF		; points to top of save area
	sub		r1,r3,r9	; r1 = length to move TXTUNF-pointer to next line
;	dea					; count is one less
	ld		r2,r9		; r2 = pointer to next line
	ld		r3,r13		; r3 = pointer to line to delete
	push	r4
ST8:
	ld		r4,(x)
	st		r4,(y)
	inx
	iny
	dea
	bne		ST8
	pop		r4
;	mvn
;	jsr		MVUP		; move up to delete
	sty		TXTUNF		; update the end pointer
	; we moved the lines of text after the line being
	; deleted down, so the pointer to the next line
	; needs to be reset
	ld		r9,r13
	bra		ST4
	; here there were no more lines, so just move the
	; end of text pointer down
ST6:
	st		r13,TXTUNF
	ld		r9,r13
ST4:
	; here we're inserting because the line wasn't found
	; or it was deleted	from the text area
	sub		r1,r12,r8		; calculate the length of new line
	cmp		#2				; is it just a line no. & CR? if so, it was just a delete
	beq		ST3
	bcc		ST3

	; compute new end of text
	ld		r10,TXTUNF		; r10 = old TXTUNF
	add		r11,r10,r1		; r11 = new top of TXTUNF (r1=line length)

	cmp		r11,VARBGN	; see if there's enough room
	bcc		ST5
	lda		#msgTooBig	; if not, say so
	jmp		ERROR

	; open a space in the text area
ST5:
	st		r11,TXTUNF	; if so, store new end position
	ld		r1,r10		; points to old end of text
	ld		r2,r11		; points to new end of text
	ld		r3,r9	    ; points to start of line after insert line
	jsr		MVDOWN		; move things out of the way

	; copy line into text space
	ld		r1,r8		; set up to do the insertion; move from buffer
	ld		r2,r13		; to vacated space
	ld		r3,r12		; until end of buffer
	jsr		MVUP		; do it
	jmp		ST3			; go back and get another line

;******************************************************************
;
; *** Tables *** DIRECT *** EXEC ***
;
; This section of the code tests a string against a table. When
; a match is found, control is transferred to the section of
; code according to the table.
;
; At 'EXEC', r8 should point to the string, r9 should point to
; the character table, and r10 should point to the execution
; table. At 'DIRECT', r8 should point to the string, r9 and
; r10 will be set up to point to TAB1 and TAB1_1, which are
; the tables of all direct and statement commands.
;
; A '.' in the string will terminate the test and the partial
; match will be considered as a match, e.g. 'P.', 'PR.','PRI.',
; 'PRIN.', or 'PRINT' will all match 'PRINT'.
;
; There are two tables: the character table and the execution
; table. The character table consists of any number of text items.
; Each item is a string of characters with the last character's
; high bit set to one. The execution table holds a 32-bit
; execution addresses that correspond to each entry in the
; character table.
;
; The end of the character table is a 0 byte which corresponds
; to the default routine in the execution table, which is
; executed if none of the other table items are matched.
;
; Character-matching tables:
message "TAB1"
TAB1:
	db	"LIS",'T'+0x80        ; Direct commands
	db	"LOA",'D'+0x80
	db	"NE",'W'+0x80
	db	"RU",'N'+0x80
	db	"SAV",'E'+0x80
TAB2:
	db	"NEX",'T'+0x80         ; Direct / statement
	db	"LE",'T'+0x80
	db	"I",'F'+0x80
	db	"GOT",'O'+0x80
	db	"GOSU",'B'+0x80
	db	"RETUR",'N'+0x80
	db	"RE",'M'+0x80
	db	"FO",'R'+0x80
	db	"INPU",'T'+0x80
	db	"PRIN",'T'+0x80
	db	"POK",'E'+0x80
	db	"STO",'P'+0x80
	db	"BY",'E'+0x80
	db	"SY",'S'+0x80
	db	"CL",'S'+0x80
    db  "CL",'R'+0x80
    db	"RDC",'F'+0x80
    db	"ONIR",'Q'+0x80
    db	"WAI",'T'+0x80
	db	0
TAB4:
	db	"PEE",'K'+0x80         ;Functions
	db	"RN",'D'+0x80
	db	"AB",'S'+0x80
	db  "SG",'N'+0x80
	db	"TIC",'K'+0x80
	db	"SIZ",'E'+0x80
	db  "US",'R'+0x80
	db	0
TAB5:
	db	"T",'O'+0x80           ;"TO" in "FOR"
	db	0
TAB6:
	db	"STE",'P'+0x80         ;"STEP" in "FOR"
	db	0
TAB8:
	db	'>','='+0x80           ;Relational operators
	db	'<','>'+0x80
	db	'>'+0x80
	db	'='+0x80
	db	'<','='+0x80
	db	'<'+0x80
	db	0
TAB9:
    db  "AN",'D'+0x80
    db  0
TAB10:
    db  "O",'R'+0x80
    db  0

;* Execution address tables:
; We save some bytes by specifiying only the low order 16 bits of the address
;
TAB1_1:
	dh	LISTX			;Direct commands
	dh	LOAD3
	dh	NEW
	dh	RUN
	dh	SAVE3
TAB2_1:
	dh	NEXT		;	Direct / statement
	dh	LET
	dh	IF
	dh	GOTO
	dh	GOSUB
	dh	RETURN
	dh	IF2			; REM
	dh	FOR
	dh	INPUT
	dh	PRINT
	dh	POKE
	dh	STOP
	dh	GOBYE
	dh	SYSX
	dh	_cls
	dh  _clr
	dh	_rdcf
	dh  ONIRQ
	dh	WAITIRQ
	dh	DEFLT
TAB4_1:
	dh	PEEK			;Functions
	dh	RND
	dh	ABS
	dh  SGN
	dh	TICKX
	dh	SIZEX
	dh  USRX
	dh	XP40
TAB5_1
	dh	FR1			;"TO" in "FOR"
	dh	QWHAT
TAB6_1
	dh	FR2			;"STEP" in "FOR"
	dh	FR3
TAB8_1
	dh	XP11	;>=		Relational operators
	dh	XP12	;<>
	dh	XP13	;>
	dh	XP15	;=
	dh	XP14	;<=
	dh	XP16	;<
	dh	XP17
TAB9_1
    dh  XP_AND
    dh  XP_ANDX
TAB10_1
    dh  XP_OR
    dh  XP_ORX

;*
; r3 = match flag (trashed)
; r9 = text table
; r10 = exec table
; r11 = trashed
message "DIRECT"
DIRECT:
	ld		r9,#TAB1
	ld		r10,#TAB1_1
EXEC:
	jsr		IGNBLK		; ignore leading blanks
	ld		r11,r8		; save the pointer
	eor		r3,r3,r3	; clear match flag
EXLP:
	lda		(r8)		; get the program character
	inc		r8
	lb		r2,$0,r9	; get the table character
	bne		EXNGO		; If end of table,
	ld		r8,r11		;	restore the text pointer and...
	bra		EXGO		;   execute the default.
EXNGO:
	cmp		r1,r3		; Else check for period... if so, execute
	beq		EXGO
	and		r2,r2,#0x7f	; ignore the table's high bit
	cmp		r2,r1		;		is there a match?
	beq		EXMAT
	inc		r10			;if not, try the next entry
	inc		r10
	ld		r8,r11		; reset the program pointer
	eor		r3,r3,r3	; sorry, no match
EX1:
	lb		r1,0,r9		; get to the end of the entry
	inc		r9
	bit		#$80		; test for bit 7 set
	beq		EX1
	bra		EXLP		; back for more matching
EXMAT:
	ldy		#'.'		; we've got a match so far
	lb		r1,0,r9		; end of table entry?
	inc		r9
	bit		#$80		; test for bit 7 set
	beq		EXLP		; if not, go back for more
EXGO:
	; execute the appropriate routine
	lb		r1,1,r10	; get the low mid order byte
	asl		r1,r1,#8
	orb		r1,r1,0,r10	; get the low order byte
	or		r1,r1,#$FFFF0000	; add in ROM base
	jmp		(r1)

    
;******************************************************************
;
; What follows is the code to execute direct and statement
; commands. Control is transferred to these points via the command
; table lookup code of 'DIRECT' and 'EXEC' in the last section.
; After the command is executed, control is transferred to other
; sections as follows:
;
; For 'LISTX', 'NEW', and 'STOP': go back to the warm start point.
; For 'RUN': go execute the first stored line if any; else go
; back to the warm start point.
; For 'GOTO' and 'GOSUB': go execute the target line.
; For 'RETURN' and 'NEXT'; go back to saved return line.
; For all others: if 'CURRNT' is 0, go to warm start; else go
; execute next command. (This is done in 'FINISH'.)
;
;******************************************************************
;
; *** NEW *** STOP *** RUN (& friends) *** GOTO ***
;
; 'NEW<CR>' sets TXTUNF to point to TXTBGN
;

NEW:
	jsr		ENDCHK
	lda		TXTBGN>>2
	sta		TXTUNF	;	set the end pointer
	jsr     clearVars

; 'STOP<CR>' goes back to WSTART
;
STOP:
	jsr		ENDCHK
	jmp		WSTART		; WSTART will reset the stack

; 'RUN<CR>' finds the first stored line, stores its address
; in CURRNT, and starts executing it. Note that only those
; commands in TAB2 are legal for a stored program.
;
; There are 3 more entries in 'RUN':
; 'RUNNXL' finds next line, stores it's address and executes it.
; 'RUNTSL' stores the address of this line and executes it.
; 'RUNSML' continues the execution on same line.
;
RUN:
	jsr		ENDCHK
	ld		r8,TXTBGN>>2	;	set pointer to beginning
	st		r8,CURRNT
	jsr     clearVars

RUNNXL					; RUN <next line>
	lda		CURRNT	; executing a program?
	beq		WSTART	; if not, we've finished a direct stat.
	lda		IRQROUT		; are we handling IRQ's ?
	beq		RUN1
	ld 		r0,IRQFlag		; was there an IRQ ?
	beq		RUN1
	stz		IRQFlag
	jsr		PUSHA_		; the same code as a GOSUB
	push	r8
	lda		CURRNT
	pha					; found it, save old 'CURRNT'...
	lda		STKGOS
	pha					; and 'STKGOS'
	stz		LOPVAR		; load new values
	tsx
	stx		STKGOS
	ld		r9,IRQROUT
	bra		RUNTSL
RUN1
	lda		#0	    ; else find the next line number
	ld		r9,r8
	jsr		FNDLNP		; search for the next line
;	cmp		#0
;	bne		RUNTSL
	cmp		r9,TXTUNF; if we've fallen off the end, stop
	beq		WSTART
	bcs		WSTART

RUNTSL					; RUN <this line>
	st		r9,CURRNT	; set CURRNT to point to the line no.
	add		r8,r9,#1	; set the text pointer to

RUNSML                 ; RUN <same line>
	jsr		CHKIO		; see if a control-C was pressed
	ld		r9,#TAB2		; find command in TAB2
	ld		r10,#TAB2_1
	jmp		EXEC		; and execute it


; 'GOTO expr<CR>' evaluates the expression, finds the target
; line, and jumps to 'RUNTSL' to do it.
;
GOTO
	jsr		OREXPR		;evaluate the following expression
;	jsr		DisplayWord
	ld      r5,r1
	jsr 	ENDCHK		;must find end of line
	ld      r1,r5
	jsr 	FNDLN		; find the target line
	cmp		#0
	bne		RUNTSL		; go do it
	lda		#msgBadGotoGosub
	jmp		ERROR		; no such line no.

_clr:
    jsr     clearVars
    jmp     FINISH

; Clear the variable area of memory
clearVars:
	push	r6
    ld      r6,#2048    ; number of words to clear
    lda     VARBGN
cv1:
    stz     (r1)
    ina
    dec		r6
    bne		cv1
    pop		r6
    rts

;******************************************************************
; ONIRQ <line number>
; ONIRQ sets up an interrupt handler which acts like a specialized
; subroutine call. ONIRQ is coded like a GOTO that never executes.
;******************************************************************
;
ONIRQ:
	jsr		OREXPR		;evaluate the following expression
	ld      r5,r1
	jsr 	ENDCHK		;must find end of line
	ld      r1,r5
	jsr 	FNDLN		; find the target line
	cmp		#0
	bne		ONIRQ1
	stz		IRQROUT
	jmp		FINISH
ONIRQ1:
	st		r9,IRQROUT
	jmp		FINISH


WAITIRQ:
	jsr		CHKIO		; see if a control-C was pressed
	ld		r0,IRQFlag
	beq		WAITIRQ
	jmp		FINISH


;******************************************************************
; LIST
;
; LISTX has two forms:
; 'LIST<CR>' lists all saved lines
; 'LIST #<CR>' starts listing at the line #
; Control-S pauses the listing, control-C stops it.
;******************************************************************
;
LISTX:
	jsr		TSTNUM		; see if there's a line no.
	ld      r5,r1
	jsr		ENDCHK		; if not, we get a zero
	ld      r1,r5
	jsr		FNDLN		; find this or next line
LS1:
	cmp		#0
	bne		LS4
	cmp		r9,TXTUNF
	beq		WSTART
	bcs		WSTART		; warm start if we passed the end
LS4:
	ld		r1,r9
	jsr		PRTLN		; print the line
	ld		r9,r1		; set pointer for next
	jsr		CHKIO		; check for listing halt request
	cmp		#0
	beq		LS3
	cmp		#CTRLS		; pause the listing?
	bne		LS3
LS2:
	jsr 	CHKIO		; if so, wait for another keypress
	cmp		#0
	beq		LS2
LS3:
	lda		#0
	jsr		FNDLNP		; find the next line
	bra		LS1


;******************************************************************
; PRINT command is 'PRINT ....:' or 'PRINT ....<CR>'
; where '....' is a list of expressions, formats, back-arrows,
; and strings.	These items a separated by commas.
;
; A format is a pound sign followed by a number.  It controls
; the number of spaces the value of an expression is going to
; be printed in.  It stays effective for the rest of the print
; command unless changed by another format.  If no format is
; specified, 11 positions will be used.
;
; A string is quoted in a pair of single- or double-quotes.
;
; An underline (back-arrow) means generate a <CR> without a <LF>
;
; A <CR LF> is generated after the entire list has been printed
; or if the list is empty.  If the list ends with a semicolon,
; however, no <CR LF> is generated.
;******************************************************************
;
PRINT:
	ld		r5,#11		; D4 = number of print spaces
	ldy		#':'
	ld		r4,#PR2
	jsr		TSTC		; if null list and ":"
	jsr		CRLF		; give CR-LF and continue
	jmp		RUNSML		;		execution on the same line
PR2:
	ldy		#CR
	ld		r4,#PR0
	jsr		TSTC		;if null list and <CR>
	jsr		CRLF		;also give CR-LF and
	jmp		RUNNXL		;execute the next line
PR0:
	ldy		#'#'
	ld		r4,#PR1
	jsr		TSTC		;else is it a format?
	jsr		OREXPR		; yes, evaluate expression
	ld		r5,r1	; and save it as print width
	bra		PR3		; look for more to print
PR1:
	ldy		#'$'
	ld		r4,#PR4
	jsr		TSTC	;	is character expression? (MRL)
	jsr		OREXPR	;	yep. Evaluate expression (MRL)
	jsr		GOOUT	;	print low byte (MRL)
	bra		PR3		;look for more. (MRL)
PR4:
	jsr		QTSTG	;	is it a string?
	; the following branch must occupy only two bytes!
	bra		PR8		;	if not, must be an expression
PR3:
	ldy		#','
	ld		r4,#PR6
	jsr		TSTC	;	if ",", go find next
	jsr		FIN		;in the list.
	bra		PR0
PR6:
	jsr		CRLF		;list ends here
	jmp		FINISH
PR8:
	jsr		OREXPR		; evaluate the expression
	ld		r2,r5		; set the width
	jsr		PRTNUM		; print its value
	bra		PR3			; more to print?

FINISH:
	jsr		FIN		; Check end of command
	jmp		QWHAT	; print "What?" if wrong


;*******************************************************************
;
; *** GOSUB *** & RETURN ***
;
; 'GOSUB expr:' or 'GOSUB expr<CR>' is like the 'GOTO' command,
; except that the current text pointer, stack pointer, etc. are
; saved so that execution can be continued after the subroutine
; 'RETURN's.  In order that 'GOSUB' can be nested (and even
; recursive), the save area must be stacked.  The stack pointer
; is saved in 'STKGOS'.  The old 'STKGOS' is saved on the stack.
; If we are in the main routine, 'STKGOS' is zero (this was done
; in the initialization section of the interpreter), but we still
; save it as a flag for no further 'RETURN's.
;******************************************************************
;
GOSUB:
	jsr		PUSHA_		; save the current 'FOR' parameters
	jsr		OREXPR		; get line number
	jsr		FNDLN		; find the target line
	cmp		#0
	bne		gosub1
	lda		#msgBadGotoGosub
	jmp		ERROR		; if not there, say "How?"
gosub1:
	push	r8
	lda		CURRNT
	pha					; found it, save old 'CURRNT'...
	lda		STKGOS
	pha					; and 'STKGOS'
	stz		LOPVAR		; load new values
	tsx
	stx		STKGOS
	jmp		RUNTSL


;******************************************************************
; 'RETURN<CR>' undoes everything that 'GOSUB' did, and thus
; returns the execution to the command after the most recent
; 'GOSUB'.  If 'STKGOS' is zero, it indicates that we never had
; a 'GOSUB' and is thus an error.
;******************************************************************
;
RETURN:
	jsr		ENDCHK		; there should be just a <CR>
	ldx		STKGOS		; get old stack pointer
	bne		return1
	lda		#msgRetWoGosub
	jmp		ERROR		; if zero, it doesn't exist
return1:
	txs					; else restore it
	pla
	sta		STKGOS		; and the old 'STKGOS'
	pla
	sta		CURRNT		; and the old 'CURRNT'
	pop		r8			; and the old text pointer
	jsr		POPA_		;and the old 'FOR' parameters
	jmp		FINISH		;and we are back home

;******************************************************************
; *** FOR *** & NEXT ***
;
; 'FOR' has two forms:
; 'FOR var=exp1 TO exp2 STEP exp1' and 'FOR var=exp1 TO exp2'
; The second form means the same thing as the first form with a
; STEP of positive 1.  The interpreter will find the variable 'var'
; and set its value to the current value of 'exp1'.  It also
; evaluates 'exp2' and 'exp1' and saves all these together with
; the text pointer, etc. in the 'FOR' save area, which consists of
; 'LOPVAR', 'LOPINC', 'LOPLMT', 'LOPLN', and 'LOPPT'.  If there is
; already something in the save area (indicated by a non-zero
; 'LOPVAR'), then the old save area is saved on the stack before
; the new values are stored.  The interpreter will then dig in the
; stack and find out if this same variable was used in another
; currently active 'FOR' loop.  If that is the case, then the old
; 'FOR' loop is deactivated. (i.e. purged from the stack)
;******************************************************************
;
FOR:
	jsr		PUSHA_		; save the old 'FOR' save area
	jsr		SETVAL		; set the control variable
	sta		LOPVAR		; save its address
	ld		r9,#TAB5
	ld		r10,#TAB5_1	; use 'EXEC' to test for 'TO'
	jmp		EXEC
FR1:
	jsr		OREXPR		; evaluate the limit
	sta		LOPLMT	; save that
	ld		r9,#TAB6
	ld		r10,#TAB6_1	; use 'EXEC' to test for the word 'STEP
	jmp		EXEC
FR2:
	jsr		OREXPR		; found it, get the step value
	bra		FR4
FR3:
	lda		#1		; not found, step defaults to 1
FR4:
	sta		LOPINC	; save that too
FR5:
	ldx		CURRNT
	stx		LOPLN	; save address of current line number
	st		r8,LOPPT	; and text pointer
	tsx
	txy					; dig into the stack to find 'LOPVAR'
	ld		r6,LOPVAR
	bra		FR7
FR6:
	add		r3,r3,#5	; look at next stack frame
FR7:
	ldx		(y)			; is it zero?
	beq		FR8			; if so, we're done
	cmp		r2,r6
	bne		FR6			; same as current LOPVAR? nope, look some more

    tya			      ; Else remove 5 long words from...
	add		r2,r3,#5   ; inside the stack.
	tsx
	txy
	jsr		MVDOWN
	pla					; set the SP 5 long words up
	pla
	pla
	pla
	pla
FR8:
    jmp	    FINISH		; and continue execution


;******************************************************************
; 'NEXT var' serves as the logical (not necessarily physical) end
; of the 'FOR' loop.  The control variable 'var' is checked with
; the 'LOPVAR'.  If they are not the same, the interpreter digs in
; the stack to find the right one and purges all those that didn't
; match.  Either way, it then adds the 'STEP' to that variable and
; checks the result with against the limit value.  If it is within
; the limit, control loops back to the command following the
; 'FOR'.  If it's outside the limit, the save area is purged and
; execution continues.
;******************************************************************
;
NEXT:
	lda		#0		; don't allocate it
	jsr		TSTV		; get address of variable
	cmp		#0
	bne		NX4
	lda		#msgNextVar
	bra		ERROR		; if no variable, say "What?"
NX4:
	ld		r9,r1	; save variable's address
NX0:
	lda		LOPVAR	; If 'LOPVAR' is zero, we never...
	bne		NX5		; had a FOR loop
	lda		#msgNextFor
	bra		ERROR
NX5:
	cmp		r1,r9
	beq		NX2		; else we check them OK, they agree
	jsr		POPA_		; nope, let's see the next frame
	bra		NX0
NX2:
	lda		(r9)		; get control variable's value
	ldx		LOPINC
	add		r1,r1,r2	; add in loop increment
;	BVS.L	QHOW		say "How?" for 32-bit overflow
	sta		(r9)		; save control variable's new value
	ldy		LOPLMT		; get loop's limit value
	cmp		r2,#1
	beq		NX1
	bpl		NX1			; check loop increment, branch if loop increment is positive
	cmp		r1,r3
	beq		NX3
	bmi		NXPurge		; test against limit
	bra     NX3
NX1:
	cmp		r1,r3
	beq		NX3
	bpl		NXPurge
NX3:
	ld		r8,LOPLN	; Within limit, go back to the...
	st		r8,CURRNT
	ld		r8,LOPPT	; saved 'CURRNT' and text pointer.
	jmp		FINISH
NXPurge:
    jsr    POPA_        ; purge this loop
    jmp     FINISH


;******************************************************************
; *** REM *** IF *** INPUT *** LET (& DEFLT) ***
;
; 'REM' can be followed by anything and is ignored by the
; interpreter.
;
;REM
;    br	    IF2		    ; skip the rest of the line
; 'IF' is followed by an expression, as a condition and one or
; more commands (including other 'IF's) separated by colons.
; Note that the word 'THEN' is not used.  The interpreter evaluates
; the expression.  If it is non-zero, execution continues.  If it
; is zero, the commands that follow are ignored and execution
; continues on the next line.
;******************************************************************
;
IF:
    jsr		OREXPR		; evaluate the expression
IF1:
	cmp		#0
    bne	    RUNSML		; is it zero? if not, continue
IF2:
    ld		r9,r8	; set lookup pointer
	lda		#0		; find line #0 (impossible)
	jsr		FNDSKP		; if so, skip the rest of the line
	cmp		#0
	bcs		WSTART	; if no next line, do a warm start
IF3:
	jmp		RUNTSL		; run the next line


;******************************************************************
; INPUT is called first and establishes a stack frame
INPERR:
	ldx		STKINP		; restore the old stack pointer
	txs
	pla
	sta		CURRNT		; and old 'CURRNT'
	pop		r8			; and old text pointer
	tsx
	add		r2,r2,#5	; fall through will subtract 5
	txs

; 'INPUT' is like the 'PRINT' command, and is followed by a list
; of items.  If the item is a string in single or double quotes,
; or is an underline (back arrow), it has the same effect as in
; 'PRINT'.  If an item is a variable, this variable name is
; printed out followed by a colon, then the interpreter waits for
; an expression to be typed in.  The variable is then set to the
; value of this expression.  If the variable is preceeded by a
; string (again in single or double quotes), the string will be
; displayed followed by a colon.  The interpreter the waits for an
; expression to be entered and sets the variable equal to the
; expression's value.  If the input expression is invalid, the
; interpreter will print "What?", "How?", or "Sorry" and reprint
; the prompt and redo the input.  The execution will not terminate
; unless you press control-C.  This is handled in 'INPERR'.
;
INPUT:
	push	r7
	tsr		sp,r7
	sub		r7,r7,#5	; allocate five words on stack
	trs		r7,sp
	st		r5,4,r7		; save off r5 into stack var
IP6:
	st		r8,(r7)		; save in case of error
	jsr		QTSTG		; is next item a string?
	bra		IP2			; nope - this branch must take only two bytes
	lda		#1		; allocate var
	jsr		TSTV		; yes, but is it followed by a variable?
	cmp		#0
	beq     IP4   ; if not, brnch
	or		r10,r1,r0		; put away the variable's address
	bra		IP3			; if so, input to variable
IP2:
	st		r8,1,r7		; save off in stack var for 'PRTSTG'
	lda		#1
	jsr		TSTV		; must be a variable now
	cmp		#0
	bne		IP7
	lda		#msgInputVar
	add		r7,r7,#5	; cleanup stack
	trs		r7,sp
	pop		r7			; so we can get back r7
	bra		ERROR		; "What?" it isn't?
IP7:
	or		r10,r1,r0	; put away the variable's address
	ld		r5,(r8)		; get ready for 'PRTSTG' by null terminating
	stz		(r8)
	lda		1,r7			; get back text pointer
	jsr		PRTSTG		; print string as prompt
	st		r5,(r8)		; un-null terminate
IP3
	st		r8,1,r7		; save in case of error
	lda		CURRNT
	sta		2,r7			; also save 'CURRNT'
	lda		#-1
	sta		CURRNT		; flag that we are in INPUT
	stx		STKINP		; save the stack pointer too
	st		r10,3,r7	; save the variable address
	lda		#':'		; print a colon first
	jsr		GETLN		; then get an input line
	ld		r8,#BUFFER	; point to the buffer
	jsr		OREXPR		; evaluate the input
	ld		r10,3,r7	; restore the variable address
	sta		(r10)		; save value in variable
	lda		2,r7		; restore old 'CURRNT'
	sta		CURRNT
	ld		r8,1,r7		; and the old text pointer
IP4:
	ldy		#','
	ld		r4,#IP5		; is the next thing a comma?
	jsr		TSTC
	bra		IP6			; yes, more items
IP5:
	ld		r5,4,r7
	add		r7,r7,#5	; cleanup stack
	trs		r7,sp
	pop		r7
 	jmp		FINISH


DEFLT:
    lda     (r8)
    cmp		#CR
	beq	    FINISH	    ; empty line is OK else it is 'LET'


;******************************************************************
; 'LET' is followed by a list of items separated by commas.
; Each item consists of a variable, an equals sign, and an
; expression.  The interpreter evaluates the expression and sets
; the variable to that value.  The interpreter will also handle
; 'LET' commands without the word 'LET'.  This is done by 'DEFLT'.
;******************************************************************
;
LET:
    jsr		SETVAL		; do the assignment
    ldy		#','
    ld		r4,#FINISH
	jsr		TSTC		; check for more 'LET' items
	bra	    LET
LT1:
    jmp	    FINISH		; until we are finished.


;******************************************************************
; *** LOAD *** & SAVE ***
;
; These two commands transfer a program to/from an auxiliary
; device such as a cassette, another computer, etc.  The program
; is converted to an easily-stored format: each line starts with
; a colon, the line no. as 4 hex digits, and the rest of the line.
; At the end, a line starting with an '@' sign is sent.  This
; format can be read back with a minimum of processing time by
; the RTF65002
;******************************************************************
;
LOAD
	ld		r8,TXTBGN>>2	; set pointer to start of prog. area
	lda		#CR			; For a CP/M host, tell it we're ready...
	jsr		GOAUXO		; by sending a CR to finish PIP command.
LOD1:
	jsr		GOAUXI		; look for start of line
	cmp		#0
	beq		LOD1
	bcc		LOD1
	cmp		#'@'		; end of program?
	beq		LODEND
	cmp		#$1A
	beq     LODEND	; or EOF marker
	cmp		#':'
	bne		LOD1	; if not, is it start of line? if not, wait for it
	jsr		GCHAR		; get line number
	sta		(r8)		; store it
	inc		r8
LOD2:
	jsr		GOAUXI		; get another text char.
	cmp		#0
	beq		LOD2
	bcc		LOD2
	sta		(r8)
	inc		r8			; store it
	cmp		#CR
	bne		LOD2		; is it the end of the line? if not, go back for more
	bra		LOD1		; if so, start a new line
LODEND:
	st		r8,TXTUNF	; set end-of program pointer
	jmp		WSTART		; back to direct mode


; get character from input (32 bit value)
GCHAR:
	push	r5
	push	r6
	ld		r6,#8       ; repeat eight times
	ld		r5,#0
GCHAR1:
	jsr		GOAUXI		; get a char
	cmp		#0
	beq		GCHAR1
	bcc		GCHAR1
	jsr		asciiToHex
	asl		r5,r5,#4
	or		r5,r5,r1
	dec		r6
	bne		GCHAR1
	ld		r1,r5
	pop		r6
	pop		r5
	rts


; convert an ascii char to hex code
; input
;	r1 = char to convert

asciiToHex:
	cmp		#'9'		; less than '9'
	beq		a2h1
	bcc		a2h1
	sub		#7			; shift 'A' to '9'+1
a2h1:
	sub		#'0'
	and		#15			; make sure a nybble
	rts

GetFilename:
	ldy		#'"'
	ld		r4,#gfn1
	jsr		TSTC
	ldy		#0
gfn2:
	ld		r1,(r8)		; get text character
	inc		r8
	cmp		#'"'
	beq		gfn3
	cmp		#0
	beq		gfn3
	sb		r1,FILENAME,y
	iny
	cpy		#32
	bne		gfn2
	rts
gfn3:
	lda		#' '
	sb		r1,FILENAME,y
	iny
	cpy		#32
	bne		gfn3
	rts
gfn1:
	jmp		WSTART

LOAD3:
	jsr		GetFilename
	jsr		AUXIN_INIT
	jmp		LOAD

;	jsr		OREXPR		;evaluate the following expression
;	lda		#5000
	ldx		#$E00
	jsr		SDReadSector
	ina
	ldx		TXTBGN>>2
	asl		r2,r2,#2
LOAD4:
	pha
	jsr		SDReadSector
	add		r2,r2,#512
	pla
	ina
	ld		r4,TXTBGN>>2
	asl		r4,r4,#2
	add		r4,r4,#65536
	cmp		r2,r4
	bmi		LOAD4
LOAD5:
	bra		WSTART

SAVE3:
	jsr		GetFilename
	jsr		AUXOUT_INIT
	jmp		SAVE

	jsr		OREXPR		;evaluate the following expression
;	lda		#5000		; starting sector
	ldx		#$E00		; starting address to write
	jsr		SDWriteSector
	ina
	ldx		TXTBGN>>2
	asl		r2,r2,#2
SAVE4:
	pha
	jsr		SDWriteSector
	add		r2,r2,#512
	pla
	ina
	ld		r4,TXTBGN>>2
	asl		r4,r4,#2
	add		r4,r4,#65536
	cmp		r2,r4
	bmi		SAVE4
	bra		WSTART

SAVE:
	ld		r8,TXTBGN>>2	;set pointer to start of prog. area
	ld		r9,TXTUNF	;set pointer to end of prog. area
SAVE1:
	jsr		AUXOCRLF    ; send out a CR & LF (CP/M likes this)
	cmp		r8,r9
	bcs		SAVEND		; are we finished?
	lda		#':'		; if not, start a line
	jsr		GOAUXO
	lda		(r8)		; get line number
	inc		r8
	jsr		PWORD       ; output line number as 4-digit hex
SAVE2:
	lda		(r8)		; get a text char.
	inc		r8
	cmp		#CR
	beq		SAVE1		; is it the end of the line? if so, send CR & LF and start new line
	jsr		GOAUXO		; send it out
	bra		SAVE2		; go back for more text
SAVEND:
	lda		#'@'		; send end-of-program indicator
	jsr		GOAUXO
	jsr		AUXOCRLF    ; followed by a CR & LF
	lda		#$1A		; and a control-Z to end the CP/M file
	jsr		GOAUXO
	jsr		AUXOUT_FLUSH
	bra		WSTART		; then go do a warm start


; output a CR LF sequence to auxillary output
; Registers Affected
;   r3 = LF
AUXOCRLF:
    lda		#CR
    jsr		GOAUXO
    lda		#LF
    jsr		GOAUXO
    rts


; output a word in hex format
; tricky because of the need to reverse the order of the chars
PWORD:
	push	r5
	ld		r5,#NUMWKA+7
	or		r4,r1,r0	; r4 = value
pword1:
    or      r1,r4,r0    ; r1 = value
    lsr		r4,r4,#4	; shift over to next nybble
    jsr		toAsciiHex  ; convert LS nybble to ascii hex
    sta     (r5)		; save in work area
    sub		r5,r5,#1
    cmp		r5,#NUMWKA
    beq		pword1
    bcs		pword1
pword2:
    add		r5,r5,#1
    lda    (r5)     ; get char to output
	jsr		GOAUXO		; send it
	cmp		r5,#NUMWKA+7
	bcc		pword2
	pop		r5
	rts


; convert nybble in r2 to ascii hex char2
; r2 = character to convert

toAsciiHex:
	and		#15	; make sure it's a nybble
	cmp		#10	; > 10 ?
	bcc		tah1
	add		#7	; bump it up to the letter 'A'
tah1:
	add		#'0'	; bump up to ascii '0'
	rts



;******************************************************************
; *** POKE ***
;
; 'POKE expr1,expr2' stores the word from 'expr2' into the memory
; address specified by 'expr1'.
;******************************************************************
;
POKE:
	jsr		OREXPR		; get the memory address
	ldy		#','
	ld		r4,#PKER	; it must be followed by a comma
	jsr		TSTC		; it must be followed by a comma
	pha					; save the address
	jsr		OREXPR		; get the byte to be POKE'd
	plx				    ; get the address back
	sta		(x)			; store the byte in memory
	jmp		FINISH
PKER:
	lda		#msgComma
	jmp		ERROR		; if no comma, say "What?"


;******************************************************************
; 'SYSX expr' jumps to the machine language subroutine whose
; starting address is specified by 'expr'.  The subroutine can use
; all registers but must leave the stack the way it found it.
; The subroutine returns to the interpreter by executing an RTS.
;******************************************************************

SYSX:
	jsr		OREXPR		; get the subroutine's address
	cmp		#0
	bne		sysx1		; make sure we got a valid address
	lda		#msgSYSBad
	jmp		ERROR
sysx1:
	push	r8			; save the text pointer
	jsr		(r1)		; jump to the subroutine
	pop		r8		    ; restore the text pointer
	jmp		FINISH

;******************************************************************
; *** EXPR ***
;
; 'EXPR' evaluates arithmetical or logical expressions.
; <OREXPR>::= <ANDEXPR> OR <ANDEXPR> ...
; <ANDEXPR>::=<EXPR> AND <EXPR> ...
; <EXPR>::=<EXPR2>
;	   <EXPR2><rel.op.><EXPR2>
; where <rel.op.> is one of the operators in TAB8 and the result
; of these operations is 1 if true and 0 if false.
; <EXPR2>::=(+ or -)<EXPR3>(+ or -)<EXPR3>(...
; where () are optional and (... are optional repeats.
; <EXPR3>::=<EXPR4>( <* or /><EXPR4> )(...
; <EXPR4>::=<variable>
;	    <function>
;	    (<EXPR>)
; <EXPR> is recursive so that the variable '@' can have an <EXPR>
; as an index, functions can have an <EXPR> as arguments, and
; <EXPR4> can be an <EXPR> in parenthesis.
;

; <OREXPR>::=<ANDEXPR> OR <ANDEXPR> ...
;
OREXPR:
	jsr		ANDEXPR		; get first <ANDEXPR>
XP_OR1:
	pha					; save <ANDEXPR> value
	ld		r9,#TAB10	; look up a logical operator
	ld		r10,#TAB10_1
	jmp		EXEC		; go do it
XP_OR:
    jsr		ANDEXPR
    plx
    or      r1,r1,r2
    bra     XP_OR1
XP_ORX:
	pla
    rts


; <ANDEXPR>::=<EXPR> AND <EXPR> ...
;
ANDEXPR:
	jsr		EXPR		; get first <EXPR>
XP_AND1:
	pha					; save <EXPR> value
	ld		r9,#TAB9		; look up a logical operator
	ld		r10,#TAB9_1
	jmp		EXEC		; go do it
XP_AND:
    jsr		EXPR
    plx
    and     r1,r1,r2
    bra     XP_AND1
XP_ANDX:
	pla
    rts


; Determine if the character is a digit
;   Parameters
;       r1 = char to test
;   Returns
;       r1 = 1 if digit, otherwise 0
;
isDigit:
	cmp		#'0'
	bcc		isDigitFalse
	cmp		#'9'+1
	bcs		isDigitFalse
	lda		#1
    rts
isDigitFalse:
    lda		#0
    rts


; Determine if the character is a alphabetic
;   Parameters
;       r1 = char to test
;   Returns
;       r1 = 1 if alpha, otherwise 0
;
isAlpha:
	cmp		#'A'
	bcc		isAlphaFalse
	cmp		#'Z'
	beq		isAlphaTrue
	bcc		isAlphaTrue
	cmp		#'a'
	bcc		isAlphaFalse
	cmp		#'z'+1
	bcs		isAlphaFalse
isAlphaTrue:
    lda		#1
    rts
isAlphaFalse:
    lda		#0
    rts


; Determine if the character is a alphanumeric
;   Parameters
;       r1 = char to test
;   Returns
;       r1 = 1 if alpha, otherwise 0
;
isAlnum:
    tax						; save test char
    jsr		isDigit
    cmp		#0
    bne		isDigitx		; if it is a digit
    txa						; get back test char
    jsr    isAlpha
isDigitx:
    rts


EXPR:
	jsr		EXPR2
	pha					; save <EXPR2> value
	ld		r9,#TAB8		; look up a relational operator
	ld		r10,#TAB8_1
	jmp		EXEC		; go do it
XP11:
	pla
	jsr		XP18	; is it ">="?
	cmp		r2,r1
	bpl		XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP12:
	pla
	jsr		XP18	; is it "<>"?
	cmp		r2,r1
	bne		XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP13:
	pla
	jsr		XP18	; is it ">"?
	cmp		r2,r1
	beq		XPRT0
	bpl		XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP14:
	pla
	jsr		XP18	; is it "<="?
	cmp		r2,r1
	beq		XPRT1	; no, return r2=1
	bmi		XPRT1
	bra		XPRT0	; else return r2=0
XP15:
	pla
	jsr		XP18	; is it "="?
	cmp		r2,r1
	beq		XPRT1	; if not, return r2=1
	bra		XPRT0	; else return r2=0
XP16:
	pla
	jsr		XP18	; is it "<"?
	cmp		r2,r1
	bmi		XPRT1	; if not, return r2=1
	bra		XPRT0	; else return r2=0
XPRT0:
	lda		#0   ; return r1=0 (false)
	rts
XPRT1:
	lda		#1	; return r1=1 (true)
	rts

XP17:				; it's not a rel. operator
	pla				; return r2=<EXPR2>
	rts

XP18:
	pha
	jsr		EXPR2		; do a second <EXPR2>
	plx
	rts

; <EXPR2>::=(+ or -)<EXPR3>(+ or -)<EXPR3>(...
message "EXPR2"
EXPR2:
	ldy		#'-'
	ld		r4,#XP21
	jsr		TSTC		; negative sign?
	lda		#0		; yes, fake '0-'
	pha
	bra		XP26
XP21:
	ldy		#'+'
	ld		r4,#XP22
	jsr		TSTC		; positive sign? ignore it
XP22:
	jsr		EXPR3		; first <EXPR3>
XP23:
	pha					; yes, save the value
	ldy		#'+'
	ld		r4,#XP25
	jsr		TSTC		; add?
	jsr		EXPR3		; get the second <EXPR3>
XP24:
	plx
	add		r1,r1,r2	; add it to the first <EXPR3>
;	BVS.L	QHOW		brnch if there's an overflow
	bra		XP23		; else go back for more operations
XP25:
	ldy		#'-'
	ld		r4,#XP45
	jsr		TSTC		; subtract?
XP26:
	jsr		EXPR3		; get second <EXPR3>
	sub		r1,r0,r1	; change its sign
	bra		XP24		; and do an addition
XP45:
	pla
	rts


; <EXPR3>::=<EXPR4>( <* or /><EXPR4> )(...

EXPR3:
	jsr	EXPR4		; get first <EXPR4>
XP31:
	pha				; yes, save that first result
	ldy		#'*'
	ld		r4,#XP34
	jsr		TSTC		; multiply?
	jsr		EXPR4		; get second <EXPR4>
	plx
	muls	r1,r1,r2	; multiply the two
	bra		XP31        ; then look for more terms
XP34:
	ldy		#'/'
	ld		r4,#XP47
	jsr		TSTC		; divide?
	jsr		EXPR4		; get second <EXPR4>
	tax
	pla
	divs	r1,r1,r2	; do the division
	bra		XP31		; go back for any more terms
XP47:
	pla
	rts


; Functions are jsred through EXPR4
; <EXPR4>::=<variable>
;	    <function>
;	    (<EXPR>)

EXPR4:
    ld		r9,#TAB4		; find possible function
    ld		r10,#TAB4_1
	jmp		EXEC        ; branch to function which does subsequent rts for EXPR4
XP40:                   ; we get here if it wasn't a function
	lda		#0
	jsr		TSTV
	cmp		#0		
	beq     XP41		; nor a variable
	lda		(r1)		; if a variable, return its value in r1
	rts
XP41:
	jsr		TSTNUM		; or is it a number?
	cmp		r2,#0
	bne		XP46		; (if not, # of digits will be zero) if so, return it in r1
	jsr		PARN        ; check for (EXPR)
XP46:
	rts


; Check for a parenthesized expression
PARN:	
	ldy		#'('
	ld		r4,#XP43
	jsr		TSTC		; else look for ( OREXPR )
	jsr		OREXPR
	ldy		#')'
	ld		r4,#XP43
	jsr		TSTC
XP42:
	rts
XP43:
	pla				; get rid of return address
	lda		#msgWhat
	jmp		ERROR


; ===== Test for a valid variable name.  Returns Z=1 if not
;	found, else returns Z=0 and the address of the
;	variable in r1.
; Parameters
;	r1 = 1 = allocate if not found
; Returns
;	r1 = address of variable, zero if not found

TSTV:
	push	r5
	ld		r5,r1		; r5=allocate flag
	jsr		IGNBLK
	lda		(r8)		; look at the program text
	cmp		#'@'
	bcc		tstv_notfound	; C=1: not a variable
	bne		TV1				; brnch if not "@" array
	inc		r8			; If it is, it should be
	jsr		PARN		; followed by (EXPR) as its index.
;	BCS.L	QHOW		say "How?" if index is too big
    pha				    ; save the index
	jsr		SIZEX		; get amount of free memory
	plx				    ; get back the index
	cmp		r2,r1
	bcc		TV2			; see if there's enough memory
	jmp    	QSORRY		; if not, say "Sorry"
TV2:
	lda		VARBGN		; put address of array element...
	sub     r1,r1,r2       ; into r1 (neg. offset is used)
	bra     TSTVRT
TV1:	
    jsr		getVarName      ; get variable name
    cmp		#0
    beq     TSTVRT    ; if not, return r1=0
    ld		r2,r5
    jsr		findVar     ; find or allocate
TSTVRT:
	pop		r5
	rts					; r1<>0 (found)
tstv_notfound:
	pop		r5
	lda		#0			; r1=0 if not found
    rts


; Returns
;   r1 = 2 character variable name + type
;
getVarName:
    push	r5

    lda     (r8)		; get first character
    pha					; save off current name
    jsr		isAlpha
    cmp		#0
    beq     gvn1
    ld	    r5,#2       ; loop two more times

	; check for second/third character
gvn4:
	inc		r8
	lda     (r8)		; do we have another char ?
	jsr		isAlnum
	cmp		#0
	beq     gvn2		; nope
	pla					; get varname
	asl
	asl
	asl
	asl
	asl
	asl
	asl
	asl
	ldx     (r8)
	or      r1,r1,r2   ; add in new char
    pha				   ; save off name again
    dec		r5
    bne		gvn4

    ; now ignore extra variable name characters
gvn6:
    inc		r8
    lda    (r8)
    jsr    isAlnum
    cmp		#0
    bne     gvn6	; keep looping as long as we have identifier chars

    ; check for a variable type
gvn2:
	lda		(r8)
	cmp		#'%'
	beq		gvn3
	cmp		#'$'
	beq		gvn3
	lda		#0
    dec		r8

    ; insert variable type indicator and return
gvn3:
    inc		r8
    plx
    asl		r2,r2
    asl		r2,r2
    asl		r2,r2
    asl		r2,r2
    asl		r2,r2
    asl		r2,r2
    asl		r2,r2
    asl		r2,r2
    or      r1,r1,r2    ; add in variable type
    pop		r5
    rts					; return Z = 0, r1 = varname

    ; not a variable name
gvn1:
	pla
	pop		r5
    lda		#0       ; return Z = 1 if not a varname
    rts


; Find variable
;   r1 = varname
;	r2 = allocate flag
; Returns
;   r1 = variable address, Z =0 if found / allocated, Z=1 if not found

findVar:
	push	r7
    ldy     VARBGN
fv4:
    ld      r7,(y)      ; get varname / type
    beq     fv3			; no more vars ?
    cmp		r1,r7
    beq     fv1			; match ?
    iny					; move to next var
    iny
    ld      r7,STKBOT
    cmp		r3,r7
    bcc     fv4			; loop back to look at next var

    ; variable not found
    ; no more memory
    lda		#msgVarSpace
    jmp     ERROR
;    lw      lr,[sp]
;    lw      r7,4[sp]
;    add     sp,sp,#8
;    lw      r1,#0
;    rts

    ; variable not found
    ; allocate new ?
fv3:
	cpx		#0
	beq		fv2
    sta     (r3)     ; save varname / type
    ; found variable
    ; return address
fv1:
    add		r1,r3,#1
	pop		r7
    rts			    ; Z = 0, r1 = address

    ; didn't find var and not allocating
fv2:
    pop		r7
	lda		#0		; Z = 1, r1 = 0
    rts


; ===== The PEEK function returns the byte stored at the address
;	contained in the following expression.
;
PEEK:
	jsr		PARN		; get the memory address
	lda		(r1)		; get the addressed byte
	rts


; user function jsr
; call the user function with argument in r1
USRX:
	jsr		PARN		; get expression value
	push	r8			; save the text pointer
	ldx		#0
	jsr		(usrJmp,x)	; get usr vector, jump to the subroutine
	pop		r8			; restore the text pointer
	rts


; ===== The RND function returns a random number from 1 to
;	the value of the following expression in D0.
;
RND:
	jsr		PARN		; get the upper limit
	cmp		#0
	beq		rnd2		; it must be positive and non-zero
	bcc		rnd1
	tax
	;gran				; generate a random number
	;mfspr	r1,rand		; get the number
	tsr		LFSR,r1
;	jsr		modu4		; RND(n)=MOD(number,n)+1
	mod		r1,r1,r2
	ina
	rts
rnd1:
	lda		#msgRNDBad
	jmp		ERROR
rnd2:
	tsr		LFSR,r1
;	gran
;	mfspr	r1,rand
	rts


; r = a mod b
; a = r1
; b = r2 
; r = r6
;modu4:
;	push	r3
;	push	r5
;	push	r6
;	push	r7
;	ld      r7,#31		; n = 32
;	eor		r5,r5,r5	; w = 0
;;	eor		r6,r6,r6	; r = 0
;mod2:
;	rol					; a <<= 1
;	and		r3,r1,#1
;	asl		r6			; r <<= 1
;	or		r6,r6,r3
;	and		#-2
;	cmp		r2,r6
;	bmi		mod1		; b < r ?
;	sub		r6,r6,r2	; r -= b
;mod1:
;	dec		r7			; n--
;	bne		mod2
;	ld		r1,r6
;	pop		r7
;	pop		r6
;	pop		r5
;	pop		r3
;	rts
;

; ===== The ABS function returns an absolute value in r2.
;
ABS:
	jsr		PARN		; get the following expr.'s value
	cmp		#0
	bmi		ABS1
	rts
ABS1:
	sub		r1,r0,r1
	rts

;==== The TICK function returns the cpu tick value in r1.
;
TICKX:
	tsr		TICK,r1
	rts

; ===== The SGN function returns the sign in r1. +1,0, or -1
;
SGN:
	jsr		PARN		; get the following expr.'s value
	cmp		#0
	beq		SGN1
	bmi		SGN2
	lda		#1
	rts
SGN2:
	lda		#-1
	rts
SGN1:
	rts	

; ===== The SIZE function returns the size of free memory in r1.
;
SIZEX:
	lda		VARBGN		; get the number of free bytes...
	ldx		TXTUNF		; between 'TXTUNF' and 'VARBGN'
	sub		r1,r1,r2
	rts					; return the number in r1


;******************************************************************
;
; *** SETVAL *** FIN *** ENDCHK *** ERROR (& friends) ***
;
; 'SETVAL' expects a variable, followed by an equal sign and then
; an expression.  It evaluates the expression and sets the variable
; to that value.
;
; returns
; r2 = variable's address
;
SETVAL:
    lda		#1		; allocate var
    jsr		TSTV		; variable name?
    cmp		#0
    bne		sv2
   	lda		#msgVar
   	jmp		ERROR 
sv2:
	pha			    ; save the variable's address
	ldy		#'='
	ld		r4,#SV1
	jsr		TSTC		; get past the "=" sign
	jsr		OREXPR		; evaluate the expression
	plx				    ; get back the variable's address
	sta     (x)		    ; and save value in the variable
	txa					; return r1 = variable address
	rts
SV1:
    jmp	    QWHAT		; if no "=" sign


; 'FIN' checks the end of a command.  If it ended with ":",
; execution continues.	If it ended with a CR, it finds the
; the next line and continues from there.
;
FIN:
	ldy		#':'
	ld		r4,#FI1
	jsr		TSTC		; *** FIN ***
	pla					; if ":", discard return address
	jmp		RUNSML		; continue on the same line
FI1:
	ldy		#CR
	ld		r4,#FI2
	jsr		TSTC		; not ":", is it a CR?
						; else return to the caller
	pla					; yes, purge return address
	jmp		RUNNXL		; execute the next line
FI2:
	rts					; else return to the caller


; 'ENDCHK' checks if a command is ended with a CR. This is
; required in certain commands, such as GOTO, RETURN, STOP, etc.
;
; Check that there is nothing else on the line
; Registers Affected
;   r1
;
ENDCHK:
	jsr		IGNBLK
	lda		(r8)
	cmp		#CR
	beq		ec1	; does it end with a CR?
	lda		#msgExtraChars
	jmp		ERROR
ec1:
	rts

; 'ERROR' prints the string pointed to by r1. It then prints the
; line pointed to by CURRNT with a "?" inserted at where the
; old text pointer (should be on top of the stack) points to.
; Execution of Tiny BASIC is stopped and a warm start is done.
; If CURRNT is zero (indicating a direct command), the direct
; command is not printed. If CURRNT is -1 (indicating
; 'INPUT' command in progress), the input line is not printed
; and execution is not terminated but continues at 'INPERR'.
;
; Related to 'ERROR' are the following:
; 'QWHAT' saves text pointer on stack and gets "What?" message.
; 'AWHAT' just gets the "What?" message and jumps to 'ERROR'.
; 'QSORRY' and 'ASORRY' do the same kind of thing.
; 'QHOW' and 'AHOW' also do this for "How?".
;
TOOBIG:
	lda		#msgTooBig
	bra		ERROR
QSORRY:
    lda		#SRYMSG
	bra	    ERROR
QWHAT:
	lda		#msgWhat
ERROR:
	jsr		PRMESG		; display the error message
	lda		CURRNT		; get the current line pointer
	beq		ERROR1		; if zero, do a warm start
	cmp		#-1
	beq		INPERR		; is the line no. pointer = -1? if so, redo input
	ld		r5,(r8)		; save the char. pointed to
	stz		(r8)		; put a zero where the error is
	lda		CURRNT		; point to start of current line
	jsr		PRTLN		; display the line in error up to the 0
	ld      r6,r1	    ; save off end pointer
	st		r5,(r8)		; restore the character
	lda		#'?'		; display a "?"
	jsr		GOOUT
	ldx		#0			; stop char = 0
	sub		r1,r6,#1	; point back to the error char.
	jsr		PRTSTG		; display the rest of the line
ERROR1:
	jmp	    WSTART		; and do a warm start

;******************************************************************
;
; *** GETLN *** FNDLN (& friends) ***
;
; 'GETLN' reads in input line into 'BUFFER'. It first prompts with
; the character in r3 (given by the caller), then it fills the
; buffer and echos. It ignores LF's but still echos
; them back. Control-H is used to delete the last character
; entered (if there is one), and control-X is used to delete the
; whole line and start over again. CR signals the end of a line,
; and causes 'GETLN' to return.
;
;
GETLN:
	push	r5
	jsr		GOOUT		; display the prompt
	lda		#1
	sta		CursorFlash	; turn on cursor flash
	lda		#' '		; and a space
	jsr		GOOUT
	ld		r8,#BUFFER	; r8 is the buffer pointer
GL1:
	jsr		CHKIO		; check keyboard
	cmp		#0
	beq		GL1			; wait for a char. to come in
	cmp		#CTRLH
	beq		GL3			; delete last character? if so
	cmp		#CTRLX
	beq		GL4			; delete the whole line?
	cmp		#CR
	beq		GL2			; accept a CR
	cmp		#' '
	bcc		GL1			; if other control char., discard it
GL2:
	sta		(r8)		; save the char.
	inc		r8
	pha
	jsr		GOOUT		; echo the char back out
	pla					; get char back (GOOUT destroys r1)
	cmp		#CR
	beq		GL7			; if it's a CR, end the line
	cmp		r8,#BUFFER+BUFLEN-1	; any more room?
	bcc		GL1			; yes: get some more, else delete last char.
GL3:
	lda		#CTRLH	; delete a char. if possible
	jsr		GOOUT
	lda		#' '
	jsr		GOOUT
	cmp		r8,#BUFFER	; any char.'s left?
	bcc		GL1			; if not
	beq		GL1
	lda		#CTRLH		; if so, finish the BS-space-BS sequence
	jsr		GOOUT
	dec		r8			; decrement the text pointer
	bra		GL1			; back for more
GL4:
	ld		r1,r8		; delete the whole line
	sub		r5,r1,#BUFFER   ; figure out how many backspaces we need
	beq		GL6				; if none needed, brnch
	dec		r5			; loop count is one less
GL5:
	lda		#CTRLH		; and display BS-space-BS sequences
	jsr		GOOUT
	lda		#' '
	jsr		GOOUT
	lda		#CTRLH
	jsr		GOOUT
	dec		r5
	bne		GL5
GL6:
	ld		r8,#BUFFER	; reinitialize the text pointer
	bra		GL1			; and go back for more
GL7:
	lda		#0		; turn off cursor flash
	stz		(r8)		; null terminate line
	stz		CursorFlash
	lda		#LF		; echo a LF for the CR
	jsr		GOOUT
	pop		r5
	rts


; 'FNDLN' finds a line with a given line no. (in r1) in the
; text save area.  r9 is used as the text pointer. If the line
; is found, r9 will point to the beginning of that line
; (i.e. the high byte of the line no.), and r1 = 1.
; If that line is not there and a line with a higher line no.
; is found, r9 points there and r1 = 0. If we reached
; the end of the text save area and cannot find the line, flags
; r9 = 0, r1 = 0.
; r1=1 if line found
; r0 = 1	<= line is found
;	r9 = pointer to line
; r0 = 0    <= line is not found
;	r9 = zero, if end of text area
;	r9 = otherwise higher line number
;
; 'FNDLN' will initialize r9 to the beginning of the text save
; area to start the search. Some other entries of this routine
; will not initialize r9 and do the search.
; 'FNDLNP' will start with r9 and search for the line no.
; 'FNDNXT' will bump r9 by 2, find a CR and then start search.
; 'FNDSKP' uses r9 to find a CR, and then starts the search.
; return Z=1 if line is found, r9 = pointer to line
;
; Parameters
;	r1 = line number to find
;
FNDLN:
	cmp		#$FFFF
	bcc		fl1	; line no. must be < 65535
	lda		#msgLineRange
	jmp		ERROR
fl1:
	ld		r9,TXTBGN>>2	; init. the text save pointer

FNDLNP:
	cmp		r9,TXTUNF	; check if we passed the end
	beq		FNDRET1
	bcs		FNDRET1		; if so, return with r9=0,r1=0
	ldx		(r9)		; get line number
	cmp		r1,r2
	beq		FNDRET2
	bcs		FNDNXT	; is this the line we want? no, not there yet
FNDRET:
	lda		#0	; line not found, but r9=next line pointer
	rts			; return the cond. codes
FNDRET1:
;	eor		r9,r9,r9	; no higher line
	lda		#0	; line not found
	rts
FNDRET2:
	lda		#1		; line found
	rts

FNDNXT:
	inc		r9	; find the next line

FNDSKP:
	ldx		(r9)
	inc		r9
	cpx		#CR
	bne		FNDSKP		; try to find a CR, keep looking
	bra		FNDLNP		; check if end of text


;******************************************************************
; 'MVUP' moves a block up from where r1 points to where r2 points
; until r1=r3
;
MVUP1:
	ld		r4,(r1)
	st		r4,(r2)
	ina
	inx
MVUP:
	cmp		r1,r3
	bne		MVUP1
MVRET:
	rts


; 'MVDOWN' moves a block down from where r1 points to where r2
; points until r1=r3
;
MVDOWN1:
	dea
	dex
	ld		r4,(r1)
	st		r4,(r2)
MVDOWN:
	cmp		r1,r3
	bne		MVDOWN1
	rts


; 'POPA_' restores the 'FOR' loop variable save area from the stack
;
; 'PUSHA_' stacks for 'FOR' loop variable save area onto the stack
;
; Note: a single zero word is stored on the stack in the
; case that no FOR loops need to be saved. This needs to be
; done because PUSHA_ / POPA_ is called all the time.
message "POPA_"
POPA_:
	ply
	pla
	sta		LOPVAR	; restore LOPVAR, but zero means no more
	beq		PP1
	pla
	sta		LOPINC
	pla
	sta		LOPLMT
	pla
	sta		LOPLN
	pla
	sta		LOPPT
PP1:
	jmp		(y)


PUSHA_:
	ply
	lda		STKBOT		; Are we running out of stack room?
	add		r1,r1,#5	; we might need this many words
	tsx
	cmp		r2,r1
	bcc		QSORRY		; out of stack space
	ldx		LOPVAR		; save loop variables
	beq		PU1			; if LOPVAR is zero, that's all
	lda		LOPPT
	pha
	lda		LOPLN
	pha
	lda		LOPLMT
	pha
	lda		LOPINC
	pha
PU1:
	phx
	jmp		(y)



;******************************************************************
;
; 'PRTSTG' prints a string pointed to by r1. It stops printing
; and returns to the caller when either a CR is printed or when
; the next byte is the same as what was passed in r2 by the
; caller.
;
; 'PRTLN' prints the saved text line pointed to by r3
; with line no. and all.
;

; r1 = pointer to string
; r2 = stop character
; return r1 = pointer to end of line + 1

PRTSTG:
	push	r5
	push	r6
	push	r7
    ld      r5,r1	    ; r5 = pointer
    ld      r6,r2	    ; r6 = stop char
PS1:
    ld      r7,(r5)     ; get a text character
    inc		r5
    cmp		r7,r6
	beq	    PRTRET		; same as stop character? if so, return
	ld      r1,r7
	jsr		GOOUT		; display the char.
	cmp		r7,#CR
	bne     PS1			; is it a C.R.? no, go back for more
	lda		#LF      ; yes, add a L.F.
	jsr		GOOUT
PRTRET:
    ld      r2,r7	    ; return r2 = stop char
	ld		r1,r5		; return r1 = line pointer
	pop		r7
	pop		r6
	pop		r5
    rts					; then return


; 'QTSTG' looks for an underline (back-arrow on some systems),
; single-quote, or double-quote.  If none of these are found, returns
; to the caller.  If underline, outputs a CR without a LF.  If single
; or double quote, prints the quoted string and demands a matching
; end quote.  After the printing, the next i-word of the caller is
; skipped over (usually a branch instruction).
;
QTSTG:
	ldy		#'"'
	ld		r4,#QT3
	jsr		TSTC		; *** QTSTG ***
	ldx		#'"'		; it is a "
QT1:
	ld		r1,r8
	jsr		PRTSTG		; print until another
	ld		r8,r1
	cpx		#CR
	bne		QT2			; was last one a CR?
	jmp		RUNNXL		; if so run next line
QT3:
	ldy		#''''
	ld		r4,#QT4
	jsr		TSTC		; is it a single quote?
	ldx		#''''	; if so, do same as above
	bra		QT1
QT4:
	ldy		#'_'
	ld		r4,#QT5
	jsr		TSTC		; is it an underline?
	lda		#CR		; if so, output a CR without LF
	jsr		GOOUT
QT2:
	pla					; get return address
	ina					; add 2 to it in order to skip following branch
	ina
	jmp		(r1)		; skip over next i-word when returning
QT5:						; not " ' or _
	rts

; Output a CR LF sequence
;
prCRLF:
	lda		#CR
	jsr		GOOUT
	lda		#LF
	jsr		GOOUT
	rts

; 'PRTNUM' prints the 32 bit number in r1, leading blanks are added if
; needed to pad the number of spaces to the number in r2.
; However, if the number of digits is larger than the no. in
; r2, all digits are printed anyway. Negative sign is also
; printed and counted in, positive sign is not.
;
; r1 = number to print
; r2 = number of digits
; Register Usage
;	r5 = number of padding spaces
public PRTNUM:
	push	r3
	push	r5
	push	r6
	push	r7
	ld		r7,#NUMWKA	; r7 = pointer to numeric work area
	ld		r6,r1		; save number for later
	ld		r5,r2		; r5 = min number of chars
	cmp		#0
	bpl		PN2			; is it negative? if not
	sub		r1,r0,r1	; else make it positive
	dec		r5			; one less for width count
PN2:
;	ld		r3,#10
PN1:
	mod		r2,r1,#10	; r2 = r1 mod 10
	div		r1,r1,#10	; r1 /= 10 divide by 10
	add		r2,r2,#'0'	; convert remainder to ascii
	stx		(r7)		; and store in buffer
	inc		r7
	dec		r5			; decrement width
	cmp		#0
	bne		PN1
PN6:
	cmp		r5,r0
	bmi		PN4		; test pad count, skip padding if not needed
	beq		PN4
PN3:
	lda		#' '		; display the required leading spaces
	jsr		GOOUT
	dec		r5
	bne		PN3
PN4:
	cmp		r6,r0
	bpl		PN5			; is number negative?
	lda		#'-'		; if so, display the sign
	jsr		GOOUT
PN5:
	dec		r7
	lda		(r7)		; now unstack the digits and display
	jsr		GOOUT
	cmp		r7,#NUMWKA
	beq		PNRET
	bcs		PN5
PNRET:
	pop		r7
	pop		r6
	pop		r5
	pop		r3
	rts

; r1 = number to print
; r2 = number of digits
public PRTHEXNUM:
	push	r4
	push	r5
	push	r6
	push	r7
	push	r8
	ld		r7,#NUMWKA	; r7 = pointer to numeric work area
	ld		r6,r1		; save number for later
;	setlo	r5,#20		; r5 = min number of chars
	ld		r5,r2
	ld		r4,r1
	cmp		r4,r0
	bpl		PHN2		; is it negative? if not
	sub		r4,r0,r4	; else make it positive
	dec		r5			; one less for width count
PHN2
	ld		r8,#10		; maximum of 10 digits
PHN1:
	ld		r1,r4
	and		#15
	cmp		#10
	bcc		PHN7
	add		#'A'-10
	bra		PHN8
PHN7:
	add		#'0'		; convert remainder to ascii
PHN8:
	sta		(r7)		; and store in buffer
	inc		r7
	dec		r5			; decrement width
	lsr		r4,r4
	lsr		r4,r4
	lsr		r4,r4
	lsr		r4,r4
	beq		PHN6			; is it zero yet ?
	dec		r8
	bne		PHN1
PHN6:	; test pad count	
	cmp		r5,r0
	beq		PHN4
	bcc		PHN4	; skip padding if not needed
PHN3:
	lda		#' '		; display the required leading spaces
	jsr		GOOUT
	dec		r5
	bne		PHN3
PHN4:
	cmp		r6,r0
	bcs		PHN5	; is number negative?
	lda		#'-'		; if so, display the sign
	jsr		GOOUT
PHN5:
	dec		r7
	lda		(r7)		; now unstack the digits and display
	jsr		GOOUT
	cmp		r7,#NUMWKA
	beq		PHNRET
	bcs		PHN5
PHNRET:
	pop		r8
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	rts


; r1 = pointer to line
; returns r1 = pointer to end of line + 1
PRTLN:
	push	r5
    ld		r5,r1		; r5 = pointer
    lda		(r5)		; get the binary line number
    inc		r5
    ldx		#5       ; display a 0 or more digit line no.
	jsr		PRTNUM
	lda		#' '     ; followed by a blank
	jsr		GOOUT
	ldx		#0       ; stop char. is a zero
	ld		r1,r5
	jsr     PRTSTG		; display the rest of the line
	pop		r5
	rts


; ===== Test text byte following the call to this subroutine. If it
;	equals the byte pointed to by r8, return to the code following
;	the call. If they are not equal, brnch to the point
;	indicated in r4.
;
; Registers Affected
;   r3,r8
; Returns
;	r8 = updated text pointer
;
TSTC
	pha
	jsr		IGNBLK		; ignore leading blanks
	lda		(r8)
	cmp		r3,r1
	beq		TC1			; is it = to what r8 points to? if so
	pla
	ply					; increment stack pointer (get rid of return address)
	jmp		(r4)		; jump to the routine
TC1:
	inc		r8			; if equal, bump text pointer
	pla
	rts

; ===== See if the text pointed to by r8 is a number. If so,
;	return the number in r2 and the number of digits in r3,
;	else return zero in r2 and r3.
; Registers Affected
;   r1,r2,r3,r4
; Returns
; 	r1 = number
;	r2 = number of digits in number
;	r8 = updated text pointer
;
TSTNUM:
	phy
	jsr		IGNBLK		; skip over blanks
	lda		#0		; initialize return parameters
	ldx		#0
	ld		r15,#10
TN1:
	ldy		(r8)
	cpy		#'0'		; is it less than zero?
	bcc		TSNMRET
	cpy		#'9'+1		; is it greater than nine?
	bcs		TSNMRET
	cmp		r1,#$7FFFFFF	; see if there's room for new digit
	bcc		TN2
	beq		TN2
	lda		#msgNumTooBig
	jmp		ERROR		; if not, we've overflowd
TN2:
	inc		r8			; adjust text pointer
	mul		r1,r1,r15	; quickly multiply result by 10
	and		r3,r3,#$0F	; add in the new digit
	add		r1,r1,r3
	inx					; increment the no. of digits
	bra		TN1
TSNMRET:
	ply
	rts


;===== Skip over blanks in the text pointed to by r8.
;
; Registers Affected:
;	r8
; Returns
;	r8 = pointer updateded past any spaces or tabs
;
IGNBLK:
	pha
IGB2:
	lda		(r8)			; get char
	cmp		#' '
	beq		IGB1	; see if it's a space
	cmp		#'\t'
	bne		IGBRET	; or a tab
IGB1:
	inc		r8		; increment the text pointer
	bra		IGB2
IGBRET:
	pla
	rts

; ===== Convert the line of text in the input buffer to upper
;	case (except for stuff between quotes).
;
; Registers Affected
;   r1,r3
; Returns
;	r8 = pointing to end of text in buffer
;
TOUPBUF:
	ld		r8,#BUFFER	; set up text pointer
	eor		r3,r3,r3	; clear quote flag
TOUPB1:
	lda		(r8)		; get the next text char.
	inc		r8
	cmp		#CR
	beq		TOUPBRT		; is it end of line?
	cmp		#'"'
	beq		DOQUO	; a double quote?
	cmp		#''''
	beq		DOQUO	; or a single quote?
	cpy		#0
	bne		TOUPB1	; inside quotes?
	jsr		toUpper 	; convert to upper case
	sta		-1,r8	; store it
	bra		TOUPB1		; and go back for more
DOQUO:
	cpy		#0
	bne		DOQUO1; are we inside quotes?
	tay				; if not, toggle inside-quotes flag
	bra		TOUPB1
DOQUO1:
	cmp		r3,r1
	bne		TOUPB1		; make sure we're ending proper quote
	eor		r3,r3,r3	; else clear quote flag
	bra		TOUPB1
TOUPBRT:
	rts


; ===== Convert the character in r1 to upper case
;
toUpper
	cmp		#'a'		; is it < 'a'?
	bcc		TOUPRET
	cmp		#'z'+1		; or > 'z'?
	bcs		TOUPRET
	sub		#32	; if not, make it upper case
TOUPRET
	rts


; 'CHKIO' checks the input. If there's no input, it will return
; to the caller with the r1=0. If there is input, the input byte is in r1.
; However, if a control-C is read, 'CHKIO' will warm-start BASIC and will
; not return to the caller.
;
message "CHKIO"
CHKIO:
	jsr		GOIN		; get input if possible
	cmp		#0
	beq		CHKRET2		; if Zero, no input
	cmp		#CTRLC
	bne		CHKRET	; is it control-C?
	pla					; dump return address
	jmp		WSTART		; if so, do a warm start
CHKRET2:
	lda		#0
CHKRET:
	rts

; ===== Display a CR-LF sequence
;
CRLF:
	lda		#CLMSG


; ===== Display a zero-ended string pointed to by register r1
; Registers Affected
;   r1,r2,r4
;
PRMESG:
	push	r5
	or      r5,r1,r0    ; r5 = pointer to message
PRMESG1:
	inc		r5
	lb		r1,-1,r5		; 	get the char.
	beq		PRMRET
	jsr		GOOUT		;else display it trashes r4
	bra		PRMESG1
PRMRET:
	or		r1,r5,r0
	pop		r5
	rts


; ===== Display a zero-ended string pointed to by register r1
; Registers Affected
;   r1,r2,r3
;
PRMESGAUX:
	phy
	tay					; y = pointer
PRMESGA1:
	iny
	lb		r1,-1,y		; 	get the char.
	beq		PRMRETA
	jsr		GOAUXO		;else display it
	bra		PRMESGA1
PRMRETA:
	tya
	ply
	rts

;*****************************************************
; The following routines are the only ones that need *
; to be changed for a different I/O environment.     *
;*****************************************************


; ===== Output character to the console (Port 1) from register r1
;	(Preserves all registers.)
;
OUTC:
	jmp		DisplayChar


; ===== Input a character from the console into register R1 (or
;	return Zero status if there's no character available).
;
INCH:
;	jsr		KeybdCheckForKeyDirect
;	cmp		#0
;	beq		INCH1
	jsr		KeybdGetChar
	cmp		#-1
	beq		INCH1
	rts
INCH1:
	ina		; return a zero for no-char
	rts

;*
;* ===== Input a character from the host into register r1 (or
;*	return Zero status if there's no character available).
;*
AUXIN_INIT:
	stz		INPPTR
	lda		#FILENAME
	ldx		#FILEBUF<<2
	ldy		#$10000
	jsr		do_load
	rts

AUXIN:
	phx
	ldx		INPPTR
	lb		r1,FILEBUF<<2,x
	inx
	stx		INPPTR
	plx
	rts
	
;	jsr		SerialGetChar
;	cmp		#-1
;	beq		AXIRET_ZERO
;	and		#$7F				;zero out the high bit
;AXIRET:
;	rts
;AXIRET_ZERO:
;	lda		#0
;	rts

; ===== Output character to the host (Port 2) from register r1
;	(Preserves all registers.)
;
AUXOUT_INIT:
	stz		OUTPTR
	rts

AUXOUT:
	phx
	ldx		OUTPTR
	sb		r1,FILEBUF<<2,x
	inx
	stx		OUTPTR
	plx
	rts

AUXOUT_FLUSH:
	lda		#FILENAME
	ldx		#FILEBUF<<2
	ldy		OUTPTR
	jsr		do_save
	rts

;	jmp		SerialPutChar	; call boot rom routine


_cls
	jsr		ClearScreen
	jsr		HomeCursor
	jmp		FINISH

_wait10
	rts
_getATAStatus
	rts
_waitCFNotBusy
	rts
_rdcf
	jmp		FINISH
rdcf6
	bra		ERROR


; ===== Return to the resident monitor, operating system, etc.
;
BYEBYE:
	jsr		ReleaseIOFocus
	ldx		OSSP
	txs
	rts
 
;	MOVE.B	#228,D7 	return to Tutor
;	TRAP	#14

msgInit db	CR,LF,"RTF65002 Tiny BASIC v1.0",CR,LF,"(C) 2013  Robert Finch",CR,LF,LF,0
OKMSG	db	CR,LF,"OK",CR,LF,0
msgWhat	db	"What?",CR,LF,0
SRYMSG	db	"Sorry."
CLMSG	db	CR,LF,0
msgReadError	db	"Compact FLASH read error",CR,LF,0
msgNumTooBig	db	"Number is too big",CR,LF,0
msgDivZero		db	"Division by zero",CR,LF,0
msgVarSpace     db  "Out of variable space",CR,LF,0
msgBytesFree	db	" words free",CR,LF,0
msgReady		db	CR,LF,"Ready",CR,LF,0
msgComma		db	"Expecting a comma",CR,LF,0
msgLineRange	db	"Line number too big",CR,LF,0
msgVar			db	"Expecting a variable",CR,LF,0
msgRNDBad		db	"RND bad parameter",CR,LF,0
msgSYSBad		db	"SYS bad address",CR,LF,0
msgInputVar		db	"INPUT expecting a variable",CR,LF,0
msgNextFor		db	"NEXT without FOR",CR,LF,0
msgNextVar		db	"NEXT expecting a defined variable",CR,LF,0
msgBadGotoGosub	db	"GOTO/GOSUB bad line number",CR,LF,0
msgRetWoGosub   db	"RETURN without GOSUB",CR,LF,0
msgTooBig		db	"Program is too big",CR,LF,0
msgExtraChars	db	"Extra characters on line ignored",CR,LF,0

	align	4
LSTROM	equ	*		; end of possible ROM area
;	END

;*
;* ===== Return to the resident monitor, operating system, etc.
;*
;BYEBYE:
;	jmp		Monitor
;    MOVE.B	#228,D7 	;return to Tutor
;	TRAP	#14

