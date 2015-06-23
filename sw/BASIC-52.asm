;*****************************************************************************
;*                                                                           *
;*                      MCS BASIC-52 (tm) Source Listing                     *
;*                             December 18, 1986                             *
;*	  The original source code of V1.1 (BASIC.SRC and FP52.SRC) by	     *
;*	       Intel Corporation, Embedded Controller Operations	     *
;*				is public donain			     *
;*                                                                           *
;*---------------------------------------------------------------------------*
;*              Alterations made by D. Wulf , December 18, 1999              *
;*              Alterations made by D. Wallner , May 4, 2002                 *
;*                                                                           *
;*****************************************************************************
;
;  The BASIC.a51 source listing, when compiled without modification,
;  create the same object code that is found on the MCS BASIC-52
;  Version 1.1 microcontrollers but with a timing independent baud rate
;  recognition routine and a shorter ego message.
;
;  The following alterations are made to the original source code:
;
;  The original source code had 2 files BASIC.SRC and FP52.SRC those have 
;  been incorporated into this file for ease of assembly. 
;
;  All absolute and relativ jumps and calls without labels were providet
;  with labels.
; 
;  All machine code in the original source, codet in databytes is replaced
;  by the menomics.
;
;  One routine in the source was different to the ROM code and is replaced 
;  by the ROM code.                       
;
;  Daniel Wallner , May 4, 2002:
;  Part of ego message replaced with a different baud recognition routine.
;
;*****************************************************************************
;
T2CON	EQU	0C8H ; This three lines are necessary for MS-DOS freeware 
TL2	EQU	0CCH ; MCS-51 Family Cross Assembler  ASEM-51 V1.2 
TH2	EQU	0CDH ; from W.W. Heinz (e-mail: ww@andiunx.m.isar.de)
;
;*****************************************************************************
;
$EJECT
	;**************************************************************
	;
	; TRAP VECTORS TO MONITOR
	;
	; RESET TAG (0AAH) ---------2001H
	;
	; TAG LOCATION (5AH) ------ 2002H
	;
	; EXTERNAL INTERRUPT 0 ---- 2040H
	;
	; COMMAND MODE ENTRY ------ 2048H
	;
	; SERIAL PORT ------------- 2050H
	;
	; MONITOR (BUBBLE) OUTPUT - 2058H
	;
	; MONITOR (BUBBLE) INPUT -- 2060H
	;
	; MONITOR (BUBBLE) CSTS --- 2068H
	;
	; GET USER JUMP VECTOR ---- 2070H
	;
	; GET USER LOOKUP VECTOR -- 2078H
	;
	; PRINT AT VECTOR --------- 2080H
	;
	; INTERRUPT PWM ----------- 2088H
	;
	; EXTERNAL RESET ---------- 2090H
	;
	; USER OUTPUT-------------- 4030H
	;
	; USER INPUT -------------- 4033H
	;
	; USER CSTS --------------- 4036H
	;
	; USER RESET -------------- 4039H
	;
	; USER DEFINED PRINT @ ---  403CH
	;
	;***************************************************************
	;
$EJECT
	;***************************************************************
	;
	; MCS - 51  -  8K BASIC VERSION 1.1
	;
	;***************************************************************
	;
	AJMP	CRST		;START THE PROGRAM
        ADDC    A,@R1
        ;
	ORG	3H
	;
	;***************************************************************
	;
	;EXTERNAL INTERRUPT 0
	;
	;***************************************************************
	;
	JB	DRQ,STQ		;SEE IF DMA IS SET
	PUSH	PSW		;SAVE THE STATUS
	LJMP	4003H		;JUMP TO USER IF NOT SET
	;
	ORG	0BH
	;
	;***************************************************************
	;
	;TIMER 0 OVERFLOW INTERRUPT
	;
	;***************************************************************
	;
	PUSH	PSW		;SAVE THE STATUS
	JB	C_BIT,STJ	;SEE IF USER WANTS INTERRUPT
	LJMP	400BH		;EXIT IF USER WANTS INTERRUPTS
	;
	ORG	13H
	;
	;***************************************************************
	;
	;EXTERNAL INTERRUPT 1
	;
	;***************************************************************
	;
	JB	INTBIT,STK
	PUSH	PSW
	LJMP	4013H
	;
$EJECT
	;
	ORG	1BH
	;
	;***************************************************************
	;
	;TIMER 1 OVERFLOW INTERRUPT
	;
	;***************************************************************
	;
	PUSH	PSW
	LJMP	CKS_I
	;
STJ:	LJMP	I_DR		;DO THE INTERRUPT
	;
	;***************************************************************
	;
	;SERIAL PORT INTERRUPT
	;
	;***************************************************************
	;
	ORG	23H
	;
	PUSH	PSW
	JB	SPINT,STU	;SEE IF MONITOR EANTS INTERRUPT
	LJMP	4023H
	;
	ORG	2BH
	;
	;**************************************************************
	;
	;TIMER 2 OVERFLOW INTERRUPT
	;
	;**************************************************************
	;
	PUSH	PSW
	LJMP	402BH
	;
$EJECT
	;**************************************************************
	;
	;USER ENTRY
	;
	;**************************************************************
	;
	ORG	30H
	;
	LJMP	IBLK		;LINK TO USER BLOCK
	;
STQ:	JB	I_T0,STS	;SEE IF MONITOR WANTS IT
	CLR	DACK
	JNB	P3.2,$		;WAIT FOR DMA TO END
	SETB	DACK
	RETI
	;
STS:	LJMP	2040H		;GO TO THE MONITOR
	;
STK:	SETB	INTPEN		;TELL BASIC AN INTERRUPT WAS RECEIVED
	RETI
	;
STU:	LJMP	2050H		;SERIAL PORT INTERRUPT
	;
$EJECT

;$INCLUDE(:F2:LOOK52.SRC)
; INCLUDED BELOW

	;
	;**************************************************************
	;
	; This is the equate table for 8052 basic.
	;
	;**************************************************************
	;
	; The register to direct equates for CJNE instructions.
	;
R0B0	EQU	0
R1B0	EQU	1
R2B0	EQU	2
R3B0	EQU	3
R4B0	EQU	4
R5B0	EQU	5
R6B0	EQU	6
R7B0	EQU	7
	;
	; Register bank 1 contains the text pointer
	; and the arg stack pointer.
	;
TXAL	EQU	8		;R0 BANK 1 = TEXT POINTER LOW
ASTKA	EQU	9		;R1 BANK 1 = ARG STACK
TXAH	EQU	10		;R2 BANK 1 = TEXT POINTER HIGH
	;
	; Now five temporary locations that are used by basic.
	;
TEMP1	EQU	11
TEMP2	EQU	12
TEMP3	EQU	13
TEMP4	EQU	14
TEMP5	EQU	15
	;
$EJECT
	; Register bank 2 contains the read text pointer
	; and the control stack pointer.
	;
RTXAL	EQU	16		;R0 BANK 2 = READ TEXT POINTER LOW
CSTKA	EQU	17		;R1 BANK 2 = CONTROL STACK POINTER
RTXAH	EQU	18		;R2 BANK 2 = READ TEXT POINTER HIGH
	;
	; Now some internal system equates.
	;
BOFAH	EQU	19		;START OF THE BASIC PROGRAM, HIGH BYTE
BOFAL	EQU	20		;START OF THE BASIC PROGRAM, LOW BYTE
NULLCT	EQU	21		;NULL COUNT
PHEAD	EQU	22		;PRINT HEAD POSITION
FORMAT	EQU	23
	;
	; Register bank 3 is for the user and can be loaded
	; by basic
	;
	;
	;
	; Now everything else is used by basic.
	; First the bit locations, these use bytes 34, 35, 36, 37 and 38
	;
$EJECT
OTS		BIT	16	;34.0-ON TIME INSTRUCTION EXECUTED
INPROG		BIT	17	;34.1-INTERRUPT IN PROCESS
INTBIT		BIT	18	;34.2-INTERRUPT SET BIT
ON_ERR		BIT	19	;34.3-ON ERROR EXECUTED
OTI		BIT	20	;34.4-ON TIME INTERRUPT IN PROGRESS
LINEB		BIT	21	;34.5-LINE CHANGE OCCURED
INTPEN		BIT	22	;34.6-INTERRUPT PENDING BIT
CONB		BIT	23	;34.7-CAN CONTINUE IF SET
GTRD		BIT	24	;35.0-READ GET LOCATION
LPB		BIT	25	;35.1-PRINT TO LINE PRINTER PORT
CKS_B		BIT	26	;35.2-FOR PWM INTERRUPT
COB		BIT	27	;35.3-CONSOLE OUT BIT
				;     0 = SERIAL PORT
				;     1 = LINE PRINTER
COUB		BIT	28	;35.4-USER CONSOLE OUT BIT
				;     0 = SERIAL PORT
				;     1 = USER DRIVER
INBIT		BIT	29	;35.5-INITIALIZATION BIT
CIUB		BIT	30	;35.6-USER CONSOLE IN BIT
				;     0 = SERIAL PORT
				;     1 = USER ROUTINE
SPINT		BIT	31	;35.7-SERIAL PORT INTERRUPT
STOPBIT		BIT	32	;36.0-PROGRAM STOP ENCOUNTERED
U_IDL		BIT	33	;36.1-USER IDLE BREAK
INP_B		BIT	34	;36.2-SET DURING INPUT INSTRUCTION
;DCMPXZ		BIT	35	;36.3-DCMPX ZERO FLAG
ARGF		BIT	36	;36.4-ARG STACK HAS A VALUE
RETBIT		BIT	37	;36.5-RET FROM INTERRUPT EXECUTED
I_T0		BIT	38	;36.6-TRAP INTERRUPT ZERO TO MON
UPB		BIT	39	;36.7-SET WHEN @ IS VALID
JKBIT		BIT	40	;37.0-WB TRIGGER
ENDBIT		BIT	41	;37.1-GET END OF PROGRAM
UBIT		BIT	42	;37.2-FOR DIM STATEMENT
ISAV		BIT	43	;37.3-SAVE INTERRUPT STATUS
BO		BIT	44	;37.4-BUBBLE OUTPUT
XBIT		BIT	45	;37.5-EXTERNAL PROGRAM PRESENT
C_BIT		BIT	46	;37.6-SET WHEN CLOCK RUNNING
DIRF		BIT	47	;37.7-DIRECT INPUT MODE
NO_C		BIT	48	;38.0-NO CONTROL C
DRQ		BIT	49	;38.1-DMA ENABLED
BI		BIT	50	;38.2-BUBBLE INPUT
INTELB		BIT	51	;38.3-INTELLIGENT PROM PROGRAMMING
C0ORX1		BIT	52	;38.4-PRINT FROM ROM OR RAM
CNT_S		BIT	53	;38.5-CONTROL S ENCOUNTERED
ZSURP		BIT	54	;38.6-ZERO SUPRESS
HMODE		BIT	55	;38.7-HEX MODE PRINT
LP		BIT	P1.7	;SOFTWARE LINE PRINTER
DACK		BIT	P1.6	;DMA ACK
PROMV		BIT	P1.5	;TURN ON PROM VOLTAGE
PROMP		BIT	P1.4	;PROM PULSE
ALED		BIT	P1.3	;ALE DISABLE
T_BIT		BIT	P1.2	;I/O TOGGLE BIT
	;
$EJECT
	;
	; The next location is a bit addressable byte counter
	;
BABC	EQU	39
	;
	; Now floating point and the other temps
	;
	; FP Uses to locations 03CH
	;
	; Now the stack designators.
	;
SPSAV	EQU	3EH
S_LEN	EQU	3FH
T_HH	EQU	40H
T_LL	EQU	41H
INTXAH	EQU	42H
INTXAL	EQU	43H
MT1	EQU	45H
MT2	EQU	46H
MILLIV	EQU	47H		;TIMER LOCATIONS
TVH	EQU	48H
TVL	EQU	49H
SAVE_T	EQU	4AH
SP_H	EQU	4BH		;SERIAL PORT TIME OUT
SP_L	EQU	4CH
CMNDSP	EQU	4DH		;SYSTEM STACK POINTER
RCAPH2  EQU     0CBH
RCAPL2  EQU     0CAH
IRAMTOP EQU     0FFH            ;TOP OF RAM
STACKTP	EQU	0FEH		;ARG AND CONTROL STACK TOPS
	;
	; The character equates
	;
CR	EQU	0DH		;CARRIAGE RETURN
LF	EQU	0AH		;LINE FEED
BELL	EQU	07H		;BELL CHARACTER
BS	EQU	08H		;BACK SPACE
CNTRLC	EQU	03H		;CONTROL C
CNTRLD	EQU	04H		;CONTROL D
NULL	EQU	00H		;NULL
	;
$EJECT
	;
	; The internal system equates
	;
LINLEN	EQU	73		;THE LENGTH OF AN INPUT LINE
EOF	EQU	01		;END OF FILE CHARACTER
ASTKAH	EQU	01		;ASTKA IS IN PAGE 1 OF RAM
CSTKAH	EQU	00		;CSTKA IS IN PAGE 0 OF RAM
FTYPE	EQU	01		;CONTROL STACK "FOR"
GTYPE	EQU	02		;CONTROL STACK "GOSUB"
DTYPE	EQU	03		;DO-WHILE/UNTIL TYPE
ROMADR	EQU	8000H		;LOCATION OF ROM
	;
	; The floating point equates
	;
FPSIZ	EQU	6		;NO. OF BYTES IN A FLOATING NUM
DIGIT	EQU	FPSIZ-2		;THE MANTISSA OF A FLOATING NUM
STESIZ	EQU	FPSIZ+3		;SIZE OF SYMBOL ADJUSTED TABLE ELEMENT
;FP_BASE EQU     1993H           ;BASE OF FLOATING POINT ROUTINES
PSTART	EQU	512		;START OF A PROGRAM IN RAM
FSIZE	EQU	FPSIZ+FPSIZ+2+2+1
	;
$EJECT
	;**************************************************************
	;
USENT:	; User entry jump table
	;
	;**************************************************************
	;
	DW	CMND1		;(00, 00H)COMMAND MODE JUMP
	DW	IFIX		;(01, 01H)CONVERT FP TO INT
	DW	PUSHAS		;(02, 02H)PUSH VALUE ONTO ARG STACK
	DW	POPAS		;(03, 03H)POP VALUE OFF ARG STACK
	DW	PG1		;(04, 04H)PROGRAM A PROM
	DW	INLINE		;(05, 05H)INPUT A LINE
	DW	UPRNT		;(06, 06H)PRINT A LINR
	DW	CRLF		;(07, 07H)OUTPUT A CRLF
	;
	;**************************************************************
	;
	; This is the operation jump table for arithmetics
	;
	;**************************************************************
	;
OPTAB:	DW	ALPAR		;(08, 08H)LEFT PAREN
	DW	AEXP		;(09, 09H)EXPONENTAION
	DW	AMUL		;(10, 0AH)FP MUL
	DW	AADD		;(11, 0BH)FLOATING POINT ADD
	DW	ADIV		;(12, 0CH)FLOATING POINT DIVIDE
	DW	ASUB		;(13, 0DH)FLOATING POINT SUBTRACTION
	DW	AXRL		;(14, 0EH)XOR
	DW	AANL		;(15, 0FH)AND
	DW	AORL		;(16, 10H)OR
	DW	ANEG		;(17, 11H)NEGATE
	DW	AEQ		;(18, 12H)EQUAL
	DW	AGE		;(19, 13H)GREATER THAN OR EQUAL
	DW	ALE		;(20, 14H)LESS THAN OR EQUAL
	DW	ANE		;(21, 15H)NOT EQUAL
	DW	ALT		;(22, 16H)LESS THAN
	DW	AGT		;(23, 17H)GREATER THAN
	;
$EJECT
	;***************************************************************
	;
	; This is the jump table for unary operators
	;
	;***************************************************************
	;
	DW	AABS		;(24, 18H)ABSOLUTE VALUE
	DW	AINT		;(25, 19H)INTEGER OPERATOR
	DW	ASGN		;(26, 1AH)SIGN OPERATOR
	DW	ANOT		;(27, 1BH)ONE'S COMPLEMENT
	DW	ACOS		;(28, 1CH)COSINE
	DW	ATAN		;(29, 1DH)TANGENT
	DW	ASIN		;(30, 1EH)SINE
	DW	ASQR		;(31, 1FH)SQUARE ROOT
	DW	ACBYTE		;(32, 20H)READ CODE
	DW	AETOX		;(33, 21H)E TO THE X
	DW	AATAN		;(34, 22H)ARC TANGENT
	DW	ALN		;(35, 23H)NATURAL LOG
	DW	ADBYTE		;(36, 24H)READ DATA MEMORY
	DW	AXBYTE		;(37, 25H)READ EXTERNAL MEMORY
	DW	PIPI		;(38, 26H)PI
	DW	ARND		;(39, 27H)RANDOM NUMBER
	DW	AGET		;(40, 28H)GET INPUT CHARACTER
	DW	AFREE		;(41, 29H)COMPUTE #BYTES FREE
	DW	ALEN		;(42, 2AH) COMPUTE LEN OF PORGRAM
	DW	AXTAL		;(43, 2BH) CRYSTAL
	DW	PMTOP		;(44, 2CH)TOP OF MEMORY
	DW	ATIME		;(45, 2DH) TIME
	DW	A_IE		;(46, 2EH) IE
	DW	A_IP		;(47, 2FH) IP
	DW	ATIM0		;(48, 30H) TIMER 0
	DW	ATIM1		;(49, 31H) TIMER 1
	DW	ATIM2		;(50, 32H) TIMER 2
	DW	AT2CON		;(51, 33H) T2CON
	DW	ATCON		;(52, 34H) TCON
	DW	ATMOD		;(53, 35H) ATMOD
	DW	ARCAP2		;(54, 36H) RCAP2
	DW	AP1		;(55, 37H) P1
	DW	APCON		;(56, 38H) PCON
	DW	EXPRB		;(57, 39H) EVALUATE AN EXPRESSION
	DW	AXTAL1		;(58, 3AH) CALCULATE CRYSTAL
	DW	LINE		;(59, 3BH) EDIT A LINE
	DW	PP		;(60, 3CH) PROCESS A LINE
        DW      UPPL0           ;(61, 3DH) UNPROCESS A LINE
	DW	VAR		;(62, 3EH) FIND A VARIABLE
	DW	GC		;(63, 3FH) GET A CHARACTER
	DW	GCI		;(64, 40H) GET CHARACTER AND INCREMENT
	DW	INCHAR		;(65, 41H) INPUT A CHARACTER
	DW	CRUN		;(66, 42H) RUN A PROGRAM
$EJECT
OPBOL:	DB	1		;
	;
	DB	15		;LEFT PAREN
	DB	14		;EXPONENTIAN **
	DB	10		;MUL
	DB	8		;ADD
	DB	10		;DIVIDE
	DB	8		;SUB
	DB	3		;XOR
	DB	5		;AND
	DB	4		;OR
	DB	12		;NEGATE
	DB	6		;EQ
	DB	6		;GT
	DB	6		;LT
	DB	6		;NE
	DB	6		;LE
	DB	6		;GE
	;
UOPBOL:	DB	15		;AABS
	DB	15		;AAINT
	DB	15		;ASGN
	DB	15		;ANOT
	DB	15		;ACOS
	DB	15		;ATAN
	DB	15		;ASIN
	DB	15		;ASQR
	DB	15		;ACBYTE
	DB	15		;E TO THE X
	DB	15		;AATAN
	DB	15		;NATURAL LOG
	DB	15		;DBYTE
	DB	15		;XBYTE
	;
$EJECT
	;***************************************************************
	;
	; The ASCII printed messages.
	;
	;***************************************************************
	;
STP:	DB	'STOP"'
	;
IAN:	DB	'TRY AGAIN"'
	;
RDYS:	DB	'READY"'
	;
INS:	DB	' - IN LINE "'
	;
	;**************************************************************
	;
	; This is the command jump table
	;
	;**************************************************************
	;
CMNDD:	DW	CRUN		;RUN
	DW	CLIST		;LIST
	DW	CNULL		;NULL
	DW	CNEW		;NEW
	DW	CCONT		;CONTINUE
	DW	CPROG		;PROGRAM A PROM
	DW	CXFER		;TRANSFER FROM ROM TO RAM
	DW	CRAM		;RAM MODE
	DW	CROM		;ROM MODE
	DW	CIPROG		;INTELLIGENT PROM PROGRAMMING
	;
$EJECT
	;***************************************************************
	;
	; This is the statement jump table.
	;
	;**************************************************************
	;
STATD:	;
	DW	SLET		;LET		80H
	DW	SCLR		;CLEAR		81H
	DW	SPUSH		;PUSH VAR	82H
	DW	SGOTO		;GO TO		83H
	DW	STONE		;TONE		84H
	DW	SPH0		;PRINT MODE 0	85H
	DW	SUI		;USER INPUT	86H
	DW	SUO		;USER OUTPUT	87H
	DW	SPOP		;POP VAR	88H
	DW	SPRINT		;PRINT		89H
	DW	SCALL		;CALL		8AH
	DW	SDIMX		;DIMENSION	8BH
	DW	STRING		;STRING ALLO	8CH
	DW	SBAUD		;SET BAUD	8DH
	DW	SCLOCK		;CLOCK		8EH
	DW	SPH1		;PRINT MODE 1   8FH
	;
	; No direct mode from here on
	;
	DW	SSTOP		;STOP		90H
	DW	SOT		;ON TIME	91H
	DW	SONEXT		;ON EXT INT	92H
	DW	SRETI		;RET FROM INT	93H
	DW	S_DO		;DO		94H
	DW	SRESTR		;RESTOR		95H
	DW	WCR		;REM		96H
	DW	SNEXT		;NEXT		97H
	DW	SONERR		;ON ERROR	98H
	DW	S_ON		;ON		99H
	DW	SINPUT		;INPUT		9AH
	DW	SREAD		;READ		9BH
	DW	FINDCR		;DATA		9CH
	DW	SRETRN		;RETURN		9DH
	DW	SIF		;IF		9EH
	DW	SGOSUB		;GOSUB		9FH
	DW	SFOR		;FOR		A0H
	DW	SWHILE		;WHILE		A1H
	DW	SUNTIL		;UNTIL		A2H
	DW	CMND1		;END		A3H
	DW	I_DL		;IDLE		A4H
	DW	ST_A		;STORE AT	A5H
	DW	LD_A		;LOAD AT	A6H
	DW	PGU		;PGM		A7H
	DW	RROM		;RUN A ROM	A9H
	;
$EJECT
	;**************************************************************
	;
TOKTAB:	; This is the basic token table
	;
	;**************************************************************
	;
	; First the tokens for statements
	;
	DB	80H		;LET TOKEN
	DB	'LET'
	;
	DB	81H		;CLEAR TOKEN
	DB	'CLEAR'
	;
	DB	82H		;PUSH TOKEN
	DB	'PUSH'
	;
T_GOTO	EQU	83H
	;
	DB	83H		;GO TO TOKEN
	DB	'GOTO'
	;
	DB	84H		;TOGGLE TOKEN
	DB	'PWM'
	;
	DB	85H		;PRINT HEX MODE 0
	DB	'PH0.'
	;
	DB	86H		;USER IN TOKEN
	DB	'UI'
	;
	DB	87H		;USER OUT TOKEN
	DB	'UO'
	;
	DB	88H		;POP TOKEN
	DB	'POP'
	;
$EJECT
	DB	89H		;PRINT TOKEN
	DB	'PRINT'
	DB	89H
	DB	'P.'		;P. ALSO MEANS PRINT
	DB	89H		;? ALSO
	DB	'?'
	;
	DB	8AH		;CALL TOKEN
	DB	'CALL'
	;
	DB	8BH		;DIMENSION TOKEN
	DB	'DIM'
	;
	DB	8CH		;STRING TOKEN
	DB	'STRING'
	;
	DB	8DH		;SET BAUD RATE
	DB	'BAUD'
	;
	DB	8EH		;CLOCK
	DB	'CLOCK'
	;
	DB	8FH		;PRINT HEX MODE 1
	DB	'PH1.'
	;
T_STOP	EQU	90H		;STOP TOKEN
	DB	T_STOP
	DB	'STOP'
	;
T_DIR	EQU	T_STOP		;NO DIRECT FROM HERE ON
	;
	DB	T_STOP+1	;ON TIMER INTERRUPT
	DB	'ONTIME'
	;
	DB	T_STOP+2	;ON EXTERNAL INTERRUPT
	DB	'ONEX1'
	;
	DB	T_STOP+3	;RETURN FROM INTERRUPT
	DB	'RETI'
	;
	DB	T_STOP+4	;DO TOKEN
	DB	'DO'
	;
	DB	T_STOP+5	;RESTORE TOKEN
	DB	'RESTORE'
	;
$EJECT
T_REM	EQU	T_STOP+6	;REMARK TOKEN
	DB	T_REM
	DB	'REM'
	;
	DB	T_REM+1		;NEXT TOKEN
	DB	'NEXT'
	;
	DB	T_REM+2		;ON ERROR TOKEN
	DB	'ONERR'
	;
	DB	T_REM+3		;ON TOKEN
	DB	'ON'
	;
	DB	T_REM+4		;INPUT
	DB	'INPUT'
	;
	DB	T_REM+5		;READ
	DB	'READ'
	;
T_DATA	EQU	T_REM+6		;DATA
	DB	T_DATA
	DB	'DATA'
	;
	DB	T_DATA+1	;RETURN
	DB	'RETURN'
	;
	DB	T_DATA+2	;IF
	DB	'IF'
	;
T_GOSB	EQU	T_DATA+3	;GOSUB
	DB	T_GOSB
	DB	'GOSUB'
	;
	DB	T_GOSB+1	;FOR
	DB	'FOR'
	;
	DB	T_GOSB+2	;WHILE
	DB	'WHILE'
	;
	DB	T_GOSB+3	;UNTIL
	DB	'UNTIL'
	;
	DB	T_GOSB+4	;END
	DB	'END'
	;
$EJECT
T_LAST	EQU	T_GOSB+5	;LAST INITIAL TOKEN
	;
T_TAB	EQU	T_LAST		;TAB TOKEN
	DB	T_TAB
	DB	'TAB'
	;
T_THEN	EQU	T_LAST+1	;THEN TOKEN
	DB	T_THEN
	DB	'THEN'
	;
T_TO	EQU	T_LAST+2	;TO TOKEN
	DB	T_TO
	DB	'TO'
	;
T_STEP	EQU	T_LAST+3	;STEP TOKEN
	DB	T_STEP
	DB	'STEP'
	;
T_ELSE	EQU	T_LAST+4	;ELSE TOKEN
	DB	T_ELSE
	DB	'ELSE'
	;
T_SPC	EQU	T_LAST+5	;SPACE TOKEN
	DB	T_SPC
	DB	'SPC'
	;
T_CR	EQU	T_LAST+6
	DB	T_CR
	DB	'CR'
	;
	DB	T_CR+1
	DB	'IDLE'
	;
	DB	T_CR+2
	DB	'ST@'
	;
	DB	T_CR+3
	DB	'LD@'
	;
	DB	T_CR+4
	DB	'PGM'
	;
	DB	T_CR+5
	DB	'RROM'
	;
$EJECT
	; Operator tokens
	;
T_LPAR	EQU	0E0H		;LEFT PAREN
	DB	T_LPAR
	DB	'('
	;
	DB	T_LPAR+1	;EXPONENTIAN
	DB	'**'
	;
	DB	T_LPAR+2	;FP MULTIPLY
	DB	'*'
	;
T_ADD	EQU	T_LPAR+3
	DB	T_LPAR+3	;ADD TOKEN
	DB	'+'
	;
	DB	T_LPAR+4	;DIVIDE TOKEN
	DB	'/'
	;
T_SUB	EQU	T_LPAR+5	;SUBTRACT TOKEN
	DB	T_SUB
	DB	'-'
	;
	DB	T_LPAR+6	;LOGICAL EXCLUSIVE OR
	DB	'.XOR.'
	;
	DB	T_LPAR+7	;LOGICAL AND
	DB	'.AND.'
	;
	DB	T_LPAR+8	;LOGICAL OR
	DB	'.OR.'
	;
T_NEG	EQU	T_LPAR+9
	;
T_EQU	EQU	T_LPAR+10	;EQUAL
	DB	T_EQU
	DB	'='
	;
	DB	T_LPAR+11	;GREATER THAN OR EQUAL
	DB	'>='
	;
	DB	T_LPAR+12	;LESS THAN OR EQUAL
	DB	'<='
	;
	DB	T_LPAR+13	;NOT EQUAL
	DB	'<>'
	;
	DB	T_LPAR+14	;LESS THAN
	DB	'<'
	;
	DB	T_LPAR+15	;GREATER THAN
	DB	'>'
	;
	;
T_UOP	EQU	0B0H		;UNARY OP BASE TOKEN
	;
	DB	T_UOP		;ABS TOKEN
	DB	'ABS'
	;
	DB	T_UOP+1		;INTEGER TOKEN
	DB	'INT'
	;
	DB	T_UOP+2		;SIGN TOKEN
	DB	'SGN'
	;
	DB	T_UOP+3		;GET TOKEN
	DB	'NOT'
	;
	DB	T_UOP+4		;COSINE TOKEN
	DB	'COS'
	;
	DB	T_UOP+5		;TANGENT TOKEN
	DB	'TAN'
	;
	DB	T_UOP+6		;SINE TOKEN
	DB	'SIN'
	;
	DB	T_UOP+7		;SQUARE ROOT TOKEN
	DB	'SQR'
	;
	DB	T_UOP+8		;CBYTE TOKEN
	DB	'CBY'
	;
	DB	T_UOP+9		;EXP (E TO THE X) TOKEN
	DB	'EXP'
	;
	DB	T_UOP+10
	DB	'ATN'
	;
	DB	T_UOP+11
	DB	'LOG'
	;
	DB	T_UOP+12	;DBYTE TOKEN
	DB	'DBY'
	;
	DB	T_UOP+13	;XBYTE TOKEN
	DB	'XBY'
	;
T_ULAST	EQU	T_UOP+14	;LAST OPERATOR NEEDING PARENS
	;
	DB	T_ULAST
	DB	'PI'
	;
	DB	T_ULAST+1	;RND TOKEN
	DB	'RND'
	;
	DB	T_ULAST+2	;GET TOKEN
	DB	'GET'
	;
	DB	T_ULAST+3	;FREE TOKEN
	DB	'FREE'
	;
	DB	T_ULAST+4	;LEN TOKEN
	DB	'LEN'
	;
T_XTAL	EQU	T_ULAST+5	;CRYSTAL TOKEN
	DB	T_XTAL
	DB	'XTAL'
	;
T_MTOP	EQU	T_ULAST+6	;MTOP
	DB	T_MTOP
	DB	'MTOP'
	;
T_IE	EQU	T_ULAST+8	;IE REGISTER
	DB	T_IE
	DB	'IE'
	;
T_IP	EQU	T_ULAST+9	;IP REGISTER
	DB	T_IP
	DB	'IP'
	;
TMR0	EQU	T_ULAST+10	;TIMER 0
	DB	TMR0
	DB	'TIMER0'
	;
TMR1	EQU	T_ULAST+11	;TIMER 1
	DB	TMR1
	DB	'TIMER1'
	;
TMR2	EQU	T_ULAST+12	;TIMER 2
	DB	TMR2
	DB	'TIMER2'
	;
T_TIME	EQU	T_ULAST+7	;TIME
	DB	T_TIME
	DB	'TIME'
	;
TT2C	EQU	T_ULAST+13	;T2CON
	DB	TT2C
	DB	'T2CON'
	;
TTC	EQU	T_ULAST+14	;TCON
	DB	TTC
	DB	'TCON'
	;
TTM	EQU	T_ULAST+15	;TMOD
	DB	TTM
	DB	'TMOD'
	;
TRC2	EQU	T_ULAST+16	;RCAP2
	DB	TRC2
	DB	'RCAP2'
	;
T_P1	EQU	T_ULAST+17	;P1
	DB	T_P1
	DB	'PORT1'
	;
T_PC	EQU	T_ULAST+18	;PCON
	DB	T_PC
	DB	'PCON'
	;
T_ASC	EQU	T_ULAST+19	;ASC TOKEN
	DB	T_ASC
	DB	'ASC('
	;
T_USE	EQU	T_ULAST+20	;USING TOKEN
	DB	T_USE
	DB	'USING('
	DB	T_USE
	DB	'U.('
	;
T_CHR	EQU	T_ULAST+21	;CHR TOKEN
	DB	T_CHR
	DB	'CHR('
	;
$EJECT
T_CMND	EQU	0F0H		;COMMAND BASE
	;
	DB	0F0H		;RUN TOKEN
	DB	'RUN'
	;
	DB	0F1H		;LIST TOKEN
	DB	'LIST'
	;
	DB	0F2H		;NULL TOKEN
	DB	'NULL'
	;
	DB	0F3H		;NEW TOKEN
	DB	'NEW'
	;
	DB	0F4H		;CONTINUE TOKEN
	DB	'CONT'
	;
	DB	0F5H		;PROGRAM TOKEN
	DB	'PROG'
	;
	DB	0F6H		;TRANSFER TOKEN
	DB	'XFER'
	;
	DB	0F7H		;RAM MODE
	DB	'RAM'
	;
	DB	0F8H		;ROM MODE
	DB	'ROM'
	;
	DB	0F9H		;INTELLIGENT PROM PROGRAMMING
	DB	'FPROG'
	;
	DB	0FFH		;END OF TABLE
	;

; END OF INCLUDE LOOK52
;$INCLUDE(:F2:LOOK52.SRC)
	;
EIG:	DB	'EXTRA IGNORED"'
	;
EXA:	DB	'A-STACK"'
	;
EXC:	DB	'C-STACK"'
	;
$EJECT
;$INCLUDE(:F2:BAS52.RST)
; BEGINNING

	;**************************************************************
	;
CRST:	; This performs system initialzation, it was moved here so the
	; new power on reset functions could be tested in an 8751.
	;
	;**************************************************************
	;
	; First, initialize SFR's
	;
	MOV	SCON,#5AH	;INITIALIZE SFR'S
	MOV	TMOD,#10H
	MOV	TCON,#54H
	MOV	T2CON,#34H
