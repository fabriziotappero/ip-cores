;*****************************************************************
;                                                                *
;		Tiny BASIC for the Motorola MC68000	                     *
;                                                                *
; Derived from Palo Alto Tiny BASIC as published in the May 1976 *
; issue of Dr. Dobb's Journal.  Adapted to the 68000 by:         *
;	Gordon Brandly                                               *
;	12147 - 51 Street                                            *
;	Edmonton AB  T5W 3G8                                         *
;	Canada                                                       *
;	(updated mailing address for 1996)                           *
;                                                                *
; This version is for MEX68KECB Educational Computer Board I/O.  *
;                                                                *
;*****************************************************************
;    Copyright (C) 1984 by Gordon Brandly. This program may be	 *
;    freely distributed for personal use only. All commercial	 *
;		       rights are reserved.                              *
;*****************************************************************
;                                                                *
; Some Modifications by: Robert Finch                            *
; This version running on a Diligent Nexys2 board XC3S1200e      *
; Running TG68 for a processor                                   *
; - two character variable names                                 *
; - TICK variable                                                *
; -                                                *
;                                                                *
;*****************************************************************
; Vers. 1.0  1984/7/17	- Original version by Gordon Brandly
;	1.1  1984/12/9	- Addition of '$' print term by Marvin Lipford
;	1.2  1985/4/9	- Bug fix in multiply routine by Rick Murray

;	OPT	FRS,BRS 	forward ref.'s & branches default to short
RANDOM		EQU		0xFFDC0C00	; Hardware random# gen. address
GRAPHICS	EQU		0xFFDAE000	; graphics (line draw) acceelerator address
SPRCTRL		EQU		0xFFDAD000	; sprite controller address

BUFLEN	EQU	80	;	length of keyboard input buffer

;*
;* Internal variables follow:
;*
	BSS
	ORG		0x600
RANPNT:
	DC.L	START	;	random number pointer
CURRNT:
	DC.L	1		;Current line pointer
STKGOS:
	DC.L	1		;Saves stack pointer in 'GOSUB'
STKINP:
	DC.L	1		;Saves stack pointer during 'INPUT'
LOPVAR:
	DC.L	1		;'FOR' loop save area
LOPINC:
	DC.L	1		;increment
LOPLMT:
	DC.L	1		;limit
LOPLN:
	DC.L	1		;line number
LOPPT:
	DC.L	1		;text pointer
TXTUNF:
	DC.L	1		;points to unfilled text area
VARBGN:
	DC.L	1		;points to variable area
STKLMT:
	DC.L	1		;holds lower limit for stack growth
BUFFER:
	FILL.B	BUFLEN,0x00	;	Keyboard input buffer

TXT	EQU	$		;Beginning of program area

	CODE
	even
	ORG	0xFFFF2400

; Tell the outside world about these symbols
; only needed for the assembler, since this file is included from another file
public START
public ENDMEM
public PRTNUM
public AUXIN

;*
;* Standard jump table. You can change these addresses if you are
;* customizing this interpreter for a different environment.
;*
START:
		BRA.L	CSTART		;Cold Start entry point
GOWARM:	BRA.L	WSTART		;Warm Start entry point
GOOUT:	BRA.L	OUTC		;Jump to character-out routine
GOIN:	BRA.L	INC		;Jump to character-in routine
GOAUXO:	BRA.L	AUXOUT		;Jump to auxiliary-out routine
GOAUXI:	BRA.L	AUXIN		;Jump to auxiliary-in routine
GOBYE:	BRA.L	BYEBYE		;Jump to monitor, DOS, etc.
;*
;* Modifiable system constants:
;*
; Give Tiny Basic 3MB
TXTBGN	DC.L	0xC00000	;beginning of program memory
ENDMEM	DC.L	0xF00000	;	end of available memory
;*
;* The main interpreter starts here:
;*
CSTART:
	LEA		START,A0
	MOVE.L	A0,RANPNT
	MOVE.L	ENDMEM,SP	;initialize stack pointer
	LEA		INITMSG,A6	;tell who we are
	BSR.L	PRMESG
	MOVE.L	TXTBGN,TXTUNF	;init. end-of-program pointer
	MOVE.L	ENDMEM,D0	;get address of end of memory
	SUB.L	#2048,D0	;reserve 2K for the stack
	MOVE.L	D0,STKLMT
	SUB.L	#4104,D0 	;reserve variable area (27 long words)
	MOVE.L	D0,VARBGN
WSTART:
	CLR.L	D0		;initialize internal variables
	MOVE.L	D0,LOPVAR
	MOVE.L	D0,STKGOS
	MOVE.L	D0,CURRNT	;current line number pointer = 0
	MOVE.L	ENDMEM,SP	;init S.P. again, just in case
	LEA	OKMSG,A6	;display "OK"
	BSR.L	PRMESG
ST3:
	MOVE.B	#'>',D0  ;       Monitor with a '>' and
	BSR.L	GETLN	;	read a line.
	BSR.L	TOUPBUF ;	convert to upper case
	MOVE.L	A0,A4	;	save pointer to end of line
	LEA	BUFFER,A0	;point to the beginning of line
	BSR.L	TSTNUM	;	is there a number there?
	BSR.L	IGNBLK	;	skip trailing blanks
	TST	D1		;does line no. exist? (or nonzero?)
	BEQ.L	DIRECT	;	if not, it's a direct statement
	CMP.L	#0xFFFF,D1	;see if line no. is <= 16 bits
	BCC.L	QHOW		;if not, we've overflowed
	MOVE.B	D1,-(A0)	;store the binary line no.
	ROR	#8,D1		;(Kludge to store a word on a
	MOVE.B	D1,-(A0)	;possible byte boundary)
	ROL	#8,D1
	BSR.L	FNDLN	;	find this line in save area
	MOVE.L	A1,A5	;	save possible line pointer
	BNE	ST4				;	if not found, insert
	BSR.L	FNDNXT		;find the next line (into A1)
	MOVE.L	A5,A2		;pointer to line to be deleted
	MOVE.L	TXTUNF,A3	;points to top of save area
	BSR.L	MVUP		;move up to delete
	MOVE.L	A2,TXTUNF	;update the end pointer
ST4:
	MOVE.L	A4,D0		;calculate the length of new line
	SUB.L	A0,D0
	CMP.L	#3,D0		;is it just a line no. & CR?
	BEQ	ST3				;if so, it was just a delete
	MOVE.L	TXTUNF,A3	;compute new end
	MOVE.L	A3,A6
	ADD.L	D0,A3
	MOVE.L	VARBGN,D0	;see if there's enough room
	CMP.L	A3,D0
	BLS.L	QSORRY		;if not, say so
	MOVE.L	A3,TXTUNF	;if so, store new end position
	MOVE.L	A6,A1		;points to old unfilled area
	MOVE.L	A5,A2		;points to beginning of move area
	BSR.L	MVDOWN		;move things out of the way
	MOVE.L	A0,A1		;set up to do the insertion
	MOVE.L	A5,A2
	MOVE.L	A4,A3
	BSR.L	MVUP		;do it
	BRA	ST3		;go back and get another line

;*
;*******************************************************************
;*
;* *** Tables *** DIRECT *** EXEC ***
;*
;* This section of the code tests a string against a table. When
;* a match is found, control is transferred to the section of
;* code according to the table.
;*
;* At 'EXEC', A0 should point to the string, A1 should point to
;* the character table, and A2 should point to the execution
;* table. At 'DIRECT', A0 should point to the string, A1 and
;* A2 will be set up to point to TAB1 and TAB1.1, which are
;* the tables of all direct and statement commands.
;*
;* A '.' in the string will terminate the test and the partial
;* match will be considered as a match, e.g. 'P.', 'PR.','PRI.',
;* 'PRIN.', or 'PRINT' will all match 'PRINT'.
;*
;* There are two tables: the character table and the execution
;* table. The character table consists of any number of text items.
;* Each item is a string of characters with the last character's
;* high bit set to one. The execution table holds a 16-bit
;* execution addresses that correspond to each entry in the
;* character table.
;*
;* The end of the character table is a 0 byte which corresponds
;* to the default routine in the execution table, which is
;* executed if none of the other table items are matched.
;*
;* Character-matching tables:
TAB1:
	DC.B	'LIS',('T'+0x80) ;        Direct commands
	DC.B	'LOA',('D'+0x80)
	DC.B	'NE',('W'+0x80)
	DC.B	'RU',('N'+0x80)
	DC.B	'SAV',('E'+0x80)
	DC.B    'CL',('S'+0x80)
TAB2:
	DC.B	'NEX',('T'+0x80)  ;       Direct / statement
	DC.B	'LE',('T'+0x80)
	DC.B	'I',('F'+0x80)
	DC.B	'GOT',('O'+0x80)
	DC.B	'GOSU',('B'+0x80)
	DC.B	'RETUR',('N'+0x80)
	DC.B	'RE',('M'+0x80)
	DC.B	'FO',('R'+0x80)
	DC.B	'INPU',('T'+0x80)
	DC.B	'PRIN',('T'+0x80)
	DC.B	'POK',('E'+0x80)
	DC.B	'STO',('P'+0x80)
	DC.B	'BY',('E'+0x80)
	DC.B	'CAL',('L'+0x80)
	DC.B	'LIN',('E'+0x80)
	DC.B    'POIN',('T'+0x80)
	DC.B	'PENCOLO',('R'+0x80)
	DC.B	'FILLCOLO',('R'+0x80)
	DC.B	'SPRPO',('S'+0x80)
	DC.B	0
TAB4:
	DC.B	'PEE',('K'+0x80)   ;      Functions
	DC.B	'RN',('D'+0x80)
	DC.B	'AB',('S'+0x80)
	DC.B	'SIZ',('E'+0x80)
	DC.B    'TIC',('K'+0x80)
	DC.B    'TEM',('P'+0x80)
	DC.B	'SG',('N'+0x80)
	DC.B	0
TAB5:
	DC.B	'T',('O'+0x80)      ;     "TO" in "FOR"
	DC.B	0
TAB6:
	DC.B	'STE',('P'+0x80)     ;    "STEP" in "FOR"
	DC.B	0
TAB8:
	DC.B	'>',('='+0x80)        ;   Relational operators
	DC.B	'<',('>'+0x80)
	DC.B	('>'+0x80)
	DC.B	('='+0x80)
	DC.B	'<',('='+0x80)
	DC.B	('<'+0x80)
	DC.B	0
;	DC.B	0	;<- for aligning on a word boundary
	
	even
	
;* Execution address tables:
TAB1_1:
	DC.W	LIST_			;Direct commands
	DC.W	LOAD
	DC.W	NEW
	DC.W	RUN
	DC.W	SAVE
	DC.W	CLS
TAB2_1:
	DC.W	NEXT			;Direct / statement
	DC.W	LET
	DC.W	IF
	DC.W	GOTO
	DC.W	GOSUB
	DC.W	RETURN
	DC.W	REM
	DC.W	FOR
	DC.W	INPUT
	DC.W	PRINT
	DC.W	POKE
	DC.W	STOP_
	DC.W	GOBYE
	DC.W	CALL
	DC.W	LINE
	DC.W	POINT
	DC.W    PENCOLOR
	DC.W	FILLCOLOR
	DC.W	SPRPOS
	DC.W	DEFLT
TAB4_1:
	DC.W	PEEK			;Functions
	DC.W	RND
	DC.W	ABS
	DC.W	SIZE_
	DC.W	TICK
	DC.W    TEMP
	DC.W	SGN
	DC.W	XP40
TAB5_1:
	DC.W	FR1		;	"TO" in "FOR"
	DC.W	QWHAT
TAB6_1:
	DC.W	FR2		;	"STEP" in "FOR"
	DC.W	FR3
TAB8_1:
	DC.W	XP11;	>=		Relational operators
	DC.W	XP12	;<>
	DC.W	XP13	;>
	DC.W	XP15	;=
	DC.W	XP14	;<=
	DC.W	XP16	;<
	DC.W	XP17
;*
DIRECT:
	LEA	TAB1,A1
	LEA	TAB1_1,A2
EXEC:
	BSR.L	IGNBLK;		ignore leading blanks
	MOVE.L	A0,A3		;save the pointer
	CLR.B	D2		;clear match flag
EXLP:
	MOVE.B	(A0)+,D0;	get the program character
	MOVE.B	(A1),D1 	;get the table character
	BNE	EXNGO		;If end of table,
	MOVE.L	A3,A0	;;	restore the text pointer and...
	BRA	EXGO		;execute the default.
EXNGO:
	MOVE.B	D0,D3	;	Else check for period...
	AND.B	D2,D3		;and a match.
	CMP.B	#'.',D3
	BEQ	EXGO		;if so, execute
	AND.B	#0x7F,D1 ;	ignore the table's high bit
	CMP.B	D0,D1	;	is there a match?
	BEQ	EXMAT
	ADDQ.L	#2,A2	;	if not, try the next entry
	MOVE.L	A3,A0	;	reset the program pointer
	CLR.B	D2		;sorry, no match
EX1:
	TST.B	(A1)+	;	get to the end of the entry
	BPL	EX1
	BRA	EXLP		;back for more matching
EXMAT:
	MOVEQ	#-1,D2;		we've got a match so far
	TST.B	(A1)+	;	end of table entry?
	BPL	EXLP		;if not, go back for more
EXGO:
	LEA		0xFFFF0000,A3	;	execute the appropriate routine
	move.w	(a2),a2
	JMP	(A3,A2.W)

CLS:
	jsr		ClearScreen
	clr.w	CursorRow
	clr.w	CursorCol
	bra		WSTART
;*
;*******************************************************************
;*
;* What follows is the code to execute direct and statement
;* commands. Control is transferred to these points via the command
;* table lookup code of 'DIRECT' and 'EXEC' in the last section.
;* After the command is executed, control is transferred to other
;* sections as follows:
;*
;* For 'LIST', 'NEW', and 'STOP': go back to the warm start point.
;* For 'RUN': go execute the first stored line if any; else go
;* back to the warm start point.
;* For 'GOTO' and 'GOSUB': go execute the target line.
;* For 'RETURN' and 'NEXT'; go back to saved return line.
;* For all others: if 'CURRNT' is 0, go to warm start; else go;
;* execute next command. (This is done in 'FINISH'.)
;*
;*******************************************************************
;*
;* *** NEW *** STOP *** RUN (& friends) *** GOTO ***
;*
;* 'NEW<CR>' sets TXTUNF to point to TXTBGN
;*
;* 'STOP<CR>' goes back to WSTART
;*
;* 'RUN<CR>' finds the first stored line, stores its address
;* in CURRNT, and starts executing it. Note that only those
;* commands in TAB2 are legal for a stored program.
;*
;* There are 3 more entries in 'RUN':
;* 'RUNNXL' finds next line, stores it's address and executes it.
;* 'RUNTSL' stores the address of this line and executes it.
;* 'RUNSML' continues the execution on same line.
;*
;* 'GOTO expr<CR>' evaluates the expression, finds the target
;* line, and jumps to 'RUNTSL' to do it.
;*
NEW:
	BSR.L	ENDCHK
	MOVE.L	TXTBGN,TXTUNF	;set the end pointer

STOP_:
	BSR.L	ENDCHK
	BRA	WSTART

RUN:
	BSR.L	ENDCHK
	MOVE.L	TXTBGN,A0	;set pointer to beginning
	MOVE.L	A0,CURRNT

RUNNXL:
	TST.L	CURRNT	;	executing a program?
	BEQ.L	WSTART		;if not, we've finished a direct stat.
	CLR.L	D1		;else find the next line number
	MOVE.L	A0,A1
	BSR.L	FNDLNP
	BCS	WSTART		;if we've fallen off the end, stop

RUNTSL:
	MOVE.L	A1,CURRNT	;set CURRNT to point to the line no.
	MOVE.L	A1,A0		;set the text pointer to
	ADDQ.L	#2,A0		;the start of the line text

RUNSML:
	BSR.L	CHKIO	;	see if a control-C was pressed
	LEA	TAB2,A1 	;find command in TAB2
	LEA	TAB2_1,A2
	BRA	EXEC		;and execute it

GOTO:
	BSR.L	EXPR	;	evaluate the following expression
	BSR.L	ENDCHK		;must find end of line
	MOVE.L	D0,D1
	BSR.L	FNDLN		;find the target line
	BNE.L	QHOW		;no such line no.
	BRA	RUNTSL		;go do it

;*
;*******************************************************************
;*
;* *** LIST *** PRINT ***
;*
;* LIST has two forms:
;* 'LIST<CR>' lists all saved lines
;* 'LIST #<CR>' starts listing at the line #
;* Control-S pauses the listing, control-C stops it.
;*
;* PRINT command is 'PRINT ....:' or 'PRINT ....<CR>'
;* where '....' is a list of expressions, formats, back-arrows,
;* and strings.	These items a separated by commas.
;*
;* A format is a pound sign followed by a number.  It controls
;* the number of spaces the value of an expression is going to
;* be printed in.  It stays effective for the rest of the print
;* command unless changed by another format.  If no format is
;* specified, 11 positions will be used.
;*
;* A string is quoted in a pair of single- or double-quotes.
;*
;* An underline (back-arrow) means generate a <CR> without a <LF>
;*
;* A <CR LF> is generated after the entire list has been printed
;* or if the list is empty.  If the list ends with a semicolon,
;* however, no <CR LF> is generated.
;*

LIST_:
	BSR.L	TSTNUM	;	see if there's a line no.
	BSR.L	ENDCHK		;if not, we get a zero
	BSR.L	FNDLN		;find this or next line
LS1:
	BCS	WSTART		;warm start if we passed the end
	BSR.L	PRTLN	;	print the line
	BSR.L	CHKIO	;	check for listing halt request
	BEQ	LS3
	CMP.B	#CTRLS,D0	;pause the listing?
	BNE	LS3
LS2:
	BSR.L	CHKIO		;if so, wait for another keypress
	BEQ	LS2
LS3:
	BSR.L	FNDLNP		;find the next line
	BRA	LS1

PRINT:
	MOVE	#11,D4	;	D4 = number of print spaces
	BSR.L	TSTC		;if null list and ":"
	DC.B	':',PR2-$
	BSR.L	CRLF1		;give CR-LF and continue
	BRA	RUNSML		;execution on the same line
PR2:
	BSR.L	TSTC		;if null list and <CR>
	DC.B	CR,PR0-$
	BSR.L	CRLF1		;also give CR-LF and
	BRA	RUNNXL		;execute the next line
PR0:
	BSR.L	TSTC		;else is it a format?
	DC.B	'#',PR1-$
	BSR.L	EXPR		;yes, evaluate expression
	MOVE	D0,D4		;and save it as print width
	BRA	PR3		;look for more to print
PR1:
	BSR.L	TSTC		;is character expression? (MRL)
	DC.B	'$',PR4-$
	BSR.L	EXPR		;yep. Evaluate expression (MRL)
	BSR	GOOUT		;print low byte (MRL)
	BRA	PR3		;look for more. (MRL)
PR4:
	BSR.L	QTSTG	;	is it a string?
	BRA.S	PR8		;if not, must be an expression