;       DB      75H             ;MOV DIRECT, # OP CODE
;       DB      0C8H            ;T2CON LOCATION
;       DB      34H             ;CONFIGURATION BYTE
	;
	MOV	DPTR,#2001H	;READ CODE AT 2001H
	CLR	A
	MOVC	A,@A+DPTR
        CJNE    A,#0AAH,CRST1   ;IF IT IS AN AAH, DO USER RESET
	LCALL	2090H
	;
CRST1:  MOV     R0,#IRAMTOP     ;PUT THE TOP OF RAM IN R0
	CLR	A		;ZERO THE ACC
	;
CRST2:  MOV     @R0,A           ;CLEAR INTERNAL MEMORY
        DJNZ    R0,CRST2        ;LOOP TIL DONE
	;
	; Now, test the external memory
	;
	MOV	SPSAV,#CMNDSP	;SET UP THE STACK
	MOV	SP,SPSAV
	;
	MOV	BOFAH,#HIGH ROMADR
	MOV	BOFAL,#LOW ROMADR+17
	MOV	DPTR,#ROMADR	;GET THE BYTE AT 8000H
	MOVX	A,@DPTR
	CLR	C
	SUBB	A,#31H		;FOR BIAS
	MOV	MT1,A		;SAVE IN DIRECT MATH LOC
	CLR	ACC.2		;SAVE FOR RESET
	MOV	R7,A		;SAVE IT IN R7
	INC	DPTR
	ACALL	L31DPI		;SAVE BAUD RATE
	LCALL	RCL
	INC	DPTR		;GET MEMTOP
	ACALL	L31DPI
	MOV	DPTR,#5FH	;READ THE EXTERNAL BYTE
	MOVX	A,@DPTR
	MOV	DPTR,#0		;ESTABLISH BASE FOR CLEAR
	CJNE	A,#0A5H,CRS
	MOV	A,MT1
	CLR	ACC.0		;CLEAR BIT ONE
	XRL	A,#4H
	JZ	CR2
	;
CRS:    CJNE    R7,#2,CRS1
        SJMP    CRS2
CRS1:   CJNE    R7,#3,CR0
CRS2:   ACALL   CL_1
        SJMP    CR1
	;
CR0:	MOV	R3,DPH		;SAVE THE DPTR
        MOV     R1,DPL
	INC	DPTR
	MOV	A,#5AH
	MOVX	@DPTR,A
	MOVX	A,@DPTR
	CJNE	A,#5AH,CR1
	CLR	A
	MOVX	@DPTR,A
	CJNE	R3,#0E0H,CR0
	;
CR1:    CJNE    R3,#03H,CR11    ;NEED THIS MUCH RAM
CR11:   JC      CRST
	MOV	DPTR,#MEMTOP	;SAVE MEMTOP
	ACALL	S31DP2		;SAVE MEMTOP AND SEED RCELL
	ACALL	CNEW		;CLEAR THE MEMORY AND SET UP POINTERS
	;
CR2:	ACALL	RC1		;SET UP STACKS IF NOT DONE
	;
	LCALL	AXTAL0		;DO THE CRYSTAL
	MOV	A,MT1		;GET THE RESET BYTE
        CJNE    A,#5,CR20
	LCALL	4039H
CR20:   JNC     BG1             ;CHECK FOR 0,1,2,3, OR 4
	JNB	ACC.0,BG3	;NO RUN IF WRONG TYPE
	MOV	DPTR,#ROMADR+16
	MOVX	A,@DPTR		;READ THE BYTE
	CJNE	A,#55H,BG3
	LJMP	CRUN

	; START OF BAUD RATE MODIFICATIONS BY DANIEL WALLNER

BG1:	CLR	A		;DO BAUD RATE
	MOV	R3,A
	MOV	R1,A
	MOV	TL2,A
	CLR	T2CON.2
	JB	RXD,$		;LOOP UNTIL A CHARACTER IS RECEIVED
	MOV	T2CON,#5
	CALL	TIB2
	JNB	RXD,$
	MOV	T2CON,#34H
	CALL	RCL		;LOAD THE TIMER
	NOP
	NOP

	; END OF BAUD RATE MODIFICATIONS BY DANIEL WALLNER


BG3:	MOV	DPTR,#S_N	;GET THE MESSAGE
	ACALL	CRP		;PRINT IT
	LJMP	CRAM

; END
;$INCLUDE(:F2:BAS52.RST)
	;
$EJECT
	;***************************************************************
	;
	; CIPROG AND CPROG - Program a prom
	;
	;***************************************************************
	;
;$INCLUDE(:F2:BAS52.PGM)
;BEGINNING

PG8:	MOV	R7,#00H		;PROGRAM ONE BYTE AT A TIME
	MOV	R6,#01H
	MOV	R2,#HIGH ROMADR-1
	MOV	R0,#LOW ROMADR-1;LOAD PROM ADDRESS
        ACALL   PG101
	INC	R6
        MOV     A,RCAPH2
;       DB      0E5H            ;MOV A DIRECT OP CODE
;       DB      0CBH            ;ADDRESS OF R2CAP HIGH
        ACALL   PG101
        MOV     A,RCAPL2
;       DB      0E5H            ;MOV A, DIRECT OP CODE
;       DB      0CAH            ;R2CAP LOW
	MOV	R6,#3
	MOV	R1,#LOW MEMTOP-1
	MOV	R3,#HIGH MEMTOP
        ACALL   PG101           ;SAVE MEMTOP
	SJMP	PGR
	;
CIPROG:	MOV	DPTR,#IPROGS	;LOAD IPROG LOCATION
	SETB	INTELB
        SJMP    CPROG1          ;GO DO PROG
	;
CPROG:	MOV	DPTR,#PROGS	;LOAD PROG LOCATION
	CLR	INTELB
	;
CPROG1: ACALL   LD_T            ;LOAD THE TIMER
	CLR	PROMV		;TURN ON THE PROM VOLTAGE
	CALL	DELTST		;SEE IF A CR
	JNZ	PG8		;SAVE TIMER IF SO
	MOV	R4,#0FEH
	SETB	INBIT
	ACALL	ROMFD		;GET THE ROM ADDRESS OF THE LAST LOCATION
	CALL	TEMPD		;SAVE THE ADDRESS
	MOV	A,R4		;GET COUNT
	CPL	A
	CALL	TWO_R2		;PUT IT ON THE STACK
        CALL    FP_BASE7        ;OUTPUT IT
	ACALL	CCAL		;GET THE PROGRAM
	ACALL	CRLF		;DO CRLF
	MOV	R0,TEMP4	;GET ADDRESS
	MOV	R2,TEMP5
	MOV	A,#55H		;LOAD SIGNIFIER
	INC	R6		;LOAD LEN + 1
        CJNE    R6,#00,CPROG2
	INC	R7
CPROG2: ACALL   PG102
	;
$EJECT
PGR:	SETB	PROMV
	AJMP	C_K
	;
PG1:	MOV	P2,R3		;GET THE BYTE TO PROGRAM
	MOVX	A,@R1
PG101:  LCALL   INC3210         ;BUMP POINTERS
PG102:  MOV     R5,#1           ;SET UP INTELLIGENT COUMTER
	;
PG2:	MOV	R4,A		;SAVE THE BYTE IN R4
	ACALL	PG7		;PROGRAM THE BYTE
	ACALL	PG9
	JB	INTELB,PG4	;SEE IF INTELLIGENT PROGRAMMING
	;
PG3:	XRL	A,R4
	JNZ	PG6		;ERROR IF NOT THE SAME
	CALL	DEC76		;BUMP THE COUNTERS
	JNZ	PG1		;LOOP IF NOT DONE
	ANL	PSW,#11100111B	;INSURE RB0
PG31:   RET
	;
PG4:	XRL	A,R4		;SEE IF PROGRAMMED
	JNZ	PG5		;JUMP IF NOT
	MOV	A,R4		;GET THE DATA BACK
	ACALL	PG7		;PROGRAM THE LOCATION
PG41:   ACALL   ZRO             ;AGAIN
	ACALL	ZRO		;AND AGAIN
	ACALL	ZRO		;AND AGAIN
        DJNZ    R5,PG41         ;KEEP DOING IT
	ACALL	PG9		;RESET PROG
	SJMP	PG3		;FINISH THE LOOP
	;
PG5:	INC	R5		;BUMP THE COUNTER
	MOV	A,R4		;GET THE BYTE
	CJNE	R5,#25,PG2	;SEE IF TRIED 25 TIMES
	;
PG6:	SETB	PROMV		;TURN OFF PROM VOLTAGE
	MOV	PSW,#0		;INSURE RB0
        JNB     DIRF,PG31       ;EXIT IF IN RUN MODE
	MOV	DPTR,#E16X	;PROGRAMMING ERROR
	;
ERRLK:	LJMP	ERROR		;PROCESS THE ERROR
	;
$EJECT
PG7:	MOV	P0,R0		;SET UP THE PORTS
	MOV	P2,R2		;LATCH LOW ORDER ADDRESS
	ACALL	PG11		;DELAY FOR 8748/9
	CLR	ALED
	MOV	P0,A		;PUT DATA ON THE PORT
	;
ZRO:	NOP			;SETTLEING TIME + FP ZERO
	NOP
	NOP
	NOP
	NOP
	NOP
	ACALL	PG11		;DELAY A WHILE
	CLR	PROMP		;START PROGRAMMING
	ACALL	TIMER_LOAD	;START THE TIMER
	JNB	TF1,$		;WAIT FOR PART TO PROGRAM
	RET			;EXIT
	;
PG9:	SETB	PROMP
	ACALL	PG11		;DELAY FOR A WHILE
	JNB	P3.2,$		;LOOP FOR EEPROMS
	MOV	P0,#0FFH
	CLR	P3.7		;LOWER READ
	ACALL	PG11
	MOV	A,P0		;READ THE PORT
	SETB	P3.7
	SETB	ALED
	RET
	;
PG11:	MOV	TEMP5,#12	;DELAY 30uS AT 12 MHZ
	DJNZ	TEMP5,$
	RET
	;

;END
;$INCLUDE(:F2:BAS52.PGM)
$EJECT
	;**************************************************************
	;
PGU:	;PROGRAM A PROM FOR THE USER
	;
	;**************************************************************
	;
	CLR	PROMV		;TURN ON THE VOLTAGE
	MOV	PSW,#00011000B	;SELECT RB3
	ACALL	PG1		;DO IT
	SETB	PROMV		;TURN IT OFF
	RET
	;
	;
	;*************************************************************
	;
CCAL:	; Set up for prom moves
	; R3:R1 gets source
	; R7:R6 gets # of bytes
	;
	;*************************************************************
	;
	ACALL	GETEND		;GET THE LAST LOCATION
	INC	DPTR		;BUMP TO LOAD EOF
	MOV	R3,BOFAH
	MOV	R1,BOFAL	;RESTORE START
	CLR	C		;PREPARE FOR SUBB
	MOV	A,DPL		;SUB DPTR - BOFA > R7:R6
	SUBB	A,R1
	MOV	R6,A
	MOV	A,DPH
	SUBB	A,R3
	MOV	R7,A
CCAL1:  RET
	;
	;
;$INCLUDE(:F2:BAS52.TL)
;BEGINNING

	;**************************************************************
	;
TIMER_LOAD:; Load the timer
	;
	;*************************************************************
	;
        ACALL   CCAL1           ;DELAY FOUR CLOCKS
TIMER_LOAD1:
        CLR     TR1             ;STOP IT WHILE IT'S LOADED
	MOV	TH1,T_HH
	MOV	TL1,T_LL
	CLR	TF1		;CLEAR THE OVERFLOW FLAG
	SETB	TR1		;START IT NOW
	RET
	;

;END
;$INCLUDE(:F2:BAS52.TL)
$EJECT
	;***************************************************************
	;
CROM:	; The command action routine - ROM - Run out of rom
	;
	;***************************************************************
	;
	CLR	CONB		;CAN'T CONTINUE IF MODE CHANGE
	ACALL	RO1		;DO IT
	;
C_K:	LJMP	CL3		;EXIT
	;
;RO1:    CALL    INTGER          ;SEE IF INTGER PRESENT
;        MOV     R4,R0B0         ;SAVE THE NUMBER
;        JNC     $+4
;        MOV     R4,#01H         ;ONE IF NO INTEGER PRESENT
;        CALL   ROMFD           ;FIND THE PROGRAM
;       ACALL   ROMFD           ;FIND THE PROGRAM

RO1:    CALL    DELTST
        MOV     R4,#1
        JNC     RO11
        CALL    ONE
        MOV     R4,A
RO11:   ACALL   ROMFD
        CJNE    R4,#0,RFX       ;EXIT IF R4 <> 0
	INC	DPTR		;BUMP PAST TAG
	MOV	BOFAH,DPH	;SAVE THE ADDRESS
	MOV	BOFAL,DPL
	RET
	;
ROMFD:	MOV	DPTR,#ROMADR+16	;START OF USER PROGRAM
	;
RF1:	MOVX	A,@DPTR		;GET THE BYTE
	CJNE	A,#55H,RF3	;SEE IF PROPER TAG
	DJNZ	R4,RF2		;BUMP COUNTER
	;
RFX:	RET			;DPTR HAS THE START ADDRESS
	;
RF2:	INC	DPTR		;BUMP PAST TAG
	ACALL	G5
	INC	DPTR		;BUMP TO NEXT PROGRAM
	SJMP	RF1		;DO IT AGAIN
	;
RF3:	JBC	INBIT,RFX	;EXIT IF SET
	;
NOGO:	MOV	DPTR,#NOROM
	AJMP	ERRLK
	;
$EJECT
	;***************************************************************
	;
L20DPI:	; load R2:R0 with the location the DPTR is pointing to
	;
	;***************************************************************
	;
	MOVX	A,@DPTR
	MOV	R2,A
	INC	DPTR
	MOVX	A,@DPTR
	MOV	R0,A
	RET			;DON'T BUMP DPTR
	;
	;***************************************************************
	;
X31DP:	; swap R3:R1 with DPTR
	;
	;***************************************************************
	;
	XCH	A,R3
	XCH	A,DPH
	XCH	A,R3
	XCH	A,R1
	XCH	A,DPL
	XCH	A,R1
	RET
	;
	;***************************************************************
	;
LD_T:	; Load the timer save location with the value the DPTR is
	; pointing to.
	;
	;****************************************************************
	;
	MOVX	A,@DPTR
	MOV	T_HH,A
	INC	DPTR
	MOVX	A,@DPTR
	MOV	T_LL,A
	RET
	;
$EJECT
	;
	;***************************************************************
	;
	;GETLIN - FIND THE LOCATION OF THE LINE NUMBER IN R3:R1
	;         IF ACC = 0 THE LINE WAS NOT FOUND I.E. R3:R1
	;         WAS TOO BIG, ELSE ACC <> 0 AND THE DPTR POINTS
	;         AT THE LINE THAT IS GREATER THAN OR EQUAL TO THE
	;         VALUE IN R3:R1.
	;
	;***************************************************************
	;
GETEND:	SETB	ENDBIT		;GET THE END OF THE PROGRAM
	;
GETLIN:	CALL	DP_B		;GET BEGINNING ADDRESS
	;
G1:	CALL	B_C
	JZ	G3		;EXIT WITH A ZERO IN A IF AT END
	INC	DPTR		;POINT AT THE LINE NUMBER
	JB	ENDBIT,G2	;SEE IF WE WANT TO FIND THE END
	ACALL	DCMPX		;SEE IF (DPTR) = R3:R1
	ACALL	DECDP		;POINT AT LINE COUNT
	MOVX	A,@DPTR		;PUT LINE LENGTH INTO ACC
	JB	UBIT,G3		;EXIT IF EQUAL
	JC	G3		;SEE IF LESS THAN OR ZERO
	;
G2:	ACALL	ADDPTR		;ADD IT TO DPTR
	SJMP	G1		;LOOP
	;
G3:	CLR	ENDBIT		;RESET ENDBIT
	RET			;EXIT
	;
G4:	MOV	DPTR,#PSTART	;DO RAM
	;
G5:	SETB	ENDBIT
	SJMP	G1		;NOW DO TEST
	;
$EJECT
	;***************************************************************
	;
	; LDPTRI - Load the DATA POINTER with the value it is pointing
	;          to - DPH = (DPTR) , DPL = (DPTR+1)
	;
	; acc gets wasted
	;
	;***************************************************************
	;
LDPTRI:	MOVX	A,@DPTR		;GET THE HIGH BYTE
	PUSH	ACC		;SAVE IT
	INC	DPTR		;BUMP THE POINTER
	MOVX	A,@DPTR		;GET THE LOW BYTE
	MOV	DPL,A		;PUT IT IN DPL
	POP	DPH		;GET THE HIGH BYTE
	RET			;GO BACK
	;
	;***************************************************************
	;
	;L31DPI - LOAD R3 WITH (DPTR) AND R1 WITH (DPTR+1)
	;
	;ACC GETS CLOBBERED
	;
	;***************************************************************
	;
L31DPI:	MOVX	A,@DPTR		;GET THE HIGH BYTE
	MOV	R3,A		;PUT IT IN THE REG
	INC	DPTR		;BUMP THE POINTER
	MOVX	A,@DPTR		;GET THE NEXT BYTE
	MOV	R1,A		;SAVE IT
	RET
	;
	;***************************************************************
	;
	;DECDP - DECREMENT THE DATA POINTER - USED TO SAVE SPACE
	;
	;***************************************************************
	;
DECDP2:	ACALL	DECDP
	;
DECDP:	XCH	A,DPL		;GET DPL
        JNZ     DECDP1          ;BUMP IF ZERO
	DEC	DPH
DECDP1: DEC     A               ;DECREMENT IT
        XCH     A,DPL           ;GET A BACK
	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
	;DCMPX - DOUBLE COMPARE - COMPARE (DPTR) TO R3:R1
	;R3:R1 - (DPTR) = SET CARRY FLAG
	;
	;IF R3:R1 > (DPTR) THEN C = 0
	;IF R3:R1 < (DPTR) THEN C = 1
	;IF R3:R1 = (DPTR) THEN C = 0
	;
	;***************************************************************
	;
DCMPX:	CLR	UBIT		;ASSUME NOT EQUAL
	MOVX	A,@DPTR		;GET THE BYTE
	CJNE	A,R3B0,D1	;IF A IS GREATER THAN R3 THEN NO CARRY
				;WHICH IS R3<@DPTR = NO CARRY AND
				;R3>@DPTR CARRY IS SET
	INC	DPTR		;BUMP THE DATA POINTER
	MOVX	A,@DPTR		;GET THE BYTE
	ACALL	DECDP		;PUT DPTR BACK
	CJNE	A,R1B0,D1	;DO THE COMPARE
	CPL	C		;FLIP CARRY
	;
	CPL	UBIT		;SET IT
D1:	CPL	C		;GET THE CARRY RIGHT
	RET			;EXIT
	;
	;***************************************************************
	;
	; ADDPTR - Add acc to the dptr
	;
	; acc gets wasted
	;
	;***************************************************************
	;
ADDPTR:	ADD	A,DPL		;ADD THE ACC TO DPL
	MOV	DPL,A		;PUT IT IN DPL
        JNC     ADDPTR1         ;JUMP IF NO CARRY
	INC	DPH		;BUMP DPH
ADDPTR1:RET                     ;EXIT
	;
$EJECT
	;*************************************************************
	;
LCLR:	; Set up the storage allocation
	;
	;*************************************************************
	;
	ACALL	ICLR		;CLEAR THE INTERRUPTS
	ACALL	G4		;PUT END ADDRESS INTO DPTR
	MOV	A,#6		;ADJUST MATRIX SPACE
	ACALL	ADDPTR		;ADD FOR PROPER BOUNDS
	ACALL	X31DP		;PUT MATRIX BOUNDS IN R3:R1
	MOV	DPTR,#MT_ALL	;SAVE R3:R1 IN MATRIX FREE SPACE
	ACALL	S31DP		;DPTR POINTS TO MEMTOP
	ACALL	L31DPI		;LOAD MEMTOP INTO R3:R1
	MOV	DPTR,#STR_AL	;GET MEMORY ALLOCATED FOR STRINGS
	ACALL	LDPTRI
	CALL	DUBSUB		;R3:R1 = MEMTOP - STRING ALLOCATION
	MOV	DPTR,#VARTOP	;SAVE R3:R1 IN VARTOP
	;
	; FALL THRU TO S31DP2
	;
	;***************************************************************
	;
	;S31DP - STORE R3 INTO (DPTR) AND R1 INTO (DPTR+1)
	;
	;ACC GETS CLOBBERED
	;
	;***************************************************************
	;
S31DP2:	ACALL	S31DP		;DO IT TWICE
	;
S31DP:	MOV	A,R3		;GET R3 INTO ACC
	MOVX	@DPTR,A		;STORE IT
	INC	DPTR		;BUMP DPTR
	MOV	A,R1		;GET R1
	MOVX	@DPTR,A		;STORE IT
	INC	DPTR		;BUMP IT AGAIN TO SAVE PROGRAM SPACE
	RET			;GO BACK
	;
	;
	;***************************************************************
	;
STRING:	; Allocate memory for strings
	;
	;***************************************************************
	;
	LCALL	TWO		;R3:R1 = NUMBER, R2:R0 = LEN
	MOV	DPTR,#STR_AL	;SAVE STRING ALLOCATION
	ACALL	S31DP
	INC	R6		;BUMP
	MOV	S_LEN,R6	;SAVE STRING LENGTH
	AJMP	RCLEAR		;CLEAR AND SET IT UP
	;
$EJECT
	;***************************************************************
	;
	; F_VAR - Find  the variable in symbol table
	;         R7:R6 contain the variable name
	;         If not found create a zero entry and set the carry
	;         R2:R0 has the address of variable on return
	;
	;***************************************************************
	;
F_VAR:	MOV	DPTR,#VARTOP	;PUT VARTOP IN DPTR
	ACALL	LDPTRI
	ACALL	DECDP2		;ADJUST DPTR FOR LOOKUP
	;
F_VAR0:	MOVX	A,@DPTR		;LOAD THE VARIABLE
	JZ	F_VAR2		;TEST IF AT THE END OF THE TABLE
	INC	DPTR		;BUMP FOR NEXT BYTE
	CJNE	A,R7B0,F_VAR1	;SEE IF MATCH
	MOVX	A,@DPTR		;LOAD THE NAME
	CJNE	A,R6B0,F_VAR1
	;
	; Found the variable now adjust and put in R2:R0
	;
DLD:	MOV	A,DPL		;R2:R0 = DPTR-2
	SUBB	A,#2
	MOV	R0,A
	MOV	A,DPH
	SUBB	A,#0		;CARRY IS CLEARED
	MOV	R2,A
	RET
	;
F_VAR1:	MOV	A,DPL		;SUBTRACT THE STACK SIZE+ADJUST
	CLR	C
	SUBB	A,#STESIZ
	MOV	DPL,A		;RESTORE DPL
	JNC	F_VAR0
	DEC	DPH
	SJMP	F_VAR0		;CONTINUE COMPARE
	;
$EJECT
	;
	; Add the entry to the symbol table
	;
F_VAR2:	LCALL	R76S		;SAVE R7 AND R6
	CLR	C
	ACALL	DLD		;BUMP THE POINTER TO GET ENTRY ADDRESS
	;
	; Adjust pointer and save storage allocation
	; and make sure we aren't wiping anything out
	; First calculate new storage allocation
	;
	MOV	A,R0
	SUBB	A,#STESIZ-3	;NEED THIS MUCH RAM
	MOV	R1,A
	MOV	A,R2
	SUBB	A,#0
	MOV	R3,A
	;
	; Now save the new storage allocation
	;
	MOV	DPTR,#ST_ALL
	CALL	S31DP		;SAVE STORAGE ALLOCATION
	;
	; Now make sure we didn't blow it, by wiping out MT_ALL
	;
	ACALL	DCMPX		;COMPARE STORAGE ALLOCATION
	JC	CCLR3		;ERROR IF CARRY
	SETB	C		;DID NOT FIND ENTRY
	RET			;EXIT IF TEST IS OK
	;
$EJECT
	;***************************************************************
	;
	; Command action routine - NEW
	;
	;***************************************************************
	;
CNEW:	MOV	DPTR,#PSTART	;SAVE THE START OF PROGRAM
	MOV	A,#EOF		;END OF FILE
	MOVX	@DPTR,A		;PUT IT IN MEMORY
	;
	; falls thru
	;
	;*****************************************************************
	;
	; The statement action routine - CLEAR
	;
	;*****************************************************************
	;
CNEW1:  CLR     LINEB           ;SET UP FOR RUN AND GOTO
	;
RCLEAR:	ACALL	LCLR		;CLEAR THE INTERRUPTS, SET UP MATRICES
	MOV	DPTR,#MEMTOP	;PUT MEMTOP IN R3:R1
	ACALL	L31DPI
	ACALL	G4		;DPTR GETS END ADDRESS
	ACALL	CL_1		;CLEAR THE MEMORY
	;
RC1:	MOV	DPTR,#STACKTP	;POINT AT CONTROL STACK TOP
	CLR	A		;CONTROL UNDERFLOW
	;
RC2:	MOVX	@DPTR,A		;SAVE IN MEMORY
	MOV	CSTKA,#STACKTP
	MOV	ASTKA,#STACKTP
	CLR	CONB		;CAN'T CONTINUE
	RET
	;
$EJECT
	;***************************************************************
	;
	; Loop until the memory is cleared
	;
	;***************************************************************
	;
CL_1:	INC	DPTR		;BUMP MEMORY POINTER
	CLR	A		;CLEAR THE MEMORY
	MOVX	@DPTR,A		;CLEAR THE RAM
	MOVX	A,@DPTR		;READ IT
	JNZ	CCLR3		;MAKE SURE IT IS CLEARED
	MOV	A,R3		;GET POINTER FOR COMPARE
	CJNE	A,DPH,CL_1	;SEE TO LOOP
	MOV	A,R1		;NOW TEST LOW BYTE
	CJNE	A,DPL,CL_1
	;
CL_2:	RET
	;
CCLR3:	JMP	TB		;ALLOCATED MEMORY DOESN'T EXSIST
	;
	;**************************************************************
	;
SCLR:	;Entry point for clear return
	;
	;**************************************************************
	;
	CALL	DELTST		;TEST FOR A CR
	JNC	RCLEAR
	CALL	GCI1		;BUMP THE TEST POINTER
	CJNE	A,#'I',RC1	;SEE IF I, ELSE RESET THE STACK
	;
	;**************************************************************
	;
ICLR:	; Clear interrupts and system garbage
	;
	;**************************************************************
	;
        JNB     INTBIT,ICLR1    ;SEE IF BASIC HAS INTERRUPTS
	CLR	EX1		;IF SO, CLEAR INTERRUPTS
ICLR1:  ANL     34,#00100000B   ;SET INTERRUPTS + CONTINUE
	RETI
	;
$EJECT
	;***************************************************************
	;
	;OUTPUT ROUTINES
	;
	;***************************************************************
	;
CRLF2:	ACALL	CRLF		;DO TWO CRLF'S
	;
CRLF:	MOV	R5,#CR		;LOAD THE CR
	ACALL	TEROT		;CALL TERMINAL OUT
	MOV	R5,#LF		;LOAD THE LF
	AJMP	TEROT		;OUTPUT IT AND RETURN
	;
	;PRINT THE MESSAGE ADDRESSED IN ROM OR RAM BY THE DPTR
	;ENDS WITH THE CHARACTER IN R4
	;DPTR HAS THE ADDRESS OF THE TERMINATOR
	;
CRP:	ACALL	CRLF		;DO A CR THEN PRINT ROM
	;
ROM_P:	CLR	A		;CLEAR A FOR LOOKUP
	MOVC	A,@A+DPTR	;GET THE CHARACTER
	CLR	ACC.7		;CLEAR MS BIT
        CJNE    A,#'"',ROM_P1   ;EXIT IF TERMINATOR
	RET
ROM_P1: SETB    C0ORX1
	;
PN1:	MOV	R5,A		;OUTPUT THE CHARACTER
	ACALL	TEROT
	INC	DPTR		;BUMP THE POINTER
	SJMP	PN0
	;
UPRNT:	ACALL	X31DP
	;
PRNTCR:	MOV	R4,#CR		;OUTPUT UNTIL A CR
	;
PN0:	JBC	C0ORX1,ROM_P
	MOVX	A,@DPTR		;GET THE RAM BYTE
        JZ      PN01
        CJNE    A,R4B0,PN02     ;SEE IF THE SAME AS TERMINATOR
PN01:   RET                     ;EXIT IF THE SAME
PN02:   CJNE    A,#CR,PN1       ;NEVER PRINT A CR IN THIS ROUTINE
	LJMP	E1XX		;BAD SYNTAX
	;
$EJECT
	;***************************************************************
	;
	; INLINE - Input a line to IBUF, exit when a CR is received
	;
	;***************************************************************
	;
INL2:	CJNE 	A,#CNTRLD,INL2B	;SEE IF A CONTROL D
	;
INL0:	ACALL	CRLF		;DO A CR
	;
INLINE:	MOV	P2,#HIGH IBUF	;IBUF IS IN THE ZERO PAGE
	MOV	R0,#LOW IBUF	;POINT AT THE INPUT BUFFER
	;
INL1:	ACALL	INCHAR		;GET A CHARACTER
	MOV	R5,A		;SAVE IN R5 FOR OUTPUT
	CJNE	A,#7FH,INL2	;SEE IF A DELETE CHARACTER
	CJNE	R0,#LOW IBUF,INL6
INL11:  MOV     R5,#BELL        ;OUTPUT A BELL
	;
INLX:	ACALL	TEROT		;OUTPUT CHARACTER
	SJMP	INL1		;DO IT AGAIN
	;
INL2B:	MOVX	@R0,A		;SAVE THE CHARACTER
        CJNE    A,#CR,INL2B1    ;IS IT A CR
	AJMP	CRLF		;OUTPUT A CRLF AND EXIT
INL2B1: CJNE    A,#20H,INL2B2
INL2B2: JC      INLX            ;ONLY ECHO CONTROL CHARACTERS
	INC	R0		;BUMP THE POINTER
	CJNE	R0,#IBUF+79,INLX
	DEC	R0		;FORCE 79
        SJMP    INL11           ;OUTPUT A BELL
	;
INL6:	DEC	R0		;DEC THE RAM POINTER
	MOV	R5,#BS		;OUTPUT A BACK SPACE
	ACALL	TEROT
	ACALL	STEROT		;OUTPUT A SPACE
	MOV	R5,#BS		;ANOTHER BACK SPACE
	SJMP	INLX		;OUTPUT IT
	;
PTIME:	DB	128-2		; PROM PROGRAMMER TIMER
	DB	00H
	DB	00H
	DB	50H
	DB	67H
	DB	41H
	;
$EJECT
;$INCLUDE(:F2:BAS52.OUT)
;BEGINNING
	;***************************************************************
	;
	; TEROT - Output a character to the system console
	;         update PHEAD position.
	;
	;***************************************************************
	;
STEROT:	MOV	R5,#' '		;OUTPUT A SPACE
	;
TEROT:	PUSH	ACC		;SAVE THE ACCUMULATOR
	PUSH	DPH		;SAVE THE DPTR
	PUSH	DPL
TEROT01:JNB     CNT_S,TEROT02   ;WAIT FOR A CONTROL Q
	ACALL	BCK		;GET SERIAL STATUS
        SJMP    TEROT01
TEROT02:MOV     A,R5            ;PUT OUTPUT BYTE IN A
        JNB     BO,TEROT03      ;CHECK FOR MONITOR
	LCALL	2040H		;DO THE MONITOR
	AJMP	TEROT1		;CLEAN UP
TEROT03:JNB     COUB,TEROT04    ;SEE IF USER WANTS OUTPUT
	LCALL	4030H
	AJMP	TEROT1
TEROT04:JNB     UPB,T_1         ;NO AT IF NO XBIT
	JNB	LPB,T_1		;AT PRINT
	LCALL	403CH		;CALL AT LOCATION
	AJMP	TEROT1		;FINISH OFF OUTPUT
	;
T_1:	JNB	COB,TXX		;SEE IF LIST SET
	MOV	DPTR,#SPV	;LOAD BAUD RATE
	ACALL	LD_T
	CLR	LP		;OUTPUT START BIT
	ACALL	TIMER_LOAD	;LOAD AND START THE TIMER
	MOV	A,R5		;GET THE OUTPUT BYTE
	SETB	C		;SET CARRY FOR LAST OUTPUT
	MOV	R5,#9		;LOAD TIMER COUNTDOWN
	;
LTOUT1:	RRC	A		;ROTATE A
	JNB	TF1,$		;WAIT TILL TIMER READY
	MOV	LP,C		;OUTPUT THE BIT
	ACALL	TIMER_LOAD	;DO THE NEXT BIT
	DJNZ	R5,LTOUT1	;LOOP UNTIL DONE
	JNB	TF1,$		;FIRST STOP BIT
	ACALL	TIMER_LOAD
	JNB	TF1,$		;SECOND STOP BIT
	MOV	R5,A		;RESTORE R5
	SJMP	TEROT1		;BACK TO TEROT
	;
$EJECT
TXX:	JNB	TI,$		;WAIT FOR TRANSMIT READY
	CLR	TI
	MOV	SBUF,R5		;SEND OUT THE CHARACTER
	;
TEROT1: CJNE    R5,#CR,TEROT11  ;SEE IF A CR
	MOV	PHEAD,#00H	;IF A CR, RESET PHEAD AND
	;
TEROT11:CJNE    R5,#LF,NLC      ;SEE IF A LF
	MOV	A,NULLCT	;GET THE NULL COUNT
	JZ	NLC		;NO NULLS IF ZERO
	;
TEROT2:	MOV	R5,#NULL	;PUT THE NULL IN THE OUTPUT REGISTER
	ACALL	TEROT		;OUTPUT THE NULL
	DEC	A		;DECREMENT NULL COUNT
	JNZ	TEROT2		;LOOP UNTIL DONE
	;
NLC:    CJNE    R5,#BS,NLC1     ;DEC PHEAD IF A BACKSPACE
	DEC	PHEAD
NLC1:   CJNE    R5,#20H,NLC2    ;IS IT A PRINTABLE CHARACTER?
NLC2:   JC      NLC3            ;DON'T INCREMENT PHEAD IF NOT PRINTABLE
	INC	PHEAD		;BUMP PRINT HEAD
NLC3:   POP     DPL             ;RESTORE DPTR
	POP	DPH
	POP	ACC		;RESTORE ACC
	RET			;EXIT
	;

;END
;$INCLUDE(:F2:BAS52.OUT)
	;
BCK:	ACALL	CSTS		;CHECK STATUS
        JNC     CI_RET1         ;EXIT IF NO CHARACTER
	;
$EJECT
	;***************************************************************
	;
	;INPUTS A CHARACTER FROM THE SYSTEM CONSOLE.
	;
	;***************************************************************
	;
INCHAR: JNB     BI,INCHAR1      ;CHECK FOR MONITOR (BUBBLE)
	LCALL	2060H
	SJMP	INCH1
INCHAR1:JNB     CIUB,INCHAR2    ;CHECK FOR USER
	LCALL	4033H
	SJMP	INCH1
INCHAR2:JNB     RI,$            ;WAIT FOR RECEIVER READY.
	MOV	A,SBUF
	CLR	RI		;RESET READY
	CLR	ACC.7		;NO BIT 7
	;
INCH1:  CJNE    A,#13H,INCH11
	SETB	CNT_S
INCH11: CJNE    A,#11H,INCH12
	CLR	CNT_S
INCH12: CJNE    A,#CNTRLC,INCH13
	JNB	NO_C,C_EX	;TRAP NO CONTROL C
	RET
	;
INCH13: CLR     JKBIT
	CJNE	A,#17H,CI_RET	;CONTROL W
	SETB	JKBIT
	;
CI_RET:	SETB	C		;CARRY SET IF A CHARACTER
CI_RET1:RET                     ;EXIT
	;
	;*************************************************************
	;
	;RROM - The Statement Action Routine RROM
	;
	;*************************************************************
	;
RROM:	SETB	INBIT		;SO NO ERRORS
	ACALL	RO1		;FIND THE LINE NUMBER
	JBC	INBIT,CRUN
	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
CSTS:	;	RETURNS CARRY = 1 IF THERE IS A CHARACTER WAITING FROM
	;       THE SYSTEM CONSOLE. IF NO CHARACTER THE READY CHARACTER
	;       WILL BE CLEARED
	;
	;***************************************************************
	;
        JNB     BI,CSTS1        ;BUBBLE STATUS
	LJMP	2068H
CSTS1:  JNB     CIUB,CSTS2      ;SEE IF EXTERNAL CONSOLE
	LJMP	4036H
CSTS2:  MOV     C,RI
	RET
	;
C_EX0:  MOV     DPTR,#WB        ;EGO MESSAGE
	ACALL	ROM_P
	;
C_EX:	CLR	CNT_S		;NO OUTPUT STOP
        LCALL   SPRINT1         ;ASSURE CONSOLE
	ACALL	CRLF
        JBC     JKBIT,C_EX0
	;
	JNB	DIRF,SSTOP0
	AJMP	C_K		;CLEAR COB AND EXIT
	;
T_CMP:	MOV	A,TVH		;COMPARE TIMER TO SP_H AND SP_L
	MOV	R1,TVL
	CJNE	A,TVH,T_CMP
	XCH	A,R1
	SUBB	A,SP_L
	MOV	A,R1
	SUBB	A,SP_H
	RET
	;
	;*************************************************************
	;
BR0:	; Trap the timer interrupt
	;
	;*************************************************************
	;
	CALL	T_CMP		;COMPARE TIMER
        JC      BCHR1           ;EXIT IF TEST FAILS
	SETB	OTI		;DOING THE TIMER INTERRUPT
	CLR	OTS		;CLEAR TIMER BIT
	MOV	C,INPROG	;SAVE IN PROGRESS
	MOV	ISAV,C
	MOV	DPTR,#TIV
	SJMP	BR2
	;
$EJECT
	;***************************************************************
	;
	; The command action routine - RUN
	;
	;***************************************************************
	;
CRUN:   LCALL   CNEW1           ;CLEAR THE STORAGE ARRAYS
        ACALL   SRESTR1         ;GET THE STARTING ADDRESS
	ACALL	B_C
	JZ	CMNDLK		;IF NULL GO TO COMMAND MODE
	;
	ACALL	T_DP
        ACALL   B_TXA           ;BUMP TO STARTING LINE
	;
CILOOP:	ACALL	SP0		;DO A CR AND A LF
CILOOP1:CLR     DIRF            ;NOT IN DIRECT MODE
	;
	;INTERPERTER DRIVER
	;
ILOOP:	MOV	SP,SPSAV	;RESTORE THE STACK EACH TIME
        JB      DIRF,ILOOP1     ;NO INTERRUPTS IF IN DIRECT MODE
	MOV	INTXAH,TXAH	;SAVE THE TEXT POINTER
	MOV	INTXAL,TXAL
ILOOP1: LCALL   BCK             ;GET CONSOLE STATUS
	JB	DIRF,I_L	;DIRECT MODE
	ANL	C,/GTRD		;SEE IF CHARACTER READY
	JNC	BCHR		;NO CHARACTER = NO CARRY
	;
	; DO TRAP OPERATION
	;
	MOV	DPTR,#GTB	;SAVE TRAP CHARACTER
	MOVX	@DPTR,A
	SETB	GTRD		;SAYS READ A BYTE
	;
BCHR:	JB	OTI,I_L		;EXIT IF TIMER INTERRUPT IN PROGRESS
	JB	OTS,BR0		;TEST TIMER VALUE IF SET
BCHR1:  JNB     INTPEN,I_L      ;SEE IF INTERRUPT PENDING
	JB	INPROG,I_L	;DON'T DO IT AGAIN IF IN PROGRESS
	MOV	DPTR,#INTLOC	;POINT AT INTERRUPT LOCATION
	;
BR2:	MOV	R4,#GTYPE	;SETUP FOR A FORCED GOSUB
	ACALL	SGS1		;PUT TXA ON STACK
	SETB	INPROG		;INTERRUPT IN PROGRESS
	;
ERL4:	CALL	L20DPI
	AJMP	D_L1		;GET THE LINE NUMBER
	;
I_L:	ACALL	ISTAT		;LOOP
	ACALL	CLN_UP		;FINISH IT OFF
	JNC	ILOOP		;LOOP ON THE DRIVER
	JNB	DIRF,CMNDLK	;CMND1 IF IN RUN MODE
	LJMP	CMNDR		;DON'T PRINT READY
	;
CMNDLK:	JMP	CMND1		;DONE
$EJECT
	;**************************************************************
	;
	; The Statement Action Routine - STOP
	;
	;**************************************************************
	;
SSTOP:	ACALL	CLN_UP		;FINISH OFF THIS LINE
	MOV	INTXAH,TXAH	;SAVE TEXT POINTER FOR CONT
	MOV	INTXAL,TXAL
	;
SSTOP0:	SETB	CONB		;CONTINUE WILL WORK
	MOV	DPTR,#STP	;PRINT THE STOP MESSAGE
	SETB	STOPBIT		;SET FOR ERROR ROUTINE
	JMP	ERRS		;JUMP TO ERROR ROUTINE
	;
$EJECT
	;**************************************************************
	;
	; ITRAP - Trap special function register operators
	;
	;**************************************************************
	;
ITRAP:  CJNE    A,#TMR0,ITRAP1  ;TIMER 0
	MOV	TH0,R3
	MOV	TL0,R1
	RET
	;
ITRAP1: CJNE    A,#TMR1,ITRAP2  ;TIMER 1
	MOV	TH1,R3
	MOV	TL1,R1
	RET
	;
ITRAP2: CJNE    A,#TMR2,ITRAP3  ;TIMER 2
        MOV     TH2,R3
        MOV     TL2,R1
;       DB      8BH             ;MOV R3 DIRECT OP CODE
;       DB      0CDH            ;T2H LOCATION
;       DB      89H             ;MOV R1 DIRECT OP CODE
;       DB      0CCH            ;T2L LOCATION
	RET
	;
ITRAP3: CJNE    A,#TRC2,RCL1    ;RCAP2 TOKEN
RCL:    MOV     RCAPH2,R3
        MOV     RCAPL2,R1
;       DB      8BH             ;MOV R3 DIRECT OP CODE
;       DB      0CBH            ;RCAP2H LOCATION
;       DB      89H             ;MOV R1 DIRECT OP CODE
;       DB      0CAH            ;RCAP2L LOCATION
	RET
	;
RCL1:   ACALL   R3CK            ;MAKE SURE THAT R3 IS ZERO
        CJNE    A,#TT2C,RCL2
        MOV     T2CON,R1
;       DB      89H             ;MOV R1 DIRECT OP CODE
;       DB      0C8H            ;T2CON LOCATION
	RET
	;
RCL2:   CJNE    A,#T_IE,RCL3    ;IE TOKEN
	MOV	IE,R1
	RET
	;
RCL3:   CJNE    A,#T_IP,RCL4    ;IP TOKEN
	MOV	IP,R1
	RET
	;
RCL4:   CJNE    A,#TTC,RCL5     ;TCON TOKEN
	MOV	TCON,R1
	RET
	;
RCL5:   CJNE    A,#TTM,RCL6     ;TMOD TOKEN
	MOV	TMOD,R1
	RET
	;
RCL6:   CJNE    A,#T_P1,T_T2    ;P1 TOKEN
	MOV	P1,R1
	RET
	;
	;***************************************************************
	;
	; T_TRAP - Trap special operators
	;
	;***************************************************************
	;
T_T:	MOV	TEMP5,A		;SAVE THE TOKEN
	ACALL	GCI1		;BUMP POINTER
	ACALL	SLET2		;EVALUATE AFTER =
	MOV	A,TEMP5		;GET THE TOKEN BACK
        CJNE    A,#T_XTAL,T_T01
	LJMP	AXTAL1		;SET UP CRYSTAL
	;
T_T01:  ACALL   IFIXL           ;R3:R1 HAS THE TOS
	MOV	A,TEMP5		;GET THE TOKEN AGAIN
	CJNE	A,#T_MTOP,T_T1	;SEE IF MTOP TOKEN
	MOV	DPTR,#MEMTOP
	CALL	S31DP
	JMP	RCLEAR		;CLEAR THE MEMORY
	;
T_T1:	CJNE	A,#T_TIME,ITRAP	;SEE IF A TIME TOKEN
	MOV	C,EA		;SAVE INTERRUPTS
	CLR	EA		;NO TIMER 0 INTERRUPTS DURING LOAD
	MOV	TVH,R3		;SAVE THE TIME
	MOV	TVL,R1
	MOV	EA,C		;RESTORE INTERRUPTS
	RET			;EXIT
	;
T_T2:	CJNE	A,#T_PC,INTERX	;PCON TOKEN
        MOV     PCON,R1
;       DB      89H             ;MOV DIRECT, R1 OP CODE
;       DB      87H             ;ADDRESS OF PCON
	RET			;EXIT
	;
T_TRAP:	CJNE	A,#T_ASC,T_T	;SEE IF ASC TOKEN
	ACALL	IGC		;EAT IT AND GET THE NEXT CHARACTER
	CJNE	A,#'$',INTERX	;ERROR IF NOT A STRING
	ACALL	CSY		;CALCULATE ADDRESS
	ACALL	X3120
	CALL	TWO_EY
        ACALL   SPEOP1          ;EVALUATE AFTER EQUALS
	AJMP	ISTAX1		;SAVE THE CHARACTER
	;
$EJECT
	;**************************************************************
	;
	;INTERPERT THE STATEMENT POINTED TO BY TXAL AND TXAH
	;
	;**************************************************************
	;
ISTAT:	ACALL	GC		;GET THR FIRST CHARACTER
	JNB	XBIT,IAT	;TRAP TO EXTERNAL RUN PACKAGE
        CJNE    A,#20H,ISTAT1
ISTAT1: JNC     IAT
	LCALL	2070H		;LET THE USER SET UP THE DPTR
	ACALL	GCI1
	ANL	A,#0FH		;STRIP OFF BIAS
	SJMP	ISTA1
	;
IAT:    CJNE    A,#T_XTAL,IAT1
IAT1:   JNC     T_TRAP
	JNB	ACC.7,SLET	;IMPLIED LET IF BIT 7 NOT SET
	CJNE	A,#T_UOP+12,ISTAX	;DBYTE TOKEN
	ACALL	SPEOP		;EVALUATE SPECIAL OPERATOR
	ACALL	R3CK		;CHECK LOCATION
	MOV	@R1,A		;SAVE IT
	RET
	;
ISTAX:	CJNE	A,#T_UOP+13,ISTAY	;XBYTE TOKEN
	ACALL	SPEOP
	;
ISTAX1:	MOV	P2,R3
	MOVX	@R1,A
	RET
	;
ISTAY:  CJNE    A,#T_CR+1,ISTAY1;TRAP NEW OPERATORS
ISTAY1: JC      I_S
        CJNE    A,#0B0H,ISTAY2  ;SEE IF TOO BIG
ISTAY2: JNC     INTERX
	ADD	A,#0F9H		;BIAS FOR LOOKUP TABLE
	SJMP	ISTA0		;DO THE OPERATION
	;
I_S:    CJNE    A,#T_LAST,I_S1  ;MAKE SURE AN INITIAL RESERVED WORD
I_S1:   JC      INTERX1         ;ERROR IF NOT
	;
INTERX:	LJMP	E1XX		;SYNTAX ERROR
	;
INTERX1:JNB     DIRF,ISTA0      ;EXECUTE ALL STATEMENTS IF IN RUN MODE
        CJNE    A,#T_DIR,INTERX2;SEE IF ON TOKEN
INTERX2:JC      ISTA0           ;OK IF DIRECT
        CJNE    A,#T_GOSB+1,INTERX3;SEE IF FOR
	SJMP	ISTA0		;FOR IS OK
INTERX3:CJNE    A,#T_REM+1,INTERX4      ;NEXT IS OK
	SJMP	ISTA0
INTERX4:CJNE    A,#T_STOP+6,INTERX      ;SO IS REM
	;
$EJECT
ISTA0:	ACALL	GCI1		;ADVANCE THE TEXT POINTER
	MOV	DPTR,#STATD	;POINT DPTR TO LOOKUP TABLE
        CJNE    A,#T_GOTO-3,ISTA01;SEE IF LET TOKEN
	SJMP	ISTAT		;WASTE LET TOKEN
ISTA01: ANL     A,#3FH          ;STRIP OFF THE GARBAGE
	;
ISTA1:	RL	A		;ROTATE FOR OFFSET
	ADD	A,DPL		;BUMP
	MOV	DPL,A		;SAVE IT
	CLR	A
	MOVC	A,@A+DPTR	;GET HIGH BYTE
	PUSH	ACC		;SAVE IT
	INC	DPTR
	CLR	A
	MOVC	A,@A+DPTR	;GET LOW BYTE
	POP	DPH
	MOV	DPL,A
	;
AC1:	CLR	A
	JMP	@A+DPTR		;GO DO IT
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - LET
	;
	;***************************************************************
	;
SLET:	ACALL	S_C		;CHECK FOR POSSIBLE STRING
	JC	SLET0		;NO STRING
	CLR	LINEB		;USED STRINGS
	;
	CALL	X31DP		;PUT ADDRESS IN DPTR
	MOV	R7,#T_EQU	;WASTE =
	ACALL	EATC
	ACALL	GC		;GET THE NEXT CHARACTER
	CJNE	A,#'"',S_3	;CHECK FOR A "
	MOV	R7,S_LEN	;GET THE STRING LENGTH
	;
S_0:	ACALL	GCI1		;BUMP PAST "
	ACALL	DELTST		;CHECK FOR DELIMITER
	JZ	INTERX		;EXIT IF CARRIAGE RETURN
	MOVX	@DPTR,A		;SAVE THE CHARACTER
	CJNE	A,#'"',S_1	;SEE IF DONE
	;
S_E:	MOV	A,#CR		;PUT A CR IN A
	MOVX	@DPTR,A		;SAVE CR
	AJMP	GCI1
	;
S_3:	PUSH	DPH
	PUSH	DPL		;SAVE DESTINATION
	ACALL	S_C		;CALCULATE SOURCE
	JC	INTERX		;ERROR IF CARRY
	POP	R0B0		;GET DESTINATION BACK
	POP	R2B0
	;
SSOOP:	MOV	R7,S_LEN	;SET UP COUNTER
	;
S_4:	CALL	TBYTE		;TRANSFER THE BYTE
        CJNE    A,#CR,S_41      ;EXIT IF A CR
	RET
S_41:   DJNZ    R7,S_5          ;BUMP COUNTER
	MOV	A,#CR		;SAVE A CR
	MOVX	@R0,A
	AJMP	EIGP		;PRINT EXTRA IGNORED
	;
$EJECT
	;
S_5:	CALL	INC3210		;BUMP POINTERS
	SJMP	S_4		;LOOP
	;
S_1:    DJNZ    R7,S_11         ;SEE IF DONE
	ACALL	S_E
	ACALL	EIGP		;PRINT EXTRA IGNORED
        AJMP    FINDCR          ;GO FIND THE END
S_11:   INC     DPTR            ;BUMP THE STORE POINTER
	SJMP	S_0		;CONTINUE TO LOOP
	;
E3XX:	MOV	DPTR,#E3X	;BAD ARG ERROR
	AJMP	EK
	;
SLET0:	ACALL	SLET1
	AJMP	POPAS		;COPY EXPRESSION TO VARIABLE
	;
SLET1:	ACALL	VAR_ER		;CHECK FOR A"VARIABLE"
	;
SLET2:	PUSH	R2B0		;SAVE THE VARIABLE ADDRESS
	PUSH	R0B0
	MOV	R7,#T_EQU	;GET EQUAL TOKEN
	ACALL	WE
	POP	R1B0		;POP VARIABLE TO R3:R1
	POP	R3B0
	RET			;EXIT
	;
R3CK:	CJNE	R3,#00H,E3XX	;CHECK TO SEE IF R3 IS ZERO
	RET
	;
SPEOP:	ACALL	GCI1		;BUMP TXA
	ACALL	P_E		;EVALUATE PAREN
SPEOP1: ACALL   SLET2           ;EVALUATE AFTER =
	CALL	TWOL		;R7:R6 GETS VALUE, R3:R1 GETS LOCATION
	MOV	A,R6		;SAVE THE VALUE
	;
	CJNE	R7,#00H,E3XX	;R2 MUST BE = 0
	RET
	;
$EJECT
	;**************************************************************
	;
	; ST_CAL - Calculate string Address
	;
	;**************************************************************
	;
IST_CAL:;
	;
	ACALL	I_PI		;BUMP TEXT, THEN EVALUATE
	ACALL	R3CK		;ERROR IF R3 <> 0
	INC	R1		;BUMP FOR OFFSET
	MOV	A,R1		;ERROR IF R1 = 255
	JZ	E3XX
	MOV	DPTR,#VARTOP	;GET TOP OF VARIABLE STORAGE
	MOV	B,S_LEN		;MULTIPLY FOR LOCATION
	ACALL	VARD		;CALCULATE THE LOCATION
	MOV	DPTR,#MEMTOP	;SEE IF BLEW IT
	CALL	FUL1
	MOV	DPL,S_LEN	;GET STRING LENGTH, DPH = 00H
	DEC	DPH		;DPH = 0
	;
DUBSUB:	CLR	C
	MOV	A,R1
	SUBB	A,DPL
	MOV	R1,A
	MOV	A,R3
	SUBB	A,DPH
	MOV	R3,A
	ORL	A,R1
	RET
	;
	;***************************************************************
	;
	;VARD - Calculate the offset base
	;
	;***************************************************************
	;
VARB:	MOV	B,#FPSIZ	;SET UP FOR OPERATION
	;
VARD:	CALL	LDPTRI		;LOAD DPTR
	MOV	A,R1		;MULTIPLY BASE
	MUL	AB
	ADD	A,DPL
	MOV	R1,A
	MOV	A,B
	ADDC	A,DPH
	MOV	R3,A
	RET
	;
$EJECT
	;*************************************************************
	;
CSY:	; Calculate a biased string address and put in R3:R1
	;
	;*************************************************************
	;
	ACALL	IST_CAL		;CALCULATE IT
	PUSH	R3B0		;SAVE IT
	PUSH	R1B0
	MOV	R7,#','		;WASTE THE COMMA
	ACALL	EATC
	ACALL	ONE		;GET THE NEXT EXPRESSION
	MOV	A,R1		;CHECK FOR BOUNDS
        CJNE    A,S_LEN,CSY1
CSY1:   JNC     E3XX            ;MUST HAVE A CARRY
	DEC	R1		;BIAS THE POINTER
	POP	ACC		;GET VALUE LOW
	ADD	A,R1		;ADD IT TO BASE
	MOV	R1,A		;SAVE IT
	POP	R3B0		;GET HIGH ADDRESS
        JNC     CSY2            ;PROPAGATE THE CARRY
	INC	R3
CSY2:   AJMP    ERPAR           ;WASTE THE RIGHT PAREN
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine FOR
	;
	;***************************************************************
	;
SFOR:	ACALL	SLET1		;SET UP CONTROL VARIABLE
	PUSH	R3B0		;SAVE THE CONTROL VARIABLE LOCATION
	PUSH	R1B0
	ACALL	POPAS		;POP ARG STACK AND COPY CONTROL VAR
	MOV	R7,#T_TO	;GET TO TOKEN
	ACALL	WE
	ACALL	GC		;GET NEXT CHARACTER
	CJNE	A,#T_STEP,SF2
	ACALL	GCI1		;EAT THE TOKEN
	ACALL	EXPRB		;EVALUATE EXPRESSION
        SJMP    SF21            ;JUMP OVER
	;
SF2:	LCALL	PUSH_ONE	;PUT ONE ON THE STACK
	;
SF21:   MOV     A,#-FSIZE       ;ALLOCATE FSIZE BYTES ON THE CONTROL STACK
	ACALL	PUSHCS		;GET CS IN R0
	ACALL	CSC		;CHECK CONTROL STACK
	MOV	R3,#CSTKAH	;IN CONTROL STACK
	MOV	R1,R0B0		;STACK ADDRESS
	ACALL	POPAS		;PUT STEP ON STACK
	ACALL	POPAS		;PUT LIMIT ON STACK
	ACALL	DP_T		;DPTR GETS TEXT
	MOV	R0,R1B0		;GET THE POINTER
	ACALL	T_X_S		;SAVE THE TEXT
	POP	TXAL		;GET CONTROL VARIABLE
	POP	TXAH
	MOV	R4,#FTYPE	;AND THE TYPE
	ACALL	T_X_S		;SAVE IT
	;
SF3:	ACALL	T_DP		;GET THE TEXT POINTER
	AJMP	ILOOP		;CONTINUE TO PROCESS
	;
$EJECT
	;**************************************************************
	;
	; The statement action routines - PUSH and POP
	;
	;**************************************************************
	;
SPUSH:	ACALL	EXPRB		;PUT EXPRESSION ON STACK
	ACALL	C_TST		;SEE IF MORE TO DO
	JNC	SPUSH		;IF A COMMA PUSH ANOTHER
	RET
	;
	;
SPOP:	ACALL	VAR_ER		;GET VARIABLE
	ACALL	XPOP		;FLIP THE REGISTERS FOR POPAS
	ACALL	C_TST		;SEE IF MORE TO DO
	JNC	SPOP
	;
SPOP1:  RET
	;
	;***************************************************************
	;
	; The statement action routine - IF
	;
	;***************************************************************
	;
SIF:	ACALL	RTST		;EVALUATE THE EXPRESSION
	MOV	R1,A		;SAVE THE RESULT
	ACALL	GC		;GET THE CHARACTER AFTER EXPR
        CJNE    A,#T_THEN,SIF1  ;SEE IF THEN TOKEN
	ACALL	GCI1		;WASTE THEN TOKEN
SIF1:   CJNE    R1,#0,T_F1      ;CHECK R_OP RESULT
	;
E_FIND:	MOV	R7,#T_ELSE	;FIND ELSE TOKEN
	ACALL	FINDC
        JZ      SPOP1           ;EXIT IF A CR
	ACALL	GCI1		;BUMP PAST TOKEN
	CJNE	A,#T_ELSE,E_FIND;WASTE IF NO ELSE
	;
T_F1:	ACALL	INTGER		;SEE IF NUMBER
	JNC	D_L1		;EXECUTE LINE NUMBER
	AJMP	ISTAT		;EXECUTE STATEMENT IN NOT
	;
B_C:	MOVX	A,@DPTR
	DEC	A
        JB      ACC.7,FL11
	RET
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - GOTO
	;
	;***************************************************************
	;
SGOTO:	ACALL	RLINE		;R2:R0 AND DPTR GET INTGER
	;
SGT1:	ACALL	T_DP		;TEXT POINTER GETS DPTR
	;
	JBC	RETBIT,SGT2	;SEE IF RETI EXECUTED
	;
        JNB     LINEB,SGT11     ;SEE IF A LINE WAS EDITED
        LCALL   CNEW1           ;CLEAR THE MEMORY IF SET
SGT11:  AJMP    CILOOP1         ;CLEAR DIRF AND LOOP
	;
SGT2:   JBC     OTI,SGT21       ;SEE IF TIMER INTERRUPT
	ANL	34,#10111101B	;CLEAR INTERRUPTS
	AJMP	ILOOP		;EXECUTE
SGT21:  MOV     C,ISAV
	MOV	INPROG,C
	AJMP	ILOOP		;RESTORE INTERRUPTS AND RET
	;
	;
	;*************************************************************
	;
RTST:	; Test for ZERO
	;
	;*************************************************************
	;
	ACALL	EXPRB		;EVALUATE EXPRESSION
	CALL	INC_ASTKA	;BUMP ARG STACK
        JZ      RTST1           ;EXIT WITH ZERO OR 0FFH
	MOV	A,#0FFH
RTST1:  RET
	;
$EJECT
	;
	;**************************************************************
	;
	; GLN - get the line number in R2:R0, return in DPTR
	;
	;**************************************************************
	;
GLN:	ACALL	DP_B		;GET THE BEGINNING ADDRESS
	;
FL1:	MOVX	A,@DPTR		;GET THE LENGTH
	MOV	R7,A		;SAVE THE LENGTH
	DJNZ	R7,FL3		;SEE IF END OF FILE
	;
FL11:   MOV     DPTR,#E10X      ;NO LINE NUMBER
	AJMP	EK		;HANDLE THE ERROR
	;
FL3:    JB      ACC.7,FL11      ;CHECK FOR BIT 7
	INC	DPTR		;POINT AT HIGH BYTE
	MOVX	A,@DPTR		;GET HIGH BYTE
	CJNE	A,R2B0,FL2	;SEE IF MATCH
	INC	DPTR		;BUMP TO LOW BYTE
	DEC	R7		;ADJUST AGAIN
	MOVX	A,@DPTR		;GET THE LOW BYTE
	CJNE	A,R0B0,FL2	;SEE IF LOW BYTE MATCH
	INC	DPTR		;POINT AT FIRST CHARACTER
	RET			;FOUND IT
	;
FL2:	MOV	A,R7		;GET THE LENGTH COUNTER
	CALL	ADDPTR		;ADD A TO DATA POINTER
	SJMP	FL1		;LOOP
	;
	;
	;*************************************************************
	;
	;RLINE - Read in ASCII string, get line, and clean it up
	;
	;*************************************************************
	;
RLINE:	ACALL	INTERR		;GET THE INTEGER
	;
RL1:	ACALL	GLN
	AJMP	CLN_UP
	;
	;
D_L1:	ACALL	GLN		;GET THE LINE
	AJMP	SGT1		;EXECUTE THE LINE
	;
$EJECT
	;***************************************************************
	;
	; The statement action routines WHILE and UNTIL
	;
	;***************************************************************
	;
SWHILE:	ACALL	RTST		;EVALUATE RELATIONAL EXPRESSION
	CPL	A
	SJMP	S_WU
	;
SUNTIL:	ACALL	RTST		;EVALUATE RELATIONAL EXPRESSION
	;
S_WU:	MOV	R4,#DTYPE	;DO EXPECTED
	MOV	R5,A		;SAVE R_OP RESULT
	SJMP	SR0		;GO PROCESS
	;
	;
	;***************************************************************
	;
CNULL:	; The Command Action Routine - NULL
	;
	;***************************************************************
	;
	ACALL	INTERR		;GET AN INTEGER FOLLOWING NULL
	MOV	NULLCT,R0	;SAVE THE NULLCOUNT
	AJMP	CMNDLK		;JUMP TO COMMAND MODE
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - RETI
	;
	;***************************************************************
	;
SRETI:	SETB	RETBIT		;SAYS THAT RETI HAS BEEN EXECUTED
	;
	;***************************************************************
	;
	; The statement action routine - RETURN
	;
	;***************************************************************
	;
SRETRN:	MOV	R4,#GTYPE	;MAKE SURE OF GOSUB
	MOV	R5,#55H		;TYPE RETURN TYPE
	;
SR0:	ACALL	CSETUP		;SET UP CONTROL STACK
	MOVX	A,@R0		;GET RETURN TEXT ADDRESS
	MOV	DPH,A
	INC	R0
	MOVX	A,@R0
	MOV	DPL,A
	INC	R0		;POP CONTROL STACK
	MOVX	A,@DPTR		;SEE IF GOSUB WAS THE LAST STATEMENT
        CJNE    A,#EOF,SR01
	AJMP	CMNDLK
SR01:   MOV     A,R5            ;GET TYPE
	JZ	SGT1		;EXIT IF ZERO
	MOV	CSTKA,R0	;POP THE STACK
	CPL	A		;OPTION TEST, 00H, 55H, 0FFH, NOW 55H
	JNZ	SGT1		;MUST BE GOSUB
	RET			;NORMAL FALL THRU EXIT FOR NO MATCH
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - GOSUB
	;
	;***************************************************************
	;
SGOSUB:	ACALL	RLINE		;NEW TXA IN DPTR
	;
SGS0:	MOV	R4,#GTYPE
	ACALL	SGS1		;SET EVERYTHING UP
	AJMP	SF3		;EXIT
	;
SGS1:	MOV	A,#-3		;ALLOCATE 3 BYTES ON CONTROL STACK
	ACALL	PUSHCS
	;
T_X_S:	MOV	P2,#CSTKAH	;SET UP PORT FOR CONTROL STACK
	MOV	A,TXAL		;GET RETURN ADDRESS AND SAVE IT
	MOVX	@R0,A
	DEC	R0
	MOV	A,TXAH
	MOVX	@R0,A
	DEC	R0
	MOV	A,R4		;GET TYPE
	MOVX	@R0,A		;SAVE TYPE
	RET			;EXIT
	;
	;
CS1:	MOV	A,#3		;POP 3 BYTES
	ACALL	PUSHCS
	;
CSETUP:	MOV	R0,CSTKA	;GET CONTROL STACK
	MOV	P2,#CSTKAH
	MOVX	A,@R0		;GET BYTE
        CJNE    A,R4B0,CSETUP1  ;SEE IF TYPE MATCH
	INC	R0
	RET
CSETUP1:JZ      E4XX            ;EXIT IF STACK UNDERFLOW
	CJNE	A,#FTYPE,CS1	;SEE IF FOR TYPE
        ACALL   XXI3            ;WASTE THE FOR TYPE
	SJMP	CSETUP		;LOOP
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - NEXT
	;
	;***************************************************************
	;
SNEXT:	MOV	R4,#FTYPE	;FOR TYPE
	ACALL	CSETUP		;SETUP CONTROL STACK
	MOV	TEMP5,R0	;SAVE CONTROL VARIABLE ADDRESS
	MOV	R1,#TEMP1	;SAVE VAR + RETURN IN TEMP1-4
	;
XXI:	MOVX	A,@R0		;LOOP UNTIL DONE
	MOV	@R1,A
	INC	R1
	INC	R0
	CJNE	R1,#TEMP5,XXI
	;
	ACALL	VAR		;SEE IF THE USER HAS A VARIABLE
        JNC     XXI1
	MOV	R2,TEMP1
	MOV	R0,TEMP2
XXI1:   MOV     A,R2            ;SEE IF VAR'S AGREE
	CJNE	A,TEMP1,E4XX
	MOV	A,R0
	CJNE	A,TEMP2,E4XX
	ACALL	PUSHAS		;PUT CONTROL VARIABLE ON STACK
	MOV	A,#FPSIZ+FPSIZ+2;COMPUTE ADDRESS TO STEP VALUE SIGN
	ADD	A,TEMP5		;ADD IT TO BASE OF STACK
	MOV	R0,A		;SAVE IN R0
	MOV	R2,#CSTKAH	;SET UP TO PUSH STEP VALUE
	MOV	P2,R2		;SET UP PORT
	MOVX	A,@R0		;GET SIGN
	INC	R0		;BACK TO EXPONENT
	PUSH	ACC		;SAVE SIGN OF STEP
	ACALL	PUSHAS		;PUT STEP VALUE ON STACK
	PUSH	R0B0		;SAVE LIMIT VALUE LOCATION
	CALL	AADD		;ADD STEP VALUE TO VARIABLE
	CALL	CSTAKA		;COPY STACK
	MOV	R3,TEMP1	;GET CONTROL VARIABLE
	MOV	R1,TEMP2
	ACALL	POPAS		;SAVE THE RESULT
	MOV	R2,#CSTKAH	;RESTORE LIMIT LOCATION
	POP	R0B0
	ACALL	PUSHAS		;PUT LIMIT ON STACK
        CALL    FP_BASE2        ;DO THE COMPARE
	POP	ACC		;GET LIMIT SIGN BACK
        JZ      XXI2            ;IF SIGN NEGATIVE, TEST "BACKWARDS"
	CPL	C
XXI2:   ORL     C,F0            ;SEE IF EQUAL
	JC	N4		;STILL SMALLER THAN LIMIT?
XXI3:   MOV     A,#FSIZE        ;REMOVE CONTROL STACK ENTRY
	;
	; Fall thru to PUSHCS
	;
$EJECT
	;***************************************************************
	;
	; PUSHCS - push frame onto control stack
	;          acc has - number of bytes, also test for overflow
	;
	;***************************************************************
	;