PR3:
	BSR.L	TSTC	;	if ",", go find next
	DC.B	',',PR6-$
	BSR.L	FIN		;in the list.
	BRA	PR0
PR6:
	BSR.L	CRLF1	;	list ends here
	BRA	FINISH
PR8:
	MOVE	D4,-(SP)	;save the width value
	BSR.L	EXPR		;evaluate the expression
	MOVE	(SP)+,D4	;restore the width
	MOVE.L	D0,D1
	BSR.L	PRTNUM		;print its value
	BRA	PR3		;more to print?

FINISH:
	BSR.L	FIN	;	Check end of command
	BRA.L	QWHAT	;	print "What?" if wrong

;*
;*******************************************************************
;*
;* *** GOSUB *** & RETURN ***
;*
;* 'GOSUB expr:' or 'GOSUB expr<CR>' is like the 'GOTO' command,
;* except that the current text pointer, stack pointer, etc. are
;* saved so that execution can be continued after the subroutine
;* 'RETURN's.  In order that 'GOSUB' can be nested (and even
;* recursive), the save area must be stacked.  The stack pointer
;* is saved in 'STKGOS'.  The old 'STKGOS' is saved on the stack.
;* If we are in the main routine, 'STKGOS' is zero (this was done
;* in the initialization section of the interpreter), but we still
;* save it as a flag for no further 'RETURN's.
;*
;* 'RETURN<CR>' undoes everything that 'GOSUB' did, and thus
;* returns the execution to the command after the most recent
;* 'GOSUB'.  If 'STKGOS' is zero, it indicates that we never had
;* a 'GOSUB' and is thus an error.
;*
GOSUB:
	BSR.L	PUSHA	;	save the current 'FOR' parameters
	BSR.L	EXPR		;get line number
	MOVE.L	A0,-(SP)	;save text pointer
	MOVE.L	D0,D1
	BSR.L	FNDLN		;find the target line
	BNE.L	AHOW		;if not there, say "How?"
	MOVE.L	CURRNT,-(SP)	;found it, save old 'CURRNT'...
	MOVE.L	STKGOS,-(SP)	;and 'STKGOS'
	CLR.L	LOPVAR		;load new values
	MOVE.L	SP,STKGOS
	BRA	RUNTSL

RETURN:
	BSR.L	ENDCHK	;	there should be just a <CR>
	MOVE.L	STKGOS,D1	;get old stack pointer
	BEQ.L	QWHAT		;if zero, it doesn't exist
	MOVE.L	D1,SP		;else restore it
	MOVE.L	(SP)+,STKGOS	;and the old 'STKGOS'
	MOVE.L	(SP)+,CURRNT	;and the old 'CURRNT'
	MOVE.L	(SP)+,A0	;and the old text pointer
	BSR.L	POPA		;and the old 'FOR' parameters
	BRA	FINISH		;and we are back home

;*
;*******************************************************************
;*
;* *** FOR *** & NEXT ***
;*
;* 'FOR' has two forms:
;* 'FOR var=exp1 TO exp2 STEP exp1' and 'FOR var=exp1 TO exp2'
;* The second form means the same thing as the first form with a
;* STEP of positive 1.  The interpreter will find the variable 'var'
;* and set its value to the current value of 'exp1'.  It also
;* evaluates 'exp2' and 'exp1' and saves all these together with
;* the text pointer, etc. in the 'FOR' save area, which consisits of
;* 'LOPVAR', 'LOPINC', 'LOPLMT', 'LOPLN', and 'LOPPT'.  If there is
;* already something in the save area (indicated by a non-zero
;* 'LOPVAR'), then the old save area is saved on the stack before
;* the new values are stored.  The interpreter will then dig in the
;* stack and find out if this same variable was used in another
;* currently active 'FOR' loop.  If that is the case, then the old
;* 'FOR' loop is deactivated. (i.e. purged from the stack)
;*
;* 'NEXT var' serves as the logical (not necessarily physical) end
;* of the 'FOR' loop.  The control variable 'var' is checked with
;* the 'LOPVAR'.  If they are not the same, the interpreter digs in
;* the stack to find the right one and purges all those that didn't
;* match.  Either way, it then adds the 'STEP' to that variable and
;* checks the result with against the limit value.  If it is within
;* the limit, control loops back to the command following the
;* 'FOR'.  If it's outside the limit, the save area is purged and
;* execution continues.
;*
FOR:
	BSR.L	PUSHA		;save the old 'FOR' save area
	BSR.L	SETVAL		;set the control variable
	MOVE.L	A6,LOPVAR	;save its address
	LEA	TAB5,A1 	;use 'EXEC' to test for 'TO'
	LEA	TAB5_1,A2
	BRA	EXEC
FR1:
	BSR.L	EXPR		;evaluate the limit
	MOVE.L	D0,LOPLMT	;save that
	LEA	TAB6,A1 	;use 'EXEC' to look for the
	LEA	TAB6_1,A2	;word 'STEP'
	BRA	EXEC
FR2:
	BSR.L	EXPR	;	found it, get the step value
	BRA	FR4
FR3:
	MOVEQ	#1,D0	;	not found, step defaults to 1
FR4:
	MOVE.L	D0,LOPINC	;save that too
FR5:
	MOVE.L	CURRNT,LOPLN	;save address of current line number
	MOVE.L	A0,LOPPT	;and text pointer
	MOVE.L	SP,A6		;dig into the stack to find 'LOPVAR'
	BRA	FR7
FR6:
	ADD.L	#20,A6		;look at next stack frame
FR7:
	MOVE.L	(A6),D0 	;is it zero?
	BEQ	FR8		;if so, we're done
	CMP.L	LOPVAR,D0	;same as current LOPVAR?
	BNE	FR6		;nope, look some more
	MOVE.L	SP,A2	;	Else remove 5 long words from...
	MOVE.L	A6,A1	;	inside the stack.
	LEA	20,A3
	ADD.L	A1,A3
	BSR.L	MVDOWN
	MOVE.L	A3,SP	;	set the SP 5 long words up
FR8:
	BRA	FINISH		;and continue execution

NEXT:
	BSR.L	TSTV;		get address of variable
	BCS.L	QWHAT	;	if no variable, say "What?"
	MOVE.L	D0,A1	;	save variable's address
NX0:
	MOVE.L	LOPVAR,D0;	If 'LOPVAR' is zero, we never...
	BEQ.L	QWHAT	;	had a FOR loop, so say "What?"
	CMP.L	D0,A1	;;	else we check them
	BEQ	NX3	;	OK, they agree
	BSR.L	POPA	;	nope, let's see the next frame
	BRA	NX0
NX3:
	MOVE.L	(A1),D0 ;	get control variable's value
	ADD.L	LOPINC,D0;	add in loop increment
	BVS.L	QHOW	;	say "How?" for 32-bit overflow
	MOVE.L	D0,(A1) ;	save control variable's new value
	MOVE.L	LOPLMT,D1;	get loop's limit value
	TST.L	LOPINC
	BPL	NX1	;	branch if loop increment is positive
	EXG	D0,D1
NX1:
	CMP.L	D0,D1;		test against limit
	BLT	NX2;		branch if outside limit
	MOVE.L	LOPLN,CURRNT	;Within limit, go back to the...
	MOVE.L	LOPPT,A0	;saved 'CURRNT' and text pointer.
	BRA	FINISH
NX2:
	BSR.L	POPA		;purge this loop
	BRA	FINISH

;*
;*******************************************************************
;*
;* *** REM *** IF *** INPUT *** LET (& DEFLT) ***
;*
;* 'REM' can be followed by anything and is ignored by the
;* interpreter.
;*
;* 'IF' is followed by an expression, as a condition and one or
;* more commands (including other 'IF's) separated by colons.
;* Note that the word 'THEN' is not used.  The interpreter evaluates
;* the expression.  If it is non-zero, execution continues.  If it
;* is zero, the commands that follow are ignored and execution
;* continues on the next line.
;*
;* 'INPUT' is like the 'PRINT' command, and is followed by a list
;* of items.  If the item is a string in single or double quotes,
;* or is an underline (back arrow), it has the same effect as in
;* 'PRINT'.  If an item is a variable, this variable name is
;* printed out followed by a colon, then the interpreter waits for
;* an expression to be typed in.  The variable is then set to the
;* value of this expression.  If the variable is preceeded by a
;* string (again in single or double quotes), the string will be
;* displayed followed by a colon.  The interpreter the waits for an
;* expression to be entered and sets the variable equal to the
;* expression's value.  If the input expression is invalid, the
;* interpreter will print "What?", "How?", or "Sorry" and reprint
;* the prompt and redo the input.  The execution will not terminate
;* unless you press control-C.  This is handled in 'INPERR'.
;*
;* 'LET' is followed by a list of items separated by commas.
;* Each item consists of a variable, an equals sign, and an
;* expression.  The interpreter evaluates the expression and sets
;* the variable to that value.  The interpreter will also handle
;* 'LET' commands without the word 'LET'.  This is done by 'DEFLT'.
;*
REM:
	BRA	IF2		;skip the rest of the line

IF:	
	BSR.L	EXPR	;	evaluate the expression
IF1:
	TST.L	D0		;is it zero?
	BNE	RUNSML		;if not, continue
IF2:
	MOVE.L	A0,A1
	CLR.L	D1
	BSR.L	FNDSKP	;	if so, skip the rest of the line
	BCC	RUNTSL		;and run the next line
	BRA.L	WSTART	;	if no next line, do a warm start

INPERR:
	MOVE.L	STKINP,SP;	restore the old stack pointer
	MOVE.L	(SP)+,CURRNT;	and old 'CURRNT'
	ADDQ.L	#4,SP
	MOVE.L	(SP)+,A0	;and old text pointer