PUSHCS:	ADD	A,CSTKA		;BUMP CONTROL STACK
        CJNE    A,#CONVT+17,PUSHCS1 ;SEE IF OVERFLOWED
PUSHCS1:JC      E4XX            ;EXIT IF STACK OVERFLOW
	XCH	A,CSTKA		;STORE NEW CONTROL STACK VALUE, GET OLD
	DEC	A		;BUMP OLD VALUE
	MOV	R0,A		;PUT OLD-1 IN R0
	;
PUSHCS2:RET                     ;EXIT
	;
CSC:	ACALL	CLN_UP		;FINISH OFF THE LINE
        JNC     PUSHCS2         ;EXIT IF NO TERMINATOR
	;
E4XX:	MOV	DPTR,#EXC	;CONTROL STACK ERROR
	AJMP	EK		;STACK ERROR
	;
N4:	MOV	TXAH,TEMP3	;GET TEXT POINTER
	MOV	TXAL,TEMP4
	AJMP	ILOOP		;EXIT
	;
	;***************************************************************
	;
	; The statement action routine - RESTORE
	;
	;***************************************************************
	;
SRESTR:	ACALL	X_TR		;SWAP POINTERS
SRESTR1:ACALL   DP_B            ;GET THE STARTING ADDRESS
	ACALL	T_DP		;PUT STARTING ADDRESS IN TEXT POINTER
	ACALL	B_TXA		;BUMP TXA
	;
	; Fall thru
	;
X_TR:	;swap txa and rtxa
	;
	XCH	A,TXAH
	XCH	A,RTXAH
	XCH	A,TXAH
	XCH	A,TXAL
	XCH	A,RTXAL
	XCH	A,TXAL
	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - READ
	;
	;***************************************************************
	;
SREAD:	ACALL	X_TR		;SWAP POINTERS
	;
SRD0:	ACALL	C_TST		;CHECK FOR COMMA
	JC	SRD4		;SEE WHAT IT IS
	;
SRD:	ACALL	EXPRB		;EVALUATE THE EXPRESSION
	ACALL	GC		;GET THE CHARACTER AFTER EXPRESSION
	CJNE	A,#',',SRD1	;SEE IF MORE DATA
	SJMP	SRD2		;BYBASS CLEAN UP IF A COMMA
	;
SRD1:	ACALL	CLN_UP		;FINISH OFF THE LINE, IF AT END
	;
SRD2:	ACALL	X_TR		;RESTORE POINTERS
	ACALL	VAR_ER		;GET VARIABLE ADDRESS
	ACALL	XPOP		;FLIP THE REGISTERS FOR POPAS
	ACALL	C_TST		;SEE IF A COMMA
	JNC	SREAD		;READ AGAIN IF A COMMA
SRD21:  RET                     ;EXIT IF NOT
	;
SRD4:	CJNE	A,#T_DATA,SRD5	;SEE IF DATA
	ACALL	GCI1		;BUMP POINTER
	SJMP	SRD
	;
SRD5:	CJNE	A,#EOF,SRD6	;SEE IF YOU BLEW IT
SRD51:  ACALL   X_TR            ;GET THE TEXT POINTER BACK
	MOV	DPTR,#E14X	;READ ERROR
	;
EK:	LJMP	ERROR
	;
SRD6:	ACALL	FINDCR		;WASTE THIS LINE
	ACALL	CLN_UP		;CLEAN IT UP
        JC      SRD51           ;ERROR IF AT END
	SJMP	SRD0
	;
NUMC:	ACALL	GC		;GET A CHARACTER
	CJNE	A,#'#',NUMC1	;SEE IF A #
	SETB	COB		;VALID LINE PRINT
	AJMP	IGC		;BUMP THE TEXT POINTER
	;
NUMC1:  CJNE    A,#'@',SRD21    ;EXIT IF NO GOOD
	SETB	LPB
	AJMP	IGC
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - PRINT
	;
	;***************************************************************
	;
SPH0:	SETB	ZSURP		;NO ZEROS
	;
SPH1:	SETB	HMODE		;HEX MODE
	;
SPRINT:	ACALL	NUMC		;TEST FOR A LINE PRINT
        ACALL   SPRINT2         ;PROCEED
SPRINT1:ANL     35,#11110101B   ;CLEAR COB AND LPB
	ANL	38,#00111111B	;NO HEX MODE
	;
	RET
	;
SPRINT2:ACALL   DELTST          ;CHECK FOR A DELIMITER
	JC	SP1
	;
SP0:	JMP	CRLF		;EXIT WITH A CR IF SO
	;
SP2:	ACALL	C_TST		;CHECK FOR A COMMA
	JC	SP0		;EXIT IF NO COMMA
	;
SP1:	ACALL	CPS		;SEE IF A STRING TO PRINT
	JNC	SP2		;IF A STRING, CHECK FOR A COMMA
	;
SP4:	CJNE	A,#T_TAB,SP6
	ACALL	I_PI		;ALWAYS CLEARS CARRY
	SUBB	A,PHEAD		;TAKE DELTA BETWEEN TAB AND PHEAD
	JC	SP2		;EXIT IF PHEAD > TAB
	SJMP	SP7		;OUTPUT SPACES
	;
SP6:	CJNE	A,#T_SPC,SM
	ACALL	I_PI		;SET UP PAREN VALUE
	;
SP7:	JZ	SP2
	LCALL	STEROT		;OUTPUT A SPACE
	DEC	A		;DECREMENT COUNTER
	SJMP	SP7		;LOOP
	;
$EJECT
SM:	CJNE	A,#T_CHR,SP8
	ACALL	IGC
        CJNE    A,#'$',SM01
	ACALL	CNX		;PUT THE CHARACTER ON THE STACK
	ACALL	IFIXL		;PUT THE CHARACTER IN R1
        SJMP    SM02
SM01:   ACALL   ONE             ;EVALUATE THE EXPRESSION, PUT IN R3:R1
	ACALL	ERPAR
SM02:   MOV     R5,R1B0         ;BYTE TO OUTPUT
	SJMP	SQ
	;
SP8:	CJNE	A,#T_CR,SX
	ACALL	GCI1		;EAT THE TOKEN
	MOV	R5,#CR
	;
SQ:	CALL	TEROT
	SJMP	SP2		;OUTPUT A CR AND DO IT AGAIN
	;
SX:	CJNE	A,#T_USE,SP9	;USING TOKEN
	ACALL	IGC		;GE THE CHARACTER AFTER THE USING TOKEN
	CJNE	A,#'F',U4	;SEE IF FLOATING
	MOV	FORMAT,#0F0H	;SET FLOATING
	ACALL	IGC		;BUMP THE POINTER AND GET THE CHARACTER
	ACALL	GCI1		;BUMP IT AGAIN
	ANL	A,#0FH		;STRIP OFF ASCII BIAS
	JZ	U3		;EXIT IF ZERO
        CJNE    A,#3,SX1        ;SEE IF AT LEAST A THREE
SX1:    JNC     U3              ;FORCE A THREE IF NOT A THREE
	MOV	A,#3
	;
U3:	ORL	FORMAT,A	;PUT DIGIT IN FORMAT
	SJMP	U8		;CLEAN UP END
	;
U4:	CJNE	A,#'0',U5
	MOV	FORMAT,#0	;FREE FORMAT
	ACALL	GCI1		;BUMP THE POINTER
	SJMP	U8
	;
U5:	CJNE	A,#'#',U8	;SEE IF INTGER FORMAT
	ACALL	U6
	MOV	FORMAT,R7	;SAVE THE FORMAT
	CJNE	A,#'.',U8A	;SEE IF TERMINATOR WAS RADIX
	ACALL	IGC		;BUMP PAST .
	ACALL	U6		;LOOP AGAIN
	MOV	A,R7		;GET COUNT
	ADD	A,FORMAT	;SEE IF TOO BIG
	ADD	A,#0F7H
	JNC	U5A
	;
$EJECT
SE0:	AJMP	INTERX		;ERROR, BAD SYNTAX
	;
U5A:	MOV	A,R7		;GET THE COUNT BACK
	SWAP	A		;ADJUST
	ORL	FORMAT,A	;GET THE COUNT
	;
U8A:	MOV	A,FORMAT
	;
U8B:	SWAP	A		;GET THE FORMAT RIGHT
	MOV	FORMAT,A
	;
U8:	ACALL	ERPAR
	AJMP	SP2		;DONE
	;
U6:	MOV	R7,#0		;SET COUNTER
	;
U7:	CJNE	A,#'#',SP9A	;EXIT IF NOT A #
	INC	R7		;BUMP COUNTER
	ACALL	IGC		;GET THE NEXT CHARACTER
	SJMP	U7		;LOOP
	;
SP9:    ACALL   DELTST1         ;CHECK FOR DELIMITER
	JNC	SP9A		;EXIT IF A DELIMITER
	;
	CJNE	A,#T_ELSE,SS
	;
SP9A:	RET			;EXIT IF ELSE TOKEN
	;
	;**************************************************************
	;
	; P_E - Evaluate an expression in parens ( )
	;
	;**************************************************************
	;
P_E:	MOV	R7,#T_LPAR
	ACALL	WE
	;
ERPAR:	MOV	R7,#')'		;EAT A RIGHT PAREN
	;
EATC:	ACALL	GCI		;GET THE CHARACTER
	CJNE	A,R7B0,SE0	;ERROR IF NOT THE SAME
	RET
	;
$EJECT
	;***************************************************************
	;
S_ON:	; ON Statement
	;
	;***************************************************************
	;
	ACALL	ONE		;GET THE EXPRESSION
	ACALL	GCI		;GET THE NEXT CHARACTER
	CJNE	A,#T_GOTO,C0
	ACALL	C1		;EAT THE COMMAS
	AJMP	SF3		;DO GOTO
	;
C0:	CJNE	A,#T_GOSB,SE0
	ACALL	C1
	AJMP	SGS0		;DO GOSUB
	;
C1:	CJNE	R1,#0,C2
	ACALL	INTERR		;GET THE LINE NUMBER
	ACALL	FINDCR
	AJMP	RL1		;FINISH UP THIS LINE
	;
C2:	MOV	R7,#','
	ACALL	FINDC
	CJNE	A,#',',SE0	;ERROR IF NOT A COMMA
	DEC	R1
	ACALL	GCI1		;BUMP PAST COMMA
	SJMP	C1
	;
$EJECT
	;
SS:	ACALL	S_C		;SEE IF A STRING
	JC	SA		;NO STRING IF CARRY IS SET
	LCALL	UPRNT		;PUT POINTER IN DPTR
	AJMP	SP2		;SEE IF MORE
	;
SA:	ACALL	EXPRB		;MUST BE AN EXPRESSION
	MOV	A,#72
        CJNE    A,PHEAD,SA1     ;CHECK PHEAD POSITION
SA1:    JNC     SA2
	ACALL	SP0		;FORCE A CRLF
SA2:    JNB     HMODE,S13       ;HEX MODE?
	CALL	FCMP		;SEE IF TOS IS < 0FFFH
	JC	S13		;EXIT IF GREATER
	CALL	AABS		;GET THE SIGN
	JNZ	OOPS		;WASTE IF NEGATIVE
	ACALL	IFIXL
        CALL    FP_BASE11       ;PRINT HEXMODE
	AJMP	SP2
OOPS:	CALL	ANEG		;MAKE IT NEGATIVE
	;
S13:    CALL    FP_BASE7        ;DO FP OUTPUT
	MOV	A,#1		;OUTPUT A SPACE
	AJMP	SP7
	;
$EJECT
	;***************************************************************
	;
	; ANU -  Get variable name from text - set carry if not found
	;        if succeeds returns variable in R7:R6
	;        R6 = 0 if no digit in name
	;
	;***************************************************************
	;
ANU:	ACALL	IGC		;INCREMENT AND GET CHARACTER
        LCALL   DIGIT_CHECK     ;CHECK FOR DIGIT
        JC      AL2             ;EXIT IF VALID DIGIT
        CJNE    A,#'_',AL       ;SEE IF A _
	RET
	;
AL:     CJNE    A,#'A',AL1      ;IS IT AN ASCII A?
AL1:    JC      AL3             ;EXIT IF CARRY IS SET
        CJNE    A,#'Z'+1,AL2    ;IS IT LESS THAN AN ASCII Z
AL2:    CPL     C               ;FLIP CARRY
AL3:    RET
	;
SD01:   JNB     F0,VAR2
	;
SD0:	MOV	DPTR,#E6X
	AJMP	EK
	;
SDIMX:	SETB	F0		;SAYS DOING A DIMENSION
	SJMP	VAR1
	;
VAR:	CLR	F0		;SAYS DOING A VARIABLE
	;
VAR1:	ACALL	GC		;GET THE CHARACTER
	ACALL	AL		;CHECK FOR ALPHA
        JNC     VAR11           ;ERROR IF IN DIM
	JB	F0,SD0
	RET
VAR11:  MOV     R7,A            ;SAVE ALPHA CHARACTER
	CLR	A		;ZERO IN CASE OF FAILURE
	MOV	R5,A		;SAVE IT
	;
VY:	MOV	R6,A
	ACALL	ANU		;CHECK FOR ALPHA OR NUMBER
	JC	VX		;EXIT IF NO ALPHA OR NUM
	;
	XCH	A,R7
	ADD	A,R5		;NUMBER OF CHARACTERS IN ALPHABET
	XCH	A,R7		;PUT IT BACK
	MOV	R5,#26		;FOR THE SECOND TIME AROUND
	SJMP	VY
	;
VX:	CLR	LINEB		;TELL EDITOR A VARIABLE IS DECLARED
	CJNE	A,#T_LPAR,V4	;SEE IF A LEFT PAREN
	;
	ORL	R6B0,#80H	;SET BIT 7 TO SIGINIFY MATRIX
	CALL	F_VAR		;FIND THE VARIABLE
	PUSH	R2B0		;SAVE THE LOCATION
	PUSH	R0B0
        JNC     SD01            ;DEFAULT IF NOT IN TABLE
	JB	F0,SDI		;NO DEFAULT FOR DIMENSION
	MOV	R1,#10
	MOV	R3,#0
	ACALL	D_CHK
	;
VAR2:	ACALL	PAREN_INT	;EVALUATE INTEGER IN PARENS
	CJNE	R3,#0,SD0	;ERROR IF R3<>0
	POP	DPL		;GET VAR FOR LOOKUP
	POP	DPH
	MOVX	A,@DPTR		;GET DIMENSION
	DEC	A		;BUMP OFFSET
	SUBB	A,R1		;A MUST BE > R1
	JC	SD0
	LCALL	DECDP2		;BUMP POINTER TWICE
	ACALL	VARB		;CALCULATE THE BASE
	;
X3120:	XCH	A,R1		;SWAP R2:R0, R3:R1
	XCH	A,R0
	XCH	A,R1
	XCH	A,R3
	XCH	A,R2
	XCH	A,R3
	RET
	;
V4:	JB	F0,SD0		;ERROR IF NO LPAR FOR DIM
	LCALL	F_VAR		;GET SCALAR VARIABLE
	CLR	C
	RET
	;
$EJECT
	;
SDI:	ACALL	PAREN_INT	;EVALUATE PAREN EXPRESSION
	CJNE	R3,#0,SD0	;ERROR IF NOT ZERO
	POP	R0B0		;SET UP R2:R0
	POP	R2B0
	ACALL	D_CHK		;DO DIM
	ACALL	C_TST		;CHECK FOR COMMA
	JNC	SDIMX		;LOOP IF COMMA
	RET			;RETURN IF NO COMMA
	;
D_CHK:	INC	R1		;BUMP FOR TABLE LOOKUP
	MOV	A,R1
	JZ	SD0		;ERROR IF 0FFFFH
	MOV	R4,A		;SAVE FOR LATER
	MOV	DPTR,#MT_ALL	;GET MATRIX ALLOCATION
	ACALL	VARB		;DO THE CALCULATION
	MOV	R7,DPH		;SAVE MATRIX ALLOCATION
	MOV	R6,DPL
	MOV	DPTR,#ST_ALL	;SEE IF TOO MUCH MEMORY TAKEN
	CALL	FUL1		;ST_ALL SHOULD BE > R3:R1
	MOV	DPTR,#MT_ALL	;SAVE THE NEW MATRIX POINTER
	CALL	S31DP
	MOV	DPL,R0		;GET VARIABLE ADDRESS
	MOV	DPH,R2
	MOV	A,R4		;DIMENSION SIZE
	MOVX	@DPTR,A		;SAVE IT
	CALL	DECDP2		;SAVE TARGET ADDRESS
	;
R76S:	MOV	A,R7
	MOVX	@DPTR,A
	INC	DPTR
	MOV	A,R6		;ELEMENT SIZE
	MOVX	@DPTR,A
	RET			;R2:R0 STILL HAS SYMBOL TABLE ADDRESS
	;
$EJECT
	;***************************************************************
	;
	; The statement action routine - INPUT
	;
	;***************************************************************
	;
SINPUT:	ACALL	CPS		;PRINT STRING IF THERE
	;
	ACALL	C_TST		;CHECK FOR A COMMA
	JNC	IN2A		;NO CRLF
	ACALL	SP0		;DO A CRLF
	;
IN2:	MOV	R5,#'?'		;OUTPUT A ?
	CALL	TEROT
	;
IN2A:	SETB	INP_B		;DOING INPUT
	CALL	INLINE		;INPUT THE LINE
	CLR	INP_B
	MOV	TEMP5,#HIGH IBUF
	MOV	TEMP4,#LOW IBUF
	;
IN3:	ACALL	S_C		;SEE IF A STRING
	JC	IN3A		;IF CARRY IS SET, NO STRING
	ACALL	X3120		;FLIP THE ADDRESSES
	MOV	R3,TEMP5
	MOV	R1,TEMP4
	ACALL	SSOOP
	ACALL	C_TST		;SEE IF MORE TO DO
	JNC	IN2
	RET
	;
IN3A:	CALL	DTEMP		;GET THE USER LOCATION
	CALL	GET_NUM		;GET THE USER SUPPLIED NUMBER
	JNZ	IN5		;ERROR IF NOT ZERO
	CALL	TEMPD		;SAVE THE DATA POINTER
	ACALL	VAR_ER		;GET THE VARIABLE
	ACALL	XPOP		;SAVE THE VARIABLE
	CALL	DTEMP		;GET DPTR BACK FROM VAR_ER
	ACALL	C_TST		;SEE IF MORE TO DO
	JC	IN6		;EXIT IF NO COMMA
	MOVX	A,@DPTR		;GET INPUT TERMINATOR
	CJNE	A,#',',IN5	;IF NOT A COMMA DO A CR AND TRY AGAIN
	INC	DPTR		;BUMP PAST COMMA AND READ NEXT VALUE
	CALL	TEMPD
	SJMP	IN3
	;
$EJECT
	;
IN5:	MOV	DPTR,#IAN	;PRINT INPUT A NUMBER
	CALL	CRP		;DO A CR, THEN, PRINT FROM ROM
	LJMP	CC1		;TRY IT AGAIN
	;
IN6:	MOVX	A,@DPTR
	CJNE	A,#CR,EIGP
	RET
	;
EIGP:	MOV	DPTR,#EIG
	CALL	CRP		;PRINT THE MESSAGE AND EXIT
	AJMP	SP0		;EXIT WITH A CRLF
	;
	;***************************************************************
	;
SOT:	; On timer interrupt
	;
	;***************************************************************
	;
	ACALL	TWO		;GET THE NUMBERS
	MOV	SP_H,R3
	MOV	SP_L,R1
	MOV	DPTR,#TIV	;SAVE THE NUMBER
	SETB	OTS
	AJMP	R76S		;EXIT
	;
	;
	;***************************************************************
	;
SCALL:	; Call a user rountine
	;
	;***************************************************************
	;
	ACALL	INTERR		;CONVERT INTEGER
	CJNE	R2,#0,S_C_1	;SEE IF TRAP
	MOV	A,R0
	JB	ACC.7,S_C_1
	ADD	A,R0
	MOV	DPTR,#4100H
	MOV	DPL,A
	;
S_C_1:	ACALL	AC1		;JUMP TO USER PROGRAM
	ANL	PSW,#11100111B	;BACK TO BANK 0
	RET			;EXIT
	;
$EJECT
	;**************************************************************
	;
THREE:	; Save value for timer function
	;
	;**************************************************************
	;
	ACALL	ONE		;GET THE FIRST INTEGER
	CALL	CBIAS		;BIAS FOR TIMER LOAD
	MOV	T_HH,R3
	MOV	T_LL,R1
	MOV	R7,#','		;WASTE A COMMA
	ACALL	EATC		;FALL THRU TO TWO
	;
	;**************************************************************
	;
TWO:	; Get two values seperated by a comma off the stack
	;
	;**************************************************************
	;
	ACALL	EXPRB
	MOV	R7,#','		;WASTE THE COMMA
	ACALL	WE
	JMP	TWOL		;EXIT
	;
	;*************************************************************
	;
ONE:	; Evaluate an expression and get an integer
	;
	;*************************************************************
	;
	ACALL	EXPRB		;EVALUATE EXPERSSION
	;
IFIXL:	CALL	IFIX		;INTEGERS IN R3:R1
	MOV	A,R1
	RET
	;
	;
	;*************************************************************
	;
I_PI:	; Increment text pointer then get an integer
	;
	;*************************************************************
	;
	ACALL	GCI1		;BUMP TEXT, THEN GET INTEGER
	;
PAREN_INT:; Get an integer in parens ( )
	;
	ACALL	P_E
	SJMP	IFIXL
	;
$EJECT
	;
DP_B:	MOV	DPH,BOFAH
	MOV	DPL,BOFAL
	RET
	;
DP_T:	MOV	DPH,TXAH
	MOV	DPL,TXAL
	RET
	;
CPS:	ACALL	GC		;GET THE CHARACTER
	CJNE	A,#'"',NOPASS	;EXIT IF NO STRING
	ACALL	DP_T		;GET TEXT POINTER
	INC	DPTR		;BUMP PAST "
	MOV	R4,#'"'
	CALL	PN0		;DO THE PRINT
	INC	DPTR		;GO PAST QUOTE
	CLR	C		;PASSED TEST
	;
T_DP:	MOV	TXAH,DPH	;TEXT POINTER GETS DPTR
	MOV	TXAL,DPL
	RET
	;
	;*************************************************************
	;
S_C:	; Check for a string
	;
	;*************************************************************
	;
	ACALL	GC		;GET THE CHARACTER
	CJNE	A,#'$',NOPASS	;SET CARRY IF NOT A STRING
	AJMP	IST_CAL		;CLEAR CARRY, CALCULATE OFFSET
	;
	;
	;
	;**************************************************************
	;
C_TST:	ACALL	GC		;GET A CHARACTER
	CJNE	A,#',',NOPASS	;SEE IF A COMMA
	;
$EJECT
	;***************************************************************
	;
	;GC AND GCI - GET A CHARACTER FROM TEXT (NO BLANKS)
	;             PUT CHARACTER IN THE ACC
	;
	;***************************************************************
	;
IGC:	ACALL	GCI1		;BUMP POINTER, THEN GET CHARACTER
	;
GC:	SETB	RS0		;USE BANK 1
	MOV	P2,R2		;SET UP PORT 2
	MOVX	A,@R0		;GET EXTERNAL BYTE
	CLR	RS0		;BACK TO BANK 0
	RET			;EXIT
	;
GCI:	ACALL	GC
	;
	; This routine bumps txa by one and always clears the carry
	;
GCI1:	SETB	RS0		;BANK 1
	INC	R0		;BUMP TXA
        CJNE    R0,#0,GCI11
	INC	R2
GCI11:  CLR     RS0
	RET			;EXIT
	;
$EJECT
	;**************************************************************
	;
	; Check delimiters
	;
	;**************************************************************
	;
DELTST:	ACALL	GC		;GET A CHARACTER
DELTST1:CJNE    A,#CR,DT1       ;SEE IF A CR
	CLR	A
	RET
	;
DT1:	CJNE	A,#':',NOPASS	;SET CARRY IF NO MATCH
	;
L_RET:	RET
	;
	;
	;***************************************************************
	;
	; FINDC - Find the character in R7, update TXA
	;
	;***************************************************************
	;
FINDCR:	MOV	R7,#CR		;KILL A STATEMENT LINE
	;
FINDC:	ACALL	DELTST
	JNC	L_RET
	;
	CJNE	A,R7B0,FNDCL2	;MATCH?
	RET
	;
FNDCL2:	ACALL	GCI1
	SJMP	FINDC		;LOOP
	;
FNDCL3: ACALL   GCI1
	;
WCR:	ACALL	DELTST		;WASTE UNTIL A "REAL" CR
        JNZ     FNDCL3
	RET
	;
$EJECT
	;***************************************************************
	;
	; VAR_ER - Check for a variable, exit if error
	;
	;***************************************************************
	;
VAR_ER:	ACALL	VAR
        SJMP    INTERR1
	;
	;
	;***************************************************************
	;
	; S_D0 - The Statement Action Routine DO
	;
	;***************************************************************
	;
S_DO:	ACALL	CSC		;FINISH UP THE LINE
	MOV	R4,#DTYPE	;TYPE FOR STACK
	ACALL	SGS1		;SAVE ON STACK
	AJMP	ILOOP		;EXIT
	;
$EJECT
	;***************************************************************
	;
	; CLN_UP - Clean up the end of a statement, see if at end of
	;          file, eat character and line count after CR
	;
	;***************************************************************
	;
C_2:	CJNE	A,#':',C_1	;SEE IF A TERMINATOR
	AJMP	GCI1		;BUMP POINTER AND EXIT, IF SO
	;
C_1:	CJNE	A,#T_ELSE,EP5
	ACALL	WCR		;WASTE UNTIL A CR
	;
CLN_UP:	ACALL	GC		;GET THE CHARACTER
	CJNE	A,#CR,C_2	;SEE IF A CR
	ACALL	IGC		;GET THE NEXT CHARACTER
	CJNE	A,#EOF,B_TXA	;SEE IF TERMINATOR
	;
NOPASS:	SETB	C
	RET
	;
B_TXA:	XCH	A,TXAL		;BUMP TXA BY THREE
	ADD	A,#3
	XCH	A,TXAL
        JBC     CY,B_TXA1
	RET
B_TXA1: INC     TXAH
	RET
	;
$EJECT
	;***************************************************************
	;
	;         Get an INTEGER from the text
	;         sets CARRY if not found
	;         returns the INTGER value in DPTR and R2:R0
	;         returns the terminator in ACC
	;
	;***************************************************************
	;
INTERR:	ACALL	INTGER		;GET THE INTEGER
INTERR1:JC      EP5             ;ERROR IF NOT FOUND
	RET			;EXIT IF FOUND
	;
INTGER:	ACALL	DP_T
        CALL    FP_BASE9        ;CONVERT THE INTEGER
	ACALL	T_DP
	MOV	DPH,R2		;PUT THE RETURNED VALUE IN THE DPTR
	MOV	DPL,R0
	;
ITRET:	RET			;EXIT
	;
	;
WE:	ACALL	EATC		;WASTE THE CHARACTER
	;
	; Fall thru to evaluate the expression
	;
$EJECT
	;***************************************************************
	;
	; EXPRB - Evaluate an expression
	;
	;***************************************************************
	;
EXPRB:	MOV	R2,#LOW OPBOL	;BASE PRECEDENCE
	;
EP1:	PUSH	R2B0		;SAVE OPERATOR PRECEDENCE
	CLR	ARGF		;RESET STACK DESIGNATOR
	;
EP2:	MOV	A,SP		;GET THE STACK POINTER
	ADD	A,#12		;NEED AT LEAST 12 BYTES
        JNC     EP21
        LJMP    E1XX2
EP21:   MOV     A,ASTKA         ;GET THE ARG STACK
	SUBB	A,#LOW TM_TOP+12;NEED 12 BYTES ALSO
        JNC     EP22
	LJMP	E4YY
EP22:   JB      ARGF,EP4        ;MUST BE AN OPERATOR, IF SET
	ACALL	VAR		;IS THE VALUE A VARIABLE?
	JNC	EP3		;PUT VARIABLE ON STACK
	;
	ACALL	CONST		;IS THE VALUE A NUMERIC CONSTANT?
	JNC	EP4		;IF SO, CONTINUE, IF NOT, SEE WHAT
	CALL	GC		;GET THE CHARACTER
	CJNE	A,#T_LPAR,EP4	;SEE IF A LEFT PAREN
	MOV	A,#(LOW OPBOL+1)
	SJMP	XLPAR		;PROCESS THE LEFT PAREN
	;
EP3:	ACALL	PUSHAS		;SAVE VAR ON STACK
	;
EP4:	ACALL	GC		;GET THE OPERATOR
	;
        CJNE    A,#T_LPAR,EP41  ;IS IT AN OPERATOR
EP41:   JNC     XOP             ;PROCESS OPERATOR
        CJNE    A,#T_UOP,EP42   ;IS IT A UNARY OPERATOR
EP42:   JNC     XBILT           ;PROCESS UNARY (BUILT IN) OPERATOR
	POP	R2B0		;GET BACK PREVIOUS OPERATOR PRECEDENCE
	JB	ARGF,ITRET	;OK IF ARG FLAG IS SET
	;
EP5:	CLR	C		;NO RECOVERY
        LJMP    E1XX1
	;
	; Process the operator
	;
XOP:	ANL	A,#1FH		;STRIP OFF THE TOKE BITS
	JB	ARGF,XOP1	;IF ARG FLAG IS SET, PROCESS
	CJNE	A,#T_SUB-T_LPAR,XOP3
	MOV	A,#T_NEG-T_LPAR
	;
$EJECT
XOP1:	ADD	A,#LOW OPBOL+1	;BIAS THE TABLE
	MOV	R2,A
	MOV	DPTR,#00H
	MOVC	A,@A+DPTR	;GET THE CURRENT PRECEDENCE
	MOV	R4,A
	POP	ACC		;GET THE PREVIOUS PRECEDENCE
	MOV	R5,A		;SAVE THE PREVIOUS PRECEDENCE
	MOVC	A,@A+DPTR	;GET IT
        CJNE    A,R4B0,XOP11    ;SEE WHICH HAS HIGHER PRECEDENCE
	CJNE	A,#12,ITRET	;SEE IF ANEG
	SETB	C
XOP11:  JNC     ITRET           ;PROCESS NON-INCREASING PRECEDENCE
	;
	; Save increasing precedence
	;
	PUSH	R5B0		;SAVE OLD PRECEDENCE ADDRESS
	PUSH	R2B0		;SAVE NEW PRECEDENCE ADDRESS
	ACALL	GCI1		;EAT THE OPERATOR
	ACALL	EP1		;EVALUATE REMAINING EXPRESSION
XOP12:  POP     ACC
	;
	; R2 has the action address, now setup and perform operation
	;
XOP2:	MOV	DPTR,#OPTAB
	ADD	A,#LOW (NOT OPBOL)
	CALL	ISTA1		;SET UP TO RETURN TO EP2
	AJMP	EP2		;JUMP TO EVALUATE EXPRESSION
	;
	; Built-in operator processing
	;
XBILT:	ACALL	GCI1		;EAT THE TOKEN
	ADD	A,#LOW (50H+LOW UOPBOL)
	JB	ARGF,EP5	;XBILT MUST COME AFTER AN OPERATOR
        CJNE    A,#STP,XBILT1
XBILT1: JNC     XOP2
	;
XLPAR:	PUSH	ACC		;PUT ADDRESS ON THE STACK
	ACALL	P_E
        SJMP    XOP12           ;PERFORM OPERATION
	;
XOP3:	CJNE	A,#T_ADD-T_LPAR,EP5
	ACALL	GCI1
	AJMP	EP2		;WASTE + SIGN
	;
$EJECT
XPOP:	ACALL	X3120		;FLIP ARGS THEN POP
	;
	;***************************************************************
	;
	; POPAS - Pop arg stack and copy variable to R3:R1
	;
	;***************************************************************
	;
POPAS:	LCALL	INC_ASTKA
	JMP	VARCOP		;COPY THE VARIABLE
	;
AXTAL:	MOV	R2,#HIGH CXTAL
	MOV	R0,#LOW CXTAL
	;
	; fall thru
	;
	;***************************************************************
	;
PUSHAS:	; Push the Value addressed by R2:R0 onto the arg stack
	;
	;***************************************************************
	;
	CALL	DEC_ASTKA
	SETB	ARGF		;SAYS THAT SOMTHING IS ON THE STACK
	LJMP	VARCOP
	;
	;
	;***************************************************************
	;
ST_A:	; Store at expression
	;
	;***************************************************************
	;
	ACALL	ONE		;GET THE EXPRESSION
	SJMP	POPAS		;SAVE IT
	;
	;
	;***************************************************************
	;
LD_A:	; Load at expression
	;
	;***************************************************************
	;
	ACALL	ONE		;GET THE EXPRESSION
	ACALL	X3120		;FLIP ARGS
	SJMP	PUSHAS
	;
$EJECT
	;***************************************************************
	;
CONST:	; Get a constant fron the text
	;
	;***************************************************************
	;
	CALL	GC		;FIRST SEE IF LITERAL
	CJNE	A,#T_ASC,C0C	;SEE IF ASCII TOKEN
	CALL	IGC		;GET THE CHARACTER AFTER TOKEN
	CJNE	A,#'$',CN0	;SEE IF A STRING
	;
CNX:	CALL	CSY		;CALCULATE IT
        JMP     AXBYTE1         ;SAVE IT ON THE STACK
	;
CN0:	CALL	TWO_R2		;PUT IT ON THE STACK
	CALL	GCI1		;BUMP THE POINTER
	JMP	ERPAR		;WASTE THE RIGHT PAREN
	;
	;
C0C:	CALL	DP_T		;GET THE TEXT POINTER
	CALL	GET_NUM		;GET THE NUMBER
	CJNE	A,#0FFH,C1C	;SEE IF NO NUMBER
	SETB	C
C2C:	RET
	;
C1C:	JNZ	FPTST
	CLR	C
	SETB	ARGF
	;
C3C:	JMP	T_DP
	;
FPTST:	ANL	A,#00001011B	;CHECK FOR ERROR
	JZ	C2C		;EXIT IF ZERO
	;
	; Handle the error condition
	;
	MOV	DPTR,#E2X	;DIVIDE BY ZERO
        JNB     ACC.0,FPTST1    ;UNDERFLOW
	MOV	DPTR,#E7X
FPTST1: JNB     ACC.1,FPTS      ;OVERFLOW
	MOV	DPTR,#E11X
	;
FPTS:	JMP	ERROR
	;
$EJECT
	;***************************************************************
	;
	; The Command action routine - LIST
	;
	;***************************************************************
	;
CLIST:	CALL	NUMC		;SEE IF TO LINE PORT
	ACALL	FSTK		;PUT 0FFFFH ON THE STACK
	CALL	INTGER		;SEE IF USER SUPPLIES LN
	CLR	A		;LN = 0 TO START
	MOV	R3,A
	MOV	R1,A
	JC	CL1		;START FROM ZERO
	;
	CALL	TEMPD		;SAVE THE START ADDTESS
	CALL	GCI		;GET THE CHARACTER AFTER LIST
        CJNE    A,#T_SUB,CLIST1 ;CHECK FOR TERMINATION ADDRESS '-'
	ACALL	INC_ASTKA	;WASTE 0FFFFH
	LCALL	INTERR		;GET TERMINATION ADDRESS
	ACALL	TWO_EY		;PUT TERMINATION ON THE ARG STACK
CLIST1: MOV     R3,TEMP5        ;GET THE START ADDTESS
	MOV	R1,TEMP4
	;
CL1:	CALL	GETLIN		;GET THE LINE NO IN R3:R1
	JZ	CL3		;RET IF AT END
	;
CL2:	ACALL	C3C		;SAVE THE ADDRESS
	INC	DPTR		;POINT TO LINE NUMBER
        ACALL   PMTOP1          ;PUT LINE NUMBER ON THE STACK
	ACALL	CMPLK		;COMPARE LN TO END ADDRESS
	JC	CL3		;EXIT IF GREATER
	CALL	BCK		;CHECK FOR A CONTROL C
	ACALL	DEC_ASTKA	;SAVE THE COMPARE ADDRESS
	CALL	DP_T		;RESTORE ADDRESS
	ACALL	UPPL		;UN-PROCESS THE LINE
	ACALL	C3C		;SAVE THE CR ADDRESS
	ACALL	CL6		;PRINT IT
	INC	DPTR		;BUMP POINTER TO NEXT LINE
	MOVX	A,@DPTR		;GET LIN LENGTH
	DJNZ	ACC,CL2		;LOOP
	ACALL	INC_ASTKA	;WASTE THE COMPARE BYTE
	;
CL3:	AJMP	CMND1		;BACK TO COMMAND PROCESSOR
	;
CL6:	MOV	DPTR,#IBUF	;PRINT IBUF
	CALL	PRNTCR		;PRINT IT
	CALL	DP_T
	;
CL7:	JMP	CRLF
	;
UPPL0:  LCALL   X31DP
$EJECT
	;***************************************************************
	;
	;UPPL - UN PREPROCESS A LINE ADDRESSED BY DPTR INTO IBUF
	;       RETURN SOURCE ADDRESS OF CR IN DPTR ON RETURN
	;
	;***************************************************************
	;
UPPL:	MOV	R3,#HIGH IBUF	;POINT R3 AT HIGH IBUF
	MOV	R1,#LOW IBUF	;POINT R1 AT IBUF
	INC	DPTR		;SKIP OVER LINE LENGTH
	ACALL	C3C		;SAVE THE DPTR (DP_T)
	CALL	L20DPI		;PUT LINE NUMBER IN R2:R0
        CALL    FP_BASE8        ;CONVERT R2:R0 TO INTEGER
	CALL	DP_T
	INC	DPTR		;BUMP DPTR PAST THE LINE NUMBER
	;
UPP0:   CJNE    R1,#LOW IBUF+6,UPP01
UPP01:  JC      UPP91           ;PUT SPACES IN TEXT
	INC	DPTR		;BUMP PAST LN HIGH
	MOVX	A,@DPTR		;GET USER TEXT
	MOV	R6,A		;SAVE A IN R6 FOR TOKE COMPARE
	JB	ACC.7,UPP1	;IF TOKEN, PROCESS
        CJNE    A,#20H,UPP02    ;TRAP THE USER TOKENS
UPP02:  JNC     UPP03
	CJNE	A,#CR,UPP1	;DO IT IF NOT A CR
UPP03:  CJNE    A,#'"',UPP9     ;SEE IF STRING
	ACALL	UPP7		;SAVE IT
UPP04:  ACALL   UPP8            ;GET THE NEXT CHARACTER AND SAVE IT
        CJNE    A,#'"',UPP04    ;LOOP ON QUOTES
	SJMP	UPP0
	;
UPP9:	CJNE	A,#':',UPP1A	;PUT A SPACE IN DELIMITER
	ACALL	UPP7A
	MOV	A,R6
	ACALL	UPP7
UPP91:  ACALL   UPP7A
	SJMP	UPP0
	;
UPP1A:  ACALL   UPP81           ;SAVE THE CHARACTER, UPDATE POINTER
	SJMP	UPP0		;EXIT IF A CR, ELSE LOOP
	;
UPP1:	ACALL	C3C		;SAVE THE TEXT POINTER
        MOV     C,XBIT
        MOV     F0,C            ;SAVE XBIT IN F0
UPP11:  MOV     DPTR,#TOKTAB    ;POINT AT TOKEN TABLE
	JNB	F0,UPP2
	LCALL	2078H		;SET UP DPTR FOR LOOKUP
	;
UPP2:	CLR	A		;ZERO A FOR LOOKUP
	MOVC	A,@A+DPTR	;GET TOKEN
	INC	DPTR		;ADVANCE THE TOKEN POINTER
	CJNE	A,#0FFH,UP_2	;SEE IF DONE
        JBC     F0,UPP11        ;NOW DO NORMAL TABLE
	AJMP	CMND1		;EXIT IF NOT FOUND
	;
UP_2:	CJNE	A,R6B0,UPP2	;LOOP UNTIL THE SAME
	;
UP_3:   CJNE    A,#T_UOP,UP_4
UP_4:   JNC     UPP3
	ACALL	UPP7A		;PRINT THE SPACE IF OK
	;
UPP3:	CLR	A		;DO LOOKUP
	MOVC	A,@A+DPTR
	JB	ACC.7,UPP4	;EXIT IF DONE, ELSE SAVE
	JZ	UPP4		;DONE IF ZERO
	ACALL	UPP7		;SAVE THE CHARACTER
	INC	DPTR
	SJMP	UPP3		;LOOP
	;
UPP4:	CALL	DP_T		;GET IT BACK
	MOV	A,R6		;SEE IF A REM TOKEN
	XRL	A,#T_REM
        JNZ     UPP42
UPP41:  ACALL   UPP8
        SJMP    UPP41
UPP42:  JNC     UPP0            ;START OVER AGAIN IF NO TOKEN
	ACALL	UPP7A		;PRINT THE SPACE IF OK
	SJMP	UPP0		;DONE
	;
UPP7A:	MOV	A,#' '		;OUTPUT A SPACE
	;
UPP7:   AJMP    PPL91           ;SAVE A
	;
UPP8:	INC	DPTR
	MOVX	A,@DPTR
UPP81:  CJNE    A,#CR,UPP7
        AJMP    PPL71
	;
$EJECT
	;**************************************************************
	;
	; This table contains all of the floating point constants
	;
	; The constants in ROM are stored "backwards" from the way
	; basic normally treats floating point numbers. Instead of
	; loading from the exponent and decrementing the pointer,
	; ROM constants pointers load from the most significant
	; digits and increment the pointers. This is done to 1) make
	; arg stack loading faster and 2) compensate for the fact that
	; no decrement data pointer instruction exsist.
	;
	; The numbers are stored as follows:
	;
	; BYTE X+5    = MOST SIGNIFICANT DIGITS IN BCD
	; BYTE X+4    = NEXT MOST SIGNIFICANT DIGITS IN BCD
	; BYTE X+3    = NEXT LEAST SIGNIFICANT DIGITS IN BCD
	; BYTE X+2    = LEAST SIGNIFICANT DIGITS IN BCD
	; BYTE X+1    = SIGN OF THE ABOVE MANTISSA 0 = +, 1 = -
	; BYTE X      = EXPONENT IN TWO'S COMPLEMENT BINARY
	;               ZERO EXPONENT = THE NUMBER ZERO
	;
	;**************************************************************
	;
ATTAB:	DB	128-2		; ARCTAN LOOKUP
	DB	00H
	DB	57H
	DB	22H
	DB	66H
	DB	28H
	;
	DB	128-1
	DB	01H
	DB	37H
	DB	57H
	DB	16H
	DB	16H
	;
	DB	128-1
	DB	00H
	DB	14H
	DB	96H
	DB	90H
	DB	42H
	;
	DB	128-1
	DB	01H
	DB	40H
	DB	96H
	DB	28H
	DB	75H
	;
	DB	128
	DB	00H
	DB	64H
	DB	62H
	DB	65H
	DB	10H
	;
	DB	128
	DB	01H
	DB	99H
	DB	88H
	DB	20H
	DB	14H
	;
	DB	128
	DB	00H
	DB	51H
	DB	35H
	DB	99H
	DB	19H
	;
	DB	128
	DB	01H
	DB	45H
	DB	31H
	DB	33H
	DB	33H
	;
	DB	129
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	10H
	;
	DB	0FFH		;END OF TABLE
	;
NTWO:	DB	129
	DB	0
	DB	0
	DB	0
	DB	0
	DB	20H
	;
TTIME:	DB	128-4		; CLOCK CALCULATION
	DB	00H
	DB	00H
	DB	00H
	DB	04H
	DB	13H
	;
$EJECT
	;***************************************************************
	;
	; COSINE - Add pi/2 to stack, then fall thru to SIN
	;
	;***************************************************************
	;
ACOS:	ACALL	POTWO		;PUT PI/2 ON THE STACK
	ACALL	AADD		;TOS = TOS+PI/2
	;
	;***************************************************************
	;
	; SINE - use taylor series to calculate sin function
	;
	;***************************************************************
	;
ASIN:	ACALL	PIPI		;PUT PI ON THE STACK
	ACALL	RV		;REDUCE THE VALUE
	MOV	A,MT2		;CALCULATE THE SIGN
	ANL	A,#01H		;SAVE LSB
	XRL	MT1,A		;SAVE SIGN IN MT1
	ACALL	CSTAKA		;NOW CONVERT TO ONE QUADRANT
	ACALL	POTWO
	ACALL	CMPLK		;DO COMPARE
        JC      ASIN1
	ACALL	PIPI
	ACALL	ASUB
ASIN1:  ACALL   AABS
	MOV	DPTR,#SINTAB	;SET UP LOOKUP TABLE
	ACALL	POLYC		;CALCULATE THE POLY
	ACALL	STRIP
	AJMP	SIN0
	;
	; Put PI/2 on the stack
	;
POTWO:	ACALL	PIPI		;PUT PI ON THE STACK, NOW DIVIDE
	;
DBTWO:	MOV	DPTR,#NTWO
	ACALL	PUSHC
	;MOV	A,#2		;BY TWO
	;ACALL	TWO_R2
	AJMP	ADIV
	;
$EJECT
	;*************************************************************
	;
POLYC:	; Expand a power series to calculate a polynomial
	;
	;*************************************************************
	;
	ACALL	CSTAKA2		;COPY THE STACK
	ACALL	AMUL		;SQUARE THE STACK
	ACALL	POP_T1		;SAVE X*X
	ACALL	PUSHC		;PUT CONSTANT ON STACK
	;
POLY1:	ACALL	PUSH_T1		;PUT COMPUTED VALUE ON STACK
	ACALL	AMUL		;MULTIPLY CONSTANT AND COMPUTED VALUE
	ACALL	PUSHC		;PUT NEXT CONSTANT ON STACK
	ACALL	AADD		;ADD IT TO THE OLD VALUE
	CLR	A		;CHECK TO SEE IF DONE
	MOVC	A,@A+DPTR
	CJNE	A,#0FFH,POLY1	;LOOP UNTIL DONE
	;
AMUL:   LCALL   FP_BASE3
	AJMP	FPTST
	;
	;*************************************************************
	;