INPUT:
	MOVE.L	A0,-(SP);	save in case of error
	BSR.L	QTSTG		;is next item a string?
	BRA.S	IP2		;nope
	BSR.L	TSTV	;	yes, but is it followed by a variable?
	BCS	IP4		;if not, branch
	MOVE.L	D0,A2	;	put away the variable's address
	BRA	IP3		;if so, input to variable
IP2:
	MOVE.L	A0,-(SP);	save for 'PRTSTG'
	BSR.L	TSTV	;	must be a variable now
	BCS.L	QWHAT	;	"What?" it isn't?
	MOVE.L	D0,A2	;	put away the variable's address
	MOVE.B	(A0),D2 ;	get ready for 'PRTSTG'
	CLR.B	D0
	MOVE.B	D0,(A0)
	MOVE.L	(SP)+,A1
	BSR.L	PRTSTG	;	print string as prompt
	MOVE.B	D2,(A0) ;	restore text
IP3:
	MOVE.L	A0,-(SP);	save in case of error
	MOVE.L	CURRNT,-(SP)	;also save 'CURRNT'
	MOVE.L	#-1,CURRNT	;flag that we are in INPUT
	MOVE.L	SP,STKINP	;save the stack pointer too
	MOVE.L	A2,-(SP)	;save the variable address
	MOVE.B	#':',D0     ;    print a colon first
	BSR.L	GETLN		;then get an input line
	LEA	BUFFER,A0	;point to the buffer
	BSR.L	EXPR	;	evaluate the input
	MOVE.L	(SP)+,A2	;restore the variable address
	MOVE.L	D0,(A2) 	;save value in variable
	MOVE.L	(SP)+,CURRNT	;restore old 'CURRNT'
	MOVE.L	(SP)+,A0;	and the old text pointer
IP4:
	ADDQ.L	#4,SP	;	clean up the stack
	BSR.L	TSTC	;	is the next thing a comma?
	DC.B	',',IP5-$
	BRA	INPUT	;	yes, more items
IP5:
	BRA	FINISH

DEFLT:
	CMP.B	#CR,(A0);	empty line is OK
	BEQ	LT1		;else it is 'LET'

LET:
	BSR.L	SETVAL		;do the assignment
	BSR.L	TSTC		;check for more 'LET' items
	DC.B	',',LT1-$
	BRA	LET
LT1:
	BRA	FINISH		;until we are finished.

;*
;*******************************************************************
;*
;* *** LOAD *** & SAVE ***
;*
;* These two commands transfer a program to/from an auxiliary
;* device such as a cassette, another computer, etc.  The program
;* is converted to an easily-stored format: each line starts with
;* a colon, the line no. as 4 hex digits, and the rest of the line.
;* At the end, a line starting with an '@' sign is sent.  This
;* format can be read back with a minimum of processing time by
;* the 68000.
;*
LOAD:
	MOVE.L	TXTBGN,A0	;set pointer to start of prog. area
	MOVE.B	#CR,D0		;For a CP/M host, tell it we're ready...
	BSR	GOAUXO		;by sending a CR to finish PIP command.
LOD1:
	BSR	GOAUXI	;	look for start of line
	BEQ	LOD1
	CMP.B	#'@',D0  ;       end of program?
	BEQ	LODEND
	CMP.B	#':',D0   ;      if not, is it start of line?
	BNE	LOD1			;if not, wait for it
	BSR	GBYTE			;get first byte of line no.
	MOVE.B	D1,(A0)+	;store it
	BSR	GBYTE			;get 2nd bye of line no.
	MOVE.B	D1,(A0)+	;	store that, too
LOD2:
	BSR	GOAUXI	;	get another text char.
	BEQ	LOD2
	MOVE.B	D0,(A0)+	;store it
	CMP.B	#CR,D0		;is it the end of the line?
	BNE	LOD2		;if not, go back for more
	BRA	LOD1		;if so, start a new line
LODEND:
	MOVE.L	A0,TXTUNF	;set end-of program pointer
	BRA	WSTART		;back to direct mode

GBYTE:
	MOVEQ	#1,D2	;		get two hex characters from auxiliary
	CLR	D1			;and store them as a byte in D1
GBYTE1:
	BSR	GOAUXI		;	get a char.
	BEQ	GBYTE1
	CMP.B	#'A',D0
	BCS	GBYTE2
	SUBQ.B	#7,D0	;	if greater than 9, adjust
GBYTE2:
	AND.B	#0xF,D0		;strip ASCII
	LSL.B	#4,D1		;put nybble into the result
	OR.B	D0,D1
	DBRA	D2,GBYTE1	;get another char.
	RTS

SAVE:
	MOVE.L	TXTBGN,A0;	set pointer to start of prog. area
	MOVE.L	TXTUNF,A1	;set pointer to end of prog. area
SAVE1:
	MOVE.B	#CR,D0	;	send out a CR & LF (CP/M likes this)
	BSR	GOAUXO
	MOVE.B	#LF,D0
	BSR	GOAUXO
	CMP.L	A0,A1		;are we finished?
	BLS	SAVEND
	MOVE.B	#':',D0      ;   if not, start a line
	BSR	GOAUXO
	MOVE.B	(A0)+,D1	;send first half of line no.
	BSR	PBYTE
	MOVE.B	(A0)+,D1	;and send 2nd half
	BSR	PBYTE
SAVE2:
	MOVE.B	(A0)+,D0;	get a text char.
	CMP.B	#CR,D0		;is it the end of the line?
	BEQ	SAVE1		;if so, send CR & LF and start new line
	BSR	GOAUXO		;send it out
	BRA	SAVE2		;go back for more text
SAVEND:
	MOVE.B	#'@',D0 ;        send end-of-program indicator
	BSR	GOAUXO
	MOVE.B	#CR,D0	;	followed by a CR & LF
	BSR	GOAUXO
	MOVE.B	#LF,D0
	BSR	GOAUXO
	MOVE.B	#0x1A,D0 	;and a control-Z to end the CP/M file
	BSR	GOAUXO
	BRA	WSTART		;then go do a warm start

PBYTE:
	MOVEQ	#1,D2	;	send two hex characters from D1's low byte
PBYTE1:
	ROL.B	#4,D1	;	get the next nybble
	MOVE.B	D1,D0
	AND.B	#0xF,D0	;	strip off garbage
	ADD.B	#'0',D0   ;      make it into ASCII
	CMP.B	#'9',D0
	BLS	PBYTE2
	ADDQ.B	#7,D0		;adjust if greater than 9
PBYTE2:
	BSR	GOAUXO		;send it out
	DBRA	D2,PBYTE1	;then send the next nybble
	RTS

;*
;*******************************************************************
;*
;* *** POKE *** & CALL ***
;*
;* 'POKE expr1,expr2' stores the byte from 'expr2' into the memory
;* address specified by 'expr1'.
;*
;* 'CALL expr' jumps to the machine language subroutine whose
;* starting address is specified by 'expr'.  The subroutine can use
;* all registers but must leave the stack the way it found it.
;* The subroutine returns to the interpreter by executing an RTS.
;*
POKE:
	BSR	EXPR		;get the memory address
	BSR.L	TSTC		;it must be followed by a comma
	DC.B	',',PKER-$
	MOVE.L	D0,-(SP)	;save the address
	BSR	EXPR		;get the byte to be POKE'd
	MOVE.L	(SP)+,A1	;get the address back
	MOVE.B	D0,(A1) 	;store the byte in memory
	BRA	FINISH
PKER:
	BRA.L	QWHAT	;	if no comma, say "What?"

;*
;*******************************************************************
;* Graphics Commands added R. Finch

POINT:
	BSR EXPR
	BSR	TSTC
	DC.B	',',PKER-$
	MOVE.L	D0,-(SP)
	BSR	EXPR
	MOVE.L  (SP)+,D1
	MOVE.L	D0,D2
	BSR DrawPixel
	BRA FINISH

PENCOLOR:
	BSR	EXPR
	MOVE.L	d0,GRAPHICS
	BRA FINISH
FILLCOLOR:
	BSR	EXPR
	MOVE.L	d0,GRAPHICS+4
	BRA FINISH

SPRPOS:
	BSR EXPR
	BSR	TSTC
	DC.B	',',LINEERR1-$
	MOVE.L	D0,-(SP)
	BSR	EXPR
	BSR	TSTC
	DC.B	',',LINEERR2-$
	MOVE.L	D0,-(SP)
	BSR	EXPR
	MOVE.L	D1,-(SP)
	MOVE.L	8(SP),D1	; D1 = sprite number
	ANDI.L  #7,D1
	ASL.L   #4,D1		; D1 * 16
	ADD.L	#SPRCTRL,D1	; D1 = register base
	MOVE.L	A1,-(SP)	; save off A1
	MOVE.L	D1,A1		; A1 = register base
	MOVE.W  D0,2(A1)	; set Y position
	MOVE.L	8(SP),D0
	MOVE.W	D0,0(A1)	; set X position
	MOVE.L	(SP)+,A1	; get back A1
	MOVE.L	(SP)+,D1	; get D1 back
	ADD.L	#8,SP		; pop stack
	BRA     FINISH

LINE:
	BSR	EXPR
	BSR	TSTC
	DC.B	',',LINEERR1-$
	MOVE.L	D0,-(SP)
	BSR	EXPR
	BSR	TSTC
	DC.B	',',LINEERR2-$
	MOVE.L	D0,-(SP)
	BSR	EXPR
	BSR	TSTC
	DC.B	',',LINEERR3-$
	MOVE.L	D0,-(SP)
	BSR	EXPR
	MOVE.W	d0,GRAPHICS+14
	MOVE.L	(SP)+,d0
	MOVE.W	d0,GRAPHICS+12
	MOVE.L	(SP)+,d0
	MOVE.W	d0,GRAPHICS+10
	MOVE.L	(SP)+,d0
	MOVE.W	d0,GRAPHICS+8
	MOVE.W	#G_DRAWLINE,GRAPHICS+30
	BRA		FINISH
	