RV:	; Reduce a value for Trig and A**X functions
	;
	; value = (value/x - INT(value/x)) * x
	;
	;*************************************************************
	;
        ACALL   C2_T2           ;COPY TOS TO T2
	ACALL	ADIV		;TOS = TOS/TEMP2
	ACALL	AABS		;MAKE THE TOS A POSITIVE NUMBER
	MOV	MT1,A		;SAVE THE SIGN
	ACALL	CSTAKA2		;COPY THE STACK TWICE
	ACALL	IFIX		;PUT THE NUMBER IN R3:R1
	PUSH	R3B0		;SAVE R3
	MOV	MT2,R1		;SAVE THE LS BYTE IN MT2
	ACALL	AINT		;MAKE THE TOS AN INTEGER
	ACALL	ASUB		;TOS = TOS/T2 - INT(TOS/T2)
	ACALL	P_T2		;TOS = T2
	ACALL	AMUL		;TOS = T2*(TOS/T2 - INT(TOS/T2)
	POP	R3B0		;RESTORE R3
	RET			;EXIT
	;
$EJECT
	;**************************************************************
	;
	; TAN
	;
	;**************************************************************
	;
ATAN:	ACALL	CSTAKA		;DUPLACATE STACK
	ACALL	ASIN		;TOS = SIN(X)
	ACALL	SWAP_ASTKA	;TOS = X
	ACALL	ACOS		;TOS = COS(X)
	AJMP	ADIV		;TOS = SIN(X)/COS(X)
	;
STRIP:	ACALL	SETREG		;SETUP R0
	MOV	R3,#1		;LOOP COUNT
        AJMP    AI11            ;WASTE THE LSB
	;
	;************************************************************
	;
	; ARC TAN
	;
	;************************************************************
	;
AATAN:	ACALL	AABS
	MOV	MT1,A		;SAVE THE SIGN
	ACALL	SETREG		;GET THE EXPONENT
	ADD	A,#7FH		;BIAS THE EXPONENT
	MOV	UBIT,C		;SAVE CARRY STATUS
        JNC     AATAN1          ;SEE IF > 1
	ACALL	RECIP		;IF > 1, TAKE RECIP
AATAN1: MOV     DPTR,#ATTAB     ;SET UP TO CALCULATE THE POLY
	ACALL	POLYC		;CALCULATE THE POLY
	JNB	UBIT,SIN0	;JUMP IF NOT SET
	ACALL	ANEG		;MAKE X POLY NEGATIVE
	ACALL	POTWO		;SUBTRACT PI/2
	ACALL	AADD
	;
SIN0:	MOV	A,MT1		;GET THE SIGN
	JZ	SRT
	AJMP	ANEG
	;
$EJECT
	;*************************************************************
	;
	; FCOMP - COMPARE 0FFFFH TO TOS
	;
	;*************************************************************
	;
FCMP:	ACALL	CSTAKA		;COPY THE STACK
	ACALL	FSTK		;MAKE THE TOS = 0FFFFH
	ACALL	SWAP_ASTKA	;NOW COMPARE IS 0FFFFH - X
	;
CMPLK:  JMP     FP_BASE2        ;DO THE COMPARE
	;
	;*************************************************************
	;
DEC_ASTKA:	;Push ARG STACK and check for underflow
	;
	;*************************************************************
	;
	MOV	A,#-FPSIZ
	ADD	A,ASTKA
        CJNE    A,#LOW TM_TOP+6,DEC_ASTKA1
DEC_ASTKA1:
        JC      E4YY
	MOV	ASTKA,A
	MOV	R1,A
	MOV	R3,#ASTKAH
	;
SRT:	RET
	;
E4YY:	MOV	DPTR,#EXA
	AJMP	FPTS		;ARG STACK ERROR
	;
	;
AXTAL3:	ACALL	PUSHC		;PUSH CONSTANT, THEN MULTIPLY
	ACALL	AMUL
	;
	; Fall thru to IFIX
	;
$EJECT
	;***************************************************************
	;
IFIX:	; Convert a floating point number to an integer, put in R3:R1
	;
	;***************************************************************
	;
	CLR	A		;RESET THE START
	MOV	R3,A
	MOV	R1,A
	MOV	R0,ASTKA	;GET THE ARG STACK
	MOV	P2,#ASTKAH
	MOVX	A,@R0		;READ EXPONENT
	CLR	C
	SUBB	A,#81H		;BASE EXPONENT
	MOV	R4,A		;SAVE IT
	DEC	R0		;POINT AT SIGN
	MOVX	A,@R0		;GET THE SIGN
	JNZ	SQ_ERR		;ERROR IF NEGATIVE
	JC	INC_ASTKA	;EXIT IF EXPONENT IS < 81H
	INC	R4		;ADJUST LOOP COUNTER
	MOV	A,R0		;BUMP THE POINTER REGISTER
	SUBB	A,#FPSIZ-1
	MOV	R0,A
	;
I2:	INC	R0		;POINT AT DIGIT
	MOVX	A,@R0		;GET DIGIT
	SWAP	A		;FLIP
        CALL    FP_BASE10       ;ACCUMULATE
	JC	SQ_ERR
        DJNZ    R4,I21
	SJMP	INC_ASTKA
I21:    MOVX    A,@R0           ;GET DIGIT
        CALL    FP_BASE10
	JC	SQ_ERR
	DJNZ	R4,I2
	;
$EJECT
	;************************************************************
	;
INC_ASTKA:	; Pop the ARG STACK and check for overflow
	;
	;************************************************************
	;
	MOV	A,#FPSIZ	;NUMBER TO POP
        SJMP    SETREG1
	;
SETREG:	CLR	A		;DON'T POP ANYTHING
SETREG1:MOV     R0,ASTKA
	MOV	R2,#ASTKAH
	MOV	P2,R2
	ADD	A,R0
	JC	E4YY
	MOV	ASTKA,A
	MOVX	A,@R0
A_D:	RET
	;
	;************************************************************
	;
	; EBIAS - Bias a number for E to the X calculations
	;
	;************************************************************
	;
EBIAS:	ACALL	PUSH_ONE
	ACALL	RV
	CJNE	R3,#00H,SQ_ERR	;ERROR IF R3 <> 0
        ACALL   C2_T2           ;TEMP 2 GETS FRACTIONS
	ACALL	INC_ASTKA
	ACALL	POP_T1
	ACALL	PUSH_ONE
	;
AELP:	MOV	A,MT2
	JNZ	AEL1
	;
	MOV	A,MT1
	JZ	A_D
	MOV	DPTR,#FPT2-1
	MOVX	@DPTR,A		;MAKE THE FRACTIONS NEGATIVE
	;
RECIP:	ACALL	PUSH_ONE
	ACALL	SWAP_ASTKA
	AJMP	ADIV
	;
AEL1:	DEC	MT2
	ACALL	PUSH_T1
	ACALL	AMUL
	SJMP	AELP
	;
SQ_ERR:	LJMP	E3XX		;LINK TO BAD ARG
	;
$EJECT
	;************************************************************
	;
	; SQUARE ROOT
	;
	;************************************************************
	;
ASQR:	ACALL	AABS		;GET THE SIGN
	JNZ	SQ_ERR		;ERROR IF NEGATIVE
        ACALL   C2_T2           ;COPY VARIABLE TO T2
	ACALL	POP_T1		;SAVE IT IN T1
	MOV	R0,#LOW FPT1
	MOVX	A,@R0		;GET EXPONENT
        JZ      SQR41           ;EXIT IF ZERO
	ADD	A,#128		;BIAS THE EXPONENT
	JNC	SQR1		;SEE IF < 80H
	RR	A
	ANL	A,#127
	SJMP	SQR2
	;
SQR1:	CPL	A		;FLIP BITS
	INC	A
	RR	A
	ANL	A,#127		;STRIP MSB
	CPL	A
	INC	A
	;
SQR2:	ADD	A,#128		;BIAS EXPONENT
	MOVX	@R0,A		;SAVE IT
	;
	; NEWGUESS = ( X/OLDGUESS + OLDGUESS) / 2
	;
SQR4:	ACALL	P_T2		;TOS = X
	ACALL	PUSH_T1		;PUT NUMBER ON STACK
	ACALL	ADIV		;TOS = X/GUESS
	ACALL	PUSH_T1		;PUT ON AGAIN
	ACALL	AADD		;TOS = X/GUESS + GUESS
	ACALL	DBTWO		;TOS = ( X/GUESS + GUESS ) / 2
	ACALL	TEMP_COMP	;SEE IF DONE
	JNB	F0,SQR4
	;
SQR41:  AJMP    PUSH_T1         ;PUT THE ANSWER ON THE STACK
	;
$EJECT
	;*************************************************************
	;
	; NATURAL LOG
	;
	;*************************************************************
	;
ALN:	ACALL	AABS		;MAKE SURE THAT NUM IS POSITIVE
	JNZ	SQ_ERR		;ERROR IF NOT
	MOV	MT2,A		;CLEAR FOR LOOP
	INC	R0		;POINT AT EXPONENT
	MOVX	A,@R0		;READ THE EXPONENT
	JZ	SQ_ERR		;ERROR IF EXPONENT IS ZERO
        CJNE    A,#81H,ALN1     ;SEE IF NUM >= 1
ALN1:   MOV     UBIT,C          ;SAVE CARRY STATUS
        JC      ALNL            ;TAKE RECIP IF >= 1
	ACALL	RECIP
	;
	; Loop to reduce
	;
ALNL:	ACALL	CSTAKA		;COPY THE STACK FOR COMPARE
	ACALL	PUSH_ONE	;COMPARE NUM TO ONE
	ACALL	CMPLK
	JNC	ALNO		;EXIT IF DONE
	ACALL	SETREG		;GET THE EXPONENT
	ADD	A,#85H		;SEE HOW BIG IT IS
	JNC	ALN11		;BUMP BY EXP(11) IF TOO SMALL
	ACALL	PLNEXP		;PUT EXP(1) ON STACK
	MOV	A,#1		;BUMP COUNT
	;
ALNE:	ADD	A,MT2
	JC	SQ_ERR
	MOV	MT2,A
	ACALL	AMUL		;BIAS THE NUMBER
	SJMP	ALNL
	;
ALN11:	MOV	DPTR,#EXP11	;PUT EXP(11) ON STACK
	ACALL	PUSHC
	MOV	A,#11
	SJMP	ALNE
	;
$EJECT
ALNO:   ACALL   C2_T2           ;PUT NUM IN TEMP 2
	ACALL	PUSH_ONE	;TOS = 1
	ACALL	ASUB		;TOS = X - 1
	ACALL	P_T2		;TOS = X
	ACALL	PUSH_ONE	;TOS = 1
	ACALL	AADD		;TOS = X + 1
	ACALL	ADIV		;TOS = (X-1)/(X+1)
	MOV	DPTR,#LNTAB	;LOG TABLE
	ACALL	POLYC
	INC	DPTR		;POINT AT LN(10)
	ACALL	PUSHC
	ACALL	AMUL
	MOV	A,MT2		;GET THE COUNT
	ACALL	TWO_R2		;PUT IT ON THE STACK
	ACALL	ASUB		;INT - POLY
	ACALL	STRIP
	JNB	UBIT,AABS
	;
LN_D:	RET
	;
	;*************************************************************
	;
TEMP_COMP:	; Compare FPTEMP1 to TOS, FPTEMP1 gets TOS
	;
	;*************************************************************
	;
	ACALL	PUSH_T1		;SAVE THE TEMP
	ACALL	SWAP_ASTKA	;TRADE WITH THE NEXT NUMBER
	ACALL	CSTAKA		;COPY THE STACK
	ACALL	POP_T1		;SAVE THE NEW NUMBER
        JMP     FP_BASE2        ;DO THE COMPARE
	;
$EJECT
AETOX:	ACALL	PLNEXP		;EXP(1) ON TOS
	ACALL	SWAP_ASTKA	;X ON TOS
	;
AEXP:	;EXPONENTIATION
	;
	ACALL	EBIAS		;T1=BASE,T2=FRACTIONS,TOS=INT MULTIPLIED
	MOV	DPTR,#FPT2	;POINT AT FRACTIONS
	MOVX	A,@DPTR		;READ THE EXP OF THE FRACTIONS
	JZ	LN_D		;EXIT IF ZERO
	ACALL	P_T2		;TOS = FRACTIONS
	ACALL	PUSH_T1		;TOS = BASE
	ACALL	SETREG		;SEE IF BASE IS ZERO
        JZ      AEXP1
	ACALL	ALN		;TOS = LN(BASE)
AEXP1:  ACALL   AMUL            ;TOS = FRACTIONS * LN(BASE)
	ACALL	PLNEXP		;TOS = EXP(1)
	ACALL	SWAP_ASTKA	;TOS = FRACTIONS * LN(BASE)
	ACALL	EBIAS		;T2 = FRACTIONS, TOS = INT MULTIPLIED
	MOV	MT2,#00H	;NOW CALCULATE E**X
	ACALL	PUSH_ONE
	ACALL	CSTAKA
	ACALL	POP_T1		;T1 = 1
	;
AEXL:	ACALL	P_T2		;TOS = FRACTIONS
	ACALL	AMUL		;TOS = FRACTIONS * ACCUMLATION
	INC	MT2		;DO THE DEMONIATOR
	MOV	A,MT2
	ACALL	TWO_R2
	ACALL	ADIV
	ACALL	CSTAKA		;SAVE THE ITERATION
	ACALL	PUSH_T1		;NOW ACCUMLATE
	ACALL	AADD		;ADD ACCUMLATION
	ACALL	TEMP_COMP
	JNB	F0,AEXL		;LOOP UNTIL DONE
	;
	ACALL	INC_ASTKA
	ACALL	PUSH_T1
	ACALL	AMUL		;LAST INT MULTIPLIED
	;
MU1:	AJMP	AMUL		;FIRST INT MULTIPLIED
	;
$EJECT
	;***************************************************************
	;
	; integer operator - INT
	;
	;***************************************************************
	;
AINT:	ACALL	SETREG		;SET UP THE REGISTERS, CLEAR CARRY
	SUBB	A,#129		;SUBTRACT EXPONENT BIAS
	JNC	AI1		;JUMP IF ACC > 81H
	;
	; Force the number to be a zero
	;
	ACALL	INC_ASTKA	;BUMP THE STACK
	;
P_Z:	MOV	DPTR,#ZRO	;PUT ZERO ON THE STACK
	AJMP	PUSHC
	;
AI1:	SUBB	A,#7
	JNC	AI3
	CPL	A
	INC	A
	MOV	R3,A
AI11:   DEC     R0              ;POINT AT SIGN
	;
AI2:	DEC	R0		;NOW AT LSB'S
	MOVX	A,@R0		;READ BYTE
	ANL	A,#0F0H		;STRIP NIBBLE
	MOVX	@R0,A		;WRITE BYTE
        DJNZ    R3,AI21
	RET
AI21:   CLR     A
	MOVX	@R0,A		;CLEAR THE LOCATION
	DJNZ	R3,AI2
	;
AI3:	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
AABS:	; Absolute value - Make sign of number positive
	;                  return sign in ACC
	;
	;***************************************************************
	;
	ACALL	ANEG		;CHECK TO SEE IF + OR -
	JNZ	ALPAR		;EXIT IF NON ZERO, BECAUSE THE NUM IS
	MOVX	@R0,A		;MAKE A POSITIVE SIGN
	RET
	;
	;***************************************************************
	;
ASGN:	; Returns the sign of the number 1 = +, -1 = -
	;
	;***************************************************************
	;
	ACALL	INC_ASTKA	;POP STACK, GET EXPONENT
	JZ	P_Z		;EXIT IF ZERO
	DEC	R0		;BUMP TO SIGN
	MOVX	A,@R0		;GET THE SIGN
	MOV	R7,A		;SAVE THE SIGN
	ACALL	PUSH_ONE	;PUT A ONE ON THE STACK
	MOV	A,R7		;GET THE SIGN
	JZ	ALPAR		;EXIT IF ZERO
	;
	; Fall thru to ANEG
	;
	;***************************************************************
	;
ANEG:	; Flip the sign of the number on the tos
	;
	;***************************************************************
	;
	ACALL	SETREG
	DEC	R0		;POINT AT THE SIGN OF THE NUMBER
	JZ	ALPAR		;EXIT IF ZERO
	MOVX	A,@R0
	XRL	A,#01H		;FLIP THE SIGN
	MOVX	@R0,A
	XRL	A,#01H		;RESTORE THE SIGN
	;
ALPAR:	RET
	;
$EJECT
	;***************************************************************
	;
ACBYTE:	; Read the ROM
	;
	;***************************************************************
	;
	ACALL	IFIX		;GET EXPRESSION
	CALL	X31DP		;PUT R3:R1 INTO THE DP
	CLR	A
	MOVC	A,@A+DPTR
	AJMP	TWO_R2
	;
	;***************************************************************
	;
ADBYTE:	; Read internal memory
	;
	;***************************************************************
	;
	ACALL	IFIX		;GET THE EXPRESSION
	CALL	R3CK		;MAKE SURE R3 = 0
	MOV	A,@R1
	AJMP	TWO_R2
	;
	;***************************************************************
	;
AXBYTE: ; Read external memory
	;
	;***************************************************************
	;
	ACALL	IFIX		;GET THE EXPRESSION
AXBYTE1:MOV     P2,R3
	MOVX	A,@R1
	AJMP	TWO_R2
	;
$EJECT
	;***************************************************************
	;
	; The relational operators - EQUAL                        (=)
	;                            GREATER THAN                 (>)
	;                            LESS THAN                    (<)
	;                            GREATER THAN OR EQUAL        (>=)
	;                            LESS THAN OR EQUAL           (<=)
	;                            NOT EQUAL                    (<>)
	;
	;***************************************************************
	;
AGT:	ACALL	CMPLK
	ORL	C,F0		;SEE IF EITHER IS A ONE
AGT1:   JC      P_Z
	;
FSTK:	MOV	DPTR,#FS
	AJMP	PUSHC
	;
FS:	DB	85H
	DB	00H
	DB	00H
	DB	50H
	DB	53H
	DB	65H
	;
ALT:	ACALL	CMPLK
ALT1:   CPL     C
        SJMP    AGT1
	;
AEQ:	ACALL	CMPLK
AEQ1:   MOV     C,F0
        SJMP    ALT1
	;
ANE:	ACALL	CMPLK
	CPL	F0
        SJMP    AEQ1
	;
AGE:	ACALL	CMPLK
        SJMP    AGT1
	;
ALE:	ACALL	CMPLK
	ORL	C,F0
        SJMP    ALT1
	;
$EJECT
	;***************************************************************
	;
ARND:	; Generate a random number
	;
	;***************************************************************
	;
	MOV	DPTR,#RCELL	;GET THE BINARY SEED
	CALL	L31DPI
	MOV	A,R1
	CLR	C
	RRC	A
	MOV	R0,A
	MOV	A,#6
	RRC	A
	ADD	A,R1
	XCH	A,R0
	ADDC	A,R3
	MOV	R2,A
	DEC	DPL		;SAVE THE NEW SEED
	ACALL	S20DP
	ACALL	TWO_EY
	ACALL	FSTK
	;
ADIV:   LCALL   FP_BASE4
	AJMP	FPTST
	;
$EJECT
	;***************************************************************
	;
SONERR:	; ON ERROR Statement
	;
	;***************************************************************
	;
	LCALL	INTERR		;GET THE LINE NUMBER
	SETB	ON_ERR
	MOV	DPTR,#ERRNUM	;POINT AT THR ERROR LOCATION
	SJMP	S20DP
	;
	;
	;**************************************************************
	;
SONEXT:	; ON EXT1 Statement
	;
	;**************************************************************
	;
	LCALL	INTERR
	SETB	INTBIT
	ORL	IE,#10000100B	;ENABLE INTERRUPTS
	MOV	DPTR,#INTLOC
	;
S20DP:	MOV	A,R2		;SAVE R2:R0 @DPTR
	MOVX	@DPTR,A
	INC	DPTR
	MOV	A,R0
	MOVX	@DPTR,A
	RET
	;
$EJECT
	;***************************************************************
	;
	; CASTAK - Copy and push another top of arg stack
	;
	;***************************************************************
	;
CSTAKA2:ACALL	CSTAKA		;COPY STACK TWICE
	;
CSTAKA:	ACALL	SETREG		;SET UP R2:R0
        SJMP    PUSH_T12
	;
PLNEXP:	MOV	DPTR,#EXP1
	;
	;***************************************************************
	;
	; PUSHC - Push constant on to the arg stack
	;
	;***************************************************************
	;
PUSHC:	ACALL	DEC_ASTKA
	MOV	P2,R3
	MOV	R3,#FPSIZ	;LOOP COUNTER
	;
PCL:	CLR	A		;SET UP A
	MOVC	A,@A+DPTR	;LOAD IT
	MOVX	@R1,A		;SAVE IT
	INC	DPTR		;BUMP POINTERS
	DEC	R1
	DJNZ	R3,PCL		;LOOP
	;
	SETB	ARGF
	RET			;EXIT
	;
PUSH_ONE:;
	;
	MOV	DPTR,#FPONE
	AJMP	PUSHC
	;
$EJECT
	;
POP_T1:
	;
	MOV	R3,#HIGH FPT1
	MOV	R1,#LOW FPT1
	JMP	POPAS
	;
PUSH_T1:
	;
	MOV	R0,#LOW FPT1
PUSH_T11:
        MOV     R2,#HIGH FPT1
PUSH_T12:
        LJMP    PUSHAS
	;
P_T2:	MOV	R0,#LOW FPT2
        SJMP    PUSH_T11                ;JUMP TO PUSHAS
	;
	;****************************************************************
	;
SWAP_ASTKA:	; SWAP TOS<>TOS-1
	;
	;****************************************************************
	;
	ACALL	SETREG		;SET UP R2:R0 AND P2
	MOV	A,#FPSIZ	;PUT TOS+1 IN R1
	MOV	R2,A
	ADD	A,R0
	MOV	R1,A
	;
S_L:	MOVX	A,@R0
	MOV	R3,A
	MOVX	A,@R1
	MOVX	@R0,A
	MOV	A,R3
	MOVX	@R1,A
	DEC	R1
	DEC	R0
	DJNZ	R2,S_L
	RET
	;
$EJECT
	;
C2_T2:  ACALL   SETREG          ;SET UP R2:R0
	MOV	R3,#HIGH FPT2
	MOV	R1,#LOW FPT2	;TEMP VALUE
	;
	; Fall thru
	;
	;***************************************************************
	;
	; VARCOP - Copy a variable from R2:R0 to R3:R1
	;
	;***************************************************************
	;
VARCOP:	MOV	R4,#FPSIZ	;LOAD THE LOOP COUNTER
	;
V_C:	MOV	P2,R2		;SET UP THE PORTS
	MOVX	A,@R0		;READ THE VALUE
	MOV	P2,R3		;PORT TIME AGAIN
	MOVX	@R1,A		;SAVE IT
	ACALL	DEC3210		;BUMP POINTERS
	DJNZ	R4,V_C		;LOOP
	RET			;EXIT
	;
PIPI:	MOV	DPTR,#PIE
	AJMP	PUSHC
	;
$EJECT
	;***************************************************************
	;
	; The logical operators ANL, ORL, XRL, NOT
	;
	;***************************************************************
	;
AANL:	ACALL	TWOL		;GET THE EXPRESSIONS
	MOV	A,R3		;DO THE AND
	ANL	A,R7
	MOV	R2,A
	MOV	A,R1
	ANL	A,R6
	SJMP	TWO_EX
	;
AORL:	ACALL	TWOL		;SAME THING FOR OR
	MOV	A,R3
	ORL	A,R7
	MOV	R2,A
	MOV	A,R1
	ORL	A,R6
	SJMP	TWO_EX
	;
ANOT:	ACALL	FSTK		;PUT 0FFFFH ON THE STACK
	;
AXRL:	ACALL	TWOL
	MOV	A,R3
	XRL	A,R7
	MOV	R2,A
	MOV	A,R1
	XRL	A,R6
	SJMP	TWO_EX
	;
TWOL:	ACALL	IFIX
	MOV	R7,R3B0
	MOV	R6,R1B0
	AJMP	IFIX
	;
$EJECT
	;*************************************************************
	;
AGET:	; READ THE BREAK BYTE AND PUT IT ON THE ARG STACK
	;
	;*************************************************************
	;
	MOV	DPTR,#GTB	;GET THE BREAK BYTE
	MOVX	A,@DPTR
	JBC	GTRD,TWO_R2
	CLR	A
	;
TWO_R2:	MOV	R2,#00H		;ACC GOES TO STACK
	;
	;
TWO_EX:	MOV	R0,A		;R2:ACC GOES TO STACK
	;
	;
TWO_EY:	SETB	ARGF		;R2:R0 GETS PUT ON THE STACK
        JMP     FP_BASE12       ;DO IT
	;
$EJECT
	;*************************************************************
	;
	; Put directs onto the stack
	;
	;**************************************************************
	;
A_IE:	MOV	A,IE		;IE
	SJMP	TWO_R2
	;
A_IP:	MOV	A,IP		;IP
	SJMP	TWO_R2
	;
ATIM0:	MOV	R2,TH0		;TIMER 0
	MOV	R0,TL0
	SJMP	TWO_EY
	;
ATIM1:	MOV	R2,TH1		;TIMER 1
	MOV	R0,TL1
	SJMP	TWO_EY
	;
ATIM2:  MOV     R2,TH2
        MOV     R0,TL2
;       DB      0AAH            ;MOV R2 DIRECT OP CODE
;       DB      0CDH            ;T2 HIGH
;       DB      0A8H            ;MOV R0 DIRECT OP CODE
;       DB      0CCH            ;T2 LOW
	SJMP	TWO_EY		;TIMER 2
	;
AT2CON: MOV     A,T2CON
;       DB      0E5H            ;MOV A,DIRECT OPCODE
;       DB      0C8H            ;T2CON LOCATION
	SJMP	TWO_R2
	;
ATCON:	MOV	A,TCON		;TCON
	SJMP	TWO_R2
	;
ATMOD:	MOV	A,TMOD		;TMOD
	SJMP	TWO_R2
	;
ARCAP2: MOV     R2,RCAPH2
        MOV     R0,RCAPL2
;       DB      0AAH            ;MOV R2, DIRECT OP CODE
;       DB      0CBH            ;RCAP2H LOCATION
;       DB      0A8H            ;MOV R0, DIRECT OP CODE
;       DB      0CAH            ;R2CAPL LOCATION
	SJMP	TWO_EY
	;
AP1:	MOV	A,P1		;GET P1
	SJMP	TWO_R2		;PUT IT ON THE STACK
	;
APCON:  MOV     A,PCON
;       DB      0E5H            ;MOV A, DIRECT OP CODE
;       DB      87H             ;ADDRESS OF PCON
	SJMP	TWO_R2		;PUT PCON ON THE STACK
	;
$EJECT
	;***************************************************************
	;
	;THIS IS THE LINE EDITOR
	;
	;TAKE THE PROCESSED LINE IN IBUF AND INSERT IT INTO THE
	;BASIC TEXT FILE.
	;
	;***************************************************************
	;
LINE0:  LJMP    NOGO            ;CAN'T EDIT A ROM
	;
LINE:	MOV	A,BOFAH
        CJNE    A,#HIGH PSTART,LINE0
	CALL	G4		;GET END ADDRESS FOR EDITING
	MOV	R4,DPL
	MOV	R5,DPH
	MOV	R3,TEMP5	;GET HIGH ORDER IBLN
	MOV	R1,TEMP4	;LOW ORDER IBLN
	;
	CALL	GETLIN		;FIND THE LINE
	JNZ	INSR		;INSERT IF NOT ZERO, ELSE APPEND
	;
	;APPEND THE LINE AT THE END
	;
	MOV	A,TEMP3		;PUT IBCNT IN THE ACC
        CJNE    A,#4H,LINE1     ;SEE IF NO ENTRY
	RET			;RET IF NO ENTRY
	;
LINE1:  ACALL   FULL            ;SEE IF ENOUGH SPACE LEFT
	MOV	R2,R5B0		;PUT END ADDRESS A INTO TRANSFER
	MOV	R0,R4B0		;REGISTERS
	ACALL	IMOV		;DO THE BLOCK MOVE
	;
UE:	MOV	A,#EOF		;SAVE EOF CHARACTER
	AJMP	TBR
	;
	;INSERT A LINE INTO THE FILE
	;
INSR:	MOV	R7,A		;SAVE IT IN R7
	CALL	TEMPD		;SAVE INSERATION ADDRESS
	MOV	A,TEMP3		;PUT THE COUNT LENGTH IN THE ACC
	JC	LTX		;JUMP IF NEW LINE # NOT = OLD LINE #
        CJNE    A,#04H,INSR1    ;SEE IF NULL
	CLR	A
	;
INSR1:  SUBB    A,R7            ;SUBTRACT LINE COUNT FROM ACC
	JZ	LIN1		;LINE LENGTHS EQUAL
	JC	GTX		;SMALLER LINE
	;
$EJECT
	;
	;EXPAND FOR A NEW LINE OR A LARGER LINE
	;
LTX:	MOV	R7,A		;SAVE A IN R7
	MOV	A,TEMP3		;GET THE COUNT IN THE ACC
        CJNE    A,#04H,LTX1     ;DO NO INSERTATION IF NULL LINE
	RET			;EXIT IF IT IS
	;
LTX1:   MOV     A,R7            ;GET THE COUNT BACK - DELTA IN A
	ACALL	FULL		;SEE IF ENOUGH MEMORY NEW EOFA IN R3:R1
	CALL	DTEMP		;GET INSERATION ADDRESS
	ACALL	NMOV		;R7:R6 GETS (EOFA)-DPTR
	CALL	X3120
	MOV	R1,R4B0		;EOFA LOW
	MOV	R3,R5B0		;EOFA HIGH
	INC	R6		;INCREMENT BYTE COUNT
        CJNE    R6,#00,LTX2     ;NEED TO BUMP HIGH BYTE?
	INC	R7
	;
LTX2:   ACALL   RMOV            ;GO DO THE INSERTION
	SJMP	LIN1		;INSERT THE CURRENT LINE
	;
GTX:	CPL	A		;FLIP ACC
	INC	A		;TWOS COMPLEMENT
	CALL	ADDPTR		;DO THE ADDITION
	ACALL	NMOV		;R7:R6 GETS (EOFA)-DPTR
	MOV	R1,DPL		;SET UP THE REGISTERS
	MOV	R3,DPH
	MOV	R2,TEMP5	;PUT INSERTATION ADDRESS IN THE RIGHT REG
	MOV	R0,TEMP4
        JZ      GTX1            ;IF ACC WAS ZERO FROM NMOV, JUMP
	ACALL	LMOV		;IF NO ZERO DO A LMOV
	;
GTX1:   ACALL   UE              ;SAVE NEW END ADDRESS
	;
LIN1:	MOV	R2,TEMP5	;GET THE INSERTATION ADDRESS
	MOV	R0,TEMP4
	MOV	A,TEMP3		;PUT THE COUNT LENGTH IN ACC
	CJNE	A,#04H,IMOV	;SEE IF NULL
	RET			;EXIT IF NULL
$EJECT
	;***************************************************************
	;
	;INSERT A LINE AT ADDRESS R2:R0
	;
	;***************************************************************
	;
IMOV:	CLR	A		;TO SET UP
	MOV	R1,#LOW IBCNT	;INITIALIZE THE REGISTERS
	MOV	R3,A
	MOV	R6,TEMP3	;PUT THE BYTE COUNT IN R6 FOR LMOV
	MOV	R7,A		;PUT A 0 IN R7 FOR LMOV
	;
	;***************************************************************
	;
	;COPY A BLOCK FROM THE BEGINNING
	;
	;R2:R0 IS THE DESTINATION ADDRESS
	;R3:R1 IS THE SOURCE ADDRESS
	;R7:R6 IS THE COUNT REGISTER
	;
	;***************************************************************
	;
LMOV:	ACALL	TBYTE		;TRANSFER THE BYTE
	ACALL	INC3210		;BUMP THE POINTER
	ACALL	DEC76		;BUMP R7:R6
	JNZ	LMOV		;LOOP
	RET			;GO BACK TO CALLING ROUTINE
	;
INC3210:INC	R0
        CJNE    R0,#00H,INC3211
	INC	R2
	;
INC3211:INC     R1
        CJNE    R1,#00H,INC3212
	INC	R3
INC3212:RET
	;
$EJECT
	;***************************************************************
	;
	;COPY A BLOCK STARTING AT THE END
	;
	;R2:R0 IS THE DESTINATION ADDRESS
	;R3:R1 IS THE SOURCE ADDRESS
	;R6:R7 IS THE COUNT REGISTER
	;
	;***************************************************************
	;
RMOV:	ACALL	TBYTE		;TRANSFER THE BYTE
	ACALL	DEC3210		;DEC THE LOCATIONS
	ACALL	DEC76		;BUMP THE COUNTER
	JNZ	RMOV		;LOOP
	;
DEC_R:	NOP			;CREATE EQUAL TIMING
	RET			;EXIT
	;
DEC3210:DEC	R0		;BUMP THE POINTER
        CJNE    R0,#0FFH,DEC3212;SEE IF OVERFLOWED
DEC3211:DEC     R2              ;BUMP THE HIGH BYTE
DEC3212:DEC     R1              ;BUMP THE POINTER
	CJNE	R1,#0FFH,DEC_R	;SEE IF OVERFLOWED
	DEC	R3		;CHANGE THE HIGH BYTE
	RET			;EXIT
	;
	;***************************************************************
	;
	;TBYTE - TRANSFER A BYTE
	;
	;***************************************************************
	;
TBYTE:	MOV	P2,R3		;OUTPUT SOURCE REGISTER TO PORT
	MOVX	A,@R1		;PUT BYTE IN ACC
	;
TBR:	MOV	P2,R2		;OUTPUT DESTINATION TO PORT
	MOVX	@R0,A		;SAVE THE BYTE
	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
	;NMOV - R7:R6 = END ADDRESS - DPTR
	;
	;ACC GETS CLOBBERED
	;
	;***************************************************************
	;
NMOV:	MOV	A,R4		;THE LOW BYTE OF EOFA
	CLR	C		;CLEAR THE CARRY FOR SUBB
	SUBB	A,DPL		;SUBTRACT DATA POINTER LOW
	MOV	R6,A		;PUT RESULT IN R6
	MOV	A,R5		;HIGH BYTE OF EOFA
	SUBB	A,DPH		;SUBTRACT DATA POINTER HIGH
	MOV	R7,A		;PUT RESULT IN R7
	ORL	A,R6		;SEE IF ZERO
NMOV1:  RET                     ;EXIT
	;
	;***************************************************************
	;
	;CHECK FOR A FILE OVERFLOW
	;LEAVES THE NEW END ADDRESS IN R3:R1
	;A HAS THE INCREASE IN SIZE
	;
	;***************************************************************
	;
FULL:	ADD	A,R4		;ADD A TO END ADDRESS
	MOV	R1,A		;SAVE IT
	CLR	A
	ADDC	A,R5		;ADD THE CARRY
	MOV	R3,A
	MOV	DPTR,#VARTOP	;POINT AT VARTOP
	;
FUL1:	CALL	DCMPX		;COMPARE THE TWO
        JC      NMOV1           ;OUT OF ROOM
	;
TB:	MOV	DPTR,#E5X	;OUT OF MEMORY
	AJMP	FPTS
	;
$EJECT
	;***************************************************************
	;
	; PP - Preprocesses the line in IBUF back into IBUF
	;      sets F0 if no line number
	;      leaves the correct length of processed line in IBCNT
	;      puts the line number in IBLN
	;      wastes the text address TXAL and TXAH
	;
	;***************************************************************
	;
PP:	ACALL	T_BUF		;TXA GETS IBUF
	CALL	INTGER		;SEE IF A NUMBER PRESENT
	CALL	TEMPD		;SAVE THE INTEGER IN TEMP5:TEMP4
	MOV	F0,C		;SAVE INTEGER IF PRESENT
	MOV	DPTR,#IBLN	;SAVE THE LINE NUMBER, EVEN IF NONE
	ACALL	S20DP
	MOV	R0,TXAL		;TEXT POINTER
	MOV	R1,#LOW IBUF	;STORE POINTER
	;
	; Now process the line back into IBUF
	;
PPL:	CLR	ARGF		;FIRST PASS DESIGNATOR
	MOV	DPTR,#TOKTAB	;POINT DPTR AT LOOK UP TABLE
	;
PPL1:	MOV	R5B0,R0		;SAVE THE READ POINTER
	CLR	A		;ZERO A FOR LOOKUP
	MOVC	A,@A+DPTR	;GET THE TOKEN
	MOV	R7,A		;SAVE TOKEN IN CASE OF MATCH
	;
PPL2:	MOVX	A,@R0		;GET THE USER CHARACTER
	MOV	R3,A		;SAVE FOR REM
        CJNE    A,#'a',PPL21
PPL21:  JC      PPX             ;CONVERT LOWER TO UPPER CASE
        CJNE    A,#('z'+1),PPL22
PPL22:  JNC     PPX
	CLR	ACC.5
	;
PPX:	MOV	R2,A
	MOVX	@R0,A		;SAVE UPPER CASE
	INC	DPTR		;BUMP THE LOOKUP POINTER
	CLR	A
	MOVC	A,@A+DPTR
	CJNE	A,R2B0,PPL3	;LEAVE IF NOT THE SAME
	INC	R0		;BUMP THE USER POINTER
	SJMP	PPL2		;CONTINUE TO LOOP
	;
PPL3:	JB	ACC.7,PPL6	;JUMP IF FOUND MATCH
	JZ	PPL6		;USER MATCH
	;
	;
	; Scan to the next TOKTAB entry
	;
PPL4:	INC	DPTR		;ADVANCE THE POINTER
	CLR	A		;ZERO A FOR LOOKUP
	MOVC	A,@A+DPTR	;LOAD A WITH TABLE
        JB      ACC.7,PPL41     ;KEEP SCANNING IF NOT A RESERVED WORD
	JNZ	PPL4
	INC	DPTR
	;
	; See if at the end of TOKTAB
	;
PPL41:  MOV     R0,R5B0         ;RESTORE THE POINTER
	CJNE	A,#0FFH,PPL1	;SEE IF END OF TABLE
	;
	; Character not in TOKTAB, so see what it is
	;
	CJNE	R2,#' ',PPLX	;SEE IF A SPACE
	INC	R0		;BUMP USER POINTER
	SJMP	PPL		;TRY AGAIN
	;
PPLX:	JNB	XBIT,PPLY	;EXTERNAL TRAP
	JB	ARGF,PPLY
	SETB	ARGF		;SAYS THAT THE USER HAS TABLE
	LCALL	2078H		;SET UP POINTER
	AJMP	PPL1
	;
PPLY:	ACALL	PPL7		;SAVE CHARACTER, EXIT IF A CR
	CJNE	A,#'"',PPL	;SEE IF QUOTED STRING, START AGAIN IF NOT
	;
	; Just copy a quoted string
	;
PPLY1:  ACALL   PPL7            ;SAVE THE CHARACTER, TEST FOR CR
        CJNE    A,#'"',PPLY1    ;IS THERE AN ENDQUOTE, IF NOT LOOP
	SJMP	PPL		;DO IT AGAIN IF ENDQUOTE
	;
PPL6:	MOV	A,R7		;GET THE TOKEN
        ACALL   PPL91           ;SAVE THE TOKEN
	CJNE	A,#T_REM,PPL	;SEE IF A REM TOKEN
	MOV	A,R3
        ACALL   PPL71           ;WASTE THE REM STATEMENT
PPL61:  ACALL   PPL7            ;LOOP UNTIL A CR
        SJMP    PPL61
	;
PPL7:	MOVX	A,@R0		;GET THE CHARACTER
PPL71:  CJNE    A,#CR,PPL9      ;FINISH IF A CR
	POP	R0B0		;WASTE THE CALLING STACK
	POP	R0B0
	MOVX	@R1,A		;SAVE CR IN MEMORY
	INC	R1		;SAVE A TERMINATOR
	MOV	A,#EOF
	MOVX	@R1,A
	MOV	A,R1		;SUBTRACT FOR LENGTH
	SUBB	A,#4
	MOV	TEMP3,A		;SAVE LENGTH
	MOV	R1,#LOW IBCNT	;POINT AT BUFFER COUNT
	;
PPL9:	INC	R0
PPL91:  MOVX    @R1,A           ;SAVE THE CHARACTER
	INC	R1		;BUMP THE POINTERS
	RET			;EXIT TO CALLING ROUTINE
	;
	;
	;***************************************************************
	;
	;DEC76 - DECREMENT THE REGISTER PAIR R7:R6
	;
	;ACC = ZERO IF R7:R6 = ZERO ; ELSE ACC DOES NOT
	;
	;***************************************************************
	;
DEC76:	DEC	R6		;BUMP R6
        CJNE    R6,#0FFH,DEC77  ;SEE IF RAPPED AROUND
	DEC	R7
DEC77:  MOV     A,R7            ;SEE IF ZERO
	ORL	A,R6
	RET			;EXIT
	;
	;***************************************************************
	;
	; MTOP - Get or Put the top of assigned memory
	;
	;***************************************************************
	;
PMTOP:	MOV	DPTR,#MEMTOP
PMTOP1: CALL    L20DPI
	AJMP	TWO_EY		;PUT R2:R0 ON THE STACK
	;
$EJECT
	;*************************************************************
	;
	; AXTAL - Crystal value calculations
	;
	;*************************************************************
	;
AXTAL0:	MOV	DPTR,#XTALV	;CRYSTAL VALUE
	ACALL	PUSHC
	;
AXTAL1:	ACALL	CSTAKA2		;COPY CRYSTAL VALUE TWICE
	ACALL	CSTAKA
	MOV	DPTR,#PTIME	;PROM TIMER
	ACALL	AXTAL2
	MOV	DPTR,#PROGS
	ACALL	S31L
	MOV	DPTR,#IPTIME	;IPROM TIMER
	ACALL	AXTAL2
	MOV	DPTR,#IPROGS
	ACALL	S31L
	MOV	DPTR,#TTIME	;CLOCK CALCULATION
	ACALL	AXTAL3
	MOV	A,R1
	CPL	A
	INC	A
	MOV	SAVE_T,A
	MOV	R3,#HIGH CXTAL
	MOV	R1,#LOW CXTAL
	JMP	POPAS
	;
AXTAL2:	ACALL	AXTAL3
	;
CBIAS:	;Bias the crystal calculations
	;
	MOV	A,R1		;GET THE LOW COUNT
	CPL	A		;FLIP IT FOR TIMER LOAD
	ADD	A,#15		;BIAS FOR CALL AND LOAD TIMES
	MOV	R1,A		;RESTORE IT
	MOV	A,R3		;GET THE HIGH COUNT
	CPL	A		;FLIP IT
	ADDC	A,#00H		;ADD THE CARRY
	MOV	R3,A		;RESTORE IT
	RET
	;
$EJECT
;$INCLUDE(:F2:BAS52.PWM)
;BEGINNING
	;**************************************************************
	;
STONE:	; Toggle the I/O port
	;
	;**************************************************************
	;
	CALL	THREE		;GET THE NUMBERS
	ACALL	CBIAS		;BIAS R3:R1 FOR COUNT LOOP
	;
STONE1:	CLR	T_BIT		;TOGGLE THE BIT
	CLR	TR1		;STOP THE TIMER
	MOV	TH1,R3		;LOAD THE TIMER
	MOV	TL1,R1
	CLR	TF1		;CLEAR THE OVERFLOW FLAG
	SETB	TR1		;TURN IT ON
	ACALL	DEC76
	JNB	TF1,$		;WAIT
	ACALL	ALPAR
	SETB	T_BIT		;BACK TO A ONE
        CALL    TIMER_LOAD1     ;LOAD THE HIGH VALUE
	JNB	TF1,$		;WAIT
	JNZ	STONE1		;LOOP
	RET
	;

;END
;$INCLUDE(:F2:BAS52.PWM)
$EJECT
	;LNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLN
	;
LNTAB:	; Natural log lookup table
	;
	;LNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLNLN
	;
	DB	80H
	DB	00H
	DB	71H
	DB	37H
	DB	13H
	DB	19H
	;
	DB	7FH
	DB	00H
	DB	76H
	DB	64H
	DB	37H
	DB	94H
	;
	DB	80H
	DB	00H
	DB	07H
	DB	22H
	DB	75H
	DB	17H
	;
	DB	80H
	DB	00H
	DB	52H
	DB	35H
	DB	93H
	DB	28H
	;
	DB	80H
	DB	00H
	DB	71H
	DB	91H
	DB	85H
	DB	86H
	;
	DB	0FFH
	;
	DB	81H
	DB	00H
	DB	51H
	DB	58H
	DB	02H
	DB	23H
	;
$EJECT
	;SINSINSINSINSINSINSINSINSINSINSINSINSINSINSINSINSIN
	;
SINTAB:	; Sin lookup table
	;
	;SINSINSINSINSINSINSINSINSINSINSINSINSINSINSINSINSIN
	;
	DB	128-9
	DB	00H
	DB	44H
	DB	90H
	DB	05H
	DB	16H
	;
	DB	128-7
	DB	01H
	DB	08H
	DB	21H
	DB	05H
	DB	25H
	;
	DB	128-5
	DB	00H
	DB	19H
	DB	73H
	DB	55H
	DB	27H
	;
$EJECT
	;
	DB	128-3
	DB	01H
	DB	70H
	DB	12H
	DB	84H
	DB	19H
	;
	DB	128-2
	DB	00H
	DB	33H
	DB	33H
	DB	33H
	DB	83H
	;
	DB	128
	DB	01H
	DB	67H
	DB	66H
	DB	66H
	DB	16H
	;
FPONE:	DB	128+1
	DB	00H
	DB	00H
	DB	00H
	DB	00H
	DB	10H
	;
	DB	0FFH		;END OF TABLE
	;
$EJECT
	;
SBAUD:	CALL	AXTAL		;PUT CRYSTAL ON THE STACK
	CALL	EXPRB		;PUT THE NUMBER AFTER BAUD ON STACK
	MOV	A,#12
	ACALL	TWO_R2		;TOS = 12
	ACALL	AMUL		;TOS = 12*BAUD
	ACALL	ADIV		;TOS = XTAL/(12*BAUD)
	ACALL	IFIX
	ACALL	CBIAS
	MOV	DPTR,#SPV
	;
S31L:	JMP	S31DP
	;
AFREE:	CALL	PMTOP		;PUT MTOP ON STACK
	CALL	G4		;GET END ADDRESS
	MOV	R0,DPL
	MOV	R2,DPH
	ACALL	TWO_EY
	;
ASUB:   LCALL   FP_BASE1        ;DO FP SUB
	AJMP	FPTST
	;
ALEN:	CALL	CCAL		;CALCULATE THE LEN OF THE SELECTED PROGRAM
	MOV	R2,R7B0		;SAVE THE HIGH BYTE
	MOV	A,R6		;SAVE THE LOW BYTE
	AJMP	TWO_EX		;PUT IT ON THE STACK
	;
ATIME:	MOV	C,EA		;SAVE INTERRUTS
	CLR	EA
	PUSH	MILLIV		;SAVE MILLI VALUE
	MOV	R2,TVH		;GET THE TIMER
	MOV	A,TVL
	MOV	EA,C		;SAVE INTERRUPTS
	ACALL	TWO_EX		;PUT TIMER ON THE STACK
	POP	ACC		;GET MILLI
	ACALL	TWO_R2		;PUT MILLI ON STACK
	MOV	A,#200
	ACALL	TWO_R2		;DIVIDE MILLI BY 200
	ACALL	ADIV
	;
AADD:	LCALL	FP_BASE		;DO FP ADDITION
	AJMP	FPTST		;CHECK FOR ERRORS
	;
$EJECT
	;**************************************************************
	;
	; Here are some error messages that were moved
	;
	;**************************************************************
	;
	;
E1X:	DB	'BAD SYNTAX"'
E2X:	DB	128+10
	DB	'DIVIDE BY ZERO"'
	;
E6X:	DB	'ARRAY SIZE"'
	;
$EJECT
	;**************************************************************
	;
T_BUF:	; TXA gets IBUF
	;
	;**************************************************************
	;
	MOV	TXAH,#HIGH IBUF
	MOV	TXAL,#LOW IBUF
	RET
	;
	;
	;***************************************************************
	;
CXFER:	; Transfer a program from rom to ram
	;
	;***************************************************************
	;
	CALL	CCAL		;GET EVERYTHING SET UP
	MOV	R2,#HIGH PSTART
	MOV	R0,#LOW PSTART
	ACALL	LMOV		;DO THE TRANSFER
	CALL	RCLEAR		;CLEAR THE MEMORY
	;
	; Fall thru to CRAM
	;
	;***************************************************************
	;
CRAM:	; The command action routine - RAM - Run out of ram
	;
	;***************************************************************
	;
	CLR	CONB		;CAN'T CONTINUE IF MODE CHANGE
	MOV	BOFAH,#HIGH PSTART
	MOV	BOFAL,#LOW PSTART
	;
	; Fall thru to Command Processor
	;
$EJECT
	;***************************************************************
	;
CMND1:	; The entry point for the command processor
	;
	;***************************************************************
	;
        LCALL   SPRINT1         ;WASTE AT AND HEX
	CLR	XBIT		;TO RESET IF NEEDED
	CLR	A
	MOV	DPTR,#2002H	;CHECK FOR EXTERNAL TRAP PACKAGE
	MOVC	A,@A+DPTR
        CJNE    A,#5AH,CMND11
	LCALL	2048H		;IF PRESENT JUMP TO LOCATION 200BH
CMND11: MOV     DPTR,#RDYS      ;PRINT THE READY MESSAGE
	CALL	CRP		;DO A CR, THEN, PRINT FROM THE ROM
	;
CMNDR:	SETB	DIRF		;SET THE DIRECT INPUT BIT
	MOV	SP,SPSAV	;LOAD THE STACK
	ACALL	CL7		;DO A CRLF
	;
CMNX:	CLR	GTRD		;CLEAR BREAK
	MOV	DPTR,#5EH	;DO RUN TRAP
	MOVX	A,@DPTR
	XRL	A,#52
        JNZ     CMNX1
	LJMP	CRUN
CMNX1:  MOV     R5,#'>'         ;OUTPUT A PROMPT
	LCALL	TEROT
	CALL	INLINE		;INPUT A LINE INTO IBUF
	CALL	PP		;PRE-PROCESS THE LINE
	JB	F0,CMND3	;NO LINE NUMBER
	CALL	LINE		;PROCESS THE LINE
	LCALL	LCLR
	JB	LINEB,CMNX	;DON'T CLEAR MEMORY IF NO NEED
	SETB	LINEB
	LCALL	RCLEAR		;CLEAR THE MEMORY
	SJMP	CMNX		;LOOP BACK
	;
CMND3:	CALL	T_BUF		;SET UP THE TEXT POINTER
	CALL	DELTST		;GET THE CHARACTER
	JZ	CMNDR		;IF CR, EXIT
	MOV	DPTR,#CMNDD	;POINT AT THE COMMAND LOOKUP
        CJNE    A,#T_CMND,CMND31;PROCESS STATEMENT IF NOT A COMMAND
CMND31: JC      CMND5
	CALL	GCI1		;BUMP TXA
	ANL	A,#0FH		;STRIP MSB'S FOR LOOKUP
	LCALL	ISTA1		;PROCESS COMMAND
	SJMP	CMNDR
	;
CMND5:	LJMP	ILOOP		;CHECK FOR A POSSIBLE BREAK
	;
	;
	;
	;CONSTANTS
	;
XTALV:	DB	128+8		; DEFAULT CRYSTAL VALUE
	DB	00H
	DB	00H
	DB	92H
	DB	05H
	DB	11H
	;
EXP11:	DB	85H
	DB	00H
	DB	42H
	DB	41H
	DB	87H
	DB	59H
	;
EXP1:	DB	128+1		; EXP(1)
	DB	00H
	DB	18H
	DB	28H
	DB	18H
	DB	27H
	;
IPTIME:	DB	128-4		;FPROG TIMING
	DB	00H
	DB	00H
	DB	00H
	DB	75H
	DB	83H
	;
PIE:	DB	128+1		;PI
	DB	00H
	DB	26H
	DB	59H
	DB	41H
	DB	31H		; 3.1415926
	;
$EJECT
	;***************************************************************
	;
	; The error messages, some have been moved
	;
	;***************************************************************
	;
E7X:	DB	128+30
	DB	'ARITH. UNDERFLOW"'
	;
E5X:	DB	'MEMORY ALLOCATION"'
	;
E3X:	DB	128+40
	DB	'BAD ARGUMENT"'
	;
EXI:	DB	'I-STACK"'
	;
$EJECT
	;***************************************************************
	;
	; The command action routine - CONTINUE
	;
	;***************************************************************
	;
CCONT:	MOV	DPTR,#E15X
	JNB	CONB,ERROR	;ERROR IF CONTINUE IS NOT SET
	;
CC1:	;used for input statement entry
	;
	MOV	TXAH,INTXAH	;RESTORE TXA
	MOV	TXAL,INTXAL
	JMP	CILOOP		;EXECUTE
	;
DTEMP:	MOV	DPH,TEMP5	;RESTORE DPTR
	MOV	DPL,TEMP4
	RET
	;
TEMPD:	MOV	TEMP5,DPH
	MOV	TEMP4,DPL
	RET
	;
$EJECT
	;**************************************************************
	;
I_DL:	; IDLE
	;
	;**************************************************************
	;
	JB	DIRF,E1XX	;SYNTAX ERROR IN DIRECT INPUT
	CLR	DACK		;ACK IDLE
	;
U_ID1:  ORL     PCON,#01H
;       DB      01000011B       ;ORL DIRECT OP CODE
;       DB      87H             ;PCON ADDRESS
;       DB      01H             ;SET IDLE BIT
	JB	INTPEN,I_RET	;EXIT IF EXTERNAL INTERRUPT
	JBC	U_IDL,I_RET	;EXIT IF USER WANTS TO
	JNB	OTS,U_ID1	;LOOP IF TIMER NOT ENABLED
	LCALL	T_CMP		;CHECK THE TIMER
	JC	U_ID1		;LOOP IF TIME NOT BIG ENOUGH
	;
I_RET:	SETB	DACK		;RESTORE EXECUTION
	RET			;EXIT IF IT IS
	;
	;
	;
ER0:	INC	DPTR		;BUMP TO TEXT
	JB	DIRF,ERROR0	;CAN'T GET OUT OF DIRECT MODE
	JNB	ON_ERR,ERROR0	;IF ON ERROR ISN'T SET, GO BACK
	MOV	DPTR,#ERRLOC	;SAVE THE ERROR CODE
	CALL	RC2		;SAVE ERROR AND SET UP THE STACKS
	INC	DPTR		;POINT AT ERRNUM
	JMP	ERL4		;LOAD ERR NUM AND EXIT
	;
$EJECT
	;
	; Syntax error
	;
E1XX:	MOV	C,DIRF		;SEE IF IN DIRECT MODE
E1XX1:  MOV     DPTR,#E1X       ;ERROR MESSAGE
        SJMP    ERROR1          ;TRAP ON SET DIRF
	;
E1XX2:  MOV     DPTR,#EXI       ;STACK ERROR
	;
	; Falls through
	;
	;***************************************************************
	;
	;ERROR PROCESSOR - PRINT OUT THE ERROR TYPE, CHECK TO SEE IF IN
	;                  RUN OR COMMAND MODE, FIND AND PRINT OUT THE
	;                  LINE NUMBER IF IN RUN MODE
	;
	;***************************************************************
	;
ERROR:	CLR	C		;RESET STACK
ERROR1: MOV     SP,SPSAV        ;RESET THE STACK
        LCALL   SPRINT1         ;CLEAR LINE AND AT MODE
	CLR	A		;SET UP TO GET ERROR CODE
	MOVC	A,@A+DPTR
	JBC	ACC.7,ER0	;PROCESS ERROR
	;
ERROR0:	ACALL	TEMPD		;SAVE THE DATA POINTER
        JC      ERROR01         ;NO RESET IF CARRY IS SET
	LCALL	RC1		;RESET THE STACKS
ERROR01:CALL    CRLF2           ;DO TWO CARRIAGE RET - LINE FEED
	MOV	DPTR,#ERS	;OUTPUT ERROR MESSAGE
	CALL	ROM_P
	CALL	DTEMP		;GET THE ERROR MESSAGE BACK
	;
ERRS:	CALL	ROM_P		;PRINT ERROR TYPE
	JNB	DIRF,ER1	;DO NOT PRINT IN LINE IF DIRF=1
	;
SERR1:	CLR	STOPBIT		;PRINT STOP THEN EXIT, FOR LIST
	JMP	CMND1
	;
ER1:	MOV	DPTR,#INS	;OUTPUT IN LINE
	CALL	ROM_P
	;
	;NOW, FIND THE LINE NUMBER
	;
	;
$EJECT
	;
	;
	CALL	DP_B		;GET THE FIRST ADDRESS OF THE PROGRAM
	CLR	A		;FOR INITIALIZATION
	;
ER2:	ACALL	TEMPD		;SAVE THE DPTR
	CALL	ADDPTR		;ADD ACC TO DPTR
	ACALL	ER4		;R3:R1 = TXA-DPTR
        JC      ER3             ;EXIT IF DPTR>TXA
	JZ	ER3		;EXIT IF DPTR=TXA
	MOVX	A,@DPTR		;GET LENGTH
	CJNE	A,#EOF,ER2	;SEE IF AT THE END
	;
ER3:	ACALL	DTEMP		;PUT THE LINE IN THE DPTR
	ACALL	ER4		;R3:R1 = TXA - BEGINNING OF LINE
	MOV	A,R1		;GET LENGTH
  	ADD	A,#10		;ADD 10 TO LENGTH, DPTR STILL HAS ADR
	MOV	MT1,A		;SAVE THE COUNT
	INC	DPTR		;POINT AT LINE NUMBER HIGH BYTE
        CALL    PMTOP1          ;LOAD R2:R0, PUT IT ON THE STACK
        ACALL   FP_BASE7        ;OUTPUT IT
	JB	STOPBIT,SERR1	;EXIT IF STOP BIT SET
	CALL	CRLF2		;DO SOME CRLF'S
	CALL	DTEMP
	CALL	UPPL		;UNPROCESS THE LINE
	CALL	CL6		;PRINT IT
ER31:   MOV     R5,#'-'         ;OUTPUT DASHES, THEN AN X
	ACALL	T_L		;PRINT AN X IF ERROR CHARACTER FOUND
        DJNZ    MT1,ER31        ;LOOP UNTIL DONE
	MOV	R5,#'X'
	ACALL	T_L
	AJMP	SERR1
	;
ER4:	MOV	R3,TXAH		;GET TEXT POINTER AND PERFORM SUBTRACTION
	MOV	R1,TXAL
	JMP	DUBSUB
	;
$EJECT
	;**************************************************************
	;
	; Interrupt driven timer
	;
	;**************************************************************
	;
I_DR:	MOV	TH0,SAVE_T	;LOAD THE TIMER
	XCH	A,MILLIV	;SAVE A, GET MILLI COUNTER
	INC	A		;BUMP COUNTER
	CJNE	A,#200,TR	;CHECK OUT TIMER VALUE
	CLR	A		;FORCE ACC TO BE ZERO
	INC	TVL		;INCREMENT LOW TIMER
	CJNE	A,TVL,TR	;CHECK LOW VALUE
	INC	TVH		;BUMP TIMER HIGH
	;
TR:	XCH	A,MILLIV
	POP	PSW
	RETI
	;
$EJECT
;$INCLUDE(:F2:BAS52.CLK)
;BEGINNING
	;**************************************************************
	;
	; The statement action routine - CLOCK
	;
	;**************************************************************
	;
SCLOCK:	ACALL	OTST		;GET CHARACTER AFTER CLOCK TOKEN
	CLR	ET0
	CLR	C_BIT
	JNC	SC_R		;EXIT IF A ZERO
	ANL	TMOD,#0F0H	;SET UP THE MODE
	SETB	C_BIT		;USER INTERRUPTS
	ORL	IE,#82H		;ENABLE ET0 AND EA
	SETB	TR0		;TURN ON THE TIMER
	;
SC_R:	RET
	;

;END
;$INCLUDE(:F2:BAS52.CLK)
	;***************************************************************
	;
SUI:	; Statement USER IN action routine
	;
	;***************************************************************
	;
	ACALL	OTST
	MOV	CIUB,C		;SET OR CLEAR CIUB
	RET
	;
	;***************************************************************
	;
SUO:	; Statement USER OUT action routine
	;
	;***************************************************************
	;
	ACALL	OTST
	MOV	COUB,C
	RET
	;
OTST:	; Check for a one
	;
	LCALL	GCI		;GET THE CHARACTER, CLEARS CARRY
	SUBB	A,#'1'		;SEE IF A ONE
	CPL	C		;SETS CARRY IF ONE, CLEARS IT IF ZERO
OTST1:  RET
	;
$EJECT
	;**************************************************************
	;
	; IBLK - EXECUTE USER SUPPLIED TOKEN
	;
	;**************************************************************
	;
IBLK:   JB      PSW.4,OTST1     ;EXIT IF REGISTER BANK <> 0
        JB      PSW.3,OTST1
        JBC     ACC.7,IBLK1     ;SEE IF BIT SEVEN IS SET
	MOV	DPTR,#USENT	;USER ENTRY LOCATION
	LJMP	ISTA1
	;
IBLK1:  JB      ACC.0,FP_BASE6  ;FLOATING POINT INPUT
	JZ	T_L		;DO OUTPUT ON 80H
	MOV	DPTR,#FP_BASE-2
	JMP	@A+DPTR
	;
	;
	;**************************************************************
	;
	; GET_NUM - GET A NUMBER, EITHER HEX OR FLOAT
	;
	;**************************************************************
	;
GET_NUM:ACALL   FP_BASE5        ;SCAN FOR HEX
        JNC     FP_BASE6        ;DO FP INPUT
	;
        ACALL   FP_BASE9        ;ASCII STRING TO R2:R0
	JNZ	H_RET
	PUSH	DPH		;SAVE THE DATA_POINTER
	PUSH	DPL
        ACALL   FP_BASE12       ;PUT R2:R0 ON THE STACK
	POP	DPL		;RESTORE THE DATA_POINTER
	POP	DPH
	CLR	A		;NO ERRORS
	RET			;EXIT
	;
$EJECT

	; START OF BAUD RATE MODIFICATIONS BY DANIEL WALLNER
TIB1:MOV	ACC,TL2
	JB	ACC.3,TIB1
	CALL    DEC3211
TIB2:	MOV	ACC,TL2
	JNB	ACC.3,TIB2
	JNB	RXD,TIB1		;16x12 CLOCKS, LOOP UNTIL DONE
	JB	RXD,$		;WAIT FOR STOP CHARACTER TO END
	RET

	;**************************************************************
	;
	; WB - THE EGO MESSAGE
	;
	;**************************************************************
	;
WB:
;	DB	'W'+80H,'R'+80H
;	DB	'I'+80H,'T'+80H,'T','E'+80H,'N'+80H
;	DB	' ','B'+80H,'Y'+80H,' '
;	DB	'J'+80H,'O'+80H,'H'+80H,'N'+80H,' '+80H
;	DB	'K','A'+80H,'T'+80H,'A'+80H,'U'+80H
;	DB	'S','K'+80H,'Y'+80H

	; END OF BAUD RATE MODIFICATIONS BY DANIEL WALLNER

	DB	', I','N'+80H,'T'+80H,'E'+80H,'L'+80H
	DB	' '+80H,'C'+80H,'O'+80H,'R'+80H,'P'+80H
	DB	'. 1','9'+80H,'85'
H_RET:	RET
	;
$EJECT
	ORG	1990H
	;
OUTPUT:
T_L:    LJMP    TEROT
	;
        ORG     1F78H
	;
CKS_I:	JB	CKS_B,CS_I
	LJMP	401BH
	;
CS_I:	LJMP	2088H
	;
E14X:	DB	'NO DATA"'
	;
E11X:	DB	128+20
	DB	'ARITH. OVERFLOW"'
	;
E16X:	DB	'PROGRAMMING"'
	;
E15X:	DB	'CAN'
	DB	27H
	DB	'T CONTINUE"'
	;
E10X:	DB	'INVALID LINE NUMBER"'
	;
NOROM:	DB	'PROM MODE"'
	;
S_N:	DB	'*MCS-51(tm) BASIC V1.1*"'
	;
	ORG	1FF8H
	;
ERS:	DB	'ERROR: "'
	;
$EJECT


;************************************************************
;
; This is a complete BCD floating point package for the 8051 micro-
; controller. It provides 8 digits of accuracy with exponents that
; range from +127 to -127. The mantissa is in packed BCD, while the
; exponent is expressed in pseudo-twos complement. A ZERO exponent
; is used to express the number ZERO. An exponent value of 80H or
; greater than means the exponent is positive, i.e. 80H = E 0,
; 81H = E+1, 82H = E+2 and so on. If the exponent is 7FH or less,
; the exponent is negative, 7FH = E-1, 7EH = E-2, and so on.
; ALL NUMBERS ARE ASSUMED TO BE NORMALIZED and all results are
; normalized after calculation. A normalized mantissa is >=.10 and
; <=.99999999.
;
; The numbers in memory assumed to be stored as follows:
;
; EXPONENT OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE
; SIGN OF ARGUMENT 2       =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-1
; DIGIT 78 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-2
; DIGIT 56 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-3
; DIGIT 34 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-4
; DIGIT 12 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-5
;
; EXPONENT OF ARGUMENT 1   =   VALUE OF ARG_STACK
; SIGN OF ARGUMENT 1       =   VALUE OF ARG_STACK-1
; DIGIT 78 OF ARGUMENT 1   =   VALUE OF ARG_STACK-2
; DIGIT 56 OF ARGUMENT 1   =   VALUE OF ARG_STACK-3
; DIGIT 34 OF ARGUMENT 1   =   VALUE OF ARG_STACK-4
; DIGIT 12 OF ARGUMENT 1   =   VALUE OF ARG_STACK-5
;
; The operations are performed thusly:
;
; ARG_STACK+FP_NUMBER_SIZE = ARG_STACK+FP_NUMBER_SIZE # ARG_STACK
;
; Which is ARGUMENT 2 = ARGUMENT 2 # ARGUMENT 1
;
; Where # can be ADD, SUBTRACT, MULTIPLY OR DIVIDE.
;
; Note that the stack gets popped after an operation.
;
; The FP_COMP instruction POPS the ARG_STACK TWICE and returns status.
;
;**********************************************************************
;
$EJECT
;**********************************************************************
;
; STATUS ON RETURN - After performing an operation (+, -, *, /)
;                    the accumulator contains the following status
;
; ACCUMULATOR - BIT 0 - FLOATING POINT UNDERFLOW OCCURED
;
;             - BIT 1 - FLOATING POINT OVERFLOW OCCURED
;
;             - BIT 2 - RESULT WAS ZER0
;
;             - BIT 3 - DIVIDE BY ZERO ATTEMPTED
;
;             - BIT 4 - NOT USED, 0 RETURNED
;
;             - BIT 5 - NOT USED, 0 RETURNED
;
;             - BIT 6 - NOT USED, 0 RETURNED
;
;             - BIT 7 - NOT USED, 0 RETURNED
;
; NOTE: When underflow occures, a ZERO result is returned.
;       When overflow or divide by zero occures, a result of
;       .99999999 E+127 is returned and it is up to the user
;       to handle these conditions as needed in the program.
;
; NOTE: The Compare instruction returns F0 = 0 if ARG 1 = ARG 2
;       and returns a CARRY FLAG = 1 if ARG 1 is > ARG 2
;
;***********************************************************************
;
$EJECT
;***********************************************************************
;
; The following values MUST be provided by the user
;
;***********************************************************************
;
ARG_STACK	EQU	9	;ARGUMENT STACK POINTER
ARG_STACK_PAGE	EQU	1
;OUTPUT          EQU     1990H   ;CALL LOCATION TO OUTPUT A CHARACTER
CONVERT         EQU     58H     ;LOCATION TO CONVERT NUMBERS
INTGRC          BIT     25      ;BIT SET IF INTGER ERROR
;
;***********************************************************************
;
; The following equates are used internally
;
;***********************************************************************
;
FP_NUMBER_SIZE	EQU	6
UNDERFLOW	EQU	0
OVERFLOW	EQU	1
ZERO		EQU	2
ZERO_DIVIDE	EQU	3
;
;***********************************************************************
$EJECT
	;**************************************************************
	;
	; The following internal locations are used by the math pack
	; ordering is important and the FP_DIGITS must be bit
	; addressable
	;
	;***************************************************************
	;
FP_STATUS	EQU	28H		;NOT USED
FP_TEMP		EQU	FP_STATUS+1	;NOT USED
FP_CARRY	EQU	FP_STATUS+2	;USED FOR BITS
ADD_IN		BIT	35		;DCMPXZ IN BASIC BACKAGE
XSIGN		BIT	FP_CARRY.0
FOUND_RADIX	BIT	FP_CARRY.1
FIRST_RADIX	BIT	FP_CARRY.2
DONE_LOAD	BIT	FP_CARRY.3
FP_DIG12	EQU	FP_CARRY+1
FP_DIG34	EQU	FP_CARRY+2
FP_DIG56	EQU	FP_CARRY+3
FP_DIG78	EQU	FP_CARRY+4
FP_SIGN		EQU	FP_CARRY+5
MSIGN		BIT	FP_SIGN.0
FP_EXP		EQU	FP_CARRY+6
FP_NIB1		EQU	FP_DIG12
FP_NIB2		EQU	FP_NIB1+1
FP_NIB3		EQU	FP_NIB1+2
FP_NIB4		EQU	FP_NIB1+3
FP_NIB5		EQU	FP_NIB1+4
FP_NIB6		EQU	FP_NIB1+5
FP_NIB7		EQU	FP_NIB1+6
FP_NIB8		EQU	FP_NIB1+7
FP_ACCX		EQU	FP_NIB1+8
FP_ACCC		EQU	FP_NIB1+9
FP_ACC1		EQU	FP_NIB1+10
FP_ACC2		EQU	FP_NIB1+11
FP_ACC3		EQU	FP_NIB1+12
FP_ACC4		EQU	FP_NIB1+13
FP_ACC5		EQU	FP_NIB1+14
FP_ACC6		EQU	FP_NIB1+15
FP_ACC7		EQU	FP_NIB1+16
FP_ACC8		EQU	FP_NIB1+17
FP_ACCS		EQU	FP_NIB1+18
	;
$EJECT
	ORG	1993H
	;
	;**************************************************************
	;
	; The floating point entry points and jump table
	;
	;**************************************************************
	;
FP_BASE:        AJMP    FLOATING_ADD
FP_BASE1:       AJMP    FLOATING_SUB
FP_BASE2:       AJMP    FLOATING_COMP
FP_BASE3:       AJMP    FLOATING_MUL
FP_BASE4:       AJMP    FLOATING_DIV
FP_BASE5:       AJMP    HEXSCAN
FP_BASE6:       AJMP    FLOATING_POINT_INPUT
FP_BASE7:       AJMP    FLOATING_POINT_OUTPUT
FP_BASE8:       AJMP    CONVERT_BINARY_TO_ASCII_STRING
FP_BASE9:       AJMP    CONVERT_ASCII_STRING_TO_BINARY
FP_BASE10:      AJMP    MULNUM10
FP_BASE11:      AJMP    HEXOUT
FP_BASE12:      AJMP    PUSHR2R0
	;
$EJECT
	;
FLOATING_SUB:
	;
	MOV	P2,#ARG_STACK_PAGE
	MOV	R0,ARG_STACK
	DEC	R0		;POINT TO SIGN
	MOVX	A,@R0		;READ SIGN
	CPL	ACC.0
	MOVX	@R0,A
	;
	;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	;
FLOATING_ADD:
	;
	;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	;
	;
	ACALL 	MDES1		;R7=TOS EXP, R6=TOS-1 EXP, R4=TOS SIGN
				;R3=TOS-1 SIGN, OPERATION IS R1 # R0
	;
	MOV	A,R7		;GET TOS EXPONENT 
	JZ	POP_AND_EXIT	;IF TOS=0 THEN POP AND EXIT
	CJNE	R6,#0,LOAD1	;CLEAR CARRY EXIT IF ZERO
	;
	;**************************************************************
	;
SWAP_AND_EXIT:	; Swap external args and return
	;
	;**************************************************************
	;
	ACALL	LOAD_POINTERS
	MOV	R7,#FP_NUMBER_SIZE
	;
SE1:	MOVX	A,@R0		;SWAP THE ARGUMENTS
	MOVX	@R1,A
	DEC	R0
	DEC	R1
	DJNZ	R7,SE1
	;
POP_AND_EXIT:
	;
	MOV	A,ARG_STACK	;POP THE STACK
	ADD	A,#FP_NUMBER_SIZE
	MOV	ARG_STACK,A
	CLR	A
	RET
	;
	;
LOAD1:	SUBB	A,R6		;A = ARG 1 EXP - ARG 2 EXP
	MOV	FP_EXP,R7	;SAVE EXPONENT AND SIGN
	MOV	FP_SIGN,R4
	JNC	LOAD2		;ARG1 EXPONENT IS LARGER OR SAME
	MOV	FP_EXP,R6
	MOV	FP_SIGN,R3
	CPL	A
	INC	A		;COMPENSATE FOR EXP DELTA
	XCH	A,R0		;FORCE R0 TO POINT AT THE LARGEST
	XCH	A,R1		;EXPONENT
	XCH	A,R0
	;
LOAD2:	MOV	R7,A		;SAVE THE EXPONENT DELTA IN R7
	CLR	ADD_IN
        CJNE    R5,#0,LOAD21
	SETB	ADD_IN
	;
$EJECT
	; Load the R1 mantissa
	;
LOAD21: ACALL   LOADR1_MANTISSA ;LOAD THE SMALLEST NUMBER
	;
	; Now align the number to the delta exponent
	; R4 points to the string of the last digits lost
	;
        CJNE    R7,#DIGIT+DIGIT+3,LOAD22
LOAD22: JC      LOAD23
	MOV	R7,#DIGIT+DIGIT+2
	;
LOAD23: MOV     FP_CARRY,#00    ;CLEAR THE CARRY
	ACALL	RIGHT		;SHIFT THE NUMBER
	;
	; Set up for addition and subtraction
	;
	MOV	R7,#DIGIT	;LOOP COUNT
	MOV	R1,#FP_DIG78
	MOV	A,#9EH
	CLR	C
	SUBB	A,R4
	DA	A
	XCH	A,R4
        JNZ     LOAD24
	MOV	R4,A
LOAD24: CJNE    A,#50H,LOAD25   ;TEST FOR SUBTRACTION
LOAD25: JNB     ADD_IN,SUBLP    ;DO SUBTRACTION IF NO ADD_IN
	CPL	C		;FLIP CARRY FOR ADDITION
	ACALL	ADDLP		;DO ADDITION
	;
	JNC	ADD_R
	INC	FP_CARRY
	MOV	R7,#1
	ACALL	RIGHT
	ACALL	INC_FP_EXP	;SHIFT AND BUMP EXPONENT
	;
ADD_R:	AJMP	STORE_ALIGN_TEST_AND_EXIT
	;
ADDLP:	MOVX	A,@R0
	ADDC	A,@R1
	DA	A
	MOV	@R1,A
	DEC	R0
	DEC	R1
	DJNZ	R7,ADDLP	;LOOP UNTIL DONE
	RET
	;
$EJECT
	;
SUBLP:	MOVX	A,@R0		;NOW DO SUBTRACTION
	MOV	R6,A
	CLR	A
	ADDC	A,#99H
	SUBB	A,@R1
	ADD	A,R6
	DA	A
	MOV	@R1,A
	DEC	R0
	DEC	R1
	DJNZ	R7,SUBLP
	JC	FSUB6
	;
$EJECT
	;
	; Need to complement the result and sign because the floating
	; point accumulator mantissa was larger than the external
	; memory and their signs were equal.
	;
	CPL	FP_SIGN.0
	MOV	R1,#FP_DIG78
	MOV	R7,#DIGIT	;LOOP COUNT
	;
FSUB5:	MOV	A,#9AH
	SUBB	A,@R1
	ADD	A,#0
	DA	A
	MOV	@R1,A
	DEC	R1
	CPL	C
	DJNZ	R7,FSUB5	;LOOP
	;
	; Now see how many zeros their are
	;
FSUB6:	MOV	R0,#FP_DIG12
	MOV	R7,#0
	;
FSUB7:	MOV	A,@R0
	JNZ	FSUB8
	INC	R7
	INC	R7
	INC	R0
	CJNE	R0,#FP_SIGN,FSUB7
	AJMP	ZERO_AND_EXIT
	;
FSUB8:  CJNE    A,#10H,FSUB81
FSUB81: JNC     FSUB9
	INC	R7
	;
	; Now R7 has the number of leading zeros in the FP ACC
	;
FSUB9:	MOV	A,FP_EXP	;GET THE OLD EXPONENT
	CLR	C
	SUBB	A,R7		;SUBTRACT FROM THE NUMBER OF ZEROS
	JZ	FSUB10
	JC	FSUB10
	;
	MOV	FP_EXP,A	;SAVE THE NEW EXPONENT
	;
	ACALL	LEFT1		;SHIFT THE FP ACC
	MOV	FP_CARRY,#0
	AJMP	STORE_ALIGN_TEST_AND_EXIT
	;
FSUB10:	AJMP	UNDERFLOW_AND_EXIT
	;
$EJECT
	;***************************************************************
	;
FLOATING_COMP:	; Compare two floating point numbers
		; used for relational operations and is faster
		; than subtraction. ON RETURN, The carry is set
		; if ARG1 is > ARG2, else carry is not set
		; if ARG1 = ARG2, F0 gets set
	;
	;***************************************************************
	;
	ACALL	MDES1		;SET UP THE REGISTERS
	MOV	A,ARG_STACK
	ADD	A,#FP_NUMBER_SIZE+FP_NUMBER_SIZE
	MOV	ARG_STACK,A	;POP THE STACK TWICE, CLEAR THE CARRY
	MOV	A,R6		;CHECK OUT EXPONENTS
	CLR	F0
	SUBB	A,R7
	JZ	EXPONENTS_EQUAL
	JC	ARG1_EXP_IS_LARGER
	;
	; Now the ARG2 EXPONENT is > ARG1 EXPONENT
	;
SIGNS_DIFFERENT:
	;
	MOV	A,R3		;SEE IF SIGN OF ARG2 IS POSITIVE
        SJMP    ARG1_EXP_IS_LARGER1
	;
ARG1_EXP_IS_LARGER:
	;
	MOV	A,R4		;GET THE SIGN OF ARG1 EXPONENT
ARG1_EXP_IS_LARGER1:
        JZ      ARG1_EXP_IS_LARGER2
	CPL	C
ARG1_EXP_IS_LARGER2:
        RET
	;
EXPONENTS_EQUAL:
	;
	; First, test the sign, then the mantissa
	;
	CJNE	R5,#0,SIGNS_DIFFERENT
	;
BOTH_PLUS:
	;
	MOV	R7,#DIGIT	;POINT AT MS DIGIT
	DEC	R0
	DEC	R0
	DEC	R0
	DEC	R1
	DEC	R1
	DEC	R1
	;
	; Now do the compare
	;
CLOOP:	MOVX	A,@R0
	MOV	R6,A
	MOVX	A,@R1
	SUBB	A,R6
	JNZ	ARG1_EXP_IS_LARGER
	INC	R0
	INC	R1
	DJNZ	R7,CLOOP
	;
	; If here, the numbers are the same, the carry is cleared
	;
	SETB	F0
	RET			;EXIT WITH EQUAL
	;
$EJECT
;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
;
FLOATING_MUL:	; Floating point multiply
;
;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
;
	ACALL	MUL_DIV_EXP_AND_SIGN
	;
	; check for zero exponents
	;
        CJNE    R6,#00,FMUL1    ;ARG 2 EXP ZERO?
FMUL0:  AJMP    ZERO_AND_EXIT
	;
	; calculate the exponent
	;
FMUL1:	MOV	FP_SIGN,R5	;SAVE THE SIGN, IN CASE OF FAILURE
	;
	MOV	A,R7
        JZ      FMUL0
	ADD	A,R6		;ADD THE EXPONENTS
	JB	ACC.7,FMUL_OVER
	JBC	CY,FMUL2	;SEE IF CARRY IS SET
	;
	AJMP	UNDERFLOW_AND_EXIT
	;
FMUL_OVER:
	;
	JNC	FMUL2		;OK IF SET
	;
FOV:	AJMP	OVERFLOW_AND_EXIT
	;
FMUL2:	SUBB	A,#129		;SUBTRACT THE EXPONENT BIAS
	MOV	R6,A		;SAVE IT FOR LATER
	;
	; Unpack and load R0
	;
	ACALL	UNPACK_R0
	;
	; Now set up for loop multiply
	;
	MOV	R3,#DIGIT
	MOV	R4,R1B0
	;
$EJECT
	;
	; Now, do the multiply and accumulate the product
	;
FMUL3:	MOV	R1B0,R4
	MOVX	A,@R1
	MOV	R2,A
	ACALL	MUL_NIBBLE
	;
	MOV	A,R2
	SWAP	A
	ACALL	MUL_NIBBLE
	DEC	R4
	DJNZ	R3,FMUL3
	;
	; Now, pack and restore the sign
	;
	MOV	FP_EXP,R6
	MOV	FP_SIGN,R5
	AJMP	PACK		;FINISH IT OFF
	;
$EJECT
	;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
	;
FLOATING_DIV:
	;
	;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
	;
	ACALL	MDES1
	;
	; Check the exponents
	;
	MOV	FP_SIGN,R5	;SAVE THE SIGN
	CJNE	R7,#0,DIV0	;CLEARS THE CARRY
	ACALL	OVERFLOW_AND_EXIT
	CLR	A
	SETB	ACC.ZERO_DIVIDE
	RET
	;
DIV0:	MOV	A,R6		;GET EXPONENT
        JZ      FMUL0           ;EXIT IF ZERO
	SUBB	A,R7		;DELTA EXPONENT
	JB	ACC.7,D_UNDER
	JNC	DIV3
	AJMP	UNDERFLOW_AND_EXIT
	;
D_UNDER:JNC	FOV
	;
DIV3:	ADD	A,#129		;CORRECTLY BIAS THE EXPONENT
	MOV	FP_EXP,A	;SAVE THE EXPONENT
	ACALL	LOADR1_MANTISSA	;LOAD THE DIVIDED
	;
	MOV	R2,#FP_ACCC	;SAVE LOCATION
	MOV	R3,R0B0		;SAVE POINTER IN R3
	MOV	FP_CARRY,#0	;ZERO CARRY BYTE
	;
DIV4:	MOV	R5,#0FFH	;LOOP COUNT
	SETB	C
	;
DIV5:	MOV	R0B0,R3		;RESTORE THE EXTERNAL POINTER
	MOV	R1,#FP_DIG78	;SET UP INTERNAL POINTER
	MOV	R7,#DIGIT	;LOOP COUNT
	JNC	DIV7		;EXIT IF NO CARRY
	;
DIV6:	MOVX	A,@R0		;DO ACCUMLATION
	MOV	R6,A
	CLR	A
	ADDC	A,#99H
	SUBB	A,R6
	ADD	A,@R1
	DA	A
	MOV	@R1,A
	DEC	R0
	DEC	R1
	DJNZ	R7,DIV6		;LOOP
	;
	INC	R5		;SUBTRACT COUNTER
	JC	DIV5		;KEEP LOOPING IF CARRY
	MOV	A,@R1		;GET CARRY
	SUBB	A,#1		;CARRY IS CLEARED
	MOV	@R1,A		;SAVE CARRY DIGIT
	CPL	C
	SJMP	DIV5		;LOOP
	;
	; Restore the result if carry was found
	;
DIV7:	ACALL	ADDLP		;ADD NUMBER BACK
	MOV	@R1,#0		;CLEAR CARRY
	MOV	R0B0,R2		;GET SAVE COUNTER
	MOV	@R0,5		;SAVE COUNT BYTE
	;
	INC	R2		;ADJUST SAVE COUNTER
	MOV	R7,#1		;BUMP DIVIDEND
	ACALL	LEFT
	CJNE	R2,#FP_ACC8+2,DIV4
	;
	DJNZ	FP_EXP,DIV8
	AJMP	UNDERFLOW_AND_EXIT
	;
DIV8:	MOV	FP_CARRY,#0
	;
$EJECT
	;***************************************************************
	;
PACK:	; Pack the mantissa
	;
	;***************************************************************
	;
	; First, set up the pointers
	;
	MOV	R0,#FP_ACCC
	MOV	A,@R0		;GET FP_ACCC
	MOV	R6,A		;SAVE FOR ZERO COUNT
	JZ	PACK0		;JUMP OVER IF ZERO
	ACALL	INC_FP_EXP	;BUMP THE EXPONENT
	DEC	R0
	;
PACK0:	INC	R0		;POINT AT FP_ACC1
	;
PACK1:	MOV	A,#8		;ADJUST NIBBLE POINTER
	MOV	R1,A
	ADD	A,R0
	MOV	R0,A
        CJNE    @R0,#5,PACK11   ;SEE IF ADJUSTING NEEDED
PACK11: JC      PACK31
	;
PACK2:	SETB	C
	CLR	A
	DEC	R0
	ADDC	A,@R0
	DA	A
	XCHD	A,@R0		;SAVE THE VALUE
	JNB	ACC.4,PACK3
	DJNZ	R1,PACK2
	;
	DEC	R0
	MOV	@R0,#1
	ACALL	INC_FP_EXP
	SJMP	PACK4
	;
PACK3:	DEC	R1
PACK31: MOV     A,R1
	CLR	C
	XCH	A,R0
	SUBB	A,R0
	MOV	R0,A
	;
PACK4:	MOV	R1,#FP_DIG12
	;
	; Now, pack
	;
PLOOP:	MOV	A,@R0
	SWAP	A		;FLIP THE DIGITS
	INC	R0
	XCHD	A,@R0
	ORL	6,A		;ACCUMULATE THE OR'ED DIGITS
	MOV	@R1,A
	INC	R0
	INC	R1
	CJNE	R1,#FP_SIGN,PLOOP
	MOV	A,R6
	JNZ	STORE_ALIGN_TEST_AND_EXIT
	MOV	FP_EXP,#0	;ZERO EXPONENT
	;
	;**************************************************************
	;
STORE_ALIGN_TEST_AND_EXIT:	;Save the number align carry and exit
	;
	;**************************************************************
	;
	ACALL	LOAD_POINTERS
	MOV	ARG_STACK,R1	;SET UP THE NEW STACK
	MOV	R0,#FP_EXP
	;
	; Now load the numbers
	;
STORE2:	MOV	A,@R0
	MOVX	@R1,A		;SAVE THE NUMBER
	DEC	R0
	DEC	R1
	CJNE	R0,#FP_CARRY,STORE2
	;
	CLR	A		;NO ERRORS
	;
PRET:	RET			;EXIT
	;
$EJECT
INC_FP_EXP:
	;
	INC	FP_EXP
	MOV	A,FP_EXP
	JNZ	PRET		;EXIT IF NOT ZERO
	POP	ACC		;WASTE THE CALLING STACK
	POP	ACC
	AJMP	OVERFLOW_AND_EXIT
	;
;***********************************************************************
;
UNPACK_R0:	; Unpack BCD digits and load into nibble locations
;
;***********************************************************************
	;
	PUSH	R1B0
	MOV	R1,#FP_NIB8
	;
ULOOP:	MOVX	A,@R0
	ANL	A,#0FH
	MOV	@R1,A		;SAVE THE NIBBLE
	MOVX	A,@R0
	SWAP	A
	ANL	A,#0FH
	DEC	R1
	MOV	@R1,A		;SAVE THE NIBBLE AGAIN
	DEC	R0
	DEC	R1
	CJNE	R1,#FP_NIB1-1,ULOOP
	;
	POP	R1B0
	;
LOAD7:	RET
	;
$EJECT
	;**************************************************************
	;
OVERFLOW_AND_EXIT:	;LOAD 99999999 E+127,  SET OV BIT, AND EXIT
	;
	;**************************************************************
	;
	MOV	R0,#FP_DIG78
	MOV	A,#99H
	;
OVE1:	MOV	@R0,A
	DEC	R0
	CJNE	R0,#FP_CARRY,OVE1
	;
	MOV	FP_EXP,#0FFH
	ACALL	STORE_ALIGN_TEST_AND_EXIT
	;
	SETB	ACC.OVERFLOW
	RET
	;
$EJECT
	;**************************************************************
	;
UNDERFLOW_AND_EXIT:	;LOAD 0, SET UF BIT, AND EXIT
	;
	;**************************************************************
	;
	ACALL	ZERO_AND_EXIT
	CLR	A
	SETB	ACC.UNDERFLOW
	RET
	;
	;**************************************************************
	;
ZERO_AND_EXIT:		;LOAD 0, SET ZERO BIT, AND EXIT
	;
	;**************************************************************
	;
	ACALL	FP_CLEAR
	ACALL	STORE_ALIGN_TEST_AND_EXIT
	SETB	ACC.ZERO
	RET			;EXIT
	;
	;**************************************************************
	;
FP_CLEAR:
	;
	; Clear internal storage
	;
	;**************************************************************
	;
	CLR	A
	MOV	R0,#FP_ACC8+1
	;
FPC1:	MOV	@R0,A
	DEC	R0
	CJNE	R0,#FP_TEMP,FPC1
	RET
	;
$EJECT
	;**************************************************************
	;
RIGHT:	; Shift ACCUMULATOR RIGHT the number of nibbles in R7
	; Save the shifted values in R4 if SAVE_ROUND is set
	;
	;**************************************************************
	;
	MOV	R4,#0		;IN CASE OF NO SHIFT
	;
RIGHT1:	CLR	C
RIGHT2: MOV     A,R7            ;GET THE DIGITS TO SHIFT
        JZ      RIGHTL1         ;EXIT IF ZERO
	SUBB	A,#2		;TWO TO DO?
	JNC	RIGHT5		;SHIFT TWO NIBBLES
	;
	; Swap one nibble then exit
	;
RIGHT3:	PUSH	R0B0		;SAVE POINTER REGISTER
	PUSH	R1B0
	;
	MOV	R1,#FP_DIG78	;LOAD THE POINTERS
	MOV	R0,#FP_DIG56
	MOV	A,R4		;GET THE OVERFLOW REGISTER
	XCHD	A,@R1		;GET DIGIT 8
	SWAP	A		;FLIP FOR LOAD
	MOV	R4,A
	;
RIGHTL:	MOV	A,@R1		;GET THE LOW ORDER BYTE
	XCHD	A,@R0		;SWAP NIBBLES
	SWAP	A		;FLIP FOR STORE
	MOV	@R1,A		;SAVE THE DIGITS
	DEC	R0		;BUMP THE POINTERS
	DEC	R1
	CJNE	R1,#FP_DIG12-1,RIGHTL	;LOOP
	;
	MOV	A,@R1		;ACC = CH8
	SWAP	A		;ACC = 8CH
	ANL	A,#0FH		;ACC = 0CH
	MOV	@R1,A		;CARRY DONE
	POP	R1B0		;EXIT
	POP	R0B0		;RESTORE REGISTER
RIGHTL1:RET
	;
RIGHT5:	MOV	R7,A		;SAVE THE NEW SHIFT NUMBER
	CLR	A
	XCH	A,FP_CARRY	;SWAP THE NIBBLES
	XCH	A,FP_DIG12
	XCH	A,FP_DIG34
	XCH	A,FP_DIG56
	XCH	A,FP_DIG78
	MOV	R4,A		;SAVE THE LAST DIGIT SHIFTED
        SJMP    RIGHT2
	;
$EJECT
	;***************************************************************
	;
LEFT:	; Shift ACCUMULATOR LEFT the number of nibbles in R7
	;
	;***************************************************************
	;
	MOV	R4,#00H		;CLEAR FOR SOME ENTRYS
	;
LEFT1:	CLR	C
LEFT2:  MOV     A,R7            ;GET SHIFT VALUE
        JZ      LEFTL1          ;EXIT IF ZERO
	SUBB	A,#2		;SEE HOW MANY BYTES TO SHIFT
	JNC	LEFT5
	;
LEFT3:	PUSH	R0B0		;SAVE POINTER
	PUSH	R1B0
	MOV	R0,#FP_CARRY
	MOV	R1,#FP_DIG12
	;
	MOV	A,@R0		;ACC=CHCL
	SWAP	A		;ACC = CLCH
	MOV	@R0,A		;ACC = CLCH, @R0 = CLCH
	;
LEFTL:	MOV	A,@R1		;DIG 12
	SWAP	A		;DIG 21
	XCHD	A,@R0
	MOV	@R1,A		;SAVE IT
	INC	R0		;BUMP POINTERS
	INC	R1
	CJNE	R0,#FP_DIG78,LEFTL
	;
	MOV	A,R4
	SWAP	A
	XCHD	A,@R0
	ANL	A,#0F0H
	MOV	R4,A
	;
	POP	R1B0
	POP	R0B0		;RESTORE
LEFTL1: RET                     ;DONE
	;
LEFT5:	MOV	R7,A		;RESTORE COUNT
	CLR	A
	XCH	A,R4		;GET THE RESTORATION BYTE
	XCH	A,FP_DIG78	;DO THE SWAP
	XCH	A,FP_DIG56
	XCH	A,FP_DIG34
	XCH	A,FP_DIG12
	XCH	A,FP_CARRY
        SJMP    LEFT2
	;
$EJECT
MUL_NIBBLE:
	;
	; Multiply the nibble in R7 by the FP_NIB locations
	; accumulate the product in FP_ACC
	;
	; Set up the pointers for multiplication
	;
	ANL	A,#0FH		;STRIP OFF MS NIBBLE
	MOV	R7,A
	MOV	R0,#FP_ACC8
	MOV	R1,#FP_NIB8
	CLR	A
	MOV	FP_ACCX,A
	;
MNLOOP:	DEC	R0		;BUMP POINTER TO PROPAGATE CARRY
	ADD	A,@R0		;ATTEMPT TO FORCE CARRY
	DA	A		;BCD ADJUST
	JNB	ACC.4,MNL0	;DON'T ADJUST IF NO NEED
	DEC	R0		;PROPAGATE CARRY TO THE NEXT DIGIT
	INC	@R0		;DO THE ADJUSTING
	INC	R0		;RESTORE R0
	;
MNL0:	XCHD	A,@R0		;RESTORE INITIAL NUMBER
	MOV	B,R7		;GET THE NUBBLE TO MULTIPLY
	MOV	A,@R1		;GET THE OTHER NIBBLE
	MUL	AB		;DO THE MULTIPLY
	MOV	B,#10		;NOW BCD ADJUST
	DIV	AB
	XCH	A,B		;GET THE REMAINDER
	ADD	A,@R0		;PROPAGATE THE PARTIAL PRODUCTS
	DA	A		;BCD ADJUST
	JNB	ACC.4,MNL1	;PROPAGATE PARTIAL PRODUCT CARRY
	INC	B
	;
MNL1:	INC	R0
	XCHD	A,@R0		;SAVE THE NEW PRODUCT
	DEC	R0
	MOV	A,B		;GET BACK THE QUOTIENT
	DEC	R1
	CJNE	R1,#FP_NIB1-1,MNLOOP
	;
	ADD	A,FP_ACCX	;GET THE OVERFLOW
	DA	A		;ADJUST
	MOV	@R0,A		;SAVE IT
	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
LOAD_POINTERS:	; Load the ARG_STACK into R0 and bump R1
	;
	;***************************************************************
	;
	MOV	P2,#ARG_STACK_PAGE
	MOV	R0,ARG_STACK
	MOV	A,#FP_NUMBER_SIZE
	ADD	A,R0
	MOV	R1,A
	RET
	;
	;***************************************************************
	;
MUL_DIV_EXP_AND_SIGN:
	;
	; Load the sign into R7, R6. R5 gets the sign for
	; multiply and divide.
	;
	;***************************************************************
	;
	ACALL	FP_CLEAR	;CLEAR INTERNAL MEMORY
	;
MDES1:	ACALL	LOAD_POINTERS	;LOAD REGISTERS
	MOVX	A,@R0		;ARG 1 EXP
	MOV	R7,A		;SAVED IN R7
	MOVX	A,@R1		;ARG 2 EXP
	MOV	R6,A		;SAVED IN R6
	DEC	R0		;BUMP POINTERS TO SIGN
	DEC	R1
	MOVX	A,@R0		;GET THE SIGN
	MOV	R4,A		;SIGN OF ARG1
	MOVX	A,@R1		;GET SIGN OF NEXT ARG
	MOV	R3,A		;SIGN OF ARG2
	XRL	A,R4		;ACC GETS THE NEW SIGN
	MOV	R5,A		;R5 GETS THE NEW SIGN
	;
	; Bump the pointers to point at the LS digit
	;
	DEC	R0
	DEC	R1
	;
	RET
	;
$EJECT
	;***************************************************************
	;
LOADR1_MANTISSA:
	;
	; Load the mantissa of R0 into FP_Digits
	;
	;***************************************************************
	;
	PUSH	R0B0		;SAVE REGISTER 1
	MOV	R0,#FP_DIG78	;SET UP THE POINTER
	;
LOADR1:	MOVX	A,@R1
	MOV	@R0,A
	DEC	R1
	DEC	R0
	CJNE	R0,#FP_CARRY,LOADR1
	;
	POP	R0B0
	RET
	;
$EJECT
	;***************************************************************
	;
HEXSCAN:	; Scan a string to determine if it is a hex number
		; set carry if hex, else carry = 0
	;
	;***************************************************************
	;
	ACALL	GET_DPTR_CHARACTER
	PUSH	DPH
	PUSH	DPL		;SAVE THE POINTER
	;
HEXSC1:	MOVX	A,@DPTR		;GET THE CHARACTER
	ACALL	DIGIT_CHECK	;SEE IF A DIGIT
	JC	HS1		;CONTINUE IF A DIGIT
	ACALL	HEX_CHECK	;SEE IF HEX
	JC	HS1
	;
	CLR	ACC.5		;NO LOWER CASE
	CJNE	A,#'H',HEXDON
	SETB	C
	SJMP	HEXDO1		;NUMBER IS VALID HEX, MAYBE
	;
HEXDON:	CLR	C
	;
HEXDO1:	POP	DPL		;RESTORE POINTER
	POP	DPH
	RET
	;
HS1:	INC	DPTR		;BUMP TO NEXT CHARACTER
	SJMP	HEXSC1		;LOOP
	;
HEX_CHECK:	;CHECK FOR A VALID ASCII HEX, SET CARRY IF FOUND
	;
	CLR	ACC.5		;WASTE LOWER CASE
        CJNE    A,#'F'+1,HEX_CHECK1     ;SEE IF F OR LESS
HEX_CHECK1:
        JC      HC1
	RET
	;
HC1:    CJNE    A,#'A',HC11     ;SEE IF A OR GREATER
HC11:   CPL     C
	RET
	;
$EJECT
	;
PUSHR2R0:
	; 
        MOV     R3,#HIGH CONVERT;CONVERSION LOCATION
        MOV     R1,#LOW CONVERT
	ACALL	CONVERT_BINARY_TO_ASCII_STRING
	MOV	A,#0DH		;A CR TO TERMINATE
	MOVX	@R1,A		;SAVE THE CR
        MOV     DPTR,#CONVERT
	;
	; Falls thru to FLOATING INPUT
	;
$EJECT
	;***************************************************************
	;
FLOATING_POINT_INPUT:	; Input a floating point number pointed to by
			; the DPTR
	;
	;***************************************************************
	;
	ACALL	FP_CLEAR	;CLEAR EVERYTHING
	ACALL	GET_DPTR_CHARACTER
	ACALL	PLUS_MINUS_TEST
	MOV	MSIGN,C		;SAVE THE MANTISSA SIGN
	;
	; Now, set up for input loop
	;
	MOV	R0,#FP_ACCC
	MOV	R6,#7FH		;BASE EXPONENT
	SETB	F0		;SET INITIAL FLAG
	;
INLOOP:	ACALL	GET_DIGIT_CHECK
	JNC	GTEST		;IF NOT A CHARACTER, WHAT IS IT?
	ANL	A,#0FH		;STRIP ASCII
	ACALL	STDIG		;STORE THE DIGITS
	;
INLPIK:	INC	DPTR		;BUMP POINTER FOR LOOP
	SJMP	INLOOP		;LOOP FOR INPUT
	;
GTEST:	CJNE	A,#'.',GT1	;SEE IF A RADIX
	JB	FOUND_RADIX,INERR
	SETB	FOUND_RADIX
	CJNE	R0,#FP_ACCC,INLPIK
	SETB	FIRST_RADIX	;SET IF FIRST RADIX
	SJMP	INLPIK		;GET ADDITIONAL DIGITS
	;
GT1:	JB	F0,INERR	;ERROR IF NOT CLEARED
        CJNE    A,#'e',GT11     ;CHECK FOR LOWER CASE
        SJMP    GT12
GT11:   CJNE    A,#'E',FINISH_UP
GT12:   ACALL   INC_AND_GET_DPTR_CHARACTER
	ACALL	PLUS_MINUS_TEST
	MOV	XSIGN,C		;SAVE SIGN STATUS
	ACALL	GET_DIGIT_CHECK
	JNC	INERR
	;
	ANL	A,#0FH		;STRIP ASCII BIAS OFF THE CHARACTER
	MOV	R5,A		;SAVE THE CHARACTER IN R5
	;
GT2:	INC	DPTR
	ACALL	GET_DIGIT_CHECK
	JNC	FINISH1
	ANL	A,#0FH		;STRIP OFF BIAS
	XCH	A,R5		;GET THE LAST DIGIT
	MOV	B,#10		;MULTIPLY BY TEN
	MUL	AB
	ADD	A,R5		;ADD TO ORIGINAL VALUE
	MOV	R5,A		;SAVE IN R5
	JNC	GT2		;LOOP IF NO CARRY
	MOV	R5,#0FFH	;FORCE AN ERROR
	;
FINISH1:MOV	A,R5		;GET THE SIGN
	JNB	XSIGN,POSNUM	;SEE IF EXPONENT IS POS OR NEG
	CLR	C
	SUBB	A,R6
	CPL	A
	INC	A
	JC	FINISH2
	MOV	A,#01H
	RET
	;
POSNUM:	ADD	A,R6		;ADD TO EXPONENT
	JNC	FINISH2
	;
POSNM1:	MOV	A,#02H
	RET
	;
FINISH2:XCH	A,R6		;SAVE THE EXPONENT
	;
FINISH_UP:
	;
	MOV	FP_EXP,R6	;SAVE EXPONENT
        CJNE    R0,#FP_ACCC,FINISH_UP1
	ACALL	FP_CLEAR	;CLEAR THE MEMORY IF 0
FINISH_UP1:
        MOV     A,ARG_STACK     ;GET THE ARG STACK
	CLR	C
	SUBB	A,#FP_NUMBER_SIZE+FP_NUMBER_SIZE
	MOV	ARG_STACK,A	;ADJUST FOR STORE
	AJMP	PACK
	;
STDIG:	CLR	F0		;CLEAR INITIAL DESIGNATOR
	JNZ	STDIG1		;CONTINUE IF NOT ZERO
	CJNE	R0,#FP_ACCC,STDIG1
	JNB	FIRST_RADIX,RET_X
	;
DECX:	DJNZ	R6,RET_X
	;
INERR:	MOV	A,#0FFH
	;
RET_X:	RET
	;
STDIG1:	JB	DONE_LOAD,FRTEST
	CLR	FIRST_RADIX
	;
FRTEST:	JB	FIRST_RADIX,DECX
	;
FDTEST:	JB	FOUND_RADIX,FDT1
	INC	R6
	;
FDT1:	JB	DONE_LOAD,RET_X
	CJNE	R0,#FP_ACC8+1,FDT2
	SETB	DONE_LOAD
	;
FDT2:	MOV	@R0,A		;SAVE THE STRIPPED ACCUMULATOR
	INC	R0		;BUMP THE POINTER
	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
	; I/O utilities
	;
	;***************************************************************
	;
INC_AND_GET_DPTR_CHARACTER:
	;
	INC	DPTR
	;
GET_DPTR_CHARACTER:
	;
	MOVX	A,@DPTR		;GET THE CHARACTER
	CJNE	A,#' ',PMT1	;SEE IF A SPACE
	;
	; Kill spaces
	;
	SJMP	INC_AND_GET_DPTR_CHARACTER
	;
PLUS_MINUS_TEST:
	;
        CJNE    A,#0E3H,PMT11   ;SEE IF A PLUS, PLUS TOKEN FROM BASIC
	SJMP	PMT3
PMT11:  CJNE    A,#'+',PMT12
	SJMP	PMT3
PMT12:  CJNE    A,#0E5H,PMT13   ;SEE IF MINUS, MINUS TOKEN FROM BASIC
	SJMP	PMT2
PMT13:  CJNE    A,#'-',PMT1
	;
PMT2:	SETB	C
	;
PMT3:	INC	DPTR
	;
PMT1:	RET
	;
$EJECT
	;***************************************************************
	;
FLOATING_POINT_OUTPUT:	; Output the number, format is in location 23
	;
	; IF FORMAT = 00 - FREE FLOATING
	;           = FX - EXPONENTIAL (X IS THE NUMBER OF SIG DIGITS)
	;           = NX - N = NUM BEFORE RADIX, X = NUM AFTER RADIX
	;                  N + X = 8 MAX
	;
	;***************************************************************
	;
	ACALL	MDES1		;GET THE NUMBER TO OUTPUT, R0 IS POINTER
	ACALL	POP_AND_EXIT	;OUTPUT POPS THE STACK
	MOV	A,R7
	MOV	R6,A		;PUT THE EXPONENT IN R6
	ACALL	UNPACK_R0	;UNPACK THE NUMBER
	MOV	R0,#FP_NIB1	;POINT AT THE NUMBER
	MOV	A,FORMAT	;GET THE FORMAT
	MOV	R3,A		;SAVE IN CASE OF EXP FORMAT
	JZ	FREE		;FREE FLOATING?
        CJNE    A,#0F0H,FPO1    ;SEE IF EXPONENTIAL
FPO1:   JNC     EXPOUT
	;
	; If here, must be integer USING format
	;
	MOV	A,R6		;GET THE EXPONENT
        JNZ     FPO2
	MOV	R6,#80H
FPO2:   MOV     A,R3            ;GET THE FORMAT
	SWAP	A		;SPLIT INTEGER AND FRACTION
	ANL	A,#0FH
	MOV	R2,A		;SAVE INTEGER
	ACALL	NUM_LT		;GET THE NUMBER OF INTEGERS
	XCH	A,R2		;FLIP FOR SUBB
	CLR	C
	SUBB	A,R2
	MOV	R7,A
        JNC     FPO3
	MOV	R5,#'?'		;OUTPUT A QUESTION MARK
	ACALL	SOUT1		;NUMBER IS TOO LARGE FOR FORMAT
	AJMP	FREE
FPO3:   CJNE    R2,#00,USING0   ;SEE IF ZERO
	DEC	R7
	ACALL	SS7
	ACALL	ZOUT		;OUTPUT A ZERO
	SJMP	USING1
	;
USING0:	ACALL	SS7		;OUTPUT SPACES, IF NEED TO
	MOV	A,R2		;OUTPUT DIGITS
	MOV	R7,A
	ACALL	OUTR0
	;
USING1:	MOV	A,R3
	ANL	A,#0FH		;GET THE NUMBER RIGHT OF DP
	MOV	R2,A		;SAVE IT
	JZ	PMT1		;EXIT IF ZERO
	ACALL	ROUT		;OUTPUT DP
	ACALL	NUM_RT
	CJNE	A,2,USINGX	;COMPARE A TO R2
	;
USINGY:	MOV	A,R2
	AJMP	Z7R7
	;
USINGX:	JNC	USINGY
	;
USING2:	XCH	A,R2
	CLR	C
	SUBB	A,R2
	XCH	A,R2
	ACALL	Z7R7		;OUTPUT ZEROS IF NEED TO
	MOV	A,R2
	MOV	R7,A
	AJMP	OUTR0
	;
	; First, force exponential output, if need to
	;
FREE:	MOV	A,R6		;GET THE EXPONENT
	JNZ	FREE1		;IF ZERO, PRINT IT
	ACALL	SOUT
	AJMP	ZOUT
	;
FREE1:	MOV	R3,#0F0H	;IN CASE EXP NEEDED
	MOV	A,#80H-DIGIT-DIGIT-1
	ADD	A,R6
	JC	EXPOUT
	SUBB	A,#0F7H
	JC	EXPOUT
	;
	; Now, just print the number
	;
	ACALL	SINOUT		;PRINT THE SIGN OF THE NUMBER
	ACALL	NUM_LT		;GET THE NUMBER LEFT OF DP
	CJNE	A,#8,FREE4
	AJMP	OUTR0
	;
FREE4:	ACALL	OUTR0
	ACALL	ZTEST		;TEST FOR TRAILING ZEROS
	JZ	U_RET		;DONE IF ALL TRAILING ZEROS
	ACALL	ROUT		;OUTPUT RADIX
	;
FREE2:	MOV	R7,#1		;OUTPUT ONE DIGIT
	ACALL	OUTR0
	JNZ	U_RET
	ACALL	ZTEST
	JZ	U_RET
	SJMP	FREE2		;LOOP
	;
EXPOUT:	ACALL	SINOUT		;PRINT THE SIGN
	MOV	R7,#1		;OUTPUT ONE CHARACTER
	ACALL	OUTR0
	ACALL	ROUT		;OUTPUT RADIX
	MOV	A,R3		;GET FORMAT
	ANL	A,#0FH		;STRIP INDICATOR
	JZ	EXPOTX
	;
	MOV	R7,A		;OUTPUT THE NUMBER OF DIGITS
	DEC	R7		;ADJUST BECAUSE ONE CHAR ALREADY OUT
	ACALL	OUTR0
	SJMP	EXPOT4
	;
EXPOTX:	ACALL	FREE2		;OUTPUT UNTIL TRAILING ZEROS
	;
EXPOT4:	ACALL	SOUT		;OUTPUT A SPACE
	MOV	R5,#'E'
	ACALL	SOUT1		;OUTPUT AN E
	MOV	A,R6		;GET THE EXPONENT
	JZ	XOUT0		;EXIT IF ZERO
	DEC	A		;ADJUST FOR THE DIGIT ALREADY OUTPUT
	CJNE	A,#80H,XOUT2	;SEE WHAT IT IS
	;
XOUT0:	ACALL	SOUT
	CLR	A
	SJMP	XOUT4
	;
XOUT2:	JC	XOUT3		;NEGATIVE EXPONENT
	MOV	R5,#'+'		;OUTPUT A PLUS SIGN
	ACALL	SOUT1
	SJMP	XOUT4
	;
XOUT3:	ACALL	MOUT
	CPL	A		;FLIP BITS
	INC	A		;BUMP
	;
XOUT4:	CLR	ACC.7
	MOV	R0,A
	MOV	R2,#0
        MOV     R1,#LOW CONVERT ;CONVERSION LOCATION
        MOV     R3,#HIGH CONVERT
	ACALL	CONVERT_BINARY_TO_ASCII_STRING
        MOV     R0,#LOW CONVERT ;NOW, OUTPUT EXPONENT
	;
EXPOT5:	MOVX	A,@R0		;GET THE CHARACTER
	MOV	R5,A		;OUTPUT IT
	ACALL	SOUT1
	INC	R0		;BUMP THE POINTER
	MOV	A,R0		;GET THE POINTER
	CJNE	A,R1B0,EXPOT5	;LOOP
	;
U_RET:	RET			;EXIT
	;
OUTR0:	; Output the characters pointed to by R0, also bias ascii
	;
	MOV	A,R7		;GET THE COUNTER
	JZ	OUTR		;EXIT IF DONE
	MOV	A,@R0		;GET THE NUMBER
	ORL	A,#30H		;ASCII BIAS
	INC	R0		;BUMP POINTER AND COUNTER
	DEC	R7
	MOV	R5,A		;PUT CHARACTER IN OUTPUT REGISTER
	ACALL	SOUT1		;OUTPUT THE CHARACTER
	CLR	A		;JUST FOR TEST
	CJNE	R0,#FP_NIB8+1,OUTR0
	MOV	A,#55H		;KNOW WHERE EXIT OCCURED
	;
OUTR:	RET
	;
ZTEST:	MOV	R1,R0B0		;GET POINTER REGISTER
	;
ZT0:	MOV	A,@R1		;GET THE VALUE
	JNZ	ZT1
	INC	R1		;BUMP POINTER
	CJNE	R1,#FP_NIB8+1,ZT0
	;
ZT1:	RET
	;
NUM_LT:	MOV	A,R6		;GET EXPONENT
	CLR	C		;GET READY FOR SUBB
	SUBB	A,#80H		;SUB EXPONENT BIAS
	JNC	NL1		;OK IF NO CARRY
	CLR	A		;NO DIGITS LEFT
	;
NL1:	MOV	R7,A		;SAVE THE COUNT
	RET
	;
NUM_RT:	CLR	C		;SUBB AGAIN
	MOV	A,#80H		;EXPONENT BIAS
	SUBB	A,R6		;GET THE BIASED EXPONENT
	JNC	NR1
	CLR	A
	;
NR1:	RET			;EXIT
	;
SPACE7:	MOV	A,R7		;GET THE NUMBER OF SPACES
	JZ	NR1		;EXIT IF ZERO
	ACALL	SOUT		;OUTPUT A SPACE
	DEC	R7		;BUMP COUNTER
	SJMP	SPACE7		;LOOP
	;
Z7R7:	MOV	R7,A
	;
ZERO7:	MOV	A,R7		;GET COUNTER
	JZ	NR1		;EXIT IF ZERO
	ACALL	ZOUT		;OUTPUT A ZERO
	DEC	R7		;BUMP COUNTER
	SJMP	ZERO7		;LOOP
	;
SS7:	ACALL	SPACE7
	;
SINOUT:	MOV	A,R4		;GET THE SIGN
	JZ	SOUT		;OUTPUT A SPACE IF ZERO
	;
MOUT:	MOV	R5,#'-'
	SJMP	SOUT1		;OUTPUT A MINUS IF NOT
	;
ROUT:	MOV	R5,#'.'		;OUTPUT A RADIX
	SJMP	SOUT1
	;
ZOUT:	MOV	R5,#'0'		;OUTPUT A ZERO
	SJMP	SOUT1
	;
SOUT:	MOV	R5,#' '		;OUTPUT A SPACE
	;
SOUT1:	AJMP	OUTPUT
	;
$EJECT
	;***************************************************************
	;
CONVERT_ASCII_STRING_TO_BINARY:
	;
	;DPTR POINTS TO ASCII STRING
	;PUT THE BINARY NUMBER IN R2:R0, ERROR IF >64K
	;
	;***************************************************************
	;
CASB:	ACALL	HEXSCAN		;SEE IF HEX NUMBER
	MOV	ADD_IN,C	;IF ADD_IN IS SET, THE NUMBER IS HEX
	ACALL	GET_DIGIT_CHECK
	CPL	C		;FLIP FOR EXIT
	JC	RCASB
	MOV	R3,#00H		;ZERO R3:R1 FOR LOOP
	MOV	R1,#00H
	SJMP	CASB5
	;
CASB2:	INC	DPTR
	MOV	R0B0,R1		;SAVE THE PRESENT CONVERTED VALUE
        MOV     R2B0,R3         ;IN R2:R0
	ACALL	GET_DIGIT_CHECK
	JC	CASB5
	JNB	ADD_IN,RCASB	;CONVERSION COMPLETE
	ACALL	HEX_CHECK	;SEE IF HEX NUMBER
	JC	CASB4		;PROCEED IF GOOD
	INC	DPTR		;BUMP PAST H
	SJMP	RCASB
	;
CASB4:	ADD	A,#9		;ADJUST HEX ASCII BIAS
	;
CASB5:	MOV	B,#10
	JNB	ADD_IN,CASB6
	MOV	B,#16		;HEX MODE
	;
CASB6:	ACALL	MULNUM		;ACCUMULATE THE DIGITS
	JNC	CASB2		;LOOP IF NO CARRY
	;
RCASB:	CLR	A		;RESET ACC
	MOV	ACC.OVERFLOW,C	;IF OVERFLOW, SAY SO
	RET			;EXIT
	;
$EJECT
	;
MULNUM10:MOV	B,#10
	;
	;***************************************************************
	;
MULNUM:	; Take the next digit in the acc (masked to 0FH)
	; accumulate in R3:R1
	;
	;***************************************************************
	;
	PUSH	ACC		;SAVE ACC
	PUSH	B		;SAVE MULTIPLIER
	MOV	A,R1		;PUT LOW ORDER BITS IN ACC
	MUL	AB		;DO THE MULTIPLY
	MOV	R1,A		;PUT THE RESULT BACK
	MOV	A,R3		;GET THE HIGH ORDER BYTE
	MOV	R3,B		;SAVE THE OVERFLOW
	POP	B		;GET THE MULTIPLIER
	MUL	AB		;DO IT
	MOV	C,OV		;SAVE OVERFLOW IN F0
	MOV	F0,C
	ADD	A,R3		;ADD OVERFLOW TO HIGH RESULT
	MOV	R3,A		;PUT IT BACK
	POP	ACC		;GET THE ORIGINAL ACC BACK
	ORL	C,F0		;OR CARRY AND OVERFLOW
	JC	MULX		;NO GOOD IF THE CARRY IS SET
	;
MUL11:	ANL	A,#0FH		;MASK OFF HIGH ORDER BITS
	ADD	A,R1		;NOW ADD THE ACC
	MOV	R1,A		;PUT IT BACK
	CLR	A		;PROPAGATE THE CARRY
	ADDC	A,R3
	MOV	R3,A		;PUT IT BACK
	;
MULX:	RET			;EXIT WITH OR WITHOUT CARRY
	;
	;***************************************************************
	;
CONVERT_BINARY_TO_ASCII_STRING:
	;
	;R3:R1 contains the address of the string
	;R2:R0 contains the value to convert
	;DPTR, R7, R6, and ACC gets clobbered
	;
	;***************************************************************
	;
	CLR	A		;NO LEADING ZEROS
	MOV	DPTR,#10000	;SUBTRACT 10000
	ACALL	RSUB		;DO THE SUBTRACTION
	MOV	DPTR,#1000	;NOW 1000
	ACALL	RSUB
	MOV	DPTR,#100	;NOW 100
	ACALL	RSUB
	MOV	DPTR,#10	;NOW 10
	ACALL	RSUB
	MOV	DPTR,#1		;NOW 1
	ACALL	RSUB
	JZ	RSUB2		;JUMP OVER RET
	;
RSUB_R:	RET
	;
RSUB:	MOV	R6,#-1		;SET UP THE COUNTER
	;
RSUB1:	INC	R6		;BUMP THE COUNTER
	XCH	A,R2		;DO A FAST COMPARE
        CJNE    A,DPH,RSUB11
RSUB11: XCH     A,R2
	JC	FAST_DONE
	XCH	A,R0		;GET LOW BYTE
	SUBB	A,DPL		;SUBTRACT, CARRY IS CLEARED
	XCH	A,R0		;PUT IT BACK
	XCH	A,R2		;GET THE HIGH BYTE
	SUBB	A,DPH		;ADD THE HIGH BYTE
	XCH	A,R2		;PUT IT BACK
	JNC	RSUB1		;LOOP UNTIL CARRY
	;
	XCH	A,R0
	ADD	A,DPL		;RESTORE R2:R0
	XCH	A,R0
	XCH	A,R2
	ADDC	A,DPH
	XCH	A,R2
	;
FAST_DONE:
	;
	ORL	A,R6		;OR THE COUNT VALUE
	JZ	RSUB_R		;RETURN IF ZERO
	;
RSUB2:	MOV	A,#'0'		;GET THE ASCII BIAS
	ADD	A,R6		;ADD THE COUNT
	;
RSUB4:	MOV	P2,R3		;SET UP P2
	MOVX	@R1,A		;PLACE THE VALUE IN MEMORY
	INC	R1
	CJNE	R1,#00H,RSUB3	;SEE IF RAPPED AROUND
	INC	R3		;BUMP HIGH BYTE
	;
RSUB3:	RET			;EXIT
	;
$EJECT
	;***************************************************************
	;
HEXOUT:	; Output the hex number in R3:R1, supress leading zeros, if set
	;
	;***************************************************************
	;
	ACALL	SOUT		;OUTPUT A SPACE
	MOV	C,ZSURP		;GET ZERO SUPPRESSION BIT
	MOV	ADD_IN,C
	MOV	A,R3		;GET HIGH NIBBLE AND PRINT IT
	ACALL	HOUTHI
	MOV	A,R3
	ACALL	HOUTLO
	;
HEX2X:	CLR	ADD_IN		;DON'T SUPPRESS ZEROS
	MOV	A,R1		;GET LOW NIBBLE AND PRINT IT
	ACALL	HOUTHI
	MOV	A,R1
	ACALL	HOUTLO
	MOV	R5,#'H'		;OUTPUT H TO INDICATE HEX MODE
	;
SOUT_1:	AJMP	SOUT1
	;
HOUT1:	CLR	ADD_IN		;PRINTED SOMETHING, SO CLEAR ADD_IN
	ADD	A,#90H		;CONVERT TO ASCII
	DA	A
	ADDC	A,#40H
	DA	A		;GOT IT HERE
	MOV	R5,A		;OUTPUT THE BYTE
	SJMP	SOUT_1
	;
HOUTHI:	SWAP	A		;SWAP TO OUTPUT HIGH NIBBLE
	;
HOUTLO:	ANL	A,#0FH		;STRIP
	JNZ	HOUT1		;PRINT IF NOT ZERO
	JNB	ADD_IN,HOUT1	;OUTPUT A ZERO IF NOT SUPRESSED
	RET
	;
$EJECT
	ORG	1FEBH		;FOR LINK COMPATABILITY
	;
	;
GET_DIGIT_CHECK:	; Get a character, then check for digit
	;
	ACALL	GET_DPTR_CHARACTER
	;
DIGIT_CHECK:	;CHECK FOR A VALID ASCII DIGIT, SET CARRY IF FOUND
	;
        CJNE    A,#'9'+1,DC10   ;SEE IF ASCII 9 OR LESS
DC10:   JC      DC1
	RET
	;
DC1:    CJNE    A,#'0',DC11     ;SEE IF ASCII 0 OR GREATER
DC11:   CPL     C
	RET
	;
        ;***************************************************************
	;
	XSEG	;External Ram
	;
	;***************************************************************
	;
	DS	4
IBCNT:	DS	1		;LENGTH OF A LINE
IBLN:	DS	2		;THE LINE NUMBER
IBUF:	DS	LINLEN		;THE INPUT BUFFER
CONVT:	DS	15		;CONVERSION LOCATION FOR FPIN
	;
	ORG	100H
	;
GTB:	DS	1		;GET LOCATION
ERRLOC:	DS	1		;ERROR TYPE
ERRNUM:	DS	2		;WHERE TO GO ON AN ERROR
VARTOP:	DS	2		;TOP OF VARIABLE STORAGE
ST_ALL:	DS	2		;STORAGE ALLOCATION
MT_ALL:	DS	2		;MATRIX ALLOCATION
MEMTOP:	DS	2		;TOP OF MEMORY
RCELL:	DS	2		;RANDOM NUMBER CELL
	DS	FPSIZ-1
CXTAL:	DS	1		;CRYSTAL
	DS	FPSIZ-1
FPT1:	DS	1		;FLOATINP POINT TEMP 1
	DS	FPSIZ-1
FPT2:	DS	1		;FLOATING POINT TEMP 2
INTLOC:	DS	2		;LOCATION TO GO TO ON INTERRUPT
STR_AL:	DS	2		;STRING ALLOCATION
SPV:	DS	2		;SERIAL PORT BAUD RATE
TIV:	DS	2		;TIMER INTERRUPT NUM AND LOC
PROGS:	DS	2		;PROGRAM A PROM TIME OUT
IPROGS:	DS	2		;INTELLIGENT PROM PROGRAMMER TIMEOUT
TM_TOP:	DS	1

        END