LINEERR1:
	BRA.L	QWHAT
LINEERR2:
	ADDQ	#4,SP
	BRA.L	QWHAT
LINEERR3:
	ADD.L	#8,SP
	BRA.L	QWHAT

;*
;*******************************************************************
;*
CALL:
	BSR	EXPR		;get the subroutine's address
	TST.L	D0		;make sure we got a valid address
	BEQ.L	QHOW	;	if not, say "How?"
	MOVE.L	A0,-(SP);	save the text pointer
	MOVE.L	D0,A1
	JSR	(A1)		;jump to the subroutine
	MOVE.L	(SP)+,A0	;restore the text pointer
	BRA	FINISH
;*
;*******************************************************************
;*
;* *** EXPR ***
;*
;* 'EXPR' evaluates arithmetical or logical expressions.
;* <EXPR>::=<EXPR2>
;*	   <EXPR2><rel.op.><EXPR2>
;* where <rel.op.> is one of the operators in TAB8 and the result
;* of these operations is 1 if true and 0 if false.
;* <EXPR2>::=(+,-,&,|)<EXPR3>(+,-,&,|)<EXPR3>(...
;* where () are optional and (... are optional repeats.
;* <EXPR3>::=<EXPR4>( <* or /><EXPR4> )(...
;* <EXPR4>::=<variable>
;*	    <function>
;*	    (<EXPR>)
;* <EXPR> is recursive so that the variable '@' can have an <EXPR>
;* as an index, functions can have an <EXPR> as arguments, and
;* <EXPR4> can be an <EXPR> in parenthesis.
;*
EXPR:
	BSR	EXPR2
	MOVE.L	D0,-(SP);	save <EXPR2> value
	LEA	TAB8,A1 	;look up a relational operator
	LEA	TAB8_1,A2
	BRA	EXEC		;go do it

XP11:
	BSR	XP18	;	is it ">="?
	BLT	XPRT0		;no, return D0=0
	BRA	XPRT1		;else return D0=1

XP12:
	BSR	XP18	;	is it "<>"?
	BEQ	XPRT0		;no, return D0=0
	BRA	XPRT1		;else return D0=1

XP13:
	BSR	XP18	;	is it ">"?
	BLE	XPRT0		;no, return D0=0
	BRA	XPRT1		;else return D0=1

XP14:
	BSR	XP18	;	is it "<="?
	BGT	XPRT0		;no, return D0=0
	BRA	XPRT1		;else return D0=1

XP15:
	BSR	XP18	;	is it "="?
	BNE	XPRT0		;if not, return D0=0
	BRA	XPRT1		;else return D0=1
XP15RT:
	RTS

XP16:
	BSR	XP18	;	is it "<"?
	BGE	XPRT0		;if not, return D0=0
	BRA	XPRT1		;else return D0=1
XP16RT:
	RTS

XPRT0:
	CLR.L	D0	;	return D0=0 (false)
	RTS

XPRT1:
	MOVEQ	#1,D0;		return D0=1 (true)
	RTS

XP17:
	MOVE.L	(SP)+,D0	;it's not a rel. operator
	RTS			;return D0=<EXPR2>

XP18:
	MOVE.L	(SP)+,D0	;reverse the top two stack items
	MOVE.L	(SP)+,D1
	MOVE.L	D0,-(SP)
	MOVE.L	D1,-(SP)
	BSR	EXPR2		;do second <EXPR2>
	MOVE.L	(SP)+,D1
	CMP.L	D0,D1	;	compare with the first result
	RTS			;return the result

EXPR2:
	BSR.L	TSTC		;negative sign?
	DC.B	'-',XP20-$
	CLR.L	D0	;	yes, fake '0-'
	BRA	XP26
XP20:
	BSR.L	TSTC
	DC.B	'!',XP21-$
	CLR.L	D0
	MOVE.L	D0,-(SP)
	BSR		EXPR3
	NOT.L	D0
	JMP		XP24
XP21:
	BSR.L	TSTC	;	positive sign? ignore it
	DC.B	'+',XP22-$
XP22:
	BSR	EXPR3		;first <EXPR3>
XP23:
	BSR.L	TSTC	;	add?
	DC.B	'+',XP25-$
	MOVE.L	D0,-(SP)	;yes, save the value
	BSR	EXPR3		;get the second <EXPR3>
XP24:
	MOVE.L	(SP)+,D1
	ADD.L	D1,D0	;	add it to the first <EXPR3>
	BVS.L	QHOW	;	branch if there's an overflow
	BRA	XP23	;	else go back for more operations
XP25:
	BSR.L	TSTC		;subtract?
	DC.B	'-',XP27-$	; was XP42-$
XP26:
	MOVE.L	D0,-(SP)	;yes, save the result of 1st <EXPR3>
	BSR	EXPR3		;get second <EXPR3>
	NEG.L	D0		;change its sign
	JMP	XP24		;and do an addition
XP27:
	BSR.L	TSTC
	DC.B	'&',XP28-$
	MOVE.L	D0,-(SP)
	BSR	EXPR3
	MOVE.L	(SP)+,D1
	AND.L	D1,D0
	BRA		XP23
XP28:
	BSR.L	TSTC
	DC.B	'|',XP42-$
	MOVE.L	D0,-(SP)
	BSR	EXPR3
	MOVE.L	(SP)+,D1
	OR.L	D1,D0
	BRA		XP23

EXPR3:
	BSR	EXPR4		;get first <EXPR4>
XP31:
	BSR.L	TSTC	;	multiply?
	DC.B	'*',XP34-$
	MOVE.L	D0,-(SP);	yes, save that first result
	BSR	EXPR4		;get second <EXPR4>
	MOVE.L	(SP)+,D1
	BSR.L	MULT32	;	multiply the two
	BRA	XP31		;then look for more terms
XP34:
	BSR.L	TSTC;		divide?
	DC.B	'/',XP42-$
	MOVE.L	D0,-(SP);	save result of 1st <EXPR4>
	BSR	EXPR4		;get second <EXPR4>
	MOVE.L	(SP)+,D1
	EXG	D0,D1
	BSR.L	DIV32	;	do the division
	BRA	XP31		;go back for any more terms

EXPR4:
	LEA	TAB4,A1 ;	find possible function
	LEA	TAB4_1,A2
	BRA	EXEC
XP40:
	BSR	TSTV	;	nope, not a function
	BCS	XP41		;nor a variable
	MOVE.L	D0,A1
	CLR.L	D0
	MOVE.L	(A1),D0 ;	if a variable, return its value in D0
EXP4RT:
	RTS
XP41:
	BSR.L	TSTNUM	;	or is it a number?
	MOVE.L	D1,D0
	TST	D2		;(if not, # of digits will be zero)
	BNE	EXP4RT	;	if so, return it in D0
PARN:
	BSR.L	TSTC	;	else look for ( EXPR )
	DC.B	'(',XP43-$
	BSR	EXPR
	BSR.L	TSTC
	DC.B	')',XP43-$
XP42:
	RTS
XP43:
	BRA.L	QWHAT	;	else say "What?"

;*
;* ===== Test for a valid variable name.  Returns Carry=1 if not
;*	found, else returns Carry=0 and the address of the
;*	variable in D0.

TSTV:
	BSR.L	IGNBLK
	CLR.L	D0
	MOVE.B	(A0),D0 ;	look at the program text
	SUB.B	#'@',D0
	BCS	TSTVRT	;	C=1: not a variable
	BNE	TV1		;branch if not "@" array
	ADDQ	#1,A0	;	If it is, it should be
	BSR	PARN		;followed by (EXPR) as its index.
	ADD.L	D0,D0
	BCS.L	QHOW	;	say "How?" if index is too big
	ADD.L	D0,D0
	BCS.L	QHOW
	MOVE.L	D0,-(SP)	;save the index
	BSR.L	SIZE_		;get amount of free memory
	MOVE.L	(SP)+,D1	;get back the index
	CMP.L	D1,D0		;see if there's enough memory
	BLS.L	QSORRY		;if not, say "Sorry"
	MOVE.L	VARBGN,D0	;put address of array element...
	SUB.L	D1,D0		;into D0
	RTS
TV1:
	CMP.B	#27,D0		;if not @, is it A through Z?
	EOR	#1,CCR
	BCS	TSTVRT		;if not, set Carry and return
	ADDQ	#1,A0	;	else bump the text pointer
;
	CLR.L	D1
	MOVE.B	(a0),D1
	BSR		CVT26
	cmpi.b	#0xff,d1
	beq		tv2
	ADDQ	#1,A0	; bump text pointer
	asl.l	#5,D1
	ADD.L	D1,D0
tv2:
	ADD	D0,D0		;compute the variable's address
	ADD	D0,D0
	MOVE.L	VARBGN,D1
	ADD	D1,D0		;and return it in D0 with Carry=0
TSTVRT:
	RTS

CVT26:
	cmpi.b	#'A',d1
	blo		CVT26a
	cmpi.b	#'Z',d1
	bhi		CVT26a
	subi.b	#'A',d1
	rts
CVT26a:
	moveq	#-1,d1
	rts
;*
;* ===== Multiplies the 32 bit values in D0 and D1, returning
;*	the 32 bit result in D0.
;*
MULT32:
	MOVE.L	D1,D4
	EOR.L	D0,D4	;	see if the signs are the same
	TST.L	D0		;take absolute value of D0
	BPL	MLT1
	NEG.L	D0
MLT1:
	TST.L	D1	;	take absolute value of D1
	BPL	MLT2
	NEG.L	D1
MLT2:
	CMP.L	#0xFFFF,D1	;is second argument <= 16 bits?
	BLS	MLT3	;	OK, let it through
	EXG	D0,D1	;	else swap the two arguments
	CMP.L	#0xFFFF,D1	;and check 2nd argument again
	BHI.L	QHOW		;one of them MUST be 16 bits
MLT3:
	MOVE	D0,D2	;	prepare for 32 bit X 16 bit multiply
	MULU	D1,D2		;multiply low word
	SWAP	D0
	MULU	D1,D0		;multiply high word
	SWAP	D0
;*** Rick Murray's bug correction follows:
	TST	D0		;if lower word not 0, then overflow
	BNE.L	QHOW	;	if overflow, say "How?"
	ADD.L	D2,D0	;	D0 now holds the product
	BMI.L	QHOW	;	if sign bit set, it's an overflow
	TST.L	D4		;were the signs the same?
	BPL	MLTRET
	NEG.L	D0		;if not, make the result negative
MLTRET:
	RTS

;*
;* ===== Divide the 32 bit value in D0 by the 32 bit value in D1.
;*	Returns the 32 bit quotient in D0, remainder in D1.
;*
DIV32:
	TST.L	D1		;check for divide-by-zero
	BEQ.L	QHOW		;if so, say "How?"
	MOVE.L	D1,D2
	MOVE.L	D1,D4
	EOR.L	D0,D4		;see if the signs are the same
	TST.L	D0		;take absolute value of D0
	BPL	DIV1
	NEG.L	D0
DIV1:
	TST.L	D1	;	take absolute value of D1
	BPL	DIV2
	NEG.L	D1
DIV2:
	MOVEQ	#31,D3	;	iteration count for 32 bits
	MOVE.L	D0,D1
	CLR.L	D0
DIV3:
	ADD.L	D1,D1	;	(This algorithm was translated from
	ADDX.L	D0,D0		;the divide routine in Ron Cain's
	BEQ	DIV4		;Small-C run time library.)
	CMP.L	D2,D0
	BMI	DIV4
	ADDQ.L	#1,D1
	SUB.L	D2,D0
DIV4:
	DBRA	D3,DIV3
	EXG	D0,D1	;	put rem. & quot. in proper registers
	TST.L	D4	;	were the signs the same?
	BPL	DIVRT
	NEG.L	D0	;	if not, results are negative
	NEG.L	D1
DIVRT:
	RTS

;*
;* ===== The PEEK function returns the byte stored at the address
;*	contained in the following expression.
;*
PEEK:
	BSR	PARN	;	get the memory address
	MOVE.L	D0,A1
	CLR.L	D0		;upper 3 bytes will be zero
	MOVE.B	(A1),D0 ;	get the addressed byte
	RTS			;and return it

;*
;* ===== The RND function returns a random number from 1 to
;*	the value of the following expression in D0.
;*  Uses hardware rand# generator R. Finch
RND:
	BSR	PARN	;	get the upper limit
	TST.L	D0	;	it must be positive and non-zero
	BEQ.L	QHOW
	BMI.L	QHOW
	MOVE.L	D0,D1
	MOVE.W	RANDOM+2,D0
	SWAP	D0
	MOVE.W	RANDOM,D0
	BCLR	#31,D0	;	make sure it's positive
	BSR	DIV32		;RND(n)=MOD(number,n)+1
	MOVE.L	D1,D0	;	MOD is the remainder of the div.
	ADDQ.L	#1,D0
	RTS

;*
;* ===== The ABS function returns an absolute value in D0.
;*
ABS:
	BSR	PARN		;get the following expr.'s value
	TST.L	D0
	BPL	ABSRT
	NEG.L	D0		;if negative, complement it
	BMI.L	QHOW	;	if still negative, it was too big
ABSRT:
	RTS

;* RTF
;* ===== The SGN function returns the sign value in D0.
;*
SGN:
	BSR		PARN	;get the following expr.'s value
	TST.L	D0
	BEQ		SGNRT
	BMI		SGNMI
	MOVEQ	#1,d0
SGNRT:
	RTS
SGNMI:
	MOVEQ	#-1,d0
	RTS

;*
;* ===== The SIZE function returns the size of free memory in D0.
;*
SIZE_:
	MOVE.L	VARBGN,D0	;get the number of free bytes...
	SUB.L	TXTUNF,D0	;between 'TXTUNF' and 'VARBGN'
	RTS			;return the number in D0

;* RTF
;* ===== return the millisecond time value
;*
TICK:
	move.l	Milliseconds,d0
	rts
	
TEMP:
	bsr		ReadTemp
	andi.l	#0xffff,d0
	rts

;*
;*******************************************************************
;*
;* *** SETVAL *** FIN *** ENDCHK *** ERROR (& friends) ***
;*
;* 'SETVAL' expects a variable, followed by an equal sign and then
;* an expression.  It evaluates the expression and sets the variable
;* to that value.
;*
;* 'FIN' checks the end of a command.  If it ended with ":",
;* execution continues.	If it ended with a CR, it finds the
;* the next line and continues from there.
;*
;* 'ENDCHK' checks if a command is ended with a CR. This is
;* required in certain commands, such as GOTO, RETURN, STOP, etc.
;*
;* 'ERROR' prints the string pointed to by A0. It then prints the
;* line pointed to by CURRNT with a "?" inserted at where the
;* old text pointer (should be on top of the stack) points to.
;* Execution of Tiny BASIC is stopped and a warm start is done.
;* If CURRNT is zero (indicating a direct command), the direct
;* command is not printed. If CURRNT is -1 (indicating
;* 'INPUT' command in progress), the input line is not printed
;* and execution is not terminated but continues at 'INPERR'.
;*
;* Related to 'ERROR' are the following:
;* 'QWHAT' saves text pointer on stack and gets "What?" message.
;* 'AWHAT' just gets the "What?" message and jumps to 'ERROR'.
;* 'QSORRY' and 'ASORRY' do the same kind of thing.
;* 'QHOW' and 'AHOW' also do this for "How?".
;*
SETVAL:
	BSR	TSTV	;	variable name?
	BCS	QWHAT		;if not, say "What?"
	MOVE.L	D0,-(SP);	save the variable's address
	BSR.L	TSTC	;	get past the "=" sign
	DC.B	'=',SV1-$
	BSR	EXPR	;	evaluate the expression
	MOVE.L	(SP)+,A6
	MOVE.L	D0,(A6) ;	and save its value in the variable
	RTS
SV1:
	BRA	QWHAT	;	if no "=" sign

FIN:
	BSR.L	TSTC	;	*** FIN ***
	DC.B	':',FI1-$
	ADDQ.L	#4,SP	;	if ":", discard return address
	BRA	RUNSML	;	continue on the same line
FI1:
	BSR.L	TSTC	;	not ":", is it a CR?
	DC.B	CR,FI2-$
	ADDQ.L	#4,SP	;	yes, purge return address
	BRA	RUNNXL		;execute the next line
FI2:
	RTS			;else return to the caller

ENDCHK:
	BSR.L	IGNBLK
	CMP.B	#CR,(A0);	does it end with a CR?
	BNE	QWHAT	;	if not, say "WHAT?"
	RTS

QWHAT:
	MOVE.L	A0,-(SP)
AWHAT:
	LEA	WHTMSG,A6
ERROR:
	BSR.L	PRMESG	;	display the error message
	MOVE.L	(SP)+,A0	;restore the text pointer
	MOVE.L	CURRNT,D0	;get the current line number
	BEQ	WSTART		;if zero, do a warm start
	CMP.L	#-1,D0		;is the line no. pointer = -1?
	BEQ	INPERR		;if so, redo input
	MOVE.B	(A0),-(SP)	;save the char. pointed to
	CLR.B	(A0)		;put a zero where the error is
	MOVE.L	CURRNT,A1	;point to start of current line
	BSR.L	PRTLN		;display the line in error up to the 0
	MOVE.B	(SP)+,(A0)	;restore the character
	MOVE.B	#'?',D0     ;    display a "?"
	BSR	GOOUT
	CLR	D0
	SUBQ.L	#1,A1		;point back to the error char.
	BSR.L	PRTSTG		;display the rest of the line
	BRA	WSTART		;and do a warm start
QSORRY:
	MOVE.L	A0,-(SP)
ASORRY:
	LEA	SRYMSG,A6
	BRA	ERROR
QHOW:
	MOVE.L	A0,-(SP)	;Error: "How?"
AHOW:
	LEA	HOWMSG,A6
	BRA	ERROR
;*
;*******************************************************************
;*
;* *** GETLN *** FNDLN (& friends) ***
;*
;* 'GETLN' reads in input line into 'BUFFER'. It first prompts with
;* the character in D0 (given by the caller), then it fills the
;* buffer and echos. It ignores LF's but still echos
;* them back. Control-H is used to delete the last character
;* entered (if there is one), and control-X is used to delete the
;* whole line and start over again. CR signals the end of a line,
;* and causes 'GETLN' to return.
;*
GETLN:
	BSR	GOOUT		;display the prompt
	MOVE.B	#' ',D0      ;   and a space
	BSR	GOOUT
	LEA	BUFFER,A0;	A0 is the buffer pointer
GL1:
	BSR.L	CHKIO;		check keyboard
	BEQ	GL1	;	wait for a char. to come in
	CMP.B	#CTRLH,D0	;delete last character?
	BEQ	GL3	;	if so
	CMP.B	#CTRLX,D0;	delete the whole line?
	BEQ	GL4	;	if so
	CMP.B	#CR,D0	;	accept a CR
	BEQ	GL2
	CMP.B	#' ',D0  ;       if other control char., discard it
	BCS	GL1
GL2:
	MOVE.B	D0,(A0)+;	save the char.
	BSR	GOOUT		;echo the char back out
	CMP.B	#CR,D0	;	if it's a CR, end the line
	BEQ	GL7
	CMP.L	#(BUFFER+BUFLEN-1),A0	;any more room?
	BCS	GL1	;	yes: get some more, else delete last char.
GL3:
	MOVE.B	#CTRLH,D0	;delete a char. if possible
	BSR	GOOUT
	MOVE.B	#' ',D0
	BSR	GOOUT
	CMP.L	#BUFFER,A0	;any char.'s left?
	BLS	GL1		;if not
	MOVE.B	#CTRLH,D0;	if so, finish the BS-space-BS sequence
	BSR	GOOUT
	SUBQ.L	#1,A0	;	decrement the text pointer
	BRA	GL1		;back for more
GL4:
	MOVE.L	A0,D1	;	delete the whole line
	SUB.L	#BUFFER,D1;	figure out how many backspaces we need
	BEQ	GL6		;if none needed, branch
	SUBQ	#1,D1	;	adjust for DBRA
GL5:
	MOVE.B	#CTRLH,D0	;and display BS-space-BS sequences
	BSR	GOOUT
	MOVE.B	#' ',D0
	BSR	GOOUT
	MOVE.B	#CTRLH,D0
	BSR	GOOUT
	DBRA	D1,GL5
GL6:
	LEA	BUFFER,A0	;reinitialize the text pointer
	BRA	GL1		;and go back for more
GL7:
	MOVE.B	#LF,D0	;	echo a LF for the CR
	BSR	GOOUT
	RTS

;*
;*******************************************************************
;*
;* *** FNDLN (& friends) ***
;*
;* 'FNDLN' finds a line with a given line no. (in D1) in the
;* text save area.  A1 is used as the text pointer. If the line
;* is found, A1 will point to the beginning of that line
;* (i.e. the high byte of the line no.), and flags are NC & Z.
;* If that line is not there and a line with a higher line no.
;* is found, A1 points there and flags are NC & NZ. If we reached
;* the end of the text save area and cannot find the line, flags
;* are C & NZ.
;* 'FNDLN' will initialize A1 to the beginning of the text save
;* area to start the search. Some other entries of this routine
;* will not initialize A1 and do the search.
;* 'FNDLNP' will start with A1 and search for the line no.
;* 'FNDNXT' will bump A1 by 2, find a CR and then start search.
;* 'FNDSKP' uses A1 to find a CR, and then starts the search.
;*
FNDLN:
	CMP.L	#0xFFFF,D1	;line no. must be < 65535
	BCC	QHOW
	MOVE.L	TXTBGN,A1	;init. the text save pointer

FNDLNP:
	MOVE.L	TXTUNF,A2	;check if we passed the end
	SUBQ.L	#1,A2
	CMPA.L	A1,A2
	BCS	FNDRET	;	if so, return with Z=0 & C=1
	MOVE.B	(A1),D2	;if not, get a line no.
	LSL.W	#8,D2
	MOVE.B	1(A1),D2
	CMP.W	D1,D2		;is this the line we want?
	BCS	FNDNXT		;no, not there yet
FNDRET:
	RTS			;return the cond. codes

FNDNXT:
	ADDQ.L	#2,A1;		find the next line

FNDSKP:
	CMP.B	#CR,(A1)+	;try to find a CR
	BNE	FNDSKP		;keep looking
	BRA	FNDLNP		;check if end of text

;*
;*******************************************************************
;*
;* *** MVUP *** MVDOWN *** POPA *** PUSHA ***
;*
;* 'MVUP' moves a block up from where A1 points to where A2 points
;* until A1=A3
;*
;* 'MVDOWN' moves a block down from where A1 points to where A3
;* points until A1=A2
;*
;* 'POPA' restores the 'FOR' loop variable save area from the stack
;*
;* 'PUSHA' stacks for 'FOR' loop variable save area onto the stack
;*
MVUP:
	CMP.L	A1,A3	;	see the above description
	BEQ	MVRET
	MOVE.B	(A1)+,(A2)+
	BRA	MVUP
MVRET:
	RTS

MVDOWN:
	CMP.L	A1,A2	;	see the above description
	BEQ	MVRET
	MOVE.B	-(A1),-(A3)
	BRA	MVDOWN

POPA:
	MOVE.L	(SP)+,A6	;A6 = return address
	MOVE.L	(SP)+,LOPVAR	;restore LOPVAR, but zero means no more
	BEQ	PP1
	MOVE.L	(SP)+,LOPINC	;if not zero, restore the rest
	MOVE.L	(SP)+,LOPLMT
	MOVE.L	(SP)+,LOPLN
	MOVE.L	(SP)+,LOPPT
PP1:
	JMP	(A6)	;	return

PUSHA:
	MOVE.L	STKLMT,D1	;Are we running out of stack room?
	SUB.L	SP,D1
	BCC		QSORRY		;if so, say we're sorry
	MOVE.L	(SP)+,A6	;else get the return address
	MOVE.L	LOPVAR,D1	;save loop variables
	BEQ		PU1		;if LOPVAR is zero, that's all
	MOVE.L	LOPPT,-(SP)	;else save all the others
	MOVE.L	LOPLN,-(SP)
	MOVE.L	LOPLMT,-(SP)
	MOVE.L	LOPINC,-(SP)
PU1:
	MOVE.L	D1,-(SP)
	JMP	(A6)		;return

;*
;*******************************************************************
;*
;* *** PRTSTG *** QTSTG *** PRTNUM *** PRTLN ***
;*
;* 'PRTSTG' prints a string pointed to by A1. It stops printing
;* and returns to the caller when either a CR is printed or when
;* the next byte is the same as what was passed in D0 by the
;* caller.
;*
;* 'QTSTG' looks for an underline (back-arrow on some systems),
;* single-quote, or double-quote.  If none of these are found, returns
;* to the caller.  If underline, outputs a CR without a LF.  If single
;* or double quote, prints the quoted string and demands a matching
;* end quote.  After the printing, the next 2 bytes of the caller are
;* skipped over (usually a short branch instruction).
;*
;* 'PRTNUM' prints the 32 bit number in D1, leading blanks are added if
;* needed to pad the number of spaces to the number in D4.
;* However, if the number of digits is larger than the no. in
;* D4, all digits are printed anyway. Negative sign is also
;* printed and counted in, positive sign is not.
;*
;* 'PRTLN' prints the saved text line pointed to by A1
;* with line no. and all.
;*
PRTSTG:
	MOVE.B	D0,D1	;	save the stop character
PS1:
	MOVE.B	(A1)+,D0	;get a text character
	CMP.B	D0,D1		;same as stop character?
	BEQ		PRTRET		;if so, return
	BSR		GOOUT		;display the char.
	CMP.B	#CR,D0		;;is it a C.R.?
	BNE		PS1		;no, go back for more
	MOVE.B	#LF,D0	;	yes, add a L.F.
	BSR		GOOUT
PRTRET:
	RTS			;then return

QTSTG:
	BSR.L	TSTC;		*** QTSTG ***
	DC.B	'"',QT3-$
	MOVE.B	#'"',D0  ;       it is a "
QT1:
	MOVE.L	A0,A1
	BSR	PRTSTG		;print until another
	MOVE.L	A1,A0
	MOVE.L	(SP)+,A1;	pop return address
	CMP.B	#LF,D0	;	was last one a CR?
	BEQ	RUNNXL		;if so, run next line
QT2:
	ADDQ.L	#2,A1	;	skip 2 bytes on return
	JMP	(A1)		;return
QT3:
	BSR.L	TSTC	;	is it a single quote?
	DC.B	'\'',QT4-$
	MOVE.B	#'''',D0  ;      if so, do same as above
	BRA	QT1
QT4:
	BSR.L	TSTC		;is it an underline?
	DC.B	'_',QT5-$
	MOVE.B	#CR,D0		;if so, output a CR without LF
	BSR.L	GOOUT
	MOVE.L	(SP)+,A1	;pop return address
	BRA	QT2
QT5:
	RTS			;none of the above

PRTNUM:
	movem.l	d0/d1/d4/a1/a5,-(a7)
	lea		scratch1,a5
	move.l	d1,d0
	jsr		HEX2DEC
	lea		scratch1,a5
PN8:
	move.b	(a5)+,d0
	beq		PN7
	dbra    d4,PN8
PN7:
	tst.w	d4
	bmi		PN9
	MOVE.B	#' ',D0  ;       display the required leading spaces
	BSR		GOOUT
	DBRA	D4,PN7
PN9:
	lea		scratch1,a1
	jsr		DisplayString
	movem.l	(a7)+,d0/d1/d4/a1/a5
	rts

;PRTNUM	
;	MOVE.L	D1,D3	;	save the number for later
;	MOVE.L	D4,-(SP)	;save the width value
;	MOVE.W	#0xFFFF,-(SP)	;flag for end of digit string
;	TST.L	D1		;is it negative?
;	BPL	PN1		;if not
;	NEG.L	D1	;	else make it positive
;	SUBQ	#1,D4	;	one less for width count
;PN1:
;	DIVU	#10,D1	;	get the next digit
;	BVS	PNOV	;	overflow flag set?
;	MOVE.L	D1,D0	;	if not, save remainder
;	AND.L	#0xFFFF,D1	;strip the remainder
;	BRA	TOASCII 	;skip the overflow stuff
;PNOV:
;	MOVE	D1,D0	;	prepare for long word division
;	CLR.W	D1		;zero out low word
;	SWAP	D1		;high word into low
;	DIVU	#10,D1	;	divide high word
;	MOVE	D1,D2	;	save quotient
;	MOVE	D0,D1	;	low word into low
;	DIVU	#10,D1	;	divide low word
;	MOVE.L	D1,D0	;	D0 = remainder
;	SWAP	D1		;	R/Q becomes Q/R
;	MOVE	D2,D1	;	D1 is low/high
;	SWAP	D1		;	D1 is finally high/low
;TOASCII:
;	SWAP	D0		;	get remainder
;	MOVE.W	D0,-(SP);	stack it as a digit
;	SWAP	D0
;	SUBQ	#1,D4	;	decrement width count
;	TST.L	D1		;if quotient is zero, we're done
;	BNE	PN1
;	SUBQ	#1,D4	;	adjust padding count for DBRA
;	BMI	PN4		;skip padding if not needed
;PN3:
;	MOVE.B	#' ',D0  ;       display the required leading spaces
;	BSR	GOOUT
;	DBRA	D4,PN3
;PN4:
;	TST.L	D3		;is number negative?
;	BPL	PN5
;	MOVE.B	#'-',D0  ;       if so, display the sign
;	BSR	GOOUT
;PN5:
;	MOVE.W	(SP)+,D0	;now unstack the digits and display
;	BMI	PNRET		;until the flag code is reached
;	ADD.B	#'0',D0   ;      make into ASCII
;	BSR	GOOUT
;	BRA	PN5
;PNRET:
;	MOVE.L	(SP)+,D4	;restore width value
;	RTS

PRTLN:
	CLR.L	D1
	MOVE.B	(A1)+,D1	;get the binary line number
	LSL	#8,D1
	MOVE.B	(A1)+,D1
	MOVEQ	#5,D4		;display a 5 digit line no.
	BSR	PRTNUM
	MOVE.B	#' ',D0      ;   followed by a blank
	BSR	GOOUT
	CLR	D0		;stop char. is a zero
	BRA	PRTSTG	;	display the rest of the line

;*
;* ===== Test text byte following the call to this subroutine. If it
;*	equals the byte pointed to by A0, return to the code following
;*	the call. If they are not equal, branch to the point
;*	indicated by the offset byte following the text byte.
;*
TSTC:
	BSR	IGNBLK		;ignore leading blanks
	MOVE.L	(SP)+,A1	;get the return address
	MOVE.B	(A1)+,D1	;get the byte to compare
	CMP.B	(A0),D1 	;is it = to what A0 points to?
	BEQ	TC1		;if so
	CLR.L	D1		;If not, add the second
	MOVE.B	(A1),D1 ;	byte following the call to
	ADD.L	D1,A1	;	the return address.
	JMP	(A1)		;jump to the routine
TC1:
	ADDQ.L	#1,A0	;	if equal, bump text pointer
	ADDQ.L	#1,A1	;	Skip the 2 bytes following
	JMP	(A1)		;the call and continue.

;*
;* ===== See if the text pointed to by A0 is a number. If so,
;*	return the number in D1 and the number of digits in D2,
;*	else return zero in D1 and D2.
;*
TSTNUM:
	CLR.L	D1		;initialize return parameters
	CLR	D2
	BSR	IGNBLK		;skip over blanks
TN1:
	CMP.B	#'0',(A0) ;      is it less than zero?
	BCS	TSNMRET 	;if so, that's all
	CMP.B	#'9',(A0) ;      is it greater than nine?
	BHI	TSNMRET 	;if so, return
	CMP.L	#214748364,D1	;see if there's room for new digit
	BCC	QHOW		;if not, we've overflowd
	MOVE.L	D1,D0	;	quickly multiply result by 10
	ADD.L	D1,D1
	ADD.L	D1,D1
	ADD.L	D0,D1
	ADD.L	D1,D1
	MOVE.B	(A0)+,D0	;add in the new digit
	AND.L	#0xF,D0
	ADD.L	D0,D1
	ADDQ	#1,D2		;increment the no. of digits
	BRA	TN1
TSNMRET:
	RTS

;*
;* ===== Skip over blanks in the text pointed to by A0.
;*
IGNBLK:
	CMP.B	#' ',(A0)   ;    see if it's a space
	BNE	IGBRET		;if so, swallow it
IGB1:
	ADDQ.L	#1,A0	;	increment the text pointer
	BRA	IGNBLK
IGBRET:
	RTS

;*
;* ===== Convert the line of text in the input buffer to upper
;*	case (except for stuff between quotes).
;*
TOUPBUF:
	LEA	BUFFER,A0	;set up text pointer
	CLR.B	D1		;clear quote flag
TOUPB1:
	MOVE.B	(A0)+,D0	;get the next text char.
	CMP.B	#CR,D0		;is it end of line?
	BEQ	TOUPBRT 	;if so, return
	CMP.B	#'"',D0  ;       a double quote?
	BEQ	DOQUO
	CMP.B	#'''',D0  ;      or a single quote?
	BEQ	DOQUO
	TST.B	D1		;inside quotes?
	BNE	TOUPB1		;if so, do the next one
	BSR	TOUPPER 	;convert to upper case
	MOVE.B	D0,-(A0);	store it
	ADDQ.L	#1,A0
	BRA	TOUPB1		;and go back for more
TOUPBRT:
	RTS

DOQUO:
	TST.B	D1	;	are we inside quotes?
	BNE	DOQUO1
	MOVE.B	D0,D1	;	if not, toggle inside-quotes flag
	BRA	TOUPB1
DOQUO1:
	CMP.B	D0,D1	;	make sure we're ending proper quote
	BNE	TOUPB1		;if not, ignore it
	CLR.B	D1		;else clear quote flag
	BRA	TOUPB1

;*
;* ===== Convert the character in D0 to upper case
;*
TOUPPER:
	CMP.B	#'a',D0   ;      is it < 'a'?
	BCS	TOUPRET
	CMP.B	#'z',D0        ; or > 'z'?
	BHI	TOUPRET
	SUB.B	#32,D0		;if not, make it upper case
TOUPRET:
	RTS

;*
;* 'CHKIO' checks the input. If there's no input, it will return
;* to the caller with the Z flag set. If there is input, the Z
;* flag is cleared and the input byte is in D0. However, if a
;* control-C is read, 'CHKIO' will warm-start BASIC and will not
;* return to the caller.
;*
CHKIO:
	BSR.L	GOIN	;	get input if possible
	BEQ	CHKRET		;if Zero, no input
	CMP.B	#CTRLC,D0	;is it control-C?
	BNE	CHKRET		;if not
	BRA.L	WSTART		;if so, do a warm start
CHKRET:
	RTS

;*
;* ===== Display a CR-LF sequence
;*
CRLF1:
	LEA	CLMSG,A6

;*
;* ===== Display a zero-ended string pointed to by register A6
;*
PRMESG:
	MOVE.B	(A6)+,D0	;get the char.
	BEQ	PRMRET		;if it's zero, we're done
	BSR	GOOUT		;else display it
	BRA	PRMESG
PRMRET:
	RTS

;******************************************************
;* The following routines are the only ones that need *
;* to be changed for a different I/O environment.     *
;******************************************************

;UART		EQU		0xFFDC0A00
;UART_LS		EQU		UART+1
;UART_CTRL	EQU		UART+7
;KEYBD		EQU		0xFFDC0000


;*
;* ===== Output character to the console (Port 1) from register D0
;*	(Preserves all registers.)
;*
OUTC:
	MOVEM.L	D0/D1,-(SP)
	MOVE.L	D0,D1
	JSR		DisplayChar
	MOVEM.L	(SP)+,D0/D1
	RTS

;*
;* ===== Input a character from the console into register D0 (or
;*	return Zero status if there's no character available).
;*
INC:
	MOVE.W	KEYBD,D0	;is character ready?
	BPL		INCRET0		;if not, return Zero status
	CLR.W	KEYBD+2		; clear keyboard strobe line
	AND.W	#0xFF,D0 	;zero out the high bit
	RTS
INCRET0
	MOVEQ	#0,D0
	RTS

;*
;* ===== Output character to the host (Port 2) from register D0
;*	(Preserves all registers.)
;*
AUXOUT:
	BTST	#5,UART_LS	;is port ready for a character?
	BEQ		AUXOUT		;if not, wait for it
	MOVE.B	D0,UART		;out it goes.
	RTS

;*
;* ===== Input a character from the host into register D0 (or
;*	return Zero status if there's no character available).
;*
AUXIN:
	BTST	#0,UART_LS	;is character ready?
	BEQ		AXIRET		;if not, return Zero status
	MOVE.B	UART,D0		;else get the character
	AND.B	#0x7F,D0 	;zero out the high bit
AXIRET:
	RTS

;*
;* ===== Return to the resident monitor, operating system, etc.
;*
BYEBYE:
	JMP		Monitor
;    MOVE.B	#228,D7 	;return to Tutor
;	TRAP	#14

INITMSG:
	DC.B	CR,LF,'Gordo\'s MC68000 Tiny BASIC, v1.3',CR,LF,LF,0
OKMSG:
	DC.B	CR,LF,'OK',CR,LF,0
HOWMSG:
	DC.B	'How?',CR,LF,0
WHTMSG:
	DC.B	'What?',CR,LF,0
SRYMSG:
	DC.B	'Sorry.'
CLMSG:
	DC.B	CR,LF,0
;	DC.B	0	;<- for aligning on a word boundary
	even
	
LSTROM	EQU		$
	;	end of possible ROM area

