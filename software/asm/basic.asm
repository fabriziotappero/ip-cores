
; Enhanced BASIC to assemble under 6502 simulator, $ver 2.22

; $E7E1 $E7CF $E7C6 $E7D3 $E7D1 $E7D5 $E7CF $E81E $E825

; 2.00	new revision numbers start here
; 2.01	fixed LCASE$() and UCASE$()
; 2.02	new get value routine done
; 2.03	changed RND() to galoise method
; 2.04	fixed SPC()
; 2.05	new get value routine fixed
; 2.06	changed USR() code
; 2.07	fixed STR$()
; 2.08	changed INPUT and READ to remove need for $00 start to input buffer
; 2.09	fixed RND()
; 2.10	integrated missed changes from an earlier version
; 2.20	added ELSE to IF .. THEN and fixed IF .. GOTO <statement> to cause error
; 2.21	fixed IF .. THEN RETURN to not cause error
; 2.22	fixed RND() breaking the get byte routine

macro nat
	.byte	$42
	xce
	cpu		RTF65002
endm

macro emm
	sec
	xce
endm

macro emm816
	clc
	xce
	cpu		W65C816S
endm

DisplayChar				= $FFFF8000
KeybdCheckForKeyDirect	= $FFFF8004
KeybdGetCharDirect		= $FFFF8008
KeybdGetChar			= $FFFF800C
KeybdCheckForChar		= $FFFF8010
RequestIOFocus			= $FFFF8014
ReleaseIOFocus			= $FFFF8018
ClearScreen				= $FFFF801C
HomeCursor				= $FFFF8020
ExitTask				= $FFFF8024
SetKeyboardEcho			= $FFFF8028
Sleep					= $FFFF802C
LoadFile				= $FFFF8030
SaveFile				= $FFFF8034
ICacheInvalidateAll		= $FFFF8038
ICacheInvalidateLine	= $FFFF803C

LEDS				=$FFDC0600

OUTNDX		EQU		0x778
INPNDX		EQU		0x779
FILENAME	EQU		0x6C0
FILEBUF		EQU		0x05F60000

; zero page use ..

LAB_WARM 		= $00		; BASIC warm start entry point
Wrmjpl 		= LAB_WARM+1; BASIC warm start vector jump low byte
Wrmjph 		= LAB_WARM+2; BASIC warm start vector jump high byte

Usrjmp		= $0A		; USR function JMP address
Usrjpl		= Usrjmp+1	; USR function JMP vector low byte
Usrjph		= Usrjmp+2	; USR function JMP vector high byte
Nullct		= $0D		; nulls output after each line
TPos			= $0E		; BASIC terminal position byte
TWidth		= $0F		; BASIC terminal width byte
Iclim			= $10		; input column limit
Itempl		= $11		; temporary integer low byte
Itemph		= Itempl+1	; temporary integer high byte

nums_1		= Itempl	; number to bin/hex string convert MSB
nums_2		= nums_1+1	; number to bin/hex string convert
nums_3		= nums_1+2	; number to bin/hex string convert LSB

Srchc			= $5B		; search character
Temp3			= Srchc	; temp byte used in number routines
Scnquo		= $5C		; scan-between-quotes flag
Asrch			= Scnquo	; alt search character

XOAw_l		= Srchc	; eXclusive OR, OR and AND word low byte
XOAw_h		= Scnquo	; eXclusive OR, OR and AND word high byte

Ibptr			= $5D		; input buffer pointer
Dimcnt		= Ibptr	; # of dimensions
Tindx			= Ibptr	; token index

Defdim		= $5E		; default DIM flag
Dtypef		= $5F		; data type flag, $FF=string, $00=numeric
Oquote		= $60		; open quote flag (b7) (Flag: DATA scan; LIST quote; memory)
Gclctd		= $60		; garbage collected flag
Sufnxf		= $61		; subscript/FNX flag, 1xxx xxx = FN(0xxx xxx)
Imode			= $62		; input mode flag, $00=INPUT, $80=READ

Cflag			= $63		; comparison evaluation flag

TabSiz		= $64		; TAB step size (was input flag)

next_s		= $65		; next descriptor stack address

					; these two bytes form a word pointer to the item
					; currently on top of the descriptor stack
last_sl		= $66		; last descriptor stack address low byte
last_sh		= $67		; last descriptor stack address high byte (always $00)

des_sk		= $68		; descriptor stack start address (temp strings)

;			= $70		; End of descriptor stack

ut1_pl		= $71		; utility pointer 1 low byte
ut1_ph		= ut1_pl+1	; utility pointer 1 high byte
ut2_pl		= $73		; utility pointer 2 low byte
ut2_ph		= ut2_pl+1	; utility pointer 2 high byte

Temp_2		= ut1_pl	; temp byte for block move	

FACt_1		= $75		; FAC temp mantissa1
FACt_2		= FACt_1+1	; FAC temp mantissa2
FACt_3		= FACt_2+1	; FAC temp mantissa3

dims_l		= FACt_2	; array dimension size low byte
dims_h		= FACt_3	; array dimension size high byte

TempB			= $78		; temp page 0 byte

Smeml			= $79		; start of mem low byte		(Start-of-Basic)
Smemh			= Smeml+1	; start of mem high byte	(Start-of-Basic)
Svarl			= $7B		; start of vars low byte	(Start-of-Variables)
Svarh			= Svarl+1	; start of vars high byte	(Start-of-Variables)
Sarryl		= $7D		; var mem end low byte		(Start-of-Arrays)
Sarryh		= Sarryl+1	; var mem end high byte		(Start-of-Arrays)
Earryl		= $7F		; array mem end low byte	(End-of-Arrays)
Earryh		= Earryl+1	; array mem end high byte	(End-of-Arrays)
Sstorl		= $81		; string storage low byte	(String storage (moving down))
Sstorh		= Sstorl+1	; string storage high byte	(String storage (moving down))
Sutill		= $83		; string utility ptr low byte
Sutilh		= Sutill+1	; string utility ptr high byte
Ememl			= $85		; end of mem low byte		(Limit-of-memory)
Ememh			= Ememl+1	; end of mem high byte		(Limit-of-memory)
Clinel		= $87		; current line low byte		(Basic line number)
Clineh		= Clinel+1	; current line high byte	(Basic line number)
Blinel		= $89		; break line low byte		(Previous Basic line number)
Blineh		= Blinel+1	; break line high byte		(Previous Basic line number)

Cpntrl		= $8B		; continue pointer low byte
Cpntrh		= Cpntrl+1	; continue pointer high byte

Dlinel		= $8D		; current DATA line low byte
Dlineh		= Dlinel+1	; current DATA line high byte

Dptrl			= $8F		; DATA pointer low byte
Dptrh			= Dptrl+1	; DATA pointer high byte

Rdptrl		= $91		; read pointer low byte
Rdptrh		= Rdptrl+1	; read pointer high byte

Varnm1		= $93		; current var name 1st byte
Varnm2		= Varnm1+1	; current var name 2nd byte

Cvaral		= $95		; current var address low byte
Cvarah		= Cvaral+1	; current var address high byte

Frnxtl		= $97		; var pointer for FOR/NEXT low byte
Frnxth		= Frnxtl+1	; var pointer for FOR/NEXT high byte

Tidx1			= Frnxtl	; temp line index

Lvarpl		= Frnxtl	; let var pointer low byte
Lvarph		= Frnxth	; let var pointer high byte

prstk			= $99		; precedence stacked flag

comp_f		= $9B		; compare function flag, bits 0,1 and 2 used
					; bit 2 set if >
					; bit 1 set if =
					; bit 0 set if <

func_l		= $9C		; function pointer low byte
func_h		= func_l+1	; function pointer high byte

garb_l		= func_l	; garbage collection working pointer low byte
garb_h		= func_h	; garbage collection working pointer high byte

des_2l		= $9E		; string descriptor_2 pointer low byte
des_2h		= des_2l+1	; string descriptor_2 pointer high byte

g_step		= $A0		; garbage collect step size

Fnxjmp		= $A1		; jump vector for functions
Fnxjpl		= Fnxjmp+1	; functions jump vector low byte
Fnxjph		= Fnxjmp+2	; functions jump vector high byte

g_indx		= Fnxjpl	; garbage collect temp index

FAC2_r		= $A3		; FAC2 rounding byte

Adatal		= $A4		; array data pointer low byte
Adatah		= Adatal+1	; array data pointer high  byte

Nbendl		= Adatal	; new block end pointer low byte
Nbendh		= Adatah	; new block end pointer high  byte

Obendl		= $A6		; old block end pointer low byte
Obendh		= Obendl+1	; old block end pointer high  byte

numexp		= $A8		; string to float number exponent count
expcnt		= $A9		; string to float exponent count

numbit		= numexp	; bit count for array element calculations

numdpf		= $AA		; string to float decimal point flag
expneg		= $AB		; string to float eval exponent -ve flag

Astrtl		= numdpf	; array start pointer low byte
Astrth		= expneg	; array start pointer high  byte

Histrl		= numdpf	; highest string low byte
Histrh		= expneg	; highest string high  byte

Baslnl		= numdpf	; BASIC search line pointer low byte
Baslnh		= expneg	; BASIC search line pointer high  byte

Fvar_l		= numdpf	; find/found variable pointer low byte
Fvar_h		= expneg	; find/found variable pointer high  byte

Ostrtl		= numdpf	; old block start pointer low byte
Ostrth		= expneg	; old block start pointer high  byte

Vrschl		= numdpf	; variable search pointer low byte
Vrschh		= expneg	; variable search pointer high  byte

FAC1_e		= $AC		; FAC1 exponent
FAC1_1		= FAC1_e+1	; FAC1 mantissa1
FAC1_2		= FAC1_e+2	; FAC1 mantissa2
FAC1_3		= FAC1_e+3	; FAC1 mantissa3
FAC1_s		= FAC1_e+4	; FAC1 sign (b7)

str_ln		= FAC1_e	; string length
str_pl		= FAC1_1	; string pointer low byte
str_ph		= FAC1_2	; string pointer high byte

des_pl		= FAC1_2	; string descriptor pointer low byte
des_ph		= FAC1_3	; string descriptor pointer high byte

mids_l		= FAC1_3	; MID$ string temp length byte

negnum		= $B1		; string to float eval -ve flag
numcon		= $B1		; series evaluation constant count

FAC1_o		= $B2		; FAC1 overflow byte

FAC2_e		= $B3		; FAC2 exponent
FAC2_1		= FAC2_e+1	; FAC2 mantissa1
FAC2_2		= FAC2_e+2	; FAC2 mantissa2
FAC2_3		= FAC2_e+3	; FAC2 mantissa3
FAC2_s		= FAC2_e+4	; FAC2 sign (b7)

FAC_sc		= $B8		; FAC sign comparison, Acc#1 vs #2
FAC1_r		= $B9		; FAC1 rounding byte

ssptr_l		= FAC_sc	; string start pointer low byte
ssptr_h		= FAC1_r	; string start pointer high byte

sdescr		= FAC_sc	; string descriptor pointer

csidx			= $BA		; line crunch save index
Asptl			= csidx	; array size/pointer low byte
Aspth			= $BB		; array size/pointer high byte

Btmpl			= Asptl	; BASIC pointer temp low byte
Btmph			= Aspth	; BASIC pointer temp low byte

Cptrl			= Asptl	; BASIC pointer temp low byte
Cptrh			= Aspth	; BASIC pointer temp low byte

Sendl			= Asptl	; BASIC pointer temp low byte
Sendh			= Aspth	; BASIC pointer temp low byte

LAB_IGBY		= $BC		; get next BASIC byte subroutine

LAB_GBYT		= $C2		; get current BASIC byte subroutine
Bpntrl		= $C3		; BASIC execute (get byte) pointer low byte
Bpntrh		= Bpntrl+1	; BASIC execute (get byte) pointer high byte

;			= $D7		; end of get BASIC char subroutine

Rbyte4		= $D8		; extra PRNG byte
Rbyte1		= Rbyte4+1	; most significant PRNG byte
Rbyte2		= Rbyte4+2	; middle PRNG byte
Rbyte3		= Rbyte4+3	; least significant PRNG byte

NmiBase		= $DC		; NMI handler enabled/setup/triggered flags
					; bit	function
					; ===	========
					; 7	interrupt enabled
					; 6	interrupt setup
					; 5	interrupt happened
;			= $DD		; NMI handler addr low byte
;			= $DE		; NMI handler addr high byte
IrqBase		= $DF		; IRQ handler enabled/setup/triggered flags
;			= $E0		; IRQ handler addr low byte
;			= $E1		; IRQ handler addr high byte

;			= $DE		; unused
;			= $DF		; unused
;			= $E0		; unused
;			= $E1		; unused
;			= $E2		; unused
;			= $E3		; unused
;			= $E4		; unused
;			= $E5		; unused
;			= $E6		; unused
;			= $E7		; unused
;			= $E8		; unused
;			= $E9		; unused
;			= $EA		; unused
;			= $EB		; unused
;			= $EC		; unused
;			= $ED		; unused
;			= $EE		; unused

Decss			= $EF		; number to decimal string start
Decssp1		= Decss+1	; number to decimal string start

;			= $FF		; decimal string end

; token values needed for BASIC

; primary command tokens (can start a statement)

TK_END		= $80			; END token
TK_FOR		= TK_END+1		; FOR token
TK_NEXT		= TK_FOR+1		; NEXT token
TK_DATA		= TK_NEXT+1		; DATA token
TK_INPUT		= TK_DATA+1		; INPUT token
TK_DIM		= TK_INPUT+1	; DIM token
TK_READ		= TK_DIM+1		; READ token
TK_LET		= TK_READ+1		; LET token
TK_DEC		= TK_LET+1		; DEC token
TK_GOTO		= TK_DEC+1		; GOTO token
TK_RUN		= TK_GOTO+1		; RUN token
TK_IF			= TK_RUN+1		; IF token
TK_RESTORE		= TK_IF+1		; RESTORE token
TK_GOSUB		= TK_RESTORE+1	; GOSUB token
TK_RETIRQ		= TK_GOSUB+1	; RETIRQ token
TK_RETNMI		= TK_RETIRQ+1	; RETNMI token
TK_RETURN		= TK_RETNMI+1	; RETURN token
TK_REM		= TK_RETURN+1	; REM token
TK_STOP		= TK_REM+1		; STOP token
TK_ON			= TK_STOP+1		; ON token
TK_NULL		= TK_ON+1		; NULL token
TK_INC		= TK_NULL+1		; INC token
TK_WAIT		= TK_INC+1		; WAIT token
TK_LOAD		= TK_WAIT+1		; LOAD token
TK_SAVE		= TK_LOAD+1		; SAVE token
TK_DEF		= TK_SAVE+1		; DEF token
TK_POKE		= TK_DEF+1		; POKE token
TK_DOKE		= TK_POKE+1		; DOKE token
TK_CALL		= TK_DOKE+1		; CALL token
TK_DO			= TK_CALL+1		; DO token
TK_LOOP		= TK_DO+1		; LOOP token
TK_PRINT		= TK_LOOP+1		; PRINT token
TK_CONT		= TK_PRINT+1	; CONT token
TK_LIST		= TK_CONT+1		; LIST token
TK_CLEAR		= TK_LIST+1		; CLEAR token
TK_NEW		= TK_CLEAR+1	; NEW token
TK_WIDTH		= TK_NEW+1		; WIDTH token
TK_GET		= TK_WIDTH+1	; GET token
TK_SWAP		= TK_GET+1		; SWAP token
TK_BITSET		= TK_SWAP+1		; BITSET token
TK_BITCLR		= TK_BITSET+1	; BITCLR token
TK_IRQ		= TK_BITCLR+1	; IRQ token
TK_NMI		= TK_IRQ+1		; NMI token
TK_BYE		= TK_NMI+1

; secondary command tokens, can't start a statement

TK_TAB		= TK_BYE+1		; TAB token
TK_ELSE		= TK_TAB+1		; ELSE token
TK_TO			= TK_ELSE+1		; TO token
TK_FN			= TK_TO+1		; FN token
TK_SPC		= TK_FN+1		; SPC token
TK_THEN		= TK_SPC+1		; THEN token
TK_NOT		= TK_THEN+1		; NOT token
TK_STEP		= TK_NOT+1		; STEP token
TK_UNTIL		= TK_STEP+1		; UNTIL token
TK_WHILE		= TK_UNTIL+1	; WHILE token
TK_OFF		= TK_WHILE+1	; OFF token

; opperator tokens

TK_PLUS		= TK_OFF+1		; + token
TK_MINUS		= TK_PLUS+1		; - token
TK_MUL		= TK_MINUS+1	; * token
TK_DIV		= TK_MUL+1		; / token
TK_POWER		= TK_DIV+1		; ^ token
TK_AND		= TK_POWER+1	; AND token
TK_EOR		= TK_AND+1		; EOR token
TK_OR			= TK_EOR+1		; OR token
TK_RSHIFT		= TK_OR+1		; RSHIFT token
TK_LSHIFT		= TK_RSHIFT+1	; LSHIFT token
TK_GT			= TK_LSHIFT+1	; > token
TK_EQUAL		= TK_GT+1		; = token
TK_LT			= TK_EQUAL+1	; < token

; functions tokens

TK_SGN		= TK_LT+1		; SGN token
TK_INT		= TK_SGN+1		; INT token
TK_ABS		= TK_INT+1		; ABS token
TK_USR		= TK_ABS+1		; USR token
TK_FRE		= TK_USR+1		; FRE token
TK_POS		= TK_FRE+1		; POS token
TK_SQR		= TK_POS+1		; SQR token
TK_RND		= TK_SQR+1		; RND token
TK_LOG		= TK_RND+1		; LOG token
TK_EXP		= TK_LOG+1		; EXP token
TK_COS		= TK_EXP+1		; COS token
TK_SIN		= TK_COS+1		; SIN token
TK_TAN		= TK_SIN+1		; TAN token
TK_ATN		= TK_TAN+1		; ATN token
TK_PEEK		= TK_ATN+1		; PEEK token
TK_DEEK		= TK_PEEK+1		; DEEK token
TK_SADD		= TK_DEEK+1		; SADD token
TK_LEN		= TK_SADD+1		; LEN token
TK_STRS		= TK_LEN+1		; STR$ token
TK_VAL		= TK_STRS+1		; VAL token
TK_ASC		= TK_VAL+1		; ASC token
TK_UCASES		= TK_ASC+1		; UCASE$ token
TK_LCASES		= TK_UCASES+1	; LCASE$ token
TK_CHRS		= TK_LCASES+1	; CHR$ token
TK_HEXS		= TK_CHRS+1		; HEX$ token
TK_BINS		= TK_HEXS+1		; BIN$ token
TK_BITTST		= TK_BINS+1		; BITTST token
TK_MAX		= TK_BITTST+1	; MAX token
TK_MIN		= TK_MAX+1		; MIN token
TK_PI			= TK_MIN+1		; PI token
TK_TWOPI		= TK_PI+1		; TWOPI token
TK_VPTR		= TK_TWOPI+1	; VARPTR token
TK_LEFTS		= TK_VPTR+1		; LEFT$ token
TK_RIGHTS		= TK_LEFTS+1	; RIGHT$ token
TK_MIDS		= TK_RIGHTS+1	; MID$ token

; offsets from a base of X or Y

PLUS_0		= $00		; X or Y plus 0
PLUS_1		= $01		; X or Y plus 1
PLUS_2		= $02		; X or Y plus 2
PLUS_3		= $03		; X or Y plus 3

LAB_STAK		= $0100	; stack bottom, no offset

LAB_SKFE		= LAB_STAK+$FE
					; flushed stack address
LAB_SKFF		= LAB_STAK+$FF
					; flushed stack address

ccflag		= $0200	; BASIC CTRL-C flag, 00 = enabled, 01 = dis
ccbyte		= ccflag+1	; BASIC CTRL-C byte
ccnull		= ccbyte+1	; BASIC CTRL-C byte timeout

VEC_CC		= ccnull+1	; ctrl c check vector

VEC_IN		= VEC_CC+2	; input vector
VEC_OUT		= VEC_IN+2	; output vector
VEC_LD		= VEC_OUT+2	; load vector
VEC_SV		= VEC_LD+2	; save vector

; Ibuffs can now be anywhere in RAM, ensure that the max length is < $80

;Ibuffs		= IRQ_vec+$14
Ibuffs		= VEC_SV+$14
					; start of input buffer after IRQ/NMI code
Ibuffe		= Ibuffs+$47; end of input buffer

Ram_base		= $0400	; start of user RAM (set as needed, should be page aligned)
Ram_top		= $1800	; end of user RAM+1 (set as needed, should be page aligned)

include "supermon816.asm"

; This start can be changed to suit your system

;	*=	$C000
	cpu	W65C02
	org	$C000

; BASIC cold start entry point

; new page 2 initialisation, copy block to ccflag on
message "LAB_COLD"
LAB_COLD
	LDY	#PG2_TABE-PG2_TABS-1
					; byte count-1
LAB_2D13
	LDA	PG2_TABS,Y		; get byte
	STA	ccflag,Y		; store in page 2
	DEY				; decrement count
	BPL	LAB_2D13		; loop if not done
	LDX	#$FF			; set byte
	STX   Ibuffs-1      ; *** Added by Daryl Rictor for SBC-2 compatibility
 	STX	Clineh		; set current line high byte (set immediate mode)
	TXS				; reset stack pointer

	LDA	#$4C			; code for JMP
	STA	Fnxjmp		; save for jump vector for functions

; copy block from LAB_2CEE to $00BC - $00D3

	LDX	#StrTab-LAB_2CEE	; set byte count
LAB_2D4E
	LDA	LAB_2CEE-1,X	; get byte from table
	STA	LAB_IGBY-1,X	; save byte in page zero
	DEX				; decrement count
	BNE	LAB_2D4E		; loop if not all done

; copy block from StrTab to $0000 - $0012

LAB_GMEM
	LDX	#EndTab-StrTab-1	; set byte count-1
TabLoop
	LDA	StrTab,X		; get byte from table
	STA	PLUS_0,X		; save byte in page zero
	DEX				; decrement count
	BPL	TabLoop		; loop if not all done

; set-up start values

	LDA	#$00			; clear A
	STA	NmiBase		; clear NMI handler enabled flag
	STA	IrqBase		; clear IRQ handler enabled flag
	STA	FAC1_o		; clear FAC1 overflow byte
	STA	last_sh		; clear descriptor stack top item pointer high byte

	LDA	#$0E			; set default tab size
	STA	TabSiz		; save it
	LDA	#$03			; set garbage collect step size for descriptor stack
	STA	g_step		; save it
	LDX	#des_sk		; descriptor stack start
	STX	next_s		; set descriptor stack pointer

	JSR	LAB_CRLF		; print CR/LF
	LDA	#<LAB_MSZM		; point to memory size message (low addr)
	LDY	#>LAB_MSZM		; point to memory size message (high addr)
	JSR	LAB_18C3		; print null terminated string from memory
	JSR	LAB_INLN		; print "? " and get BASIC input
	STX	Bpntrl		; set BASIC execute pointer low byte
	STY	Bpntrh		; set BASIC execute pointer high byte
	JSR	LAB_GBYT		; get last byte back

	BNE	LAB_2DAA		; branch if not null (user typed something)

	LDY	#$00			; else clear Y
					; character was null so get memory size the hard way
					; we get here with Y=0 and Itempl/h = Ram_base
LAB_2D93
	INC	Itempl		; increment temporary integer low byte
	BNE	LAB_2D99		; branch if no overflow

	INC	Itemph		; increment temporary integer high byte
	LDA	Itemph		; get high byte
	CMP	#>Ram_top		; compare with top of RAM+1
	BEQ	LAB_2DB6		; branch if match (end of user RAM)

LAB_2D99
	LDA	#$55			; set test byte
	STA	(Itempl),Y		; save via temporary integer
	CMP	(Itempl),Y		; compare via temporary integer
	BNE	LAB_2DB6		; branch if fail

	ASL				; shift test byte left (now $AA)
	STA	(Itempl),Y		; save via temporary integer
	CMP	(Itempl),Y		; compare via temporary integer
	BEQ	LAB_2D93		; if ok go do next byte

	BNE	LAB_2DB6		; branch if fail

LAB_2DAA
	JSR	LAB_2887		; get FAC1 from string
	LDA	FAC1_e		; get FAC1 exponent
	CMP	#$98			; compare with exponent = 2^24
	BCS	LAB_GMEM		; if too large go try again

	JSR	LAB_F2FU		; save integer part of FAC1 in temporary integer
					; (no range check)

LAB_2DB6
	LDA	Itempl		; get temporary integer low byte
	LDY	Itemph		; get temporary integer high byte
	CPY	#<Ram_base+1	; compare with start of RAM+$100 high byte
	BCC	LAB_GMEM		; if too small go try again


; uncomment these lines if you want to check on the high limit of memory. Note if
; Ram_top is set too low then this will fail. default is ignore it and assume the
; users know what they're doing!

;	CPY	#>Ram_top		; compare with top of RAM high byte
;	BCC	MEM_OK		; branch if < RAM top

;	BNE	LAB_GMEM		; if too large go try again
					; else was = so compare low bytes
;	CMP	#<Ram_top		; compare with top of RAM low byte
;	BEQ	MEM_OK		; branch if = RAM top

;	BCS	LAB_GMEM		; if too large go try again

;MEM_OK
	STA	Ememl			; set end of mem low byte
	STY	Ememh			; set end of mem high byte
	STA	Sstorl		; set bottom of string space low byte
	STY	Sstorh		; set bottom of string space high byte

	LDY	#<Ram_base		; set start addr low byte
	LDX	#>Ram_base		; set start addr high byte
	STY	Smeml			; save start of mem low byte
	STX	Smemh			; save start of mem high byte

; this line is only needed if Ram_base is not $xx00

;	LDY	#$00			; clear Y
	TYA				; clear A
	STA	(Smeml),Y		; clear first byte
	INC	Smeml			; increment start of mem low byte

; these two lines are only needed if Ram_base is $xxFF

;	BNE	LAB_2E05		; branch if no rollover

;	INC	Smemh			; increment start of mem high byte
LAB_2E05
	JSR	LAB_CRLF		; print CR/LF
	JSR	LAB_1463		; do "NEW" and "CLEAR"
	LDA	Ememl			; get end of mem low byte
	SEC				; set carry for subtract
	SBC	Smeml			; subtract start of mem low byte
	TAX				; copy to X
	LDA	Ememh			; get end of mem high byte
	SBC	Smemh			; subtract start of mem high byte
	JSR	LAB_295E		; print XA as unsigned integer (bytes free)
	LDA	#<LAB_SMSG		; point to sign-on message (low addr)
	LDY	#>LAB_SMSG		; point to sign-on message (high addr)
	JSR	LAB_18C3		; print null terminated string from memory
	LDA	#<LAB_1274		; warm start vector low byte
	LDY	#>LAB_1274		; warm start vector high byte
	STA	Wrmjpl		; save warm start vector low byte
	STY	Wrmjph		; save warm start vector high byte
	JMP	(Wrmjpl)		; go do warm start

; open up space in memory
; move (Ostrtl)-(Obendl) to new block ending at (Nbendl)

; Nbendl,Nbendh - new block end address (A/Y)
; Obendl,Obendh - old block end address
; Ostrtl,Ostrth - old block start address

; returns with ..

; Nbendl,Nbendh - new block start address (high byte - $100)
; Obendl,Obendh - old block start address (high byte - $100)
; Ostrtl,Ostrth - old block start address (unchanged)

LAB_11CF
	JSR	LAB_121F		; check available memory, "Out of memory" error if no room
					; addr to check is in AY (low/high)
	STA	Earryl		; save new array mem end low byte
	STY	Earryh		; save new array mem end high byte

; open up space in memory
; move (Ostrtl)-(Obendl) to new block ending at (Nbendl)
; don't set array end

LAB_11D6
	SEC				; set carry for subtract
	LDA	Obendl		; get block end low byte
	SBC	Ostrtl		; subtract block start low byte
	TAY				; copy MOD(block length/$100) byte to Y
	LDA	Obendh		; get block end high byte
	SBC	Ostrth		; subtract block start high byte
	TAX				; copy block length high byte to X
	INX				; +1 to allow for count=0 exit
	TYA				; copy block length low byte to A
	BEQ	LAB_120A		; branch if length low byte=0

					; block is (X-1)*256+Y bytes, do the Y bytes first

	SEC				; set carry for add + 1, two's complement
	EOR	#$FF			; invert low byte for subtract
	ADC	Obendl		; add block end low byte

	STA	Obendl		; save corrected old block end low byte
	BCS	LAB_11F3		; branch if no underflow

	DEC	Obendh		; else decrement block end high byte
	SEC				; set carry for add + 1, two's complement
LAB_11F3
	TYA				; get MOD(block length/$100) byte
	EOR	#$FF			; invert low byte for subtract
	ADC	Nbendl		; add destination end low byte
	STA	Nbendl		; save modified new block end low byte
	BCS	LAB_1203		; branch if no underflow

	DEC	Nbendh		; else decrement block end high byte
	BCC	LAB_1203		; branch always

LAB_11FF
	LDA	(Obendl),Y		; get byte from source
	STA	(Nbendl),Y		; copy byte to destination
LAB_1203
	DEY				; decrement index
	BNE	LAB_11FF		; loop until Y=0

					; now do Y=0 indexed byte
	LDA	(Obendl),Y		; get byte from source
	STA	(Nbendl),Y		; save byte to destination
LAB_120A
	DEC	Obendh		; decrement source pointer high byte
	DEC	Nbendh		; decrement destination pointer high byte
	DEX				; decrement block count
	BNE	LAB_1203		; loop until count = $0

	RTS

; check room on stack for A bytes
; stack too deep? do OM error

LAB_1212
	STA	TempB			; save result in temp byte
	TSX				; copy stack
	CPX	TempB			; compare new "limit" with stack
	BCC	LAB_OMER		; if stack < limit do "Out of memory" error then warm start

	RTS

; check available memory, "Out of memory" error if no room
; addr to check is in AY (low/high)

LAB_121F
	CPY	Sstorh		; compare bottom of string mem high byte
	BCC	LAB_124B		; if less then exit (is ok)

	BNE	LAB_1229		; skip next test if greater (tested <)

					; high byte was =, now do low byte
	CMP	Sstorl		; compare with bottom of string mem low byte
	BCC	LAB_124B		; if less then exit (is ok)

					; addr is > string storage ptr (oops!)
LAB_1229
	PHA				; push addr low byte
	LDX	#$08			; set index to save Adatal to expneg inclusive
	TYA				; copy addr high byte (to push on stack)

					; save misc numeric work area
LAB_122D
	PHA				; push byte
	LDA	Adatal-1,X		; get byte from Adatal to expneg ( ,$00 not pushed)
	DEX				; decrement index
	BPL	LAB_122D		; loop until all done

	JSR	LAB_GARB		; garbage collection routine

					; restore misc numeric work area
	LDX	#$00			; clear the index to restore bytes
LAB_1238
	PLA				; pop byte
	STA	Adatal,X		; save byte to Adatal to expneg
	INX				; increment index
	CPX	#$08			; compare with end + 1
	BMI	LAB_1238		; loop if more to do

	PLA				; pop addr high byte
	TAY				; copy back to Y
	PLA				; pop addr low byte
	CPY	Sstorh		; compare bottom of string mem high byte
	BCC	LAB_124B		; if less then exit (is ok)

	BNE	LAB_OMER		; if greater do "Out of memory" error then warm start

					; high byte was =, now do low byte
	CMP	Sstorl		; compare with bottom of string mem low byte
	BCS	LAB_OMER		; if >= do "Out of memory" error then warm start

					; ok exit, carry clear
LAB_124B
	RTS

; do "Out of memory" error then warm start

LAB_OMER
	LDX	#$0C			; error code $0C ("Out of memory" error)

; do error #X, then warm start

LAB_XERR
	JSR	LAB_CRLF		; print CR/LF

	LDA	LAB_BAER,X		; get error message pointer low byte
	LDY	LAB_BAER+1,X	; get error message pointer high byte
	JSR	LAB_18C3		; print null terminated string from memory

	JSR	LAB_1491		; flush stack and clear continue flag
	LDA	#<LAB_EMSG		; point to " Error" low addr
	LDY	#>LAB_EMSG		; point to " Error" high addr
LAB_1269
	JSR	LAB_18C3		; print null terminated string from memory
	LDY	Clineh		; get current line high byte
	INY				; increment it
	BEQ	LAB_1274		; go do warm start (was immediate mode)

					; else print line number
	JSR	LAB_2953		; print " in line [LINE #]"

; BASIC warm start entry point
; wait for Basic command

LAB_1274
					; clear ON IRQ/NMI bytes
	LDA	#$00			; clear A
	STA	IrqBase		; clear enabled byte
	STA	NmiBase		; clear enabled byte
	LDA	#<LAB_RMSG		; point to "Ready" message low byte
	LDY	#>LAB_RMSG		; point to "Ready" message high byte

	JSR	LAB_18C3		; go do print string

; wait for Basic command (no "Ready")

LAB_127D
	JSR	LAB_1357		; call for BASIC input
LAB_1280
	STX	Bpntrl		; set BASIC execute pointer low byte
	STY	Bpntrh		; set BASIC execute pointer high byte
	JSR	LAB_GBYT		; scan memory
	BEQ	LAB_127D		; loop while null

; got to interpret input line now ..

	LDX	#$FF			; current line to null value
	STX	Clineh		; set current line high byte
	BCC	LAB_1295		; branch if numeric character (handle new BASIC line)

					; no line number .. immediate mode
	JSR	LAB_13A6		; crunch keywords into Basic tokens
	JMP	LAB_15F6		; go scan and interpret code

; handle new BASIC line

LAB_1295
	JSR	LAB_GFPN		; get fixed-point number into temp integer
	JSR	LAB_13A6		; crunch keywords into Basic tokens
	STY	Ibptr			; save index pointer to end of crunched line
	JSR	LAB_SSLN		; search BASIC for temp integer line number
	BCC	LAB_12E6		; branch if not found

					; aroooogah! line # already exists! delete it
	LDY	#$01			; set index to next line pointer high byte
	LDA	(Baslnl),Y		; get next line pointer high byte
	STA	ut1_ph		; save it
	LDA	Svarl			; get start of vars low byte
	STA	ut1_pl		; save it
	LDA	Baslnh		; get found line pointer high byte
	STA	ut2_ph		; save it
	LDA	Baslnl		; get found line pointer low byte
	DEY				; decrement index
	SBC	(Baslnl),Y		; subtract next line pointer low byte
	CLC				; clear carry for add
	ADC	Svarl			; add start of vars low byte
	STA	Svarl			; save new start of vars low byte
	STA	ut2_pl		; save destination pointer low byte
	LDA	Svarh			; get start of vars high byte
	ADC	#$FF			; -1 + carry
	STA	Svarh			; save start of vars high byte
	SBC	Baslnh		; subtract found line pointer high byte
	TAX				; copy to block count
	SEC				; set carry for subtract
	LDA	Baslnl		; get found line pointer low byte
	SBC	Svarl			; subtract start of vars low byte
	TAY				; copy to bytes in first block count
	BCS	LAB_12D0		; branch if overflow

	INX				; increment block count (correct for =0 loop exit)
	DEC	ut2_ph		; decrement destination high byte
LAB_12D0
	CLC				; clear carry for add
	ADC	ut1_pl		; add source pointer low byte
	BCC	LAB_12D8		; branch if no overflow

	DEC	ut1_ph		; else decrement source pointer high byte
	CLC				; clear carry

					; close up memory to delete old line
LAB_12D8
	LDA	(ut1_pl),Y		; get byte from source
	STA	(ut2_pl),Y		; copy to destination
	INY				; increment index
	BNE	LAB_12D8		; while <> 0 do this block

	INC	ut1_ph		; increment source pointer high byte
	INC	ut2_ph		; increment destination pointer high byte
	DEX				; decrement block count
	BNE	LAB_12D8		; loop until all done

					; got new line in buffer and no existing same #
LAB_12E6
	LDA	Ibuffs		; get byte from start of input buffer
	BEQ	LAB_1319		; if null line just go flush stack/vars and exit

					; got new line and it isn't empty line
	LDA	Ememl			; get end of mem low byte
	LDY	Ememh			; get end of mem high byte
	STA	Sstorl		; set bottom of string space low byte
	STY	Sstorh		; set bottom of string space high byte
	LDA	Svarl			; get start of vars low byte	(end of BASIC)
	STA	Obendl		; save old block end low byte
	LDY	Svarh			; get start of vars high byte	(end of BASIC)
	STY	Obendh		; save old block end high byte
	ADC	Ibptr			; add input buffer pointer	(also buffer length)
	BCC	LAB_1301		; branch if no overflow from add

	INY				; else increment high byte
LAB_1301
	STA	Nbendl		; save new block end low byte	(move to, low byte)
	STY	Nbendh		; save new block end high byte
	JSR	LAB_11CF		; open up space in memory
					; old start pointer Ostrtl,Ostrth set by the find line call
	LDA	Earryl		; get array mem end low byte
	LDY	Earryh		; get array mem end high byte
	STA	Svarl			; save start of vars low byte
	STY	Svarh			; save start of vars high byte
	LDY	Ibptr			; get input buffer pointer	(also buffer length)
	DEY				; adjust for loop type
LAB_1311
	LDA	Ibuffs-4,Y		; get byte from crunched line
	STA	(Baslnl),Y		; save it to program memory
	DEY				; decrement count
	CPY	#$03			; compare with first byte-1
	BNE	LAB_1311		; continue while count <> 3

	LDA	Itemph		; get line # high byte
	STA	(Baslnl),Y		; save it to program memory
	DEY				; decrement count
	LDA	Itempl		; get line # low byte
	STA	(Baslnl),Y		; save it to program memory
	DEY				; decrement count
	LDA	#$FF			; set byte to allow chain rebuild. if you didn't set this
					; byte then a zero already here would stop the chain rebuild
					; as it would think it was the [EOT] marker.
	STA	(Baslnl),Y		; save it to program memory

LAB_1319
	JSR	LAB_1477		; reset execution to start, clear vars and flush stack
	LDX	Smeml			; get start of mem low byte
	LDA	Smemh			; get start of mem high byte
	LDY	#$01			; index to high byte of next line pointer
LAB_1325
	STX	ut1_pl		; set line start pointer low byte
	STA	ut1_ph		; set line start pointer high byte
	LDA	(ut1_pl),Y		; get it
	BEQ	LAB_133E		; exit if end of program

; rebuild chaining of Basic lines

	LDY	#$04			; point to first code byte of line
					; there is always 1 byte + [EOL] as null entries are deleted
LAB_1330
	INY				; next code byte
	LDA	(ut1_pl),Y		; get byte
	BNE	LAB_1330		; loop if not [EOL]

	SEC				; set carry for add + 1
	TYA				; copy end index
	ADC	ut1_pl		; add to line start pointer low byte
	TAX				; copy to X
	LDY	#$00			; clear index, point to this line's next line pointer
	STA	(ut1_pl),Y		; set next line pointer low byte
	TYA				; clear A
	ADC	ut1_ph		; add line start pointer high byte + carry
	INY				; increment index to high byte
	STA	(ut1_pl),Y		; save next line pointer low byte
	BCC	LAB_1325		; go do next line, branch always, carry clear


LAB_133E
	JMP	LAB_127D		; else we just wait for Basic command, no "Ready"

; print "? " and get BASIC input

LAB_INLN
	JSR	LAB_18E3		; print "?" character
	JSR	LAB_18E0		; print " "
	BNE	LAB_1357		; call for BASIC input and return

; receive line from keyboard

					; $08 as delete key (BACKSPACE on standard keyboard)
LAB_134B
	JSR	LAB_PRNA		; go print the character
	DEX				; decrement the buffer counter (delete)
	.byte	$2C			; make LDX into BIT abs

; call for BASIC input (main entry point)

LAB_1357
	LDX	#$00			; clear BASIC line buffer pointer
LAB_1359
	JSR	V_INPT		; call scan input device
	BCC	LAB_1359		; loop if no byte

	BEQ	LAB_1359		; loop until valid input (ignore NULLs)

	CMP	#$07			; compare with [BELL]
	BEQ	LAB_1378		; branch if [BELL]

	CMP	#$0D			; compare with [CR]
	BEQ	LAB_1384		; do CR/LF exit if [CR]

	CPX	#$00			; compare pointer with $00
	BNE	LAB_1374		; branch if not empty

; next two lines ignore any non print character and [SPACE] if input buffer empty

	CMP	#$21			; compare with [SP]+1
	BCC	LAB_1359		; if < ignore character

LAB_1374
	CMP	#$08			; compare with [BACKSPACE] (delete last character)
	BEQ	LAB_134B		; go delete last character

LAB_1378
	CPX	#Ibuffe-Ibuffs	; compare character count with max
	BCS	LAB_138E		; skip store and do [BELL] if buffer full

	STA	Ibuffs,X		; else store in buffer
	INX				; increment pointer
LAB_137F
	JSR	LAB_PRNA		; go print the character
	BNE	LAB_1359		; always loop for next character

LAB_1384
	JMP	LAB_1866		; do CR/LF exit to BASIC
message "LAB_138E"
; announce buffer full

LAB_138E
	LDA	#$07			; [BELL] character into A
	BNE	LAB_137F		; go print the [BELL] but ignore input character
					; branch always

; crunch keywords into Basic tokens
; position independent buffer version ..
; faster, dictionary search version ....

LAB_13A6
	LDY	#$FF			; set save index (makes for easy math later)

	SEC				; set carry for subtract
	LDA	Bpntrl		; get basic execute pointer low byte
	SBC	#<Ibuffs		; subtract input buffer start pointer
	TAX				; copy result to X (index past line # if any)

	STX	Oquote		; clear open quote/DATA flag
LAB_13AC
	LDA	Ibuffs,X		; get byte from input buffer
	BEQ	LAB_13EC		; if null save byte then exit

	CMP	#'_'			; compare with "_"
	BCS	LAB_13EC		; if >= go save byte then continue crunching

	CMP	#'<'			; compare with "<"
	BCS	LAB_13CC		; if >= go crunch now

	CMP	#'0'			; compare with "0"
	BCS	LAB_13EC		; if >= go save byte then continue crunching

	STA	Scnquo		; save buffer byte as search character
	CMP	#$22			; is it quote character?
	BEQ	LAB_1410		; branch if so (copy quoted string)

	CMP	#'*'			; compare with "*"
	BCC	LAB_13EC		; if < go save byte then continue crunching

					; else crunch now
LAB_13CC
	BIT	Oquote		; get open quote/DATA token flag
	BVS	LAB_13EC		; branch if b6 of Oquote set (was DATA)
					; go save byte then continue crunching

	STX	TempB			; save buffer read index
	STY	csidx			; copy buffer save index
	LDY	#<TAB_1STC		; get keyword first character table low address
	STY	ut2_pl		; save pointer low byte
	LDY	#>TAB_1STC		; get keyword first character table high address
	STY	ut2_ph		; save pointer high byte
	LDY	#$00			; clear table pointer

LAB_13D0
	CMP	(ut2_pl),Y		; compare with keyword first character table byte
	BEQ	LAB_13D1		; go do word_table_chr if match

	BCC	LAB_13EA		; if < keyword first character table byte go restore
					; Y and save to crunched

	INY				; else increment pointer
	BNE	LAB_13D0		; and loop (branch always)

; have matched first character of some keyword

LAB_13D1
	TYA				; copy matching index
	ASL				; *2 (bytes per pointer)
	TAX				; copy to new index
	LDA	TAB_CHRT,X		; get keyword table pointer low byte
	STA	ut2_pl		; save pointer low byte
	LDA	TAB_CHRT+1,X	; get keyword table pointer high byte
	STA	ut2_ph		; save pointer high byte

	LDY	#$FF			; clear table pointer (make -1 for start)

	LDX	TempB			; restore buffer read index

LAB_13D6
	INY				; next table byte
	LDA	(ut2_pl),Y		; get byte from table
LAB_13D8
	BMI	LAB_13EA		; all bytes matched so go save token

	INX				; next buffer byte
	CMP	Ibuffs,X		; compare with byte from input buffer
	BEQ	LAB_13D6		; go compare next if match

	BNE	LAB_1417		; branch if >< (not found keyword)

LAB_13EA
	LDY	csidx			; restore save index

					; save crunched to output
LAB_13EC
	INX				; increment buffer index (to next input byte)
	INY				; increment save index (to next output byte)
	STA	Ibuffs,Y		; save byte to output
	CMP	#$00			; set the flags, set carry
	BEQ	LAB_142A		; do exit if was null [EOL]

					; A holds token or byte here
	SBC	#':'			; subtract ":" (carry set by CMP #00)
	BEQ	LAB_13FF		; branch if it was ":" (is now $00)

					; A now holds token-$3A
	CMP	#TK_DATA-$3A	; compare with DATA token - $3A
	BNE	LAB_1401		; branch if not DATA

					; token was : or DATA
LAB_13FF
	STA	Oquote		; save token-$3A (clear for ":", TK_DATA-$3A for DATA)
LAB_1401
	EOR	#TK_REM-$3A		; effectively subtract REM token offset
	BNE	LAB_13AC		; If wasn't REM then go crunch rest of line

	STA	Asrch			; else was REM so set search for [EOL]

					; loop for REM, "..." etc.
LAB_1408
	LDA	Ibuffs,X		; get byte from input buffer
	BEQ	LAB_13EC		; branch if null [EOL]

	CMP	Asrch			; compare with stored character
	BEQ	LAB_13EC		; branch if match (end quote)

					; entry for copy string in quotes, don't crunch
LAB_1410
	INY				; increment buffer save index
	STA	Ibuffs,Y		; save byte to output
	INX				; increment buffer read index
	BNE	LAB_1408		; loop while <> 0 (should never be 0!)

					; not found keyword this go
LAB_1417
	LDX	TempB			; compare has failed, restore buffer index (start byte!)

					; now find the end of this word in the table
LAB_141B
	LDA	(ut2_pl),Y		; get table byte
	PHP				; save status
	INY				; increment table index
	PLP				; restore byte status
	BPL	LAB_141B		; if not end of keyword go do next

	LDA	(ut2_pl),Y		; get byte from keyword table
	BNE	LAB_13D8		; go test next word if not zero byte (end of table)

					; reached end of table with no match
	LDA	Ibuffs,X		; restore byte from input buffer
	BPL	LAB_13EA		; branch always (all bytes in buffer are $00-$7F)
					; go save byte in output and continue crunching

					; reached [EOL]
LAB_142A
	INY				; increment pointer
	INY				; increment pointer (makes it next line pointer high byte)
	STA	Ibuffs,Y		; save [EOL] (marks [EOT] in immediate mode)
	INY				; adjust for line copy
	INY				; adjust for line copy
	INY				; adjust for line copy
	DEC	Bpntrl		; allow for increment (change if buffer starts at $xxFF)
	RTS

; search Basic for temp integer line number from start of mem

LAB_SSLN
	LDA	Smeml			; get start of mem low byte
	LDX	Smemh			; get start of mem high byte

; search Basic for temp integer line number from AX
; returns carry set if found
; returns Baslnl/Baslnh pointer to found or next higher (not found) line

; old 541 new 507

LAB_SHLN
	LDY	#$01			; set index
	STA	Baslnl		; save low byte as current
	STX	Baslnh		; save high byte as current
	LDA	(Baslnl),Y		; get pointer high byte from addr
	BEQ	LAB_145F		; pointer was zero so we're done, do 'not found' exit

	LDY	#$03			; set index to line # high byte
	LDA	(Baslnl),Y		; get line # high byte
	DEY				; decrement index (point to low byte)
	CMP	Itemph		; compare with temporary integer high byte
	BNE	LAB_1455		; if <> skip low byte check

	LDA	(Baslnl),Y		; get line # low byte
	CMP	Itempl		; compare with temporary integer low byte
LAB_1455
	BCS	LAB_145E		; else if temp < this line, exit (passed line#)

LAB_1456
	DEY				; decrement index to next line ptr high byte
	LDA	(Baslnl),Y		; get next line pointer high byte
	TAX				; copy to X
	DEY				; decrement index to next line ptr low byte
	LDA	(Baslnl),Y		; get next line pointer low byte
	BCC	LAB_SHLN		; go search for line # in temp (Itempl/Itemph) from AX
					; (carry always clear)

LAB_145E
	BEQ	LAB_1460		; exit if temp = found line #, carry is set

LAB_145F
	CLC				; clear found flag
LAB_1460
	RTS

; perform NEW

LAB_NEW
	BNE	LAB_1460		; exit if not end of statement (to do syntax error)

LAB_1463
	LDA	#$00			; clear A
	TAY				; clear Y
	STA	(Smeml),Y		; clear first line, next line pointer, low byte
	INY				; increment index
	STA	(Smeml),Y		; clear first line, next line pointer, high byte
	CLC				; clear carry
	LDA	Smeml			; get start of mem low byte
	ADC	#$02			; calculate end of BASIC low byte
	STA	Svarl			; save start of vars low byte
	LDA	Smemh			; get start of mem high byte
	ADC	#$00			; add any carry
	STA	Svarh			; save start of vars high byte

; reset execution to start, clear vars and flush stack

LAB_1477
	CLC				; clear carry
	LDA	Smeml			; get start of mem low byte
	ADC	#$FF			; -1
	STA	Bpntrl		; save BASIC execute pointer low byte
	LDA	Smemh			; get start of mem high byte
	ADC	#$FF			; -1+carry
	STA	Bpntrh		; save BASIC execute pointer high byte

; "CLEAR" command gets here

LAB_147A
	LDA	Ememl			; get end of mem low byte
	LDY	Ememh			; get end of mem high byte
	STA	Sstorl		; set bottom of string space low byte
	STY	Sstorh		; set bottom of string space high byte
	LDA	Svarl			; get start of vars low byte
	LDY	Svarh			; get start of vars high byte
	STA	Sarryl		; save var mem end low byte
	STY	Sarryh		; save var mem end high byte
	STA	Earryl		; save array mem end low byte
	STY	Earryh		; save array mem end high byte
	JSR	LAB_161A		; perform RESTORE command

; flush stack and clear continue flag

LAB_1491
	LDX	#des_sk		; set descriptor stack pointer
	STX	next_s		; save descriptor stack pointer
	PLA				; pull return address low byte
	TAX				; copy return address low byte
	PLA				; pull return address high byte
	STX	LAB_SKFE		; save to cleared stack
	STA	LAB_SKFF		; save to cleared stack
	LDX	#$FD			; new stack pointer
	TXS				; reset stack
	LDA	#$00			; clear byte
	STA	Cpntrh		; clear continue pointer high byte
	STA	Sufnxf		; clear subscript/FNX flag
LAB_14A6
	RTS

; perform CLEAR

LAB_CLEAR
	BEQ	LAB_147A		; if no following token go do "CLEAR"

					; else there was a following token (go do syntax error)
	RTS

; perform LIST [n][-m]
; bigger, faster version (a _lot_ faster)

LAB_LIST
	BCC	LAB_14BD		; branch if next character numeric (LIST n..)

	BEQ	LAB_14BD		; branch if next character [NULL] (LIST)

	CMP	#TK_MINUS		; compare with token for -
	BNE	LAB_14A6		; exit if not - (LIST -m)

					; LIST [[n][-m]]
					; this bit sets the n , if present, as the start and end
LAB_14BD
	JSR	LAB_GFPN		; get fixed-point number into temp integer
	JSR	LAB_SSLN		; search BASIC for temp integer line number
					; (pointer in Baslnl/Baslnh)
	JSR	LAB_GBYT		; scan memory
	BEQ	LAB_14D4		; branch if no more characters

					; this bit checks the - is present
	CMP	#TK_MINUS		; compare with token for -
	BNE	LAB_1460		; return if not "-" (will be Syntax error)

					; LIST [n]-m
					; the - was there so set m as the end value
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_GFPN		; get fixed-point number into temp integer
	BNE	LAB_1460		; exit if not ok

LAB_14D4
	LDA	Itempl		; get temporary integer low byte
	ORA	Itemph		; OR temporary integer high byte
	BNE	LAB_14E2		; branch if start set

	LDA	#$FF			; set for -1
	STA	Itempl		; set temporary integer low byte
	STA	Itemph		; set temporary integer high byte
LAB_14E2
	LDY	#$01			; set index for line
	STY	Oquote		; clear open quote flag
	JSR	LAB_CRLF		; print CR/LF
	LDA	(Baslnl),Y		; get next line pointer high byte
					; pointer initially set by search at LAB_14BD
	BEQ	LAB_152B		; if null all done so exit
	JSR	LAB_1629		; do CRTL-C check vector

	INY				; increment index for line
	LDA	(Baslnl),Y		; get line # low byte
	TAX				; copy to X
	INY				; increment index
	LDA	(Baslnl),Y		; get line # high byte
	CMP	Itemph		; compare with temporary integer high byte
	BNE	LAB_14FF		; branch if no high byte match

	CPX	Itempl		; compare with temporary integer low byte
	BEQ	LAB_1501		; branch if = last line to do (< will pass next branch)

LAB_14FF				; else ..
	BCS	LAB_152B		; if greater all done so exit

LAB_1501
	STY	Tidx1			; save index for line
	JSR	LAB_295E		; print XA as unsigned integer
	LDA	#$20			; space is the next character
LAB_1508
	LDY	Tidx1			; get index for line
	AND	#$7F			; mask top out bit of character
LAB_150C
	JSR	LAB_PRNA		; go print the character
	CMP	#$22			; was it " character
	BNE	LAB_1519		; branch if not

					; we are either entering or leaving a pair of quotes
	LDA	Oquote		; get open quote flag
	EOR	#$FF			; toggle it
	STA	Oquote		; save it back
LAB_1519
	INY				; increment index
	LDA	(Baslnl),Y		; get next byte
	BNE	LAB_152E		; branch if not [EOL] (go print character)
	TAY				; else clear index
	LDA	(Baslnl),Y		; get next line pointer low byte
	TAX				; copy to X
	INY				; increment index
	LDA	(Baslnl),Y		; get next line pointer high byte
	STX	Baslnl		; set pointer to line low byte
	STA	Baslnh		; set pointer to line high byte
	BNE	LAB_14E2		; go do next line if not [EOT]
					; else ..
LAB_152B
	RTS

LAB_152E
	BPL	LAB_150C		; just go print it if not token byte

					; else was token byte so uncrunch it (maybe)
	BIT	Oquote		; test the open quote flag
	BMI	LAB_150C		; just go print character if open quote set

	LDX	#>LAB_KEYT		; get table address high byte
	ASL				; *2
	ASL				; *4
	BCC	LAB_152F		; branch if no carry

	INX				; else increment high byte
	CLC				; clear carry for add
LAB_152F
	ADC	#<LAB_KEYT		; add low byte
	BCC	LAB_1530		; branch if no carry

	INX				; else increment high byte
LAB_1530
	STA	ut2_pl		; save table pointer low byte
	STX	ut2_ph		; save table pointer high byte
	STY	Tidx1			; save index for line
	LDY	#$00			; clear index
	LDA	(ut2_pl),Y		; get length
	TAX				; copy length
	INY				; increment index
	LDA	(ut2_pl),Y		; get 1st character
	DEX				; decrement length
	BEQ	LAB_1508		; if no more characters exit and print

	JSR	LAB_PRNA		; go print the character
	INY				; increment index
	LDA	(ut2_pl),Y		; get keyword address low byte
	PHA				; save it for now
	INY				; increment index
	LDA	(ut2_pl),Y		; get keyword address high byte
	LDY	#$00
	STA	ut2_ph		; save keyword pointer high byte
	PLA				; pull low byte
	STA	ut2_pl		; save keyword pointer low byte
LAB_1540
	LDA	(ut2_pl),Y		; get character
	DEX				; decrement character count
	BEQ	LAB_1508		; if last character exit and print

	JSR	LAB_PRNA		; go print the character
	INY				; increment index
	BNE	LAB_1540		; loop for next character

; perform FOR

LAB_FOR
	LDA	#$80			; set FNX
	STA	Sufnxf		; set subscript/FNX flag
	JSR	LAB_LET		; go do LET
	PLA				; pull return address
	PLA				; pull return address
	LDA	#$10			; we need 16d bytes !
	JSR	LAB_1212		; check room on stack for A bytes
	JSR	LAB_SNBS		; scan for next BASIC statement ([:] or [EOL])
	CLC				; clear carry for add
	TYA				; copy index to A
	ADC	Bpntrl		; add BASIC execute pointer low byte
	PHA				; push onto stack
	LDA	Bpntrh		; get BASIC execute pointer high byte
	ADC	#$00			; add carry
	PHA				; push onto stack
	LDA	Clineh		; get current line high byte
	PHA				; push onto stack
	LDA	Clinel		; get current line low byte
	PHA				; push onto stack
	LDA	#TK_TO		; get "TO" token
	JSR	LAB_SCCA		; scan for CHR$(A) , else do syntax error then warm start
	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	LDA	FAC1_s		; get FAC1 sign (b7)
	ORA	#$7F			; set all non sign bits
	AND	FAC1_1		; and FAC1 mantissa1
	STA	FAC1_1		; save FAC1 mantissa1
	LDA	#<LAB_159F		; set return address low byte
	LDY	#>LAB_159F		; set return address high byte
	STA	ut1_pl		; save return address low byte
	STY	ut1_ph		; save return address high byte
	JMP	LAB_1B66		; round FAC1 and put on stack (returns to next instruction)

LAB_159F
	LDA	#<LAB_259C		; set 1 pointer low addr (default step size)
	LDY	#>LAB_259C		; set 1 pointer high addr
	JSR	LAB_UFAC		; unpack memory (AY) into FAC1
	JSR	LAB_GBYT		; scan memory
	CMP	#TK_STEP		; compare with STEP token
	BNE	LAB_15B3		; jump if not "STEP"

					;.was step so ..
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
LAB_15B3
	JSR	LAB_27CA		; return A=FF,C=1/-ve A=01,C=0/+ve
	STA	FAC1_s		; set FAC1 sign (b7)
					; this is +1 for +ve step and -1 for -ve step, in NEXT we
					; compare the FOR value and the TO value and return +1 if
					; FOR > TO, 0 if FOR = TO and -1 if FOR < TO. the value
					; here (+/-1) is then compared to that result and if they
					; are the same (+ve and FOR > TO or -ve and FOR < TO) then
					; the loop is done
	JSR	LAB_1B5B		; push sign, round FAC1 and put on stack
	LDA	Frnxth		; get var pointer for FOR/NEXT high byte
	PHA				; push on stack
	LDA	Frnxtl		; get var pointer for FOR/NEXT low byte
	PHA				; push on stack
	LDA	#TK_FOR		; get FOR token
	PHA				; push on stack

; interpreter inner loop
message "LAB_15C2"
LAB_15C2
	JSR	LAB_1629		; do CRTL-C check vector
	LDA	Bpntrl		; get BASIC execute pointer low byte
	LDY	Bpntrh		; get BASIC execute pointer high byte

	LDX	Clineh		; continue line is $FFxx for immediate mode
					; ($00xx for RUN from immediate mode)
	INX				; increment it (now $00 if immediate mode)
	BEQ	LAB_15D1		; branch if null (immediate mode)

	STA	Cpntrl		; save continue pointer low byte
	STY	Cpntrh		; save continue pointer high byte
LAB_15D1
	LDY	#$00			; clear index
	LDA	(Bpntrl),Y		; get next byte
	BEQ	LAB_15DC		; branch if null [EOL]

	CMP	#':'			; compare with ":"
	BEQ	LAB_15F6		; branch if = (statement separator)

LAB_15D9
	JMP	LAB_SNER		; else syntax error then warm start

					; have reached [EOL]
LAB_15DC
	LDY	#$02			; set index
	LDA	(Bpntrl),Y		; get next line pointer high byte
	CLC				; clear carry for no "BREAK" message
	BEQ	LAB_1651		; if null go to immediate mode (was immediate or [EOT]
					; marker)

	INY				; increment index
	LDA	(Bpntrl),Y		; get line # low byte
	STA	Clinel		; save current line low byte
	INY				; increment index
	LDA	(Bpntrl),Y		; get line # high byte
	STA	Clineh		; save current line high byte
	TYA				; A now = 4
	ADC	Bpntrl		; add BASIC execute pointer low byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	BCC	LAB_15F6		; branch if no overflow

	INC	Bpntrh		; else increment BASIC execute pointer high byte
LAB_15F6
	JSR	LAB_IGBY		; increment and scan memory

LAB_15F9
	JSR	LAB_15FF		; go interpret BASIC code from (Bpntrl)

LAB_15FC
	JMP	LAB_15C2		; loop

; interpret BASIC code from (Bpntrl)

LAB_15FF
	BEQ	LAB_1628		; exit if zero [EOL]

LAB_1602
	ASL				; *2 bytes per vector and normalise token
	BCS	LAB_1609		; branch if was token

	JMP	LAB_LET		; else go do implied LET
message "LAB_1609"
LAB_1609
	CMP	#[TK_TAB-$80]*2	; compare normalised token * 2 with TAB
	BCS	LAB_15D9		; branch if A>=TAB (do syntax error then warm start)
					; only tokens before TAB can start a line
	TAY				; copy to index
	LDA	LAB_CTBL+1,Y	; get vector high byte
	PHA				; onto stack
	LDA	LAB_CTBL,Y		; get vector low byte
	PHA				; onto stack
	JMP	LAB_IGBY		; jump to increment and scan memory
					; then "return" to vector

; CTRL-C check jump. this is called as a subroutine but exits back via a jump if a
; key press is detected.
message "LAB_1629"
LAB_1629
	JMP	(VEC_CC)		; ctrl c check vector

; if there was a key press it gets back here ..

LAB_1636
	CMP	#$03			; compare with CTRL-C

; perform STOP

LAB_STOP
	BCS	LAB_163B		; branch if token follows STOP
					; else just END
; END

LAB_END
	CLC				; clear the carry, indicate a normal program end
LAB_163B
	BNE	LAB_167A		; if wasn't CTRL-C or there is a following byte return

	LDA	Bpntrh		; get the BASIC execute pointer high byte
	EOR	#>Ibuffs		; compare with buffer address high byte (Cb unchanged)
	BEQ	LAB_164F		; branch if the BASIC pointer is in the input buffer
					; (can't continue in immediate mode)

					; else ..
	EOR	#>Ibuffs		; correct the bits
	LDY	Bpntrl		; get BASIC execute pointer low byte
	STY	Cpntrl		; save continue pointer low byte
	STA	Cpntrh		; save continue pointer high byte
LAB_1647
	LDA	Clinel		; get current line low byte
	LDY	Clineh		; get current line high byte
	STA	Blinel		; save break line low byte
	STY	Blineh		; save break line high byte
LAB_164F
	PLA				; pull return address low
	PLA				; pull return address high
LAB_1651
	BCC	LAB_165E		; if was program end just do warm start

					; else ..
	LDA	#<LAB_BMSG		; point to "Break" low byte
	LDY	#>LAB_BMSG		; point to "Break" high byte
	JMP	LAB_1269		; print "Break" and do warm start

LAB_165E
	JMP	LAB_1274		; go do warm start

; perform RESTORE

LAB_RESTORE
	BNE	LAB_RESTOREn	; branch if next character not null (RESTORE n)

LAB_161A
	SEC				; set carry for subtract
	LDA	Smeml			; get start of mem low byte
	SBC	#$01			; -1
	LDY	Smemh			; get start of mem high byte
	BCS	LAB_1624		; branch if no underflow

LAB_uflow
	DEY				; else decrement high byte
LAB_1624
	STA	Dptrl			; save DATA pointer low byte
	STY	Dptrh			; save DATA pointer high byte
LAB_1628
	RTS

					; is RESTORE n
LAB_RESTOREn
	JSR	LAB_GFPN		; get fixed-point number into temp integer
	JSR	LAB_SNBL		; scan for next BASIC line
	LDA	Clineh		; get current line high byte
	CMP	Itemph		; compare with temporary integer high byte
	BCS	LAB_reset_search	; branch if >= (start search from beginning)

	TYA				; else copy line index to A
	SEC				; set carry (+1)
	ADC	Bpntrl		; add BASIC execute pointer low byte
	LDX	Bpntrh		; get BASIC execute pointer high byte
	BCC	LAB_go_search	; branch if no overflow to high byte

	INX				; increment high byte
	BCS	LAB_go_search	; branch always (can never be carry clear)

; search for line # in temp (Itempl/Itemph) from start of mem pointer (Smeml)

LAB_reset_search
	LDA	Smeml			; get start of mem low byte
	LDX	Smemh			; get start of mem high byte

; search for line # in temp (Itempl/Itemph) from (AX)

LAB_go_search

	JSR	LAB_SHLN		; search Basic for temp integer line number from AX
	BCS	LAB_line_found	; if carry set go set pointer

	JMP	LAB_16F7		; else go do "Undefined statement" error

LAB_line_found
					; carry already set for subtract
	LDA	Baslnl		; get pointer low byte
	SBC	#$01			; -1
	LDY	Baslnh		; get pointer high byte
	BCS	LAB_1624		; branch if no underflow (save DATA pointer and return)

	BCC	LAB_uflow		; else decrement high byte then save DATA pointer and
					; return (branch always)

; perform NULL

LAB_NULL
	JSR	LAB_GTBY		; get byte parameter
	STX	Nullct		; save new NULL count
LAB_167A
	RTS

; perform CONT
message "LAB_CONT"
LAB_CONT
	BNE	LAB_167A		; if following byte exit to do syntax error

	LDY	Cpntrh		; get continue pointer high byte
	BNE	LAB_166C		; go do continue if we can

	LDX	#$1E			; error code $1E ("Can't continue" error)
	JMP	LAB_XERR		; do error #X, then warm start

					; we can continue so ..
LAB_166C
	LDA	#TK_ON		; set token for ON
	JSR	LAB_IRQ		; set IRQ flags
	LDA	#TK_ON		; set token for ON
	JSR	LAB_NMI		; set NMI flags

	STY	Bpntrh		; save BASIC execute pointer high byte
	LDA	Cpntrl		; get continue pointer low byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	LDA	Blinel		; get break line low byte
	LDY	Blineh		; get break line high byte
	STA	Clinel		; set current line low byte
	STY	Clineh		; set current line high byte
	RTS

; perform RUN

LAB_RUN
	BNE	LAB_1696		; branch if RUN n
	JMP	LAB_1477		; reset execution to start, clear variables, flush stack and
					; return

; does RUN n

LAB_1696
	JSR	LAB_147A		; go do "CLEAR"
	BEQ	LAB_16B0		; get n and do GOTO n (branch always as CLEAR sets Z=1)

; perform DO

LAB_DO
	LDA	#$05			; need 5 bytes for DO
	JSR	LAB_1212		; check room on stack for A bytes
	LDA	Bpntrh		; get BASIC execute pointer high byte
	PHA				; push on stack
	LDA	Bpntrl		; get BASIC execute pointer low byte
	PHA				; push on stack
	LDA	Clineh		; get current line high byte
	PHA				; push on stack
	LDA	Clinel		; get current line low byte
	PHA				; push on stack
	LDA	#TK_DO		; token for DO
	PHA				; push on stack
	JSR	LAB_GBYT		; scan memory
	JMP	LAB_15C2		; go do interpreter inner loop

; perform GOSUB

LAB_GOSUB
	LDA	#$05			; need 5 bytes for GOSUB
	JSR	LAB_1212		; check room on stack for A bytes
	LDA	Bpntrh		; get BASIC execute pointer high byte
	PHA				; push on stack
	LDA	Bpntrl		; get BASIC execute pointer low byte
	PHA				; push on stack
	LDA	Clineh		; get current line high byte
	PHA				; push on stack
	LDA	Clinel		; get current line low byte
	PHA				; push on stack
	LDA	#TK_GOSUB		; token for GOSUB
	PHA				; push on stack
LAB_16B0
	JSR	LAB_GBYT		; scan memory
	JSR	LAB_GOTO		; perform GOTO n
	JMP	LAB_15C2		; go do interpreter inner loop
					; (can't RTS, we used the stack!)

; perform GOTO

LAB_GOTO
	JSR	LAB_GFPN		; get fixed-point number into temp integer
	JSR	LAB_SNBL		; scan for next BASIC line
	LDA	Clineh		; get current line high byte
	CMP	Itemph		; compare with temporary integer high byte
	BCS	LAB_16D0		; branch if >= (start search from beginning)

	TYA				; else copy line index to A
	SEC				; set carry (+1)
	ADC	Bpntrl		; add BASIC execute pointer low byte
	LDX	Bpntrh		; get BASIC execute pointer high byte
	BCC	LAB_16D4		; branch if no overflow to high byte

	INX				; increment high byte
	BCS	LAB_16D4		; branch always (can never be carry)

; search for line # in temp (Itempl/Itemph) from start of mem pointer (Smeml)

LAB_16D0
	LDA	Smeml			; get start of mem low byte
	LDX	Smemh			; get start of mem high byte

; search for line # in temp (Itempl/Itemph) from (AX)

LAB_16D4
	JSR	LAB_SHLN		; search Basic for temp integer line number from AX
	BCC	LAB_16F7		; if carry clear go do "Undefined statement" error
					; (unspecified statement)

					; carry already set for subtract
	LDA	Baslnl		; get pointer low byte
	SBC	#$01			; -1
	STA	Bpntrl		; save BASIC execute pointer low byte
	LDA	Baslnh		; get pointer high byte
	SBC	#$00			; subtract carry
	STA	Bpntrh		; save BASIC execute pointer high byte
LAB_16E5
	RTS

LAB_DONOK
	LDX	#$22			; error code $22 ("LOOP without DO" error)
	JMP	LAB_XERR		; do error #X, then warm start

; perform LOOP

LAB_LOOP
	TAY				; save following token
	TSX				; copy stack pointer
	LDA	LAB_STAK+3,X	; get token byte from stack
	CMP	#TK_DO		; compare with DO token
	BNE	LAB_DONOK		; branch if no matching DO

	INX				; dump calling routine return address
	INX				; dump calling routine return address
	TXS				; correct stack
	TYA				; get saved following token back
	BEQ	LoopAlways		; if no following token loop forever
					; (stack pointer in X)

	CMP	#':'			; could be ':'
	BEQ	LoopAlways		; if :... loop forever

	SBC	#TK_UNTIL		; subtract token for UNTIL, we know carry is set here
	TAX				; copy to X (if it was UNTIL then Y will be correct)
	BEQ	DoRest		; branch if was UNTIL

	DEX				; decrement result
	BNE	LAB_16FC		; if not WHILE go do syntax error and warm start
					; only if the token was WHILE will this fail

	DEX				; set invert result byte
DoRest
	STX	Frnxth		; save invert result byte
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_EVEX		; evaluate expression
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	DoCmp			; if =0 go do straight compare

	LDA	#$FF			; else set all bits
DoCmp
	TSX				; copy stack pointer
	EOR	Frnxth		; EOR with invert byte
	BNE	LoopDone		; if <> 0 clear stack and back to interpreter loop

					; loop condition wasn't met so do it again
LoopAlways
	LDA	LAB_STAK+2,X	; get current line low byte
	STA	Clinel		; save current line low byte
	LDA	LAB_STAK+3,X	; get current line high byte
	STA	Clineh		; save current line high byte
	LDA	LAB_STAK+4,X	; get BASIC execute pointer low byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	LDA	LAB_STAK+5,X	; get BASIC execute pointer high byte
	STA	Bpntrh		; save BASIC execute pointer high byte
	JSR	LAB_GBYT		; scan memory
	JMP	LAB_15C2		; go do interpreter inner loop

					; clear stack and back to interpreter loop
LoopDone
	INX				; dump DO token
	INX				; dump current line low byte
	INX				; dump current line high byte
	INX				; dump BASIC execute pointer low byte
	INX				; dump BASIC execute pointer high byte
	TXS				; correct stack
	JMP	LAB_DATA		; go perform DATA (find : or [EOL])

; do the return without gosub error

LAB_16F4
	LDX	#$04			; error code $04 ("RETURN without GOSUB" error)
	.byte	$2C			; makes next line BIT LAB_0EA2

LAB_16F7				; do undefined statement error
	LDX	#$0E			; error code $0E ("Undefined statement" error)
	JMP	LAB_XERR		; do error #X, then warm start

; perform RETURN

LAB_RETURN
	BNE	LAB_16E5		; exit if following token (to allow syntax error)

LAB_16E8
	PLA				; dump calling routine return address
	PLA				; dump calling routine return address
	PLA				; pull token
	CMP	#TK_GOSUB		; compare with GOSUB token
	BNE	LAB_16F4		; branch if no matching GOSUB

LAB_16FF
	PLA				; pull current line low byte
	STA	Clinel		; save current line low byte
	PLA				; pull current line high byte
	STA	Clineh		; save current line high byte
	PLA				; pull BASIC execute pointer low byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	PLA				; pull BASIC execute pointer high byte
	STA	Bpntrh		; save BASIC execute pointer high byte

					; now do the DATA statement as we could be returning into
					; the middle of an ON <var> GOSUB n,m,p,q line
					; (the return address used by the DATA statement is the one
					; pushed before the GOSUB was executed!)

; perform DATA

LAB_DATA
	JSR	LAB_SNBS		; scan for next BASIC statement ([:] or [EOL])

					; set BASIC execute pointer
LAB_170F
	TYA				; copy index to A
	CLC				; clear carry for add
	ADC	Bpntrl		; add BASIC execute pointer low byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	BCC	LAB_1719		; skip next if no carry

	INC	Bpntrh		; else increment BASIC execute pointer high byte
LAB_1719
	RTS

LAB_16FC
	JMP	LAB_SNER		; do syntax error then warm start

; scan for next BASIC statement ([:] or [EOL])
; returns Y as index to [:] or [EOL]

LAB_SNBS
	LDX	#':'			; set look for character = ":"
	.byte	$2C			; makes next line BIT $00A2

; scan for next BASIC line
; returns Y as index to [EOL]

LAB_SNBL
	LDX	#$00			; set alt search character = [EOL]
	LDY	#$00			; set search character = [EOL]
	STY	Asrch			; store search character
LAB_1725
	TXA				; get alt search character
	EOR	Asrch			; toggle search character, effectively swap with $00
	STA	Asrch			; save swapped search character
LAB_172D
	LDA	(Bpntrl),Y		; get next byte
	BEQ	LAB_1719		; exit if null [EOL]

	CMP	Asrch			; compare with search character
	BEQ	LAB_1719		; exit if found

	INY				; increment index
	CMP	#$22			; compare current character with open quote
	BNE	LAB_172D		; if not open quote go get next character

	BEQ	LAB_1725		; if found go swap search character for alt search character

; perform IF

LAB_IF
	JSR	LAB_EVEX		; evaluate the expression
	JSR	LAB_GBYT		; scan memory
	CMP	#TK_THEN		; compare with THEN token
	BEQ	LAB_174B		; if it was THEN go do IF

					; wasn't IF .. THEN so must be IF .. GOTO
	CMP	#TK_GOTO		; compare with GOTO token
	BNE	LAB_16FC		; if it wasn't GOTO go do syntax error

	LDX	Bpntrl		; save the basic pointer low byte
	LDY	Bpntrh		; save the basic pointer high byte
	JSR	LAB_IGBY		; increment and scan memory
	BCS	LAB_16FC		; if not numeric go do syntax error

	STX	Bpntrl		; restore the basic pointer low byte
	STY	Bpntrh		; restore the basic pointer high byte
LAB_174B
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_174E		; if the result was zero go look for an ELSE

	JSR	LAB_IGBY		; else increment and scan memory
	BCS	LAB_174D		; if not numeric go do var or keyword

LAB_174C
	JMP	LAB_GOTO		; else was numeric so do GOTO n
message "LAB_174D"
					; is var or keyword
LAB_174D
	CMP	#TK_RETURN		; compare the byte with the token for RETURN
	BNE	LAB_174G		; if it wasn't RETURN go interpret BASIC code from (Bpntrl)
					; and return to this code to process any following code

	JMP	LAB_1602		; else it was RETURN so interpret BASIC code from (Bpntrl)
					; but don't return here

LAB_174G
	JSR	LAB_15FF		; interpret BASIC code from (Bpntrl)

; the IF was executed and there may be a following ELSE so the code needs to return
; here to check and ignore the ELSE if present

	LDY	#$00			; clear the index
	LDA	(Bpntrl),Y		; get the next BASIC byte
	CMP	#TK_ELSE		; compare it with the token for ELSE
	BEQ	LAB_DATA		; if ELSE ignore the following statement

; there was no ELSE so continue execution of IF <expr> THEN <stat> [: <stat>]. any
; following ELSE will, correctly, cause a syntax error

	RTS				; else return to the interpreter inner loop

; perform ELSE after IF

LAB_174E
	LDY	#$00			; clear the BASIC byte index
	LDX	#$01			; clear the nesting depth
LAB_1750
	INY				; increment the BASIC byte index
	LDA	(Bpntrl),Y		; get the next BASIC byte
	BEQ	LAB_1753		; if EOL go add the pointer and return

	CMP	#TK_IF		; compare the byte with the token for IF
	BNE	LAB_1752		; if not IF token skip the depth increment

	INX				; else increment the nesting depth ..
	BNE	LAB_1750		; .. and continue looking

LAB_1752
	CMP	#TK_ELSE		; compare the byte with the token for ELSE
	BNE	LAB_1750		; if not ELSE token continue looking

	DEX				; was ELSE so decrement the nesting depth
	BNE	LAB_1750		; loop if still nested

	INY				; increment the BASIC byte index past the ELSE

; found the matching ELSE, now do <{n|statement}>

LAB_1753
	TYA				; else copy line index to A
	CLC				; clear carry for add
	ADC	Bpntrl		; add the BASIC execute pointer low byte
	STA	Bpntrl		; save the BASIC execute pointer low byte
	BCC	LAB_1754		; branch if no overflow to high byte

	INC	Bpntrh		; else increment the BASIC execute pointer high byte
LAB_1754
	JSR	LAB_GBYT		; scan memory
	BCC	LAB_174C		; if numeric do GOTO n
					; the code will return to the interpreter loop at the
					; tail end of the GOTO <n>

	JMP	LAB_15FF		; interpret BASIC code from (Bpntrl)
					; the code will return to the interpreter loop at the
					; tail end of the <statement>

; perform REM, skip (rest of) line

LAB_REM
	JSR	LAB_SNBL		; scan for next BASIC line
	JMP	LAB_170F		; go set BASIC execute pointer and return, branch always

LAB_16FD
	JMP	LAB_SNER		; do syntax error then warm start

; perform ON

LAB_ON
	CMP	#TK_IRQ		; was it IRQ token ?
	BNE	LAB_NOIN		; if not go check NMI

	JMP	LAB_SIRQ		; else go set-up IRQ

LAB_NOIN
	CMP	#TK_NMI		; was it NMI token ?
	BNE	LAB_NONM		; if not go do normal ON command

	JMP	LAB_SNMI		; else go set-up NMI

LAB_NONM
	JSR	LAB_GTBY		; get byte parameter
	PHA				; push GOTO/GOSUB token
	CMP	#TK_GOSUB		; compare with GOSUB token
	BEQ	LAB_176B		; branch if GOSUB

	CMP	#TK_GOTO		; compare with GOTO token
LAB_1767
	BNE	LAB_16FD		; if not GOTO do syntax error then warm start


; next character was GOTO or GOSUB

LAB_176B
	DEC	FAC1_3		; decrement index (byte value)
	BNE	LAB_1773		; branch if not zero

	PLA				; pull GOTO/GOSUB token
	JMP	LAB_1602		; go execute it

LAB_1773
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_GFPN		; get fixed-point number into temp integer (skip this n)
					; (we could LDX #',' and JSR LAB_SNBL+2, then we
					; just BNE LAB_176B for the loop. should be quicker ..
					; no we can't, what if we meet a colon or [EOL]?)
	CMP	#$2C			; compare next character with ","
	BEQ	LAB_176B		; loop if ","

LAB_177E
	PLA				; else pull keyword token (run out of options)
					; also dump +/-1 pointer low byte and exit
LAB_177F
	RTS

; takes n * 106 + 11 cycles where n is the number of digits

; get fixed-point number into temp integer

LAB_GFPN
	LDX	#$00			; clear reg
	STX	Itempl		; clear temporary integer low byte
LAB_1785
	STX	Itemph		; save temporary integer high byte
	BCS	LAB_177F		; return if carry set, end of scan, character was
					; not 0-9

	CPX	#$19			; compare high byte with $19
	TAY				; ensure Zb = 0 if the branch is taken
	BCS	LAB_1767		; branch if >=, makes max line # 63999 because next
					; bit does *$0A, = 64000, compare at target will fail
					; and do syntax error

	SBC	#'0'-1		; subtract "0", $2F + carry, from byte
	TAY				; copy binary digit
	LDA	Itempl		; get temporary integer low byte
	ASL				; *2 low byte
	ROL	Itemph		; *2 high byte
	ASL				; *2 low byte
	ROL	Itemph		; *2 high byte, *4
	ADC	Itempl		; + low byte, *5
	STA	Itempl		; save it
	TXA				; get high byte copy to A
	ADC	Itemph		; + high byte, *5
	ASL	Itempl		; *2 low byte, *10d
	ROL				; *2 high byte, *10d
	TAX				; copy high byte back to X
	TYA				; get binary digit back
	ADC	Itempl		; add number low byte
	STA	Itempl		; save number low byte
	BCC	LAB_17B3		; if no overflow to high byte get next character

	INX				; else increment high byte
LAB_17B3
	JSR	LAB_IGBY		; increment and scan memory
	JMP	LAB_1785		; loop for next character

; perform DEC

LAB_DEC
	LDA	#<LAB_2AFD		; set -1 pointer low byte
	.byte	$2C			; BIT abs to skip the LDA below

; perform INC

LAB_INC
	LDA	#<LAB_259C		; set 1 pointer low byte
LAB_17B5
	PHA				; save +/-1 pointer low byte
LAB_17B7
	JSR	LAB_GVAR		; get var address
	LDX	Dtypef		; get data type flag, $FF=string, $00=numeric
	BMI	IncrErr		; exit if string

	STA	Lvarpl		; save var address low byte
	STY	Lvarph		; save var address high byte
	JSR	LAB_UFAC		; unpack memory (AY) into FAC1
	PLA				; get +/-1 pointer low byte
	PHA				; save +/-1 pointer low byte
	LDY	#>LAB_259C		; set +/-1 pointer high byte (both the same)
	JSR	LAB_246C		; add (AY) to FAC1
	JSR	LAB_PFAC		; pack FAC1 into variable (Lvarpl)

	JSR	LAB_GBYT		; scan memory
	CMP	#','			; compare with ","
	BNE	LAB_177E		; exit if not "," (either end or error)

					; was "," so another INCR variable to do
	JSR	LAB_IGBY		; increment and scan memory
	JMP	LAB_17B7		; go do next var

IncrErr
	JMP	LAB_1ABC		; do "Type mismatch" error then warm start

; perform LET

LAB_LET
	JSR	LAB_GVAR		; get var address
	STA	Lvarpl		; save var address low byte
	STY	Lvarph		; save var address high byte
	LDA	#TK_EQUAL		; get = token
	JSR	LAB_SCCA		; scan for CHR$(A), else do syntax error then warm start
	LDA	Dtypef		; get data type flag, $FF=string, $00=numeric
	PHA				; push data type flag
	JSR	LAB_EVEX		; evaluate expression
	PLA				; pop data type flag
	ROL				; set carry if type = string
	JSR	LAB_CKTM		; type match check, set C for string
	BNE	LAB_17D5		; branch if string

	JMP	LAB_PFAC		; pack FAC1 into variable (Lvarpl) and return

; string LET

LAB_17D5
	LDY	#$02			; set index to pointer high byte
	LDA	(des_pl),Y		; get string pointer high byte
	CMP	Sstorh		; compare bottom of string space high byte
	BCC	LAB_17F4		; if less assign value and exit (was in program memory)

	BNE	LAB_17E6		; branch if >
					; else was equal so compare low bytes
	DEY				; decrement index
	LDA	(des_pl),Y		; get pointer low byte
	CMP	Sstorl		; compare bottom of string space low byte
	BCC	LAB_17F4		; if less assign value and exit (was in program memory)

					; pointer was >= to bottom of string space pointer
LAB_17E6
	LDY	des_ph		; get descriptor pointer high byte
	CPY	Svarh			; compare start of vars high byte
	BCC	LAB_17F4		; branch if less (descriptor is on stack)

	BNE	LAB_17FB		; branch if greater (descriptor is not on stack)

					; else high bytes were equal so ..
	LDA	des_pl		; get descriptor pointer low byte
	CMP	Svarl			; compare start of vars low byte
	BCS	LAB_17FB		; branch if >= (descriptor is not on stack)

LAB_17F4
	LDA	des_pl		; get descriptor pointer low byte
	LDY	des_ph		; get descriptor pointer high byte
	JMP	LAB_1811		; clean stack, copy descriptor to variable and return

					; make space and copy string
LAB_17FB
	LDY	#$00			; index to length
	LDA	(des_pl),Y		; get string length
	JSR	LAB_209C		; copy string
	LDA	des_2l		; get descriptor pointer low byte
	LDY	des_2h		; get descriptor pointer high byte
	STA	ssptr_l		; save descriptor pointer low byte
	STY	ssptr_h		; save descriptor pointer high byte
	JSR	LAB_228A		; copy string from descriptor (sdescr) to (Sutill)
	LDA	#<FAC1_e		; set descriptor pointer low byte
	LDY	#>FAC1_e		; get descriptor pointer high byte

					; clean stack and assign value to string variable
LAB_1811
	STA	des_2l		; save descriptor_2 pointer low byte
	STY	des_2h		; save descriptor_2 pointer high byte
	JSR	LAB_22EB		; clean descriptor stack, YA = pointer
	LDY	#$00			; index to length
	LDA	(des_2l),Y		; get string length
	STA	(Lvarpl),Y		; copy to let string variable
	INY				; index to string pointer low byte
	LDA	(des_2l),Y		; get string pointer low byte
	STA	(Lvarpl),Y		; copy to let string variable
	INY				; index to string pointer high byte
	LDA	(des_2l),Y		; get string pointer high byte
	STA	(Lvarpl),Y		; copy to let string variable
	RTS

; perform GET

LAB_GET
	JSR	LAB_GVAR		; get var address
	STA	Lvarpl		; save var address low byte
	STY	Lvarph		; save var address high byte
	JSR	INGET			; get input byte
	LDX	Dtypef		; get data type flag, $FF=string, $00=numeric
	BMI	LAB_GETS		; go get string character

					; was numeric get
	TAY				; copy character to Y
	JSR	LAB_1FD0		; convert Y to byte in FAC1
	JMP	LAB_PFAC		; pack FAC1 into variable (Lvarpl) and return

LAB_GETS
	PHA				; save character
	LDA	#$01			; string is single byte
	BCS	LAB_IsByte		; branch if byte received

	PLA				; string is null
LAB_IsByte
	JSR	LAB_MSSP		; make string space A bytes long A=$AC=length,
					; X=$AD=Sutill=ptr low byte, Y=$AE=Sutilh=ptr high byte
	BEQ	LAB_NoSt		; skip store if null string

	PLA				; get character back
	LDY	#$00			; clear index
	STA	(str_pl),Y		; save byte in string (byte IS string!)
LAB_NoSt
	JSR	LAB_RTST		; check for space on descriptor stack then put address
					; and length on descriptor stack and update stack pointers

	JMP	LAB_17D5		; do string LET and return

; perform PRINT

LAB_1829
	JSR	LAB_18C6		; print string from Sutill/Sutilh
LAB_182C
	JSR	LAB_GBYT		; scan memory

; PRINT

LAB_PRINT
	BEQ	LAB_CRLF		; if nothing following just print CR/LF

LAB_1831
	CMP	#TK_TAB		; compare with TAB( token
	BEQ	LAB_18A2		; go do TAB/SPC

	CMP	#TK_SPC		; compare with SPC( token
	BEQ	LAB_18A2		; go do TAB/SPC

	CMP	#','			; compare with ","
	BEQ	LAB_188B		; go do move to next TAB mark

	CMP	#';'			; compare with ";"
	BEQ	LAB_18BD		; if ";" continue with PRINT processing

	JSR	LAB_EVEX		; evaluate expression
	BIT	Dtypef		; test data type flag, $FF=string, $00=numeric
	BMI	LAB_1829		; branch if string

	JSR	LAB_296E		; convert FAC1 to string
	JSR	LAB_20AE		; print " terminated string to Sutill/Sutilh
	LDY	#$00			; clear index

; don't check fit if terminal width byte is zero

	LDA	TWidth		; get terminal width byte
	BEQ	LAB_185E		; skip check if zero

	SEC				; set carry for subtract
	SBC	TPos			; subtract terminal position
	SBC	(des_pl),Y		; subtract string length
	BCS	LAB_185E		; branch if less than terminal width

	JSR	LAB_CRLF		; else print CR/LF
LAB_185E
	JSR	LAB_18C6		; print string from Sutill/Sutilh
	BEQ	LAB_182C		; always go continue processing line

; CR/LF return to BASIC from BASIC input handler

LAB_1866
	LDA	#$00			; clear byte
	STA	Ibuffs,X		; null terminate input
	LDX	#<Ibuffs		; set X to buffer start-1 low byte
	LDY	#>Ibuffs		; set Y to buffer start-1 high byte

; print CR/LF

LAB_CRLF
	LDA	#$0D			; load [CR]
	JSR	LAB_PRNA		; go print the character
	LDA	#$0A			; load [LF]
	BNE	LAB_PRNA		; go print the character and return, branch always

LAB_188B
	LDA	TPos			; get terminal position
	CMP	Iclim			; compare with input column limit
	BCC	LAB_1897		; branch if less

	JSR	LAB_CRLF		; else print CR/LF (next line)
	BNE	LAB_18BD		; continue with PRINT processing (branch always)

LAB_1897
	SEC				; set carry for subtract
LAB_1898
	SBC	TabSiz		; subtract TAB size
	BCS	LAB_1898		; loop if result was +ve

	EOR	#$FF			; complement it
	ADC	#$01			; +1 (twos complement)
	BNE	LAB_18B6		; always print A spaces (result is never $00)

					; do TAB/SPC
LAB_18A2
	PHA				; save token
	JSR	LAB_SGBY		; scan and get byte parameter
	CMP	#$29			; is next character )
	BNE	LAB_1910		; if not do syntax error then warm start

	PLA				; get token back
	CMP	#TK_TAB		; was it TAB ?
	BNE	LAB_18B7		; if not go do SPC

					; calculate TAB offset
	TXA				; copy integer value to A
	SBC	TPos			; subtract terminal position
	BCC	LAB_18BD		; branch if result was < 0 (can't TAB backwards)

					; print A spaces
LAB_18B6
	TAX				; copy result to X
LAB_18B7
	TXA				; set flags on size for SPC
	BEQ	LAB_18BD		; branch if result was = $0, already here

					; print X spaces
LAB_18BA
	JSR	LAB_18E0		; print " "
	DEX				; decrement count
	BNE	LAB_18BA		; loop if not all done

					; continue with PRINT processing
LAB_18BD
	JSR	LAB_IGBY		; increment and scan memory
	BNE	LAB_1831		; if more to print go do it

	RTS

; print null terminated string from memory

LAB_18C3
	JSR	LAB_20AE		; print " terminated string to Sutill/Sutilh

; print string from Sutill/Sutilh

LAB_18C6
	JSR	LAB_22B6		; pop string off descriptor stack, or from top of string
					; space returns with A = length, X=$71=pointer low byte,
					; Y=$72=pointer high byte
	LDY	#$00			; reset index
	TAX				; copy length to X
	BEQ	LAB_188C		; exit (RTS) if null string

LAB_18CD

	LDA	(ut1_pl),Y		; get next byte
	JSR	LAB_PRNA		; go print the character
	INY				; increment index
	DEX				; decrement count
	BNE	LAB_18CD		; loop if not done yet

	RTS

					; Print single format character
; print " "

LAB_18E0
	LDA	#$20			; load " "
	.byte	$2C			; change next line to BIT LAB_3FA9

; print "?" character

LAB_18E3
	LDA	#$3F			; load "?" character

; print character in A
; now includes the null handler
; also includes infinite line length code
; note! some routines expect this one to exit with Zb=0

LAB_PRNA
	CMP	#' '			; compare with " "
	BCC	LAB_18F9		; branch if less (non printing)

					; else printable character
	PHA				; save the character

; don't check fit if terminal width byte is zero

	LDA	TWidth		; get terminal width
	BNE	LAB_18F0		; branch if not zero (not infinite length)

; is "infinite line" so check TAB position

	LDA	TPos			; get position
	SBC	TabSiz		; subtract TAB size, carry set by CMP #$20 above
	BNE	LAB_18F7		; skip reset if different

	STA	TPos			; else reset position
	BEQ	LAB_18F7		; go print character

LAB_18F0
	CMP	TPos			; compare with terminal character position
	BNE	LAB_18F7		; branch if not at end of line

	JSR	LAB_CRLF		; else print CR/LF
LAB_18F7
	INC	TPos			; increment terminal position
	PLA				; get character back
LAB_18F9
	JSR	V_OUTP		; output byte via output vector
	CMP	#$0D			; compare with [CR]
	BNE	LAB_188A		; branch if not [CR]

					; else print nullct nulls after the [CR]
	STX	TempB			; save buffer index
	LDX	Nullct		; get null count
	BEQ	LAB_1886		; branch if no nulls

	LDA	#$00			; load [NULL]
LAB_1880
	JSR	LAB_PRNA		; go print the character
	DEX				; decrement count
	BNE	LAB_1880		; loop if not all done

	LDA	#$0D			; restore the character (and set the flags)
LAB_1886
	STX	TPos			; clear terminal position (X always = zero when we get here)
	LDX	TempB			; restore buffer index
LAB_188A
	AND	#$FF			; set the flags
LAB_188C
	RTS

; handle bad input data

LAB_1904
	LDA	Imode			; get input mode flag, $00=INPUT, $00=READ
	BPL	LAB_1913		; branch if INPUT (go do redo)

	LDA	Dlinel		; get current DATA line low byte
	LDY	Dlineh		; get current DATA line high byte
	STA	Clinel		; save current line low byte
	STY	Clineh		; save current line high byte
LAB_1910
	JMP	LAB_SNER		; do syntax error then warm start

					; mode was INPUT
LAB_1913
	LDA	#<LAB_REDO		; point to redo message (low addr)
	LDY	#>LAB_REDO		; point to redo message (high addr)
	JSR	LAB_18C3		; print null terminated string from memory
	LDA	Cpntrl		; get continue pointer low byte
	LDY	Cpntrh		; get continue pointer high byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	STY	Bpntrh		; save BASIC execute pointer high byte
	RTS

; perform INPUT

LAB_INPUT
	CMP	#$22			; compare next byte with open quote
	BNE	LAB_1934		; branch if no prompt string

	JSR	LAB_1BC1		; print "..." string
	LDA	#$3B			; load A with ";"
	JSR	LAB_SCCA		; scan for CHR$(A), else do syntax error then warm start
	JSR	LAB_18C6		; print string from Sutill/Sutilh

					; done with prompt, now get data
LAB_1934
	JSR	LAB_CKRN		; check not Direct, back here if ok
	JSR	LAB_INLN		; print "? " and get BASIC input
	LDA	#$00			; set mode = INPUT
	CMP	Ibuffs		; test first byte in buffer
	BNE	LAB_1953		; branch if not null input

	CLC				; was null input so clear carry to exit program
	JMP	LAB_1647		; go do BREAK exit

; perform READ

LAB_READ
	LDX	Dptrl			; get DATA pointer low byte
	LDY	Dptrh			; get DATA pointer high byte
	LDA	#$80			; set mode = READ

LAB_1953
	STA	Imode			; set input mode flag, $00=INPUT, $80=READ
	STX	Rdptrl		; save READ pointer low byte
	STY	Rdptrh		; save READ pointer high byte

					; READ or INPUT next variable from list
LAB_195B
	JSR	LAB_GVAR		; get (var) address
	STA	Lvarpl		; save address low byte
	STY	Lvarph		; save address high byte
	LDA	Bpntrl		; get BASIC execute pointer low byte
	LDY	Bpntrh		; get BASIC execute pointer high byte
	STA	Itempl		; save as temporary integer low byte
	STY	Itemph		; save as temporary integer high byte
	LDX	Rdptrl		; get READ pointer low byte
	LDY	Rdptrh		; get READ pointer high byte
	STX	Bpntrl		; set BASIC execute pointer low byte
	STY	Bpntrh		; set BASIC execute pointer high byte
	JSR	LAB_GBYT		; scan memory
	BNE	LAB_1988		; branch if not null

					; pointer was to null entry
	BIT	Imode			; test input mode flag, $00=INPUT, $80=READ
	BMI	LAB_19DD		; branch if READ

					; mode was INPUT
	JSR	LAB_18E3		; print "?" character (double ? for extended input)
	JSR	LAB_INLN		; print "? " and get BASIC input
	STX	Bpntrl		; set BASIC execute pointer low byte
	STY	Bpntrh		; set BASIC execute pointer high byte
LAB_1985
	JSR	LAB_GBYT		; scan memory
LAB_1988
	BIT	Dtypef		; test data type flag, $FF=string, $00=numeric
	BPL	LAB_19B0		; branch if numeric

					; else get string
	STA	Srchc			; save search character
	CMP	#$22			; was it " ?
	BEQ	LAB_1999		; branch if so

	LDA	#':'			; else search character is ":"
	STA	Srchc			; set new search character
	LDA	#','			; other search character is ","
	CLC				; clear carry for add
LAB_1999
	STA	Asrch			; set second search character
	LDA	Bpntrl		; get BASIC execute pointer low byte
	LDY	Bpntrh		; get BASIC execute pointer high byte

	ADC	#$00			; c is =1 if we came via the BEQ LAB_1999, else =0
	BCC	LAB_19A4		; branch if no execute pointer low byte rollover

	INY				; else increment high byte
LAB_19A4
	JSR	LAB_20B4		; print Srchc or Asrch terminated string to Sutill/Sutilh
	JSR	LAB_23F3		; restore BASIC execute pointer from temp (Btmpl/Btmph)
	JSR	LAB_17D5		; go do string LET
	JMP	LAB_19B6		; go check string terminator

					; get numeric INPUT
LAB_19B0
	JSR	LAB_2887		; get FAC1 from string
	JSR	LAB_PFAC		; pack FAC1 into (Lvarpl)
LAB_19B6
	JSR	LAB_GBYT		; scan memory
	BEQ	LAB_19C5		; branch if null (last entry)

	CMP	#','			; else compare with ","
	BEQ	LAB_19C2		; branch if ","

	JMP	LAB_1904		; else go handle bad input data

					; got good input data
LAB_19C2
	JSR	LAB_IGBY		; increment and scan memory
LAB_19C5
	LDA	Bpntrl		; get BASIC execute pointer low byte (temp READ/INPUT ptr)
	LDY	Bpntrh		; get BASIC execute pointer high byte (temp READ/INPUT ptr)
	STA	Rdptrl		; save for now
	STY	Rdptrh		; save for now
	LDA	Itempl		; get temporary integer low byte (temp BASIC execute ptr)
	LDY	Itemph		; get temporary integer high byte (temp BASIC execute ptr)
	STA	Bpntrl		; set BASIC execute pointer low byte
	STY	Bpntrh		; set BASIC execute pointer high byte
	JSR	LAB_GBYT		; scan memory
	BEQ	LAB_1A03		; if null go do extra ignored message

	JSR	LAB_1C01		; else scan for "," , else do syntax error then warm start
	JMP	LAB_195B		; go INPUT next variable from list

					; find next DATA statement or do "Out of DATA" error
LAB_19DD
	JSR	LAB_SNBS		; scan for next BASIC statement ([:] or [EOL])
	INY				; increment index
	TAX				; copy character ([:] or [EOL])
	BNE	LAB_19F6		; branch if [:]

	LDX	#$06			; set for "Out of DATA" error
	INY				; increment index, now points to next line pointer high byte
	LDA	(Bpntrl),Y		; get next line pointer high byte
	BEQ	LAB_1A54		; branch if end (eventually does error X)

	INY				; increment index
	LDA	(Bpntrl),Y		; get next line # low byte
	STA	Dlinel		; save current DATA line low byte
	INY				; increment index
	LDA	(Bpntrl),Y		; get next line # high byte
	INY				; increment index
	STA	Dlineh		; save current DATA line high byte
LAB_19F6
	LDA	(Bpntrl),Y		; get byte
	INY				; increment index
	TAX				; copy to X
	JSR	LAB_170F		; set BASIC execute pointer
	CPX	#TK_DATA		; compare with "DATA" token
	BEQ	LAB_1985		; was "DATA" so go do next READ

	BNE	LAB_19DD		; go find next statement if not "DATA"

; end of INPUT/READ routine

LAB_1A03
	LDA	Rdptrl		; get temp READ pointer low byte
	LDY	Rdptrh		; get temp READ pointer high byte
	LDX	Imode			; get input mode flag, $00=INPUT, $80=READ
	BPL	LAB_1A0E		; branch if INPUT

	JMP	LAB_1624		; save AY as DATA pointer and return

					; we were getting INPUT
LAB_1A0E
	LDY	#$00			; clear index
	LDA	(Rdptrl),Y		; get next byte
	BNE	LAB_1A1B		; error if not end of INPUT

	RTS

					; user typed too much
LAB_1A1B
	LDA	#<LAB_IMSG		; point to extra ignored message (low addr)
	LDY	#>LAB_IMSG		; point to extra ignored message (high addr)
	JMP	LAB_18C3		; print null terminated string from memory and return

; search the stack for FOR activity
; exit with z=1 if FOR else exit with z=0

LAB_11A1
	TSX				; copy stack pointer
	INX				; +1 pass return address
	INX				; +2 pass return address
	INX				; +3 pass calling routine return address
	INX				; +4 pass calling routine return address
LAB_11A6
	LDA	LAB_STAK+1,X	; get token byte from stack
	CMP	#TK_FOR		; is it FOR token
	BNE	LAB_11CE		; exit if not FOR token

					; was FOR token
	LDA	Frnxth		; get var pointer for FOR/NEXT high byte
	BNE	LAB_11BB		; branch if not null

	LDA	LAB_STAK+2,X	; get FOR variable pointer low byte
	STA	Frnxtl		; save var pointer for FOR/NEXT low byte
	LDA	LAB_STAK+3,X	; get FOR variable pointer high byte
	STA	Frnxth		; save var pointer for FOR/NEXT high byte
LAB_11BB
	CMP	LAB_STAK+3,X	; compare var pointer with stacked var pointer (high byte)
	BNE	LAB_11C7		; branch if no match

	LDA	Frnxtl		; get var pointer for FOR/NEXT low byte
	CMP	LAB_STAK+2,X	; compare var pointer with stacked var pointer (low byte)
	BEQ	LAB_11CE		; exit if match found

LAB_11C7
	TXA				; copy index
	CLC				; clear carry for add
	ADC	#$10			; add FOR stack use size
	TAX				; copy back to index
	BNE	LAB_11A6		; loop if not at start of stack

LAB_11CE
	RTS

; perform NEXT

LAB_NEXT
	BNE	LAB_1A46		; branch if NEXT var

	LDY	#$00			; else clear Y
	BEQ	LAB_1A49		; branch always (no variable to search for)

; NEXT var

LAB_1A46
	JSR	LAB_GVAR		; get variable address
LAB_1A49
	STA	Frnxtl		; store variable pointer low byte
	STY	Frnxth		; store variable pointer high byte
					; (both cleared if no variable defined)
	JSR	LAB_11A1		; search the stack for FOR activity
	BEQ	LAB_1A56		; branch if found

	LDX	#$00			; else set error $00 ("NEXT without FOR" error)
LAB_1A54
	BEQ	LAB_1ABE		; do error #X, then warm start

LAB_1A56
	TXS				; set stack pointer, X set by search, dumps return addresses

	TXA				; copy stack pointer
	SEC				; set carry for subtract
	SBC	#$F7			; point to TO var
	STA	ut2_pl		; save pointer to TO var for compare
	ADC	#$FB			; point to STEP var

	LDY	#>LAB_STAK		; point to stack page high byte
	JSR	LAB_UFAC		; unpack memory (STEP value) into FAC1
	TSX				; get stack pointer back
	LDA	LAB_STAK+8,X	; get step sign
	STA	FAC1_s		; save FAC1 sign (b7)
	LDA	Frnxtl		; get FOR variable pointer low byte
	LDY	Frnxth		; get FOR variable pointer high byte
	JSR	LAB_246C		; add (FOR variable) to FAC1
	JSR	LAB_PFAC		; pack FAC1 into (FOR variable)
	LDY	#>LAB_STAK		; point to stack page high byte
	JSR	LAB_27FA		; compare FAC1 with (Y,ut2_pl) (TO value)
	TSX				; get stack pointer back
	CMP	LAB_STAK+8,X	; compare step sign
	BEQ	LAB_1A9B		; branch if = (loop complete)

					; loop back and do it all again
	LDA	LAB_STAK+$0D,X	; get FOR line low byte
	STA	Clinel		; save current line low byte
	LDA	LAB_STAK+$0E,X	; get FOR line high byte
	STA	Clineh		; save current line high byte
	LDA	LAB_STAK+$10,X	; get BASIC execute pointer low byte
	STA	Bpntrl		; save BASIC execute pointer low byte
	LDA	LAB_STAK+$0F,X	; get BASIC execute pointer high byte
	STA	Bpntrh		; save BASIC execute pointer high byte
LAB_1A98
	JMP	LAB_15C2		; go do interpreter inner loop

					; loop complete so carry on
LAB_1A9B
	TXA				; stack copy to A
	ADC	#$0F			; add $10 ($0F+carry) to dump FOR structure
	TAX				; copy back to index
	TXS				; copy to stack pointer
	JSR	LAB_GBYT		; scan memory
	CMP	#','			; compare with ","
	BNE	LAB_1A98		; branch if not "," (go do interpreter inner loop)

					; was "," so another NEXT variable to do
	JSR	LAB_IGBY		; else increment and scan memory
	JSR	LAB_1A46		; do NEXT (var)

; evaluate expression and check is numeric, else do type mismatch

LAB_EVNM
	JSR	LAB_EVEX		; evaluate expression

; check if source is numeric, else do type mismatch

LAB_CTNM
	CLC				; destination is numeric
	.byte	$24			; makes next line BIT $38

; check if source is string, else do type mismatch

LAB_CTST
	SEC				; required type is string

; type match check, set C for string, clear C for numeric

LAB_CKTM
	BIT	Dtypef		; test data type flag, $FF=string, $00=numeric
	BMI	LAB_1ABA		; branch if data type is string

					; else data type was numeric
	BCS	LAB_1ABC		; if required type is string do type mismatch error
LAB_1AB9
	RTS

					; data type was string, now check required type
LAB_1ABA
	BCS	LAB_1AB9		; exit if required type is string

					; else do type mismatch error
LAB_1ABC
	LDX	#$18			; error code $18 ("Type mismatch" error)
LAB_1ABE
	JMP	LAB_XERR		; do error #X, then warm start

; evaluate expression

LAB_EVEX
	LDX	Bpntrl		; get BASIC execute pointer low byte
	BNE	LAB_1AC7		; skip next if not zero

	DEC	Bpntrh		; else decrement BASIC execute pointer high byte
LAB_1AC7
	DEC	Bpntrl		; decrement BASIC execute pointer low byte

LAB_EVEZ
	LDA	#$00			; set null precedence (flag done)
LAB_1ACC
	PHA				; push precedence byte
	LDA	#$02			; 2 bytes
	JSR	LAB_1212		; check room on stack for A bytes
	JSR	LAB_GVAL		; get value from line
	LDA	#$00			; clear A
	STA	comp_f		; clear compare function flag
LAB_1ADB
	JSR	LAB_GBYT		; scan memory
LAB_1ADE
	SEC				; set carry for subtract
	SBC	#TK_GT		; subtract token for > (lowest comparison function)
	BCC	LAB_1AFA		; branch if < TK_GT

	CMP	#$03			; compare with ">" to "<" tokens
	BCS	LAB_1AFA		; branch if >= TK_SGN (highest evaluation function +1)

					; was token for > = or < (A = 0, 1 or 2)
	CMP	#$01			; compare with token for =
	ROL				; *2, b0 = carry (=1 if token was = or <)
					; (A = 0, 3 or 5)
	EOR	#$01			; toggle b0
					; (A = 1, 2 or 4. 1 if >, 2 if =, 4 if <)
	EOR	comp_f		; EOR with compare function flag bits
	CMP	comp_f		; compare with compare function flag
	BCC	LAB_1B53		; if <(comp_f) do syntax error then warm start
					; was more than one <, = or >)

	STA	comp_f		; save new compare function flag
	JSR	LAB_IGBY		; increment and scan memory
	JMP	LAB_1ADE		; go do next character

					; token is < ">" or > "<" tokens
LAB_1AFA
	LDX	comp_f		; get compare function flag
	BNE	LAB_1B2A		; branch if compare function

	BCS	LAB_1B78		; go do functions

					; else was <  TK_GT so is operator or lower
	ADC	#TK_GT-TK_PLUS	; add # of operators (+, -, *, /, ^, AND, OR or EOR)
	BCC	LAB_1B78		; branch if < + operator

					; carry was set so token was +, -, *, /, ^, AND, OR or EOR
	BNE	LAB_1B0B		; branch if not + token

	BIT	Dtypef		; test data type flag, $FF=string, $00=numeric
	BPL	LAB_1B0B		; branch if not string

					; will only be $00 if type is string and token was +
	JMP	LAB_224D		; add strings, string 1 is in descriptor des_pl, string 2
					; is in line, and return

LAB_1B0B
	STA	ut1_pl		; save it
	ASL				; *2
	ADC	ut1_pl		; *3
	TAY				; copy to index
LAB_1B13
	PLA				; pull previous precedence
	CMP	LAB_OPPT,Y		; compare with precedence byte
	BCS	LAB_1B7D		; branch if A >=

	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
LAB_1B1C
	PHA				; save precedence
LAB_1B1D
	JSR	LAB_1B43		; get vector, execute function then continue evaluation
	PLA				; restore precedence
	LDY	prstk			; get precedence stacked flag
	BPL	LAB_1B3C		; branch if stacked values

	TAX				; copy precedence (set flags)
	BEQ	LAB_1B9D		; exit if done

	BNE	LAB_1B86		; else pop FAC2 and return, branch always

LAB_1B2A
	ROL	Dtypef		; shift data type flag into Cb
	TXA				; copy compare function flag
	STA	Dtypef		; clear data type flag, X is 0xxx xxxx
	ROL				; shift data type into compare function byte b0
	LDX	Bpntrl		; get BASIC execute pointer low byte
	BNE	LAB_1B34		; branch if no underflow

	DEC	Bpntrh		; else decrement BASIC execute pointer high byte
LAB_1B34
	DEC	Bpntrl		; decrement BASIC execute pointer low byte
TK_LT_PLUS	= TK_LT-TK_PLUS
	LDY	#TK_LT_PLUS*3	; set offset to last operator entry
	STA	comp_f		; save new compare function flag
	BNE	LAB_1B13		; branch always

LAB_1B3C
	CMP	LAB_OPPT,Y		;.compare with stacked function precedence
	BCS	LAB_1B86		; branch if A >=, pop FAC2 and return

	BCC	LAB_1B1C		; branch always

;.get vector, execute function then continue evaluation

LAB_1B43
	LDA	LAB_OPPT+2,Y	; get function vector high byte
	PHA				; onto stack
	LDA	LAB_OPPT+1,Y	; get function vector low byte
	PHA				; onto stack
					; now push sign, round FAC1 and put on stack
	JSR	LAB_1B5B		; function will return here, then the next RTS will call
					; the function
	LDA	comp_f		; get compare function flag
	PHA				; push compare evaluation byte
	LDA	LAB_OPPT,Y		; get precedence byte
	JMP	LAB_1ACC		; continue evaluating expression

LAB_1B53
	JMP	LAB_SNER		; do syntax error then warm start

; push sign, round FAC1 and put on stack

LAB_1B5B
	PLA				; get return addr low byte
	STA	ut1_pl		; save it
	INC	ut1_pl		; increment it (was ret-1 pushed? yes!)
					; note! no check is made on the high byte! if the calling
					; routine assembles to a page edge then this all goes
					; horribly wrong !!!
	PLA				; get return addr high byte
	STA	ut1_ph		; save it
	LDA	FAC1_s		; get FAC1 sign (b7)
	PHA				; push sign

; round FAC1 and put on stack

LAB_1B66
	JSR	LAB_27BA		; round FAC1
	LDA	FAC1_3		; get FAC1 mantissa3
	PHA				; push on stack
	LDA	FAC1_2		; get FAC1 mantissa2
	PHA				; push on stack
	LDA	FAC1_1		; get FAC1 mantissa1
	PHA				; push on stack
	LDA	FAC1_e		; get FAC1 exponent
	PHA				; push on stack
	JMP	(ut1_pl)		; return, sort of

; do functions

LAB_1B78
	LDY	#$FF			; flag function
	PLA				; pull precedence byte
LAB_1B7B
	BEQ	LAB_1B9D		; exit if done

LAB_1B7D
	CMP	#$64			; compare previous precedence with $64
	BEQ	LAB_1B84		; branch if was $64 (< function)

	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
LAB_1B84
	STY	prstk			; save precedence stacked flag

					; pop FAC2 and return
LAB_1B86
	PLA				; pop byte
	LSR				; shift out comparison evaluation lowest bit
	STA	Cflag			; save comparison evaluation flag
	PLA				; pop exponent
	STA	FAC2_e		; save FAC2 exponent
	PLA				; pop mantissa1
	STA	FAC2_1		; save FAC2 mantissa1
	PLA				; pop mantissa2
	STA	FAC2_2		; save FAC2 mantissa2
	PLA				; pop mantissa3
	STA	FAC2_3		; save FAC2 mantissa3
	PLA				; pop sign
	STA	FAC2_s		; save FAC2 sign (b7)
	EOR	FAC1_s		; EOR FAC1 sign (b7)
	STA	FAC_sc		; save sign compare (FAC1 EOR FAC2)
LAB_1B9D
	LDA	FAC1_e		; get FAC1 exponent
	RTS

; print "..." string to string util area

LAB_1BC1
	LDA	Bpntrl		; get BASIC execute pointer low byte
	LDY	Bpntrh		; get BASIC execute pointer high byte
	ADC	#$00			; add carry to low byte
	BCC	LAB_1BCA		; branch if no overflow

	INY				; increment high byte
LAB_1BCA
	JSR	LAB_20AE		; print " terminated string to Sutill/Sutilh
	JMP	LAB_23F3		; restore BASIC execute pointer from temp and return

; get value from line

LAB_GVAL
	JSR	LAB_IGBY		; increment and scan memory
	BCS	LAB_1BAC		; branch if not numeric character

					; else numeric string found (e.g. 123)
LAB_1BA9
	JMP	LAB_2887		; get FAC1 from string and return

; get value from line .. continued

					; wasn't a number so ..
LAB_1BAC
	TAX				; set the flags
	BMI	LAB_1BD0		; if -ve go test token values

					; else it is either a string, number, variable or (<expr>)
	CMP	#'$'			; compare with "$"
	BEQ	LAB_1BA9		; branch if "$", hex number

	CMP	#'%'			; else compare with "%"
	BEQ	LAB_1BA9		; branch if "%", binary number

	CMP	#'.'			; compare with "."
	BEQ	LAB_1BA9		; if so get FAC1 from string and return (e.g. was .123)

					; it wasn't any sort of number so ..
	CMP	#$22			; compare with "
	BEQ	LAB_1BC1		; branch if open quote

					; wasn't any sort of number so ..

; evaluate expression within parentheses

	CMP	#'('			; compare with "("
	BNE	LAB_1C18		; if not "(" get (var), return value in FAC1 and $ flag

LAB_1BF7
	JSR	LAB_EVEZ		; evaluate expression, no decrement

; all the 'scan for' routines return the character after the sought character

; scan for ")" , else do syntax error then warm start

LAB_1BFB
	LDA	#$29			; load A with ")"

; scan for CHR$(A) , else do syntax error then warm start

LAB_SCCA
	LDY	#$00			; clear index
	CMP	(Bpntrl),Y		; check next byte is = A
	BNE	LAB_SNER		; if not do syntax error then warm start

	JMP	LAB_IGBY		; increment and scan memory then return

; scan for "(" , else do syntax error then warm start

LAB_1BFE
	LDA	#$28			; load A with "("
	BNE	LAB_SCCA		; scan for CHR$(A), else do syntax error then warm start
					; (branch always)

; scan for "," , else do syntax error then warm start

LAB_1C01
	LDA	#$2C			; load A with ","
	BNE	LAB_SCCA		; scan for CHR$(A), else do syntax error then warm start
					; (branch always)

; syntax error then warm start

LAB_SNER
	LDX	#$02			; error code $02 ("Syntax" error)
	JMP	LAB_XERR		; do error #X, then warm start

; get value from line .. continued
; do tokens

LAB_1BD0
	CMP	#TK_MINUS		; compare with token for -
	BEQ	LAB_1C11		; branch if - token (do set-up for functions)

					; wasn't -n so ..
	CMP	#TK_PLUS		; compare with token for +
	BEQ	LAB_GVAL		; branch if + token (+n = n so ignore leading +)

	CMP	#TK_NOT		; compare with token for NOT
	BNE	LAB_1BE7		; branch if not token for NOT

					; was NOT token
TK_EQUAL_PLUS	= TK_EQUAL-TK_PLUS
	LDY	#TK_EQUAL_PLUS*3	; offset to NOT function
	BNE	LAB_1C13		; do set-up for function then execute (branch always)

; do = compare

LAB_EQUAL
	JSR	LAB_EVIR		; evaluate integer expression (no sign check)
	LDA	FAC1_3		; get FAC1 mantissa3
	EOR	#$FF			; invert it
	TAY				; copy it
	LDA	FAC1_2		; get FAC1 mantissa2
	EOR	#$FF			; invert it
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; get value from line .. continued

					; wasn't +, -, or NOT so ..
LAB_1BE7
	CMP	#TK_FN		; compare with token for FN
	BNE	LAB_1BEE		; branch if not token for FN

	JMP	LAB_201E		; go evaluate FNx

; get value from line .. continued

					; wasn't +, -, NOT or FN so ..
LAB_1BEE
	SBC	#TK_SGN		; subtract with token for SGN
	BCS	LAB_1C27		; if a function token go do it

	JMP	LAB_SNER		; else do syntax error

; set-up for functions

LAB_1C11
TK_GT_PLUS	= TK_GT-TK_PLUS
	LDY	#TK_GT_PLUS*3	; set offset from base to > operator
LAB_1C13
	PLA				; dump return address low byte
	PLA				; dump return address high byte
	JMP	LAB_1B1D		; execute function then continue evaluation

; variable name set-up
; get (var), return value in FAC_1 and $ flag

LAB_1C18
	JSR	LAB_GVAR		; get (var) address
	STA	FAC1_2		; save address low byte in FAC1 mantissa2
	STY	FAC1_3		; save address high byte in FAC1 mantissa3
	LDX	Dtypef		; get data type flag, $FF=string, $00=numeric
	BMI	LAB_1C25		; if string then return (does RTS)

LAB_1C24
	JMP	LAB_UFAC		; unpack memory (AY) into FAC1

LAB_1C25
	RTS

; get value from line .. continued
; only functions left so ..

; set up function references

; new for V2.0+ this replaces a lot of IF .. THEN .. ELSEIF .. THEN .. that was needed
; to process function calls. now the function vector is computed and pushed on the stack
; and the preprocess offset is read. if the preprocess offset is non zero then the vector
; is calculated and the routine called, if not this routine just does RTS. whichever
; happens the RTS at the end of this routine, or the end of the preprocess routine, calls
; the function code

; this also removes some less than elegant code that was used to bypass type checking
; for functions that returned strings

LAB_1C27
	ASL				; *2 (2 bytes per function address)
	TAY				; copy to index

	LDA	LAB_FTBM,Y		; get function jump vector high byte
	PHA				; push functions jump vector high byte
	LDA	LAB_FTBL,Y		; get function jump vector low byte
	PHA				; push functions jump vector low byte

	LDA	LAB_FTPM,Y		; get function pre process vector high byte
	BEQ	LAB_1C56		; skip pre process if null vector

	PHA				; push functions pre process vector high byte
	LDA	LAB_FTPL,Y		; get function pre process vector low byte
	PHA				; push functions pre process vector low byte

LAB_1C56
	RTS				; do function, or pre process, call

; process string expression in parenthesis

LAB_PPFS
	JSR	LAB_1BF7		; process expression in parenthesis
	JMP	LAB_CTST		; check if source is string then do function,
					; else do type mismatch

; process numeric expression in parenthesis

LAB_PPFN
	JSR	LAB_1BF7		; process expression in parenthesis
	JMP	LAB_CTNM		; check if source is numeric then do function,
					; else do type mismatch

; set numeric data type and increment BASIC execute pointer

LAB_PPBI
	LSR	Dtypef		; clear data type flag, $FF=string, $00=numeric
	JMP	LAB_IGBY		; increment and scan memory then do function

; process string for LEFT$, RIGHT$ or MID$

LAB_LRMS
	JSR	LAB_EVEZ		; evaluate (should be string) expression
	JSR	LAB_1C01		; scan for ",", else do syntax error then warm start
	JSR	LAB_CTST		; check if source is string, else do type mismatch

	PLA				; get function jump vector low byte
	TAX				; save functions jump vector low byte
	PLA				; get function jump vector high byte
	TAY				; save functions jump vector high byte
	LDA	des_ph		; get descriptor pointer high byte
	PHA				; push string pointer high byte
	LDA	des_pl		; get descriptor pointer low byte
	PHA				; push string pointer low byte
	TYA				; get function jump vector high byte back
	PHA				; save functions jump vector high byte
	TXA				; get function jump vector low byte back
	PHA				; save functions jump vector low byte
	JSR	LAB_GTBY		; get byte parameter
	TXA				; copy byte parameter to A
	RTS				; go do function

; process numeric expression(s) for BIN$ or HEX$

LAB_BHSS
	JSR	LAB_EVEZ		; process expression
	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
	LDA	FAC1_e		; get FAC1 exponent
	CMP	#$98			; compare with exponent = 2^24
	BCS	LAB_BHER		; branch if n>=2^24 (is too big)

	JSR	LAB_2831		; convert FAC1 floating-to-fixed
	LDX	#$02			; 3 bytes to do
LAB_CFAC
	LDA	FAC1_1,X		; get byte from FAC1
	STA	nums_1,X		; save byte to temp
	DEX				; decrement index
	BPL	LAB_CFAC		; copy FAC1 mantissa to temp

	JSR	LAB_GBYT		; get next BASIC byte
	LDX	#$00			; set default to no leading "0"s
	CMP	#')'			; compare with close bracket
	BEQ	LAB_1C54		; if ")" go do rest of function

	JSR	LAB_SCGB		; scan for "," and get byte
	JSR	LAB_GBYT		; get last byte back
	CMP	#')'			; is next character )
	BNE	LAB_BHER		; if not ")" go do error

LAB_1C54
	RTS				; else do function

LAB_BHER
	JMP	LAB_FCER		; do function call error then warm start

; perform EOR

; added operator format is the same as AND or OR, precedence is the same as OR

; this bit worked first time but it took a while to sort out the operator table
; pointers and offsets afterwards!

LAB_EOR
	JSR	GetFirst		; get first integer expression (no sign check)
	EOR	XOAw_l		; EOR with expression 1 low byte
	TAY				; save in Y
	LDA	FAC1_2		; get FAC1 mantissa2
	EOR	XOAw_h		; EOR with expression 1 high byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; perform OR

LAB_OR
	JSR	GetFirst		; get first integer expression (no sign check)
	ORA	XOAw_l		; OR with expression 1 low byte
	TAY				; save in Y
	LDA	FAC1_2		; get FAC1 mantissa2
	ORA	XOAw_h		; OR with expression 1 high byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; perform AND

LAB_AND
	JSR	GetFirst		; get first integer expression (no sign check)
	AND	XOAw_l		; AND with expression 1 low byte
	TAY				; save in Y
	LDA	FAC1_2		; get FAC1 mantissa2
	AND	XOAw_h		; AND with expression 1 high byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; get first value for OR, AND or EOR

GetFirst
	JSR	LAB_EVIR		; evaluate integer expression (no sign check)
	LDA	FAC1_2		; get FAC1 mantissa2
	STA	XOAw_h		; save it
	LDA	FAC1_3		; get FAC1 mantissa3
	STA	XOAw_l		; save it
	JSR	LAB_279B		; copy FAC2 to FAC1 (get 2nd value in expression)
	JSR	LAB_EVIR		; evaluate integer expression (no sign check)
	LDA	FAC1_3		; get FAC1 mantissa3
LAB_1C95
	RTS

; perform comparisons

; do < compare

LAB_LTHAN
	JSR	LAB_CKTM		; type match check, set C for string
	BCS	LAB_1CAE		; branch if string

					; do numeric < compare
	LDA	FAC2_s		; get FAC2 sign (b7)
	ORA	#$7F			; set all non sign bits
	AND	FAC2_1		; and FAC2 mantissa1 (AND in sign bit)
	STA	FAC2_1		; save FAC2 mantissa1
	LDA	#<FAC2_e		; set pointer low byte to FAC2
	LDY	#>FAC2_e		; set pointer high byte to FAC2
	JSR	LAB_27F8		; compare FAC1 with FAC2 (AY)
	TAX				; copy result
	JMP	LAB_1CE1		; go evaluate result

					; do string < compare
LAB_1CAE
	LSR	Dtypef		; clear data type flag, $FF=string, $00=numeric
	DEC	comp_f		; clear < bit in compare function flag
	JSR	LAB_22B6		; pop string off descriptor stack, or from top of string
					; space returns with A = length, X=pointer low byte,
					; Y=pointer high byte
	STA	str_ln		; save length
	STX	str_pl		; save string pointer low byte
	STY	str_ph		; save string pointer high byte
	LDA	FAC2_2		; get descriptor pointer low byte
	LDY	FAC2_3		; get descriptor pointer high byte
	JSR	LAB_22BA		; pop (YA) descriptor off stack or from top of string space
					; returns with A = length, X=pointer low byte,
					; Y=pointer high byte
	STX	FAC2_2		; save string pointer low byte
	STY	FAC2_3		; save string pointer high byte
	TAX				; copy length
	SEC				; set carry for subtract
	SBC	str_ln		; subtract string 1 length
	BEQ	LAB_1CD6		; branch if str 1 length = string 2 length

	LDA	#$01			; set str 1 length > string 2 length
	BCC	LAB_1CD6		; branch if so

	LDX	str_ln		; get string 1 length
	LDA	#$FF			; set str 1 length < string 2 length
LAB_1CD6
	STA	FAC1_s		; save length compare
	LDY	#$FF			; set index
	INX				; adjust for loop
LAB_1CDB
	INY				; increment index
	DEX				; decrement count
	BNE	LAB_1CE6		; branch if still bytes to do

	LDX	FAC1_s		; get length compare back
LAB_1CE1
	BMI	LAB_1CF2		; branch if str 1 < str 2

	CLC				; flag str 1 <= str 2
	BCC	LAB_1CF2		; go evaluate result

LAB_1CE6
	LDA	(FAC2_2),Y		; get string 2 byte
	CMP	(FAC1_1),Y		; compare with string 1 byte
	BEQ	LAB_1CDB		; loop if bytes =

	LDX	#$FF			; set str 1 < string 2
	BCS	LAB_1CF2		; branch if so

	LDX	#$01			;  set str 1 > string 2
LAB_1CF2
	INX				; x = 0, 1 or 2
	TXA				; copy to A
	ROL				; *2 (1, 2 or 4)
	AND	Cflag			; AND with comparison evaluation flag
	BEQ	LAB_1CFB		; branch if 0 (compare is false)

	LDA	#$FF			; else set result true
LAB_1CFB
	JMP	LAB_27DB		; save A as integer byte and return

LAB_1CFE
	JSR	LAB_1C01		; scan for ",", else do syntax error then warm start

; perform DIM

LAB_DIM
	TAX				; copy "DIM" flag to X
	JSR	LAB_1D10		; search for variable
	JSR	LAB_GBYT		; scan memory
	BNE	LAB_1CFE		; scan for "," and loop if not null

	RTS

; perform << (left shift)

LAB_LSHIFT
	JSR	GetPair		; get integer expression and byte (no sign check)
	LDA	FAC1_2		; get expression high byte
	LDX	TempB			; get shift count
	BEQ	NoShift		; branch if zero

	CPX	#$10			; compare bit count with 16d
	BCS	TooBig		; branch if >=

Ls_loop
	ASL	FAC1_3		; shift low byte
	ROL				; shift high byte
	DEX				; decrement bit count
	BNE	Ls_loop		; loop if shift not complete

	LDY	FAC1_3		; get expression low byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; perform >> (right shift)

LAB_RSHIFT
	JSR	GetPair		; get integer expression and byte (no sign check)
	LDA	FAC1_2		; get expression high byte
	LDX	TempB			; get shift count
	BEQ	NoShift		; branch if zero

	CPX	#$10			; compare bit count with 16d
	BCS	TooBig		; branch if >=

Rs_loop
	LSR				; shift high byte
	ROR	FAC1_3		; shift low byte
	DEX				; decrement bit count
	BNE	Rs_loop		; loop if shift not complete

NoShift
	LDY	FAC1_3		; get expression low byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

TooBig
	LDA	#$00			; clear high byte
	TAY				; copy to low byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

GetPair
	JSR	LAB_EVBY		; evaluate byte expression, result in X
	STX	TempB			; save it
	JSR	LAB_279B		; copy FAC2 to FAC1 (get 2nd value in expression)
	JMP	LAB_EVIR		; evaluate integer expression (no sign check)

; search for variable

; return pointer to variable in Cvaral/Cvarah

LAB_GVAR
	LDX	#$00			; set DIM flag = $00
	JSR	LAB_GBYT		; scan memory (1st character)
LAB_1D10
	STX	Defdim		; save DIM flag
LAB_1D12
	STA	Varnm1		; save 1st character
	AND	#$7F			; clear FN flag bit
	JSR	LAB_CASC		; check byte, return C=0 if<"A" or >"Z"
	BCS	LAB_1D1F		; branch if ok

	JMP	LAB_SNER		; else syntax error then warm start

					; was variable name so ..
LAB_1D1F
	LDX	#$00			; clear 2nd character temp
	STX	Dtypef		; clear data type flag, $FF=string, $00=numeric
	JSR	LAB_IGBY		; increment and scan memory (2nd character)
	BCC	LAB_1D2D		; branch if character = "0"-"9" (ok)

					; 2nd character wasn't "0" to "9" so ..
	JSR	LAB_CASC		; check byte, return C=0 if<"A" or >"Z"
	BCC	LAB_1D38		; branch if <"A" or >"Z" (go check if string)

LAB_1D2D
	TAX				; copy 2nd character

					; ignore further (valid) characters in the variable name
LAB_1D2E
	JSR	LAB_IGBY		; increment and scan memory (3rd character)
	BCC	LAB_1D2E		; loop if character = "0"-"9" (ignore)

	JSR	LAB_CASC		; check byte, return C=0 if<"A" or >"Z"
	BCS	LAB_1D2E		; loop if character = "A"-"Z" (ignore)

					; check if string variable
LAB_1D38
	CMP	#'$'			; compare with "$"
	BNE	LAB_1D47		; branch if not string

; to introduce a new variable type (% suffix for integers say) then this branch
; will need to go to that check and then that branch, if it fails, go to LAB_1D47

					; type is string
	LDA	#$FF			; set data type = string
	STA	Dtypef		; set data type flag, $FF=string, $00=numeric
	TXA				; get 2nd character back
	ORA	#$80			; set top bit (indicate string var)
	TAX				; copy back to 2nd character temp
	JSR	LAB_IGBY		; increment and scan memory

; after we have determined the variable type we need to come back here to determine
; if it's an array of type. this would plug in a%(b[,c[,d]])) integer arrays nicely


LAB_1D47				; gets here with character after var name in A
	STX	Varnm2		; save 2nd character
	ORA	Sufnxf		; or with subscript/FNX flag (or FN name)
	CMP	#'('			; compare with "("
	BNE	LAB_1D53		; branch if not "("

	JMP	LAB_1E17		; go find, or make, array

; either find or create var
; var name (1st two characters only!) is in Varnm1,Varnm2

					; variable name wasn't var(... so look for plain var
LAB_1D53
	LDA	#$00			; clear A
	STA	Sufnxf		; clear subscript/FNX flag
	LDA	Svarl			; get start of vars low byte
	LDX	Svarh			; get start of vars high byte
	LDY	#$00			; clear index
LAB_1D5D
	STX	Vrschh		; save search address high byte
LAB_1D5F
	STA	Vrschl		; save search address low byte
	CPX	Sarryh		; compare high address with var space end
	BNE	LAB_1D69		; skip next compare if <>

					; high addresses were = so compare low addresses
	CMP	Sarryl		; compare low address with var space end
	BEQ	LAB_1D8B		; if not found go make new var

LAB_1D69
	LDA	Varnm1		; get 1st character of var to find
	CMP	(Vrschl),Y		; compare with variable name 1st character
	BNE	LAB_1D77		; branch if no match

					; 1st characters match so compare 2nd characters
	LDA	Varnm2		; get 2nd character of var to find
	INY				; index to point to variable name 2nd character
	CMP	(Vrschl),Y		; compare with variable name 2nd character
	BEQ	LAB_1DD7		; branch if match (found var)

	DEY				; else decrement index (now = $00)
LAB_1D77
	CLC				; clear carry for add
	LDA	Vrschl		; get search address low byte
	ADC	#$06			; +6 (offset to next var name)
	BCC	LAB_1D5F		; loop if no overflow to high byte

	INX				; else increment high byte
	BNE	LAB_1D5D		; loop always (RAM doesn't extend to $FFFF !)

; check byte, return C=0 if<"A" or >"Z" or "a" to "z"

LAB_CASC
	CMP	#'a'			; compare with "a"
	BCS	LAB_1D83		; go check <"z"+1

; check byte, return C=0 if<"A" or >"Z"

LAB_1D82
	CMP	#'A'			; compare with "A"
	BCC	LAB_1D8A		; exit if less

					; carry is set
	SBC	#$5B			; subtract "Z"+1
	SEC				; set carry
	SBC	#$A5			; subtract $A5 (restore byte)
					; carry clear if byte>$5A
LAB_1D8A
	RTS

LAB_1D83
	SBC	#$7B			; subtract "z"+1
	SEC				; set carry
	SBC	#$85			; subtract $85 (restore byte)
					; carry clear if byte>$7A
	RTS

					; reached end of variable mem without match
					; .. so create new variable
LAB_1D8B
	PLA				; pop return address low byte
	PHA				; push return address low byte
LAB_1C18p2	= LAB_1C18+2
	CMP	#<LAB_1C18p2	; compare with expected calling routine return low byte
	BNE	LAB_1D98		; if not get (var) go create new var

; This will only drop through if the call was from LAB_1C18 and is only called
; from there if it is searching for a variable from the RHS of a LET a=b statement
; it prevents the creation of variables not assigned a value.

; value returned by this is either numeric zero (exponent byte is $00) or null string
; (descriptor length byte is $00). in fact a pointer to any $00 byte would have done.

; doing this saves 6 bytes of variable memory and 168 machine cycles of time

; this is where you would put the undefined variable error call e.g.

;					; variable doesn't exist so flag error
;	LDX	#$24			; error code $24 ("undefined variable" error)
;	JMP	LAB_XERR		; do error #X then warm start

; the above code has been tested and works a treat! (it replaces the three code lines
; below)

					; else return dummy null value
	LDA	#<LAB_1D96		; low byte point to $00,$00
					; (uses part of misc constants table)
	LDY	#>LAB_1D96		; high byte point to $00,$00
	RTS

					; create new numeric variable
LAB_1D98
	LDA	Sarryl		; get var mem end low byte
	LDY	Sarryh		; get var mem end high byte
	STA	Ostrtl		; save old block start low byte
	STY	Ostrth		; save old block start high byte
	LDA	Earryl		; get array mem end low byte
	LDY	Earryh		; get array mem end high byte
	STA	Obendl		; save old block end low byte
	STY	Obendh		; save old block end high byte
	CLC				; clear carry for add
	ADC	#$06			; +6 (space for one var)
	BCC	LAB_1DAE		; branch if no overflow to high byte

	INY				; else increment high byte
LAB_1DAE
	STA	Nbendl		; set new block end low byte
	STY	Nbendh		; set new block end high byte
	JSR	LAB_11CF		; open up space in memory
	LDA	Nbendl		; get new start low byte
	LDY	Nbendh		; get new start high byte (-$100)
	INY				; correct high byte
	STA	Sarryl		; save new var mem end low byte
	STY	Sarryh		; save new var mem end high byte
	LDY	#$00			; clear index
	LDA	Varnm1		; get var name 1st character
	STA	(Vrschl),Y		; save var name 1st character
	INY				; increment index
	LDA	Varnm2		; get var name 2nd character
	STA	(Vrschl),Y		; save var name 2nd character
	LDA	#$00			; clear A
	INY				; increment index
	STA	(Vrschl),Y		; initialise var byte
	INY				; increment index
	STA	(Vrschl),Y		; initialise var byte
	INY				; increment index
	STA	(Vrschl),Y		; initialise var byte
	INY				; increment index
	STA	(Vrschl),Y		; initialise var byte

					; found a match for var ((Vrschl) = ptr)
LAB_1DD7
	LDA	Vrschl		; get var address low byte
	CLC				; clear carry for add
	ADC	#$02			; +2 (offset past var name bytes)
	LDY	Vrschh		; get var address high byte
	BCC	LAB_1DE1		; branch if no overflow from add

	INY				; else increment high byte
LAB_1DE1
	STA	Cvaral		; save current var address low byte
	STY	Cvarah		; save current var address high byte
	RTS

; set-up array pointer (Adatal/h) to first element in array
; set Adatal,Adatah to Astrtl,Astrth+2*Dimcnt+#$05

LAB_1DE6
	LDA	Dimcnt		; get # of dimensions (1, 2 or 3)
	ASL				; *2 (also clears the carry !)
	ADC	#$05			; +5 (result is 7, 9 or 11 here)
	ADC	Astrtl		; add array start pointer low byte
	LDY	Astrth		; get array pointer high byte
	BCC	LAB_1DF2		; branch if no overflow

	INY				; else increment high byte
LAB_1DF2
	STA	Adatal		; save array data pointer low byte
	STY	Adatah		; save array data pointer high byte
	RTS

; evaluate integer expression

LAB_EVIN
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch

; evaluate integer expression (no check)

LAB_EVPI
	LDA	FAC1_s		; get FAC1 sign (b7)
	BMI	LAB_1E12		; do function call error if -ve

; evaluate integer expression (no sign check)

LAB_EVIR
	LDA	FAC1_e		; get FAC1 exponent
	CMP	#$90			; compare with exponent = 2^16 (n>2^15)
	BCC	LAB_1E14		; branch if n<2^16 (is ok)

	LDA	#<LAB_1DF7		; set pointer low byte to -32768
	LDY	#>LAB_1DF7		; set pointer high byte to -32768
	JSR	LAB_27F8		; compare FAC1 with (AY)
LAB_1E12
	BNE	LAB_FCER		; if <> do function call error then warm start

LAB_1E14
	JMP	LAB_2831		; convert FAC1 floating-to-fixed and return

; find or make array

LAB_1E17
	LDA	Defdim		; get DIM flag
	PHA				; push it
	LDA	Dtypef		; get data type flag, $FF=string, $00=numeric
	PHA				; push it
	LDY	#$00			; clear dimensions count

; now get the array dimension(s) and stack it (them) before the data type and DIM flag

LAB_1E1F
	TYA				; copy dimensions count
	PHA				; save it
	LDA	Varnm2		; get array name 2nd byte
	PHA				; save it
	LDA	Varnm1		; get array name 1st byte
	PHA				; save it
	JSR	LAB_EVIN		; evaluate integer expression
	PLA				; pull array name 1st byte
	STA	Varnm1		; restore array name 1st byte
	PLA				; pull array name 2nd byte
	STA	Varnm2		; restore array name 2nd byte
	PLA				; pull dimensions count
	TAY				; restore it
	TSX				; copy stack pointer
	LDA	LAB_STAK+2,X	; get DIM flag
	PHA				; push it
	LDA	LAB_STAK+1,X	; get data type flag
	PHA				; push it
	LDA	FAC1_2		; get this dimension size high byte
	STA	LAB_STAK+2,X	; stack before flag bytes
	LDA	FAC1_3		; get this dimension size low byte
	STA	LAB_STAK+1,X	; stack before flag bytes
	INY				; increment dimensions count
	JSR	LAB_GBYT		; scan memory
	CMP	#','			; compare with ","
	BEQ	LAB_1E1F		; if found go do next dimension

	STY	Dimcnt		; store dimensions count
	JSR	LAB_1BFB		; scan for ")" , else do syntax error then warm start
	PLA				; pull data type flag
	STA	Dtypef		; restore data type flag, $FF=string, $00=numeric
	PLA				; pull DIM flag
	STA	Defdim		; restore DIM flag
	LDX	Sarryl		; get array mem start low byte
	LDA	Sarryh		; get array mem start high byte

; now check to see if we are at the end of array memory (we would be if there were
; no arrays).

LAB_1E5C
	STX	Astrtl		; save as array start pointer low byte
	STA	Astrth		; save as array start pointer high byte
	CMP	Earryh		; compare with array mem end high byte
	BNE	LAB_1E68		; branch if not reached array mem end

	CPX	Earryl		; else compare with array mem end low byte
	BEQ	LAB_1EA1		; go build array if not found

					; search for array
LAB_1E68
	LDY	#$00			; clear index
	LDA	(Astrtl),Y		; get array name first byte
	INY				; increment index to second name byte
	CMP	Varnm1		; compare with this array name first byte
	BNE	LAB_1E77		; branch if no match

	LDA	Varnm2		; else get this array name second byte
	CMP	(Astrtl),Y		; compare with array name second byte
	BEQ	LAB_1E8D		; array found so branch

					; no match
LAB_1E77
	INY				; increment index
	LDA	(Astrtl),Y		; get array size low byte
	CLC				; clear carry for add
	ADC	Astrtl		; add array start pointer low byte
	TAX				; copy low byte to X
	INY				; increment index
	LDA	(Astrtl),Y		; get array size high byte
	ADC	Astrth		; add array mem pointer high byte
	BCC	LAB_1E5C		; if no overflow go check next array

; do array bounds error

LAB_1E85
	LDX	#$10			; error code $10 ("Array bounds" error)
	.byte	$2C			; makes next bit BIT LAB_08A2

; do function call error

LAB_FCER
	LDX	#$08			; error code $08 ("Function call" error)
LAB_1E8A
	JMP	LAB_XERR		; do error #X, then warm start

					; found array, are we trying to dimension it?
LAB_1E8D
	LDX	#$12			; set error $12 ("Double dimension" error)
	LDA	Defdim		; get DIM flag
	BNE	LAB_1E8A		; if we are trying to dimension it do error #X, then warm
					; start

; found the array and we're not dimensioning it so we must find an element in it

	JSR	LAB_1DE6		; set-up array pointer (Adatal/h) to first element in array
					; (Astrtl,Astrth points to start of array)
	LDA	Dimcnt		; get dimensions count
	LDY	#$04			; set index to array's # of dimensions
	CMP	(Astrtl),Y		; compare with no of dimensions
	BNE	LAB_1E85		; if wrong do array bounds error, could do "Wrong
					; dimensions" error here .. if we want a different
					; error message

	JMP	LAB_1F28		; found array so go get element
					; (could jump to LAB_1F28 as all LAB_1F24 does is take
					; Dimcnt and save it at (Astrtl),Y which is already the
					; same or we would have taken the BNE)

					; array not found, so build it
LAB_1EA1
	JSR	LAB_1DE6		; set-up array pointer (Adatal/h) to first element in array
					; (Astrtl,Astrth points to start of array)
	JSR	LAB_121F		; check available memory, "Out of memory" error if no room
					; addr to check is in AY (low/high)
	LDY	#$00			; clear Y (don't need to clear A)
	STY	Aspth			; clear array data size high byte
	LDA	Varnm1		; get variable name 1st byte
	STA	(Astrtl),Y		; save array name 1st byte
	INY				; increment index
	LDA	Varnm2		; get variable name 2nd byte
	STA	(Astrtl),Y		; save array name 2nd byte
	LDA	Dimcnt		; get dimensions count
	LDY	#$04			; index to dimension count
	STY	Asptl			; set array data size low byte (four bytes per element)
	STA	(Astrtl),Y		; set array's dimensions count

					; now calculate the size of the data space for the array
	CLC				; clear carry for add (clear on subsequent loops)
LAB_1EC0
	LDX	#$0B			; set default dimension value low byte
	LDA	#$00			; set default dimension value high byte
	BIT	Defdim		; test default DIM flag
	BVC	LAB_1ED0		; branch if b6 of Defdim is clear

	PLA				; else pull dimension value low byte
	ADC	#$01			; +1 (allow for zeroeth element)
	TAX				; copy low byte to X
	PLA				; pull dimension value high byte
	ADC	#$00			; add carry from low byte

LAB_1ED0
	INY				; index to dimension value high byte
	STA	(Astrtl),Y		; save dimension value high byte
	INY				; index to dimension value high byte
	TXA				; get dimension value low byte
	STA	(Astrtl),Y		; save dimension value low byte
	JSR	LAB_1F7C		; does XY = (Astrtl),Y * (Asptl)
	STX	Asptl			; save array data size low byte
	STA	Aspth			; save array data size high byte
	LDY	ut1_pl		; restore index (saved by subroutine)
	DEC	Dimcnt		; decrement dimensions count
	BNE	LAB_1EC0		; loop while not = 0

	ADC	Adatah		; add size high byte to first element high byte
					; (carry is always clear here)
	BCS	LAB_1F45		; if overflow go do "Out of memory" error

	STA	Adatah		; save end of array high byte
	TAY				; copy end high byte to Y
	TXA				; get array size low byte
	ADC	Adatal		; add array start low byte
	BCC	LAB_1EF3		; branch if no carry

	INY				; else increment end of array high byte
	BEQ	LAB_1F45		; if overflow go do "Out of memory" error

					; set-up mostly complete, now zero the array
LAB_1EF3
	JSR	LAB_121F		; check available memory, "Out of memory" error if no room
					; addr to check is in AY (low/high)
	STA	Earryl		; save array mem end low byte
	STY	Earryh		; save array mem end high byte
	LDA	#$00			; clear byte for array clear
	INC	Aspth			; increment array size high byte (now block count)
	LDY	Asptl			; get array size low byte (now index to block)
	BEQ	LAB_1F07		; branch if low byte = $00
message "LAB_1F02"
LAB_1F02
	DEY				; decrement index (do 0 to n-1)
	STA	(Adatal),Y		; zero byte
	BNE	LAB_1F02		; loop until this block done

LAB_1F07
	DEC	Adatah		; decrement array pointer high byte
	DEC	Aspth			; decrement block count high byte
	BNE	LAB_1F02		; loop until all blocks done

	INC	Adatah		; correct for last loop
	SEC				; set carry for subtract
	LDY	#$02			; index to array size low byte
	LDA	Earryl		; get array mem end low byte
	SBC	Astrtl		; subtract array start low byte
	STA	(Astrtl),Y		; save array size low byte
	INY				; index to array size high byte
	LDA	Earryh		; get array mem end high byte
	SBC	Astrth		; subtract array start high byte
	STA	(Astrtl),Y		; save array size high byte
	LDA	Defdim		; get default DIM flag
	BNE	LAB_1F7B		; exit (RET) if this was a DIM command

					; else, find element
	INY				; index to # of dimensions

LAB_1F24
	LDA	(Astrtl),Y		; get array's dimension count
	STA	Dimcnt		; save it

; we have found, or built, the array. now we need to find the element

LAB_1F28
	LDA	#$00			; clear byte
	STA	Asptl			; clear array data pointer low byte
LAB_1F2C
	STA	Aspth			; save array data pointer high byte
	INY				; increment index (point to array bound high byte)
	PLA				; pull array index low byte
	TAX				; copy to X
	STA	FAC1_2		; save index low byte to FAC1 mantissa2
	PLA				; pull array index high byte
	STA	FAC1_3		; save index high byte to FAC1 mantissa3
	CMP	(Astrtl),Y		; compare with array bound high byte
	BCC	LAB_1F48		; branch if within bounds

	BNE	LAB_1F42		; if outside bounds do array bounds error

					; else high byte was = so test low bytes
	INY				; index to array bound low byte
	TXA				; get array index low byte
	CMP	(Astrtl),Y		; compare with array bound low byte
	BCC	LAB_1F49		; branch if within bounds

LAB_1F42
	JMP	LAB_1E85		; else do array bounds error

LAB_1F45
	JMP	LAB_OMER		; do "Out of memory" error then warm start

LAB_1F48
	INY				; index to array bound low byte
LAB_1F49
	LDA	Aspth			; get array data pointer high byte
	ORA	Asptl			; OR with array data pointer low byte
	BEQ	LAB_1F5A		; branch if array data pointer = null (skip multiply)

	JSR	LAB_1F7C		; does XY = (Astrtl),Y * (Asptl)
	TXA				; get result low byte
	ADC	FAC1_2		; add index low byte from FAC1 mantissa2
	TAX				; save result low byte
	TYA				; get result high byte
	LDY	ut1_pl		; restore index
LAB_1F5A
	ADC	FAC1_3		; add index high byte from FAC1 mantissa3
	STX	Asptl			; save array data pointer low byte
	DEC	Dimcnt		; decrement dimensions count
	BNE	LAB_1F2C		; loop if dimensions still to do

	ASL	Asptl			; array data pointer low byte * 2
	ROL				; array data pointer high byte * 2
	ASL	Asptl			; array data pointer low byte * 4
	ROL				; array data pointer high byte * 4
	TAY				; copy high byte
	LDA	Asptl			; get low byte
	ADC	Adatal		; add array data start pointer low byte
	STA	Cvaral		; save as current var address low byte
	TYA				; get high byte back
	ADC	Adatah		; add array data start pointer high byte
	STA	Cvarah		; save as current var address high byte
	TAY				; copy high byte to Y
	LDA	Cvaral		; get current var address low byte
LAB_1F7B
	RTS

; does XY = (Astrtl),Y * (Asptl)

LAB_1F7C
	STY	ut1_pl		; save index
	LDA	(Astrtl),Y		; get dimension size low byte
	STA	dims_l		; save dimension size low byte
	DEY				; decrement index
	LDA	(Astrtl),Y		; get dimension size high byte
	STA	dims_h		; save dimension size high byte

	LDA	#$10			; count = $10 (16 bit multiply)
	STA	numbit		; save bit count
	LDX	#$00			; clear result low byte
	LDY	#$00			; clear result high byte
LAB_1F8F
	TXA				; get result low byte
	ASL				; *2
	TAX				; save result low byte
	TYA				; get result high byte
	ROL				; *2
	TAY				; save result high byte
	BCS	LAB_1F45		; if overflow go do "Out of memory" error

	ASL	Asptl			; shift multiplier low byte
	ROL	Aspth			; shift multiplier high byte
	BCC	LAB_1FA8		; skip add if no carry

	CLC				; else clear carry for add
	TXA				; get result low byte
	ADC	dims_l		; add dimension size low byte
	TAX				; save result low byte
	TYA				; get result high byte
	ADC	dims_h		; add dimension size high byte
	TAY				; save result high byte
	BCS	LAB_1F45		; if overflow go do "Out of memory" error

LAB_1FA8
	DEC	numbit		; decrement bit count
	BNE	LAB_1F8F		; loop until all done

	RTS

; perform FRE()

LAB_FRE
	LDA	Dtypef		; get data type flag, $FF=string, $00=numeric
	BPL	LAB_1FB4		; branch if numeric

	JSR	LAB_22B6		; pop string off descriptor stack, or from top of string
					; space returns with A = length, X=$71=pointer low byte,
					; Y=$72=pointer high byte

					; FRE(n) was numeric so do this
LAB_1FB4
	JSR	LAB_GARB		; go do garbage collection
	SEC				; set carry for subtract
	LDA	Sstorl		; get bottom of string space low byte
	SBC	Earryl		; subtract array mem end low byte
	TAY				; copy result to Y
	LDA	Sstorh		; get bottom of string space high byte
	SBC	Earryh		; subtract array mem end high byte

; save and convert integer AY to FAC1

LAB_AYFC
	LSR	Dtypef		; clear data type flag, $FF=string, $00=numeric
	STA	FAC1_1		; save FAC1 mantissa1
	STY	FAC1_2		; save FAC1 mantissa2
	LDX	#$90			; set exponent=2^16 (integer)
	JMP	LAB_27E3		; set exp=X, clear FAC1_3, normalise and return

; perform POS()

LAB_POS
	LDY	TPos			; get terminal position

; convert Y to byte in FAC1

LAB_1FD0
	LDA	#$00			; clear high byte
	BEQ	LAB_AYFC		; always save and convert integer AY to FAC1 and return

; check not Direct (used by DEF and INPUT)

LAB_CKRN
	LDX	Clineh		; get current line high byte
	INX				; increment it
	BNE	LAB_1F7B		; return if can continue not direct mode

					; else do illegal direct error
LAB_1FD9
	LDX	#$16			; error code $16 ("Illegal direct" error)
LAB_1FDB
	JMP	LAB_XERR		; go do error #X, then warm start

; perform DEF

LAB_DEF
	JSR	LAB_200B		; check FNx syntax
	STA	func_l		; save function pointer low byte
	STY	func_h		; save function pointer high byte
	JSR	LAB_CKRN		; check not Direct (back here if ok)
	JSR	LAB_1BFE		; scan for "(" , else do syntax error then warm start
	LDA	#$80			; set flag for FNx
	STA	Sufnxf		; save subscript/FNx flag
	JSR	LAB_GVAR		; get (var) address
	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
	JSR	LAB_1BFB		; scan for ")" , else do syntax error then warm start
	LDA	#TK_EQUAL		; get = token
	JSR	LAB_SCCA		; scan for CHR$(A), else do syntax error then warm start
	LDA	Cvarah		; get current var address high byte
	PHA				; push it
	LDA	Cvaral		; get current var address low byte
	PHA				; push it
	LDA	Bpntrh		; get BASIC execute pointer high byte
	PHA				; push it
	LDA	Bpntrl		; get BASIC execute pointer low byte
	PHA				; push it
	JSR	LAB_DATA		; go perform DATA
	JMP	LAB_207A		; put execute pointer and variable pointer into function
					; and return

; check FNx syntax

LAB_200B
	LDA	#TK_FN		; get FN" token
	JSR	LAB_SCCA		; scan for CHR$(A) , else do syntax error then warm start
					; return character after A
	ORA	#$80			; set FN flag bit
	STA	Sufnxf		; save FN flag so array variable test fails
	JSR	LAB_1D12		; search for FN variable
	JMP	LAB_CTNM		; check if source is numeric and return, else do type
					; mismatch

					; Evaluate FNx
LAB_201E
	JSR	LAB_200B		; check FNx syntax
	PHA				; push function pointer low byte
	TYA				; copy function pointer high byte
	PHA				; push function pointer high byte
	JSR	LAB_1BFE		; scan for "(", else do syntax error then warm start
	JSR	LAB_EVEX		; evaluate expression
	JSR	LAB_1BFB		; scan for ")", else do syntax error then warm start
	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
	PLA				; pop function pointer high byte
	STA	func_h		; restore it
	PLA				; pop function pointer low byte
	STA	func_l		; restore it
	LDX	#$20			; error code $20 ("Undefined function" error)
	LDY	#$03			; index to variable pointer high byte
	LDA	(func_l),Y		; get variable pointer high byte
	BEQ	LAB_1FDB		; if zero go do undefined function error

	STA	Cvarah		; save variable address high byte
	DEY				; index to variable address low byte
	LDA	(func_l),Y		; get variable address low byte
	STA	Cvaral		; save variable address low byte
	TAX				; copy address low byte

					; now stack the function variable value before use
	INY				; index to mantissa_3
LAB_2043
	LDA	(Cvaral),Y		; get byte from variable
	PHA				; stack it
	DEY				; decrement index
	BPL	LAB_2043		; loop until variable stacked

	LDY	Cvarah		; get variable address high byte
	JSR	LAB_2778		; pack FAC1 (function expression value) into (XY)
					; (function variable), return Y=0, always
	LDA	Bpntrh		; get BASIC execute pointer high byte
	PHA				; push it
	LDA	Bpntrl		; get BASIC execute pointer low byte
	PHA				; push it
	LDA	(func_l),Y		; get function execute pointer low byte
	STA	Bpntrl		; save as BASIC execute pointer low byte
	INY				; index to high byte
	LDA	(func_l),Y		; get function execute pointer high byte
	STA	Bpntrh		; save as BASIC execute pointer high byte
	LDA	Cvarah		; get variable address high byte
	PHA				; push it
	LDA	Cvaral		; get variable address low byte
	PHA				; push it
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	PLA				; pull variable address low byte
	STA	func_l		; save variable address low byte
	PLA				; pull variable address high byte
	STA	func_h		; save variable address high byte
	JSR	LAB_GBYT		; scan memory
	BEQ	LAB_2074		; branch if null (should be [EOL] marker)

	JMP	LAB_SNER		; else syntax error then warm start

; restore Bpntrl,Bpntrh and function variable from stack

LAB_2074
	PLA				; pull BASIC execute pointer low byte
	STA	Bpntrl		; restore BASIC execute pointer low byte
	PLA				; pull BASIC execute pointer high byte
	STA	Bpntrh		; restore BASIC execute pointer high byte

; put execute pointer and variable pointer into function

LAB_207A
	LDY	#$00			; clear index
	PLA				; pull BASIC execute pointer low byte
	STA	(func_l),Y		; save to function
	INY				; increment index
	PLA				; pull BASIC execute pointer high byte
	STA	(func_l),Y		; save to function
	INY				; increment index
	PLA				; pull current var address low byte
	STA	(func_l),Y		; save to function
	INY				; increment index
	PLA				; pull current var address high byte
	STA	(func_l),Y		; save to function
	RTS

; perform STR$()

LAB_STRS
	JSR	LAB_CTNM		; check if source is numeric, else do type mismatch
	JSR	LAB_296E		; convert FAC1 to string
	LDA	#<Decssp1		; set result string low pointer
	LDY	#>Decssp1		; set result string high pointer
	BEQ	LAB_20AE		; print null terminated string to Sutill/Sutilh

; Do string vector
; copy des_pl/h to des_2l/h and make string space A bytes long

LAB_209C
	LDX	des_pl		; get descriptor pointer low byte
	LDY	des_ph		; get descriptor pointer high byte
	STX	des_2l		; save descriptor pointer low byte
	STY	des_2h		; save descriptor pointer high byte

; make string space A bytes long
; A=length, X=Sutill=ptr low byte, Y=Sutilh=ptr high byte

LAB_MSSP
	JSR	LAB_2115		; make space in string memory for string A long
					; return X=Sutill=ptr low byte, Y=Sutilh=ptr high byte
	STX	str_pl		; save string pointer low byte
	STY	str_ph		; save string pointer high byte
	STA	str_ln		; save length
	RTS

; Scan, set up string
; print " terminated string to Sutill/Sutilh

LAB_20AE
	LDX	#$22			; set terminator to "
	STX	Srchc			; set search character (terminator 1)
	STX	Asrch			; set terminator 2

; print [Srchc] or [Asrch] terminated string to Sutill/Sutilh
; source is AY

LAB_20B4
	STA	ssptr_l		; store string start low byte
	STY	ssptr_h		; store string start high byte
	STA	str_pl		; save string pointer low byte
	STY	str_ph		; save string pointer high byte
	LDY	#$FF			; set length to -1
LAB_20BE
	INY				; increment length
	LDA	(ssptr_l),Y		; get byte from string
	BEQ	LAB_20CF		; exit loop if null byte [EOS]

	CMP	Srchc			; compare with search character (terminator 1)
	BEQ	LAB_20CB		; branch if terminator

	CMP	Asrch			; compare with terminator 2
	BNE	LAB_20BE		; loop if not terminator 2

LAB_20CB
	CMP	#$22			; compare with "
	BEQ	LAB_20D0		; branch if " (carry set if = !)

LAB_20CF
	CLC				; clear carry for add (only if [EOL] terminated string)
LAB_20D0
	STY	str_ln		; save length in FAC1 exponent
	TYA				; copy length to A
	ADC	ssptr_l		; add string start low byte
	STA	Sendl			; save string end low byte
	LDX	ssptr_h		; get string start high byte
	BCC	LAB_20DC		; branch if no low byte overflow

	INX				; else increment high byte
LAB_20DC
	STX	Sendh			; save string end high byte
	LDA	ssptr_h		; get string start high byte
	CMP	#>Ram_base		; compare with start of program memory
	BCS	LAB_RTST		; branch if not in utility area

					; string in utility area, move to string memory
	TYA				; copy length to A
	JSR	LAB_209C		; copy des_pl/h to des_2l/h and make string space A bytes
					; long
	LDX	ssptr_l		; get string start low byte
	LDY	ssptr_h		; get string start high byte
	JSR	LAB_2298		; store string A bytes long from XY to (Sutill)

; check for space on descriptor stack then ..
; put string address and length on descriptor stack and update stack pointers

LAB_RTST
	LDX	next_s		; get string stack pointer
	CPX	#des_sk+$09		; compare with max+1
	BNE	LAB_20F8		; branch if space on string stack

					; else do string too complex error
	LDX	#$1C			; error code $1C ("String too complex" error)
LAB_20F5
	JMP	LAB_XERR		; do error #X, then warm start

; put string address and length on descriptor stack and update stack pointers

LAB_20F8
	LDA	str_ln		; get string length
	STA	PLUS_0,X		; put on string stack
	LDA	str_pl		; get string pointer low byte
	STA	PLUS_1,X		; put on string stack
	LDA	str_ph		; get string pointer high byte
	STA	PLUS_2,X		; put on string stack
	LDY	#$00			; clear Y
	STX	des_pl		; save string descriptor pointer low byte
	STY	des_ph		; save string descriptor pointer high byte (always $00)
	DEY				; Y = $FF
	STY	Dtypef		; save data type flag, $FF=string
	STX	last_sl		; save old stack pointer (current top item)
	INX				; update stack pointer
	INX				; update stack pointer
	INX				; update stack pointer
	STX	next_s		; save new top item value
	RTS

; Build descriptor
; make space in string memory for string A long
; return X=Sutill=ptr low byte, Y=Sutill=ptr high byte

LAB_2115
	LSR	Gclctd		; clear garbage collected flag (b7)

					; make space for string A long
LAB_2117
	PHA				; save string length
	EOR	#$FF			; complement it
	SEC				; set carry for subtract (twos comp add)
	ADC	Sstorl		; add bottom of string space low byte (subtract length)
	LDY	Sstorh		; get bottom of string space high byte
	BCS	LAB_2122		; skip decrement if no underflow

	DEY				; decrement bottom of string space high byte
LAB_2122
	CPY	Earryh		; compare with array mem end high byte
	BCC	LAB_2137		; do out of memory error if less

	BNE	LAB_212C		; if not = skip next test

	CMP	Earryl		; compare with array mem end low byte
	BCC	LAB_2137		; do out of memory error if less

LAB_212C
	STA	Sstorl		; save bottom of string space low byte
	STY	Sstorh		; save bottom of string space high byte
	STA	Sutill		; save string utility ptr low byte
	STY	Sutilh		; save string utility ptr high byte
	TAX				; copy low byte to X
	PLA				; get string length back
	RTS

LAB_2137
	LDX	#$0C			; error code $0C ("Out of memory" error)
	LDA	Gclctd		; get garbage collected flag
	BMI	LAB_20F5		; if set then do error code X

	JSR	LAB_GARB		; else go do garbage collection
	LDA	#$80			; flag for garbage collected
	STA	Gclctd		; set garbage collected flag
	PLA				; pull length
	BNE	LAB_2117		; go try again (loop always, length should never be = $00)

; garbage collection routine

LAB_GARB
	LDX	Ememl			; get end of mem low byte
	LDA	Ememh			; get end of mem high byte

; re-run routine from last ending

LAB_214B
	STX	Sstorl		; set string storage low byte
	STA	Sstorh		; set string storage high byte
	LDY	#$00			; clear index
	STY	garb_h		; clear working pointer high byte (flag no strings to move)
	LDA	Earryl		; get array mem end low byte
	LDX	Earryh		; get array mem end high byte
	STA	Histrl		; save as highest string low byte
	STX	Histrh		; save as highest string high byte
	LDA	#des_sk		; set descriptor stack pointer
	STA	ut1_pl		; save descriptor stack pointer low byte
	STY	ut1_ph		; save descriptor stack pointer high byte ($00)
LAB_2161
	CMP	next_s		; compare with descriptor stack pointer
	BEQ	LAB_216A		; branch if =

	JSR	LAB_21D7		; go garbage collect descriptor stack
	BEQ	LAB_2161		; loop always

					; done stacked strings, now do string vars
LAB_216A
	ASL	g_step		; set step size = $06
	LDA	Svarl			; get start of vars low byte
	LDX	Svarh			; get start of vars high byte
	STA	ut1_pl		; save as pointer low byte
	STX	ut1_ph		; save as pointer high byte
LAB_2176
	CPX	Sarryh		; compare start of arrays high byte
	BNE	LAB_217E		; branch if no high byte match

	CMP	Sarryl		; else compare start of arrays low byte
	BEQ	LAB_2183		; branch if = var mem end

LAB_217E
	JSR	LAB_21D1		; go garbage collect strings
	BEQ	LAB_2176		; loop always

					; done string vars, now do string arrays
LAB_2183
	STA	Nbendl		; save start of arrays low byte as working pointer
	STX	Nbendh		; save start of arrays high byte as working pointer
	LDA	#$04			; set step size
	STA	g_step		; save step size
LAB_218B
	LDA	Nbendl		; get pointer low byte
	LDX	Nbendh		; get pointer high byte
LAB_218F
	CPX	Earryh		; compare with array mem end high byte
	BNE	LAB_219A		; branch if not at end

	CMP	Earryl		; else compare with array mem end low byte
	BEQ	LAB_2216		; tidy up and exit if at end

LAB_219A
	STA	ut1_pl		; save pointer low byte
	STX	ut1_ph		; save pointer high byte
	LDY	#$02			; set index
	LDA	(ut1_pl),Y		; get array size low byte
	ADC	Nbendl		; add start of this array low byte
	STA	Nbendl		; save start of next array low byte
	INY				; increment index
	LDA	(ut1_pl),Y		; get array size high byte
	ADC	Nbendh		; add start of this array high byte
	STA	Nbendh		; save start of next array high byte
	LDY	#$01			; set index
	LDA	(ut1_pl),Y		; get name second byte
	BPL	LAB_218B		; skip if not string array

; was string array so ..

	LDY	#$04			; set index
	LDA	(ut1_pl),Y		; get # of dimensions
	ASL				; *2
	ADC	#$05			; +5 (array header size)
	JSR	LAB_2208		; go set up for first element
LAB_21C4
	CPX	Nbendh		; compare with start of next array high byte
	BNE	LAB_21CC		; branch if <> (go do this array)

	CMP	Nbendl		; else compare element pointer low byte with next array
					; low byte
	BEQ	LAB_218F		; if equal then go do next array

LAB_21CC
	JSR	LAB_21D7		; go defrag array strings
	BEQ	LAB_21C4		; go do next array string (loop always)

; defrag string variables
; enter with XA = variable pointer
; return with XA = next variable pointer

LAB_21D1
	INY				; increment index (Y was $00)
	LDA	(ut1_pl),Y		; get var name byte 2
	BPL	LAB_2206		; if not string, step pointer to next var and return

	INY				; else increment index
LAB_21D7
	LDA	(ut1_pl),Y		; get string length
	BEQ	LAB_2206		; if null, step pointer to next string and return

	INY				; else increment index
	LDA	(ut1_pl),Y		; get string pointer low byte
	TAX				; copy to X
	INY				; increment index
	LDA	(ut1_pl),Y		; get string pointer high byte
	CMP	Sstorh		; compare bottom of string space high byte
	BCC	LAB_21EC		; branch if less

	BNE	LAB_2206		; if greater, step pointer to next string and return

					; high bytes were = so compare low bytes
	CPX	Sstorl		; compare bottom of string space low byte
	BCS	LAB_2206		; if >=, step pointer to next string and return

					; string pointer is < string storage pointer (pos in mem)
LAB_21EC
	CMP	Histrh		; compare to highest string high byte
	BCC	LAB_2207		; if <, step pointer to next string and return

	BNE	LAB_21F6		; if > update pointers, step to next and return

					; high bytes were = so compare low bytes
	CPX	Histrl		; compare to highest string low byte
	BCC	LAB_2207		; if <, step pointer to next string and return

					; string is in string memory space
LAB_21F6
	STX	Histrl		; save as new highest string low byte
	STA	Histrh		; save as new highest string high byte
	LDA	ut1_pl		; get start of vars(descriptors) low byte
	LDX	ut1_ph		; get start of vars(descriptors) high byte
	STA	garb_l		; save as working pointer low byte
	STX	garb_h		; save as working pointer high byte
	DEY				; decrement index DIFFERS
	DEY				; decrement index (should point to descriptor start)
	STY	g_indx		; save index pointer

					; step pointer to next string
LAB_2206
	CLC				; clear carry for add
LAB_2207
	LDA	g_step		; get step size
LAB_2208
	ADC	ut1_pl		; add pointer low byte
	STA	ut1_pl		; save pointer low byte
	BCC	LAB_2211		; branch if no overflow

	INC	ut1_ph		; else increment high byte
LAB_2211
	LDX	ut1_ph		; get pointer high byte
	LDY	#$00			; clear Y
	RTS

; search complete, now either exit or set-up and move string

LAB_2216
	DEC	g_step		; decrement step size (now $03 for descriptor stack)
	LDX	garb_h		; get string to move high byte
	BEQ	LAB_2211		; exit if nothing to move

	LDY	g_indx		; get index byte back (points to descriptor)
	CLC				; clear carry for add
	LDA	(garb_l),Y		; get string length
	ADC	Histrl		; add highest string low byte
	STA	Obendl		; save old block end low pointer
	LDA	Histrh		; get highest string high byte
	ADC	#$00			; add any carry
	STA	Obendh		; save old block end high byte
	LDA	Sstorl		; get bottom of string space low byte
	LDX	Sstorh		; get bottom of string space high byte
	STA	Nbendl		; save new block end low byte
	STX	Nbendh		; save new block end high byte
	JSR	LAB_11D6		; open up space in memory, don't set array end
	LDY	g_indx		; get index byte
	INY				; point to descriptor low byte
	LDA	Nbendl		; get string pointer low byte
	STA	(garb_l),Y		; save new string pointer low byte
	TAX				; copy string pointer low byte
	INC	Nbendh		; correct high byte (move sets high byte -1)
	LDA	Nbendh		; get new string pointer high byte
	INY				; point to descriptor high byte
	STA	(garb_l),Y		; save new string pointer high byte
	JMP	LAB_214B		; re-run routine from last ending
					; (but don't collect this string)

; concatenate
; add strings, string 1 is in descriptor des_pl, string 2 is in line

LAB_224D
	LDA	des_ph		; get descriptor pointer high byte
	PHA				; put on stack
	LDA	des_pl		; get descriptor pointer low byte
	PHA				; put on stack
	JSR	LAB_GVAL		; get value from line
	JSR	LAB_CTST		; check if source is string, else do type mismatch
	PLA				; get descriptor pointer low byte back
	STA	ssptr_l		; set pointer low byte
	PLA				; get descriptor pointer high byte back
	STA	ssptr_h		; set pointer high byte
	LDY	#$00			; clear index
	LDA	(ssptr_l),Y		; get length_1 from descriptor
	CLC				; clear carry for add
	ADC	(des_pl),Y		; add length_2
	BCC	LAB_226D		; branch if no overflow

	LDX	#$1A			; else set error code $1A ("String too long" error)
	JMP	LAB_XERR		; do error #X, then warm start

LAB_226D
	JSR	LAB_209C		; copy des_pl/h to des_2l/h and make string space A bytes
					; long
	JSR	LAB_228A		; copy string from descriptor (sdescr) to (Sutill)
	LDA	des_2l		; get descriptor pointer low byte
	LDY	des_2h		; get descriptor pointer high byte
	JSR	LAB_22BA		; pop (YA) descriptor off stack or from top of string space
					; returns with A = length, ut1_pl = pointer low byte,
					; ut1_ph = pointer high byte
	JSR	LAB_229C		; store string A bytes long from (ut1_pl) to (Sutill)
	LDA	ssptr_l		;.set descriptor pointer low byte
	LDY	ssptr_h		;.set descriptor pointer high byte
	JSR	LAB_22BA		; pop (YA) descriptor off stack or from top of string space
					; returns with A = length, X=ut1_pl=pointer low byte,
					; Y=ut1_ph=pointer high byte
	JSR	LAB_RTST		; check for space on descriptor stack then put string
					; address and length on descriptor stack and update stack
					; pointers
	JMP	LAB_1ADB		;.continue evaluation

; copy string from descriptor (sdescr) to (Sutill)

LAB_228A
	LDY	#$00			; clear index
	LDA	(sdescr),Y		; get string length
	PHA				; save on stack
	INY				; increment index
	LDA	(sdescr),Y		; get source string pointer low byte
	TAX				; copy to X
	INY				; increment index
	LDA	(sdescr),Y		; get source string pointer high byte
	TAY				; copy to Y
	PLA				; get length back

; store string A bytes long from YX to (Sutill)

LAB_2298
	STX	ut1_pl		; save source string pointer low byte
	STY	ut1_ph		; save source string pointer high byte

; store string A bytes long from (ut1_pl) to (Sutill)

LAB_229C
	TAX				; copy length to index (don't count with Y)
	BEQ	LAB_22B2		; branch if = $0 (null string) no need to add zero length

	LDY	#$00			; zero pointer (copy forward)
LAB_22A0
	LDA	(ut1_pl),Y		; get source byte
	STA	(Sutill),Y		; save destination byte

	INY				; increment index
	DEX				; decrement counter
	BNE	LAB_22A0		; loop while <> 0

	TYA				; restore length from Y
LAB_22A9
	CLC				; clear carry for add
	ADC	Sutill		; add string utility ptr low byte
	STA	Sutill		; save string utility ptr low byte
	BCC	LAB_22B2		; branch if no carry

	INC	Sutilh		; else increment string utility ptr high byte
LAB_22B2
	RTS

; evaluate string

LAB_EVST
	JSR	LAB_CTST		; check if source is string, else do type mismatch

; pop string off descriptor stack, or from top of string space
; returns with A = length, X=pointer low byte, Y=pointer high byte

LAB_22B6
	LDA	des_pl		; get descriptor pointer low byte
	LDY	des_ph		; get descriptor pointer high byte

; pop (YA) descriptor off stack or from top of string space
; returns with A = length, X=ut1_pl=pointer low byte, Y=ut1_ph=pointer high byte

LAB_22BA
	STA	ut1_pl		; save descriptor pointer low byte
	STY	ut1_ph		; save descriptor pointer high byte
	JSR	LAB_22EB		; clean descriptor stack, YA = pointer
	PHP				; save status flags
	LDY	#$00			; clear index
	LDA	(ut1_pl),Y		; get length from string descriptor
	PHA				; put on stack
	INY				; increment index
	LDA	(ut1_pl),Y		; get string pointer low byte from descriptor
	TAX				; copy to X
	INY				; increment index
	LDA	(ut1_pl),Y		; get string pointer high byte from descriptor
	TAY				; copy to Y
	PLA				; get string length back
	PLP				; restore status
	BNE	LAB_22E6		; branch if pointer <> last_sl,last_sh

	CPY	Sstorh		; compare bottom of string space high byte
	BNE	LAB_22E6		; branch if <>

	CPX	Sstorl		; else compare bottom of string space low byte
	BNE	LAB_22E6		; branch if <>

	PHA				; save string length
	CLC				; clear carry for add
	ADC	Sstorl		; add bottom of string space low byte
	STA	Sstorl		; save bottom of string space low byte
	BCC	LAB_22E5		; skip increment if no overflow

	INC	Sstorh		; increment bottom of string space high byte
LAB_22E5
	PLA				; restore string length
LAB_22E6
	STX	ut1_pl		; save string pointer low byte
	STY	ut1_ph		; save string pointer high byte
	RTS

; clean descriptor stack, YA = pointer
; checks if AY is on the descriptor stack, if so does a stack discard

LAB_22EB
	CPY	last_sh		; compare pointer high byte
	BNE	LAB_22FB		; exit if <>

	CMP	last_sl		; compare pointer low byte
	BNE	LAB_22FB		; exit if <>

	STA	next_s		; save descriptor stack pointer
	SBC	#$03			; -3
	STA	last_sl		; save low byte -3
	LDY	#$00			; clear high byte
LAB_22FB
	RTS

; perform CHR$()

LAB_CHRS
	JSR	LAB_EVBY		; evaluate byte expression, result in X
	TXA				; copy to A
	PHA				; save character
	LDA	#$01			; string is single byte
	JSR	LAB_MSSP		; make string space A bytes long A=$AC=length,
					; X=$AD=Sutill=ptr low byte, Y=$AE=Sutilh=ptr high byte
	PLA				; get character back
	LDY	#$00			; clear index
	STA	(str_pl),Y		; save byte in string (byte IS string!)
	JMP	LAB_RTST		; check for space on descriptor stack then put string
					; address and length on descriptor stack and update stack
					; pointers

; perform LEFT$()

LAB_LEFT
	PHA				; push byte parameter
	JSR	LAB_236F		; pull string data and byte parameter from stack
					; return pointer in des_2l/h, byte in A (and X), Y=0
	CMP	(des_2l),Y		; compare byte parameter with string length
	TYA				; clear A
	BEQ	LAB_2316		; go do string copy (branch always)

; perform RIGHT$()

LAB_RIGHT
	PHA				; push byte parameter
	JSR	LAB_236F		; pull string data and byte parameter from stack
					; return pointer in des_2l/h, byte in A (and X), Y=0
	CLC				; clear carry for add-1
	SBC	(des_2l),Y		; subtract string length
	EOR	#$FF			; invert it (A=LEN(expression$)-l)

LAB_2316
	BCC	LAB_231C		; branch if string length > byte parameter

	LDA	(des_2l),Y		; else make parameter = length
	TAX				; copy to byte parameter copy
	TYA				; clear string start offset
LAB_231C
	PHA				; save string start offset
LAB_231D
	TXA				; copy byte parameter (or string length if <)
LAB_231E
	PHA				; save string length
	JSR	LAB_MSSP		; make string space A bytes long A=$AC=length,
					; X=$AD=Sutill=ptr low byte, Y=$AE=Sutilh=ptr high byte
	LDA	des_2l		; get descriptor pointer low byte
	LDY	des_2h		; get descriptor pointer high byte
	JSR	LAB_22BA		; pop (YA) descriptor off stack or from top of string space
					; returns with A = length, X=ut1_pl=pointer low byte,
					; Y=ut1_ph=pointer high byte
	PLA				; get string length back
	TAY				; copy length to Y
	PLA				; get string start offset back
	CLC				; clear carry for add
	ADC	ut1_pl		; add start offset to string start pointer low byte
	STA	ut1_pl		; save string start pointer low byte
	BCC	LAB_2335		; branch if no overflow

	INC	ut1_ph		; else increment string start pointer high byte
LAB_2335
	TYA				; copy length to A
	JSR	LAB_229C		; store string A bytes long from (ut1_pl) to (Sutill)
	JMP	LAB_RTST		; check for space on descriptor stack then put string
					; address and length on descriptor stack and update stack
					; pointers

; perform MID$()

LAB_MIDS
	PHA				; push byte parameter
	LDA	#$FF			; set default length = 255
	STA	mids_l		; save default length
	JSR	LAB_GBYT		; scan memory
	CMP	#')'			; compare with ")"
	BEQ	LAB_2358		; branch if = ")" (skip second byte get)

	JSR	LAB_1C01		; scan for "," , else do syntax error then warm start
	JSR	LAB_GTBY		; get byte parameter (use copy in mids_l)
LAB_2358
	JSR	LAB_236F		; pull string data and byte parameter from stack
					; return pointer in des_2l/h, byte in A (and X), Y=0
	DEX				; decrement start index
	TXA				; copy to A
	PHA				; save string start offset
	CLC				; clear carry for sub-1
	LDX	#$00			; clear output string length
	SBC	(des_2l),Y		; subtract string length
	BCS	LAB_231D		; if start>string length go do null string

	EOR	#$FF			; complement -length
	CMP	mids_l		; compare byte parameter
	BCC	LAB_231E		; if length>remaining string go do RIGHT$

	LDA	mids_l		; get length byte
	BCS	LAB_231E		; go do string copy (branch always)

; pull string data and byte parameter from stack
; return pointer in des_2l/h, byte in A (and X), Y=0

LAB_236F
	JSR	LAB_1BFB		; scan for ")" , else do syntax error then warm start
	PLA				; pull return address low byte (return address)
	STA	Fnxjpl		; save functions jump vector low byte
	PLA				; pull return address high byte (return address)
	STA	Fnxjph		; save functions jump vector high byte
	PLA				; pull byte parameter
	TAX				; copy byte parameter to X
	PLA				; pull string pointer low byte
	STA	des_2l		; save it
	PLA				; pull string pointer high byte
	STA	des_2h		; save it
	LDY	#$00			; clear index
	TXA				; copy byte parameter
	BEQ	LAB_23A8		; if null do function call error then warm start

	INC	Fnxjpl		; increment function jump vector low byte
					; (JSR pushes return addr-1. this is all very nice
					; but will go tits up if either call is on a page
					; boundary!)
	JMP	(Fnxjpl)		; in effect, RTS

; perform LCASE$()

LAB_LCASE
	JSR	LAB_EVST		; evaluate string
	STA	str_ln		; set string length
	TAY				; copy length to Y
	BEQ	NoString		; branch if null string

	JSR	LAB_MSSP		; make string space A bytes long A=length,
					; X=Sutill=ptr low byte, Y=Sutilh=ptr high byte
	STX	str_pl		; save string pointer low byte
	STY	str_ph		; save string pointer high byte
	TAY				; get string length back

LC_loop
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get byte from string
	JSR	LAB_1D82		; is character "A" to "Z"
	BCC	NoUcase		; branch if not upper case alpha

	ORA	#$20			; convert upper to lower case
NoUcase
	STA	(Sutill),Y		; save byte back to string
	TYA				; test index
	BNE	LC_loop		; loop if not all done

	BEQ	NoString		; tidy up and exit, branch always

; perform UCASE$()

LAB_UCASE
	JSR	LAB_EVST		; evaluate string
	STA	str_ln		; set string length
	TAY				; copy length to Y
	BEQ	NoString		; branch if null string

	JSR	LAB_MSSP		; make string space A bytes long A=length,
					; X=Sutill=ptr low byte, Y=Sutilh=ptr high byte
	STX	str_pl		; save string pointer low byte
	STY	str_ph		; save string pointer high byte
	TAY				; get string length back

UC_loop
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get byte from string
	JSR	LAB_CASC		; is character "a" to "z" (or "A" to "Z")
	BCC	NoLcase		; branch if not alpha

	AND	#$DF			; convert lower to upper case
NoLcase
	STA	(Sutill),Y		; save byte back to string
	TYA				; test index
	BNE	UC_loop		; loop if not all done

NoString
	JMP	LAB_RTST		; check for space on descriptor stack then put string
					; address and length on descriptor stack and update stack
					; pointers

; perform SADD()

LAB_SADD
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_GVAR		; get var address

	JSR	LAB_1BFB		; scan for ")", else do syntax error then warm start
	JSR	LAB_CTST		; check if source is string, else do type mismatch

	LDY	#$02			; index to string pointer high byte
	LDA	(Cvaral),Y		; get string pointer high byte
	TAX				; copy string pointer high byte to X
	DEY				; index to string pointer low byte
	LDA	(Cvaral),Y		; get string pointer low byte
	TAY				; copy string pointer low byte to Y
	TXA				; copy string pointer high byte to A
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; perform LEN()

LAB_LENS
	JSR	LAB_ESGL		; evaluate string, get length in A (and Y)
	JMP	LAB_1FD0		; convert Y to byte in FAC1 and return

; evaluate string, get length in Y

LAB_ESGL
	JSR	LAB_EVST		; evaluate string
	TAY				; copy length to Y
	RTS

; perform ASC()

LAB_ASC
	JSR	LAB_ESGL		; evaluate string, get length in A (and Y)
	BEQ	LAB_23A8		; if null do function call error then warm start

	LDY	#$00			; set index to first character
	LDA	(ut1_pl),Y		; get byte
	TAY				; copy to Y
	JMP	LAB_1FD0		; convert Y to byte in FAC1 and return

; do function call error then warm start

LAB_23A8
	JMP	LAB_FCER		; do function call error then warm start

; scan and get byte parameter

LAB_SGBY
	JSR	LAB_IGBY		; increment and scan memory

; get byte parameter

LAB_GTBY
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch

; evaluate byte expression, result in X

LAB_EVBY
	JSR	LAB_EVPI		; evaluate integer expression (no check)

	LDY	FAC1_2		; get FAC1 mantissa2
	BNE	LAB_23A8		; if top byte <> 0 do function call error then warm start

	LDX	FAC1_3		; get FAC1 mantissa3
	JMP	LAB_GBYT		; scan memory and return

; perform VAL()

LAB_VAL
	JSR	LAB_ESGL		; evaluate string, get length in A (and Y)
	BNE	LAB_23C5		; branch if not null string

					; string was null so set result = $00
	JMP	LAB_24F1		; clear FAC1 exponent and sign and return

LAB_23C5
	LDX	Bpntrl		; get BASIC execute pointer low byte
	LDY	Bpntrh		; get BASIC execute pointer high byte
	STX	Btmpl			; save BASIC execute pointer low byte
	STY	Btmph			; save BASIC execute pointer high byte
	LDX	ut1_pl		; get string pointer low byte
	STX	Bpntrl		; save as BASIC execute pointer low byte
	CLC				; clear carry
	ADC	ut1_pl		; add string length
	STA	ut2_pl		; save string end low byte
	LDA	ut1_ph		; get string pointer high byte
	STA	Bpntrh		; save as BASIC execute pointer high byte
	ADC	#$00			; add carry to high byte
	STA	ut2_ph		; save string end high byte
	LDY	#$00			; set index to $00
	LDA	(ut2_pl),Y		; get string end +1 byte
	PHA				; push it
	TYA				; clear A
	STA	(ut2_pl),Y		; terminate string with $00
	JSR	LAB_GBYT		; scan memory
	JSR	LAB_2887		; get FAC1 from string
	PLA				; restore string end +1 byte
	LDY	#$00			; set index to zero
	STA	(ut2_pl),Y		; put string end byte back

; restore BASIC execute pointer from temp (Btmpl/Btmph)

LAB_23F3
	LDX	Btmpl			; get BASIC execute pointer low byte back
	LDY	Btmph			; get BASIC execute pointer high byte back
	STX	Bpntrl		; save BASIC execute pointer low byte
	STY	Bpntrh		; save BASIC execute pointer high byte
	RTS

; get two parameters for POKE or WAIT

LAB_GADB
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	JSR	LAB_F2FX		; save integer part of FAC1 in temporary integer

; scan for "," and get byte, else do Syntax error then warm start

LAB_SCGB
	JSR	LAB_1C01		; scan for "," , else do syntax error then warm start
	LDA	Itemph		; save temporary integer high byte
	PHA				; on stack
	LDA	Itempl		; save temporary integer low byte
	PHA				; on stack
	JSR	LAB_GTBY		; get byte parameter
	PLA				; pull low byte
	STA	Itempl		; restore temporary integer low byte
	PLA				; pull high byte
	STA	Itemph		; restore temporary integer high byte
	RTS

; convert float to fixed routine. accepts any value that fits in 24 bits, +ve or
; -ve and converts it into a right truncated integer in Itempl and Itemph

; save unsigned 16 bit integer part of FAC1 in temporary integer

LAB_F2FX
	LDA	FAC1_e		; get FAC1 exponent
	CMP	#$98			; compare with exponent = 2^24
	BCS	LAB_23A8		; if >= do function call error then warm start

LAB_F2FU
	JSR	LAB_2831		; convert FAC1 floating-to-fixed
	LDA	FAC1_2		; get FAC1 mantissa2
	LDY	FAC1_3		; get FAC1 mantissa3
	STY	Itempl		; save temporary integer low byte
	STA	Itemph		; save temporary integer high byte
	RTS

; perform PEEK()

LAB_PEEK
	JSR	LAB_F2FX		; save integer part of FAC1 in temporary integer
	LDX	#$00			; clear index
	LDA	(Itempl,X)		; get byte via temporary integer (addr)
	TAY				; copy byte to Y
	JMP	LAB_1FD0		; convert Y to byte in FAC1 and return

; perform POKE

LAB_POKE
	JSR	LAB_GADB		; get two parameters for POKE or WAIT
	TXA				; copy byte argument to A
	LDX	#$00			; clear index
	STA	(Itempl,X)		; save byte via temporary integer (addr)
	RTS

; perform DEEK()

LAB_DEEK
	JSR	LAB_F2FX		; save integer part of FAC1 in temporary integer
	LDX	#$00			; clear index
	LDA	(Itempl,X)		; PEEK low byte
	TAY				; copy to Y
	INC	Itempl		; increment pointer low byte
	BNE	Deekh			; skip high increment if no rollover

	INC	Itemph		; increment pointer high byte
Deekh
	LDA	(Itempl,X)		; PEEK high byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; perform DOKE

LAB_DOKE
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	JSR	LAB_F2FX		; convert floating-to-fixed

	STY	Frnxtl		; save pointer low byte (float to fixed returns word in AY)
	STA	Frnxth		; save pointer high byte

	JSR	LAB_1C01		; scan for "," , else do syntax error then warm start
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	JSR	LAB_F2FX		; convert floating-to-fixed

	TYA				; copy value low byte (float to fixed returns word in AY)
	LDX	#$00			; clear index
	STA	(Frnxtl,X)		; POKE low byte
	INC	Frnxtl		; increment pointer low byte
	BNE	Dokeh			; skip high increment if no rollover

	INC	Frnxth		; increment pointer high byte
Dokeh
	LDA	Itemph		; get value high byte
	STA	(Frnxtl,X)		; POKE high byte
	JMP	LAB_GBYT		; scan memory and return

; perform SWAP

LAB_SWAP
	JSR	LAB_GVAR		; get var1 address
	STA	Lvarpl		; save var1 address low byte
	STY	Lvarph		; save var1 address high byte
	LDA	Dtypef		; get data type flag, $FF=string, $00=numeric
	PHA				; save data type flag

	JSR	LAB_1C01		; scan for "," , else do syntax error then warm start
	JSR	LAB_GVAR		; get var2 address (pointer in Cvaral/h)
	PLA				; pull var1 data type flag
	EOR	Dtypef		; compare with var2 data type
	BPL	SwapErr		; exit if not both the same type

	LDY	#$03			; four bytes to swap (either value or descriptor+1)
SwapLp
	LDA	(Lvarpl),Y		; get byte from var1
	TAX				; save var1 byte
	LDA	(Cvaral),Y		; get byte from var2
	STA	(Lvarpl),Y		; save byte to var1
	TXA				; restore var1 byte
	STA	(Cvaral),Y		; save byte to var2
	DEY				; decrement index
	BPL	SwapLp		; loop until done

	RTS

SwapErr
	JMP	LAB_1ABC		; do "Type mismatch" error then warm start

; perform CALL

LAB_CALL
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	JSR	LAB_F2FX		; convert floating-to-fixed
	LDA	#>CallExit		; set return address high byte
	PHA				; put on stack
	LDA	#<CallExit-1	; set return address low byte
	PHA				; put on stack
	JMP	(Itempl)		; do indirect jump to user routine

; if the called routine exits correctly then it will return to here. this will then get
; the next byte for the interpreter and return

CallExit
	JMP	LAB_GBYT		; scan memory and return

; perform WAIT

LAB_WAIT
	JSR	LAB_GADB		; get two parameters for POKE or WAIT
	STX	Frnxtl		; save byte
	LDX	#$00			; clear mask
	JSR	LAB_GBYT		; scan memory
	BEQ	LAB_2441		; skip if no third argument

	JSR	LAB_SCGB		; scan for "," and get byte, else SN error then warm start
LAB_2441
	STX	Frnxth		; save EOR argument
LAB_2445
	LDA	(Itempl),Y		; get byte via temporary integer (addr)
	EOR	Frnxth		; EOR with second argument (mask)
	AND	Frnxtl		; AND with first argument (byte)
	BEQ	LAB_2445		; loop if result is zero

LAB_244D
	RTS

; perform subtraction, FAC1 from (AY)

LAB_2455
	JSR	LAB_264D		; unpack memory (AY) into FAC2

; perform subtraction, FAC1 from FAC2

LAB_SUBTRACT
	LDA	FAC1_s		; get FAC1 sign (b7)
	EOR	#$FF			; complement it
	STA	FAC1_s		; save FAC1 sign (b7)
	EOR	FAC2_s		; EOR with FAC2 sign (b7)
	STA	FAC_sc		; save sign compare (FAC1 EOR FAC2)
	LDA	FAC1_e		; get FAC1 exponent
	JMP	LAB_ADD		; go add FAC2 to FAC1

; perform addition

LAB_2467
	JSR	LAB_257B		; shift FACX A times right (>8 shifts)
	BCC	LAB_24A8		;.go subtract mantissas

; add 0.5 to FAC1

LAB_244E
	LDA	#<LAB_2A96		; set 0.5 pointer low byte
	LDY	#>LAB_2A96		; set 0.5 pointer high byte

; add (AY) to FAC1

LAB_246C
	JSR	LAB_264D		; unpack memory (AY) into FAC2

; add FAC2 to FAC1

LAB_ADD
	BNE	LAB_2474		; branch if FAC1 was not zero

; copy FAC2 to FAC1

LAB_279B
	LDA	FAC2_s		; get FAC2 sign (b7)

; save FAC1 sign and copy ABS(FAC2) to FAC1

LAB_279D
	STA	FAC1_s		; save FAC1 sign (b7)
	LDX	#$04			; 4 bytes to copy
LAB_27A1
	LDA	FAC1_o,X		; get byte from FAC2,X
	STA	FAC1_e-1,X		; save byte at FAC1,X
	DEX				; decrement count
	BNE	LAB_27A1		; loop if not all done

	STX	FAC1_r		; clear FAC1 rounding byte
	RTS

					; FAC1 is non zero
LAB_2474
	LDX	FAC1_r		; get FAC1 rounding byte
	STX	FAC2_r		; save as FAC2 rounding byte
	LDX	#FAC2_e		; set index to FAC2 exponent addr
	LDA	FAC2_e		; get FAC2 exponent
LAB_247C
	TAY				; copy exponent
	BEQ	LAB_244D		; exit if zero

	SEC				; set carry for subtract
	SBC	FAC1_e		; subtract FAC1 exponent
	BEQ	LAB_24A8		; branch if = (go add mantissa)

	BCC	LAB_2498		; branch if <

					; FAC2>FAC1
	STY	FAC1_e		; save FAC1 exponent
	LDY	FAC2_s		; get FAC2 sign (b7)
	STY	FAC1_s		; save FAC1 sign (b7)
	EOR	#$FF			; complement A
	ADC	#$00			; +1 (twos complement, carry is set)
	LDY	#$00			; clear Y
	STY	FAC2_r		; clear FAC2 rounding byte
	LDX	#FAC1_e		; set index to FAC1 exponent addr
	BNE	LAB_249C		; branch always

LAB_2498
	LDY	#$00			; clear Y
	STY	FAC1_r		; clear FAC1 rounding byte
LAB_249C
	CMP	#$F9			; compare exponent diff with $F9
	BMI	LAB_2467		; branch if range $79-$F8

	TAY				; copy exponent difference to Y
	LDA	FAC1_r		; get FAC1 rounding byte
	LSR	PLUS_1,X		; shift FAC? mantissa1
	JSR	LAB_2592		; shift FACX Y times right

					; exponents are equal now do mantissa subtract
LAB_24A8
	BIT	FAC_sc		; test sign compare (FAC1 EOR FAC2)
	BPL	LAB_24F8		; if = add FAC2 mantissa to FAC1 mantissa and return

	LDY	#FAC1_e		; set index to FAC1 exponent addr
	CPX	#FAC2_e		; compare X to FAC2 exponent addr
	BEQ	LAB_24B4		; branch if =

	LDY	#FAC2_e		; else set index to FAC2 exponent addr

					; subtract smaller from bigger (take sign of bigger)
LAB_24B4
	SEC				; set carry for subtract
	EOR	#$FF			; ones complement A
	ADC	FAC2_r		; add FAC2 rounding byte
	STA	FAC1_r		; save FAC1 rounding byte
	LDA	PLUS_3,Y		; get FACY mantissa3
	SBC	PLUS_3,X		; subtract FACX mantissa3
	STA	FAC1_3		; save FAC1 mantissa3
	LDA	PLUS_2,Y		; get FACY mantissa2
	SBC	PLUS_2,X		; subtract FACX mantissa2
	STA	FAC1_2		; save FAC1 mantissa2
	LDA	PLUS_1,Y		; get FACY mantissa1
	SBC	PLUS_1,X		; subtract FACX mantissa1
	STA	FAC1_1		; save FAC1 mantissa1

; do ABS and normalise FAC1

LAB_24D0
	BCS	LAB_24D5		; branch if number is +ve

	JSR	LAB_2537		; negate FAC1

; normalise FAC1

LAB_24D5
	LDY	#$00			; clear Y
	TYA				; clear A
	CLC				; clear carry for add
LAB_24D9
	LDX	FAC1_1		; get FAC1 mantissa1
	BNE	LAB_251B		; if not zero normalise FAC1

	LDX	FAC1_2		; get FAC1 mantissa2
	STX	FAC1_1		; save FAC1 mantissa1
	LDX	FAC1_3		; get FAC1 mantissa3
	STX	FAC1_2		; save FAC1 mantissa2
	LDX	FAC1_r		; get FAC1 rounding byte
	STX	FAC1_3		; save FAC1 mantissa3
	STY	FAC1_r		; clear FAC1 rounding byte
	ADC	#$08			; add x to exponent offset
	CMP	#$18			; compare with $18 (max offset, all bits would be =0)
	BNE	LAB_24D9		; loop if not max

; clear FAC1 exponent and sign

LAB_24F1
	LDA	#$00			; clear A
LAB_24F3
	STA	FAC1_e		; set FAC1 exponent

; save FAC1 sign

LAB_24F5
	STA	FAC1_s		; save FAC1 sign (b7)
	RTS

; add FAC2 mantissa to FAC1 mantissa

LAB_24F8
	ADC	FAC2_r		; add FAC2 rounding byte
	STA	FAC1_r		; save FAC1 rounding byte
	LDA	FAC1_3		; get FAC1 mantissa3
	ADC	FAC2_3		; add FAC2 mantissa3
	STA	FAC1_3		; save FAC1 mantissa3
	LDA	FAC1_2		; get FAC1 mantissa2
	ADC	FAC2_2		; add FAC2 mantissa2
	STA	FAC1_2		; save FAC1 mantissa2
	LDA	FAC1_1		; get FAC1 mantissa1
	ADC	FAC2_1		; add FAC2 mantissa1
	STA	FAC1_1		; save FAC1 mantissa1
	BCS	LAB_252A		; if carry then normalise FAC1 for C=1

	RTS				; else just exit

LAB_2511
	ADC	#$01			; add 1 to exponent offset
	ASL	FAC1_r		; shift FAC1 rounding byte
	ROL	FAC1_3		; shift FAC1 mantissa3
	ROL	FAC1_2		; shift FAC1 mantissa2
	ROL	FAC1_1		; shift FAC1 mantissa1

; normalise FAC1

LAB_251B
	BPL	LAB_2511		; loop if not normalised

	SEC				; set carry for subtract
	SBC	FAC1_e		; subtract FAC1 exponent
	BCS	LAB_24F1		; branch if underflow (set result = $0)

	EOR	#$FF			; complement exponent
	ADC	#$01			; +1 (twos complement)
	STA	FAC1_e		; save FAC1 exponent

; test and normalise FAC1 for C=0/1

LAB_2528
	BCC	LAB_2536		; exit if no overflow

; normalise FAC1 for C=1

LAB_252A
	INC	FAC1_e		; increment FAC1 exponent
	BEQ	LAB_2564		; if zero do overflow error and warm start

	ROR	FAC1_1		; shift FAC1 mantissa1
	ROR	FAC1_2		; shift FAC1 mantissa2
	ROR	FAC1_3		; shift FAC1 mantissa3
	ROR	FAC1_r		; shift FAC1 rounding byte
LAB_2536
	RTS

; negate FAC1

LAB_2537
	LDA	FAC1_s		; get FAC1 sign (b7)
	EOR	#$FF			; complement it
	STA	FAC1_s		; save FAC1 sign (b7)

; twos complement FAC1 mantissa

LAB_253D
	LDA	FAC1_1		; get FAC1 mantissa1
	EOR	#$FF			; complement it
	STA	FAC1_1		; save FAC1 mantissa1
	LDA	FAC1_2		; get FAC1 mantissa2
	EOR	#$FF			; complement it
	STA	FAC1_2		; save FAC1 mantissa2
	LDA	FAC1_3		; get FAC1 mantissa3
	EOR	#$FF			; complement it
	STA	FAC1_3		; save FAC1 mantissa3
	LDA	FAC1_r		; get FAC1 rounding byte
	EOR	#$FF			; complement it
	STA	FAC1_r		; save FAC1 rounding byte
	INC	FAC1_r		; increment FAC1 rounding byte
	BNE	LAB_2563		; exit if no overflow

; increment FAC1 mantissa

LAB_2559
	INC	FAC1_3		; increment FAC1 mantissa3
	BNE	LAB_2563		; finished if no rollover

	INC	FAC1_2		; increment FAC1 mantissa2
	BNE	LAB_2563		; finished if no rollover

	INC	FAC1_1		; increment FAC1 mantissa1
LAB_2563
	RTS

; do overflow error (overflow exit)

LAB_2564
	LDX	#$0A			; error code $0A ("Overflow" error)
	JMP	LAB_XERR		; do error #X, then warm start

; shift FCAtemp << A+8 times

LAB_2569
	LDX	#FACt_1-1		; set offset to FACtemp
LAB_256B
	LDY	PLUS_3,X		; get FACX mantissa3
	STY	FAC1_r		; save as FAC1 rounding byte
	LDY	PLUS_2,X		; get FACX mantissa2
	STY	PLUS_3,X		; save FACX mantissa3
	LDY	PLUS_1,X		; get FACX mantissa1
	STY	PLUS_2,X		; save FACX mantissa2
	LDY	FAC1_o		; get FAC1 overflow byte
	STY	PLUS_1,X		; save FACX mantissa1

; shift FACX -A times right (> 8 shifts)

LAB_257B
	ADC	#$08			; add 8 to shift count
	BMI	LAB_256B		; go do 8 shift if still -ve

	BEQ	LAB_256B		; go do 8 shift if zero

	SBC	#$08			; else subtract 8 again
	TAY				; save count to Y
	LDA	FAC1_r		; get FAC1 rounding byte
	BCS	LAB_259A		;.

LAB_2588
	ASL	PLUS_1,X		; shift FACX mantissa1
	BCC	LAB_258E		; branch if +ve

	INC	PLUS_1,X		; this sets b7 eventually
LAB_258E
	ROR	PLUS_1,X		; shift FACX mantissa1 (correct for ASL)
	ROR	PLUS_1,X		; shift FACX mantissa1 (put carry in b7)

; shift FACX Y times right

LAB_2592
	ROR	PLUS_2,X		; shift FACX mantissa2
	ROR	PLUS_3,X		; shift FACX mantissa3
	ROR				; shift FACX rounding byte
	INY				; increment exponent diff
	BNE	LAB_2588		; branch if range adjust not complete

LAB_259A
	CLC				; just clear it
	RTS

; perform LOG()

LAB_LOG
	JSR	LAB_27CA		; test sign and zero
	BEQ	LAB_25C4		; if zero do function call error then warm start

	BPL	LAB_25C7		; skip error if +ve

LAB_25C4
	JMP	LAB_FCER		; do function call error then warm start (-ve)

LAB_25C7
	LDA	FAC1_e		; get FAC1 exponent
	SBC	#$7F			; normalise it
	PHA				; save it
	LDA	#$80			; set exponent to zero
	STA	FAC1_e		; save FAC1 exponent
	LDA	#<LAB_25AD		; set 1/root2 pointer low byte
	LDY	#>LAB_25AD		; set 1/root2 pointer high byte
	JSR	LAB_246C		; add (AY) to FAC1 (1/root2)
	LDA	#<LAB_25B1		; set root2 pointer low byte
	LDY	#>LAB_25B1		; set root2 pointer high byte
	JSR	LAB_26CA		; convert AY and do (AY)/FAC1 (root2/(x+(1/root2)))
	LDA	#<LAB_259C		; set 1 pointer low byte
	LDY	#>LAB_259C		; set 1 pointer high byte
	JSR	LAB_2455		; subtract (AY) from FAC1 ((root2/(x+(1/root2)))-1)
	LDA	#<LAB_25A0		; set pointer low byte to counter
	LDY	#>LAB_25A0		; set pointer high byte to counter
	JSR	LAB_2B6E		; ^2 then series evaluation
	LDA	#<LAB_25B5		; set -0.5 pointer low byte
	LDY	#>LAB_25B5		; set -0.5 pointer high byte
	JSR	LAB_246C		; add (AY) to FAC1
	PLA				; restore FAC1 exponent
	JSR	LAB_2912		; evaluate new ASCII digit
	LDA	#<LAB_25B9		; set LOG(2) pointer low byte
	LDY	#>LAB_25B9		; set LOG(2) pointer high byte

; do convert AY, FCA1*(AY)

LAB_25FB
	JSR	LAB_264D		; unpack memory (AY) into FAC2
LAB_MULTIPLY
	BEQ	LAB_264C		; exit if zero

	JSR	LAB_2673		; test and adjust accumulators
	LDA	#$00			; clear A
	STA	FACt_1		; clear temp mantissa1
	STA	FACt_2		; clear temp mantissa2
	STA	FACt_3		; clear temp mantissa3
	LDA	FAC1_r		; get FAC1 rounding byte
	JSR	LAB_2622		; go do shift/add FAC2
	LDA	FAC1_3		; get FAC1 mantissa3
	JSR	LAB_2622		; go do shift/add FAC2
	LDA	FAC1_2		; get FAC1 mantissa2
	JSR	LAB_2622		; go do shift/add FAC2
	LDA	FAC1_1		; get FAC1 mantissa1
	JSR	LAB_2627		; go do shift/add FAC2
	JMP	LAB_273C		; copy temp to FAC1, normalise and return

LAB_2622
	BNE	LAB_2627		; branch if byte <> zero

	JMP	LAB_2569		; shift FCAtemp << A+8 times

					; else do shift and add
LAB_2627
	LSR				; shift byte
	ORA	#$80			; set top bit (mark for 8 times)
LAB_262A
	TAY				; copy result
	BCC	LAB_2640		; skip next if bit was zero

	CLC				; clear carry for add
	LDA	FACt_3		; get temp mantissa3
	ADC	FAC2_3		; add FAC2 mantissa3
	STA	FACt_3		; save temp mantissa3
	LDA	FACt_2		; get temp mantissa2
	ADC	FAC2_2		; add FAC2 mantissa2
	STA	FACt_2		; save temp mantissa2
	LDA	FACt_1		; get temp mantissa1
	ADC	FAC2_1		; add FAC2 mantissa1
	STA	FACt_1		; save temp mantissa1
LAB_2640
	ROR	FACt_1		; shift temp mantissa1
	ROR	FACt_2		; shift temp mantissa2
	ROR	FACt_3		; shift temp mantissa3
	ROR	FAC1_r		; shift temp rounding byte
	TYA				; get byte back
	LSR				; shift byte
	BNE	LAB_262A		; loop if all bits not done

LAB_264C
	RTS

; unpack memory (AY) into FAC2

LAB_264D
	STA	ut1_pl		; save pointer low byte
	STY	ut1_ph		; save pointer high byte
	LDY	#$03			; 4 bytes to get (0-3)
	LDA	(ut1_pl),Y		; get mantissa3
	STA	FAC2_3		; save FAC2 mantissa3
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get mantissa2
	STA	FAC2_2		; save FAC2 mantissa2
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get mantissa1+sign
	STA	FAC2_s		; save FAC2 sign (b7)
	EOR	FAC1_s		; EOR with FAC1 sign (b7)
	STA	FAC_sc		; save sign compare (FAC1 EOR FAC2)
	LDA	FAC2_s		; recover FAC2 sign (b7)
	ORA	#$80			; set 1xxx xxx (set normal bit)
	STA	FAC2_1		; save FAC2 mantissa1
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get exponent byte
	STA	FAC2_e		; save FAC2 exponent
	LDA	FAC1_e		; get FAC1 exponent
	RTS

; test and adjust accumulators

LAB_2673
	LDA	FAC2_e		; get FAC2 exponent
LAB_2675
	BEQ	LAB_2696		; branch if FAC2 = $00 (handle underflow)

	CLC				; clear carry for add
	ADC	FAC1_e		; add FAC1 exponent
	BCC	LAB_2680		; branch if sum of exponents <$0100

	BMI	LAB_269B		; do overflow error

	CLC				; clear carry for the add
	.byte	$2C			; makes next line BIT $1410
LAB_2680
	BPL	LAB_2696		; if +ve go handle underflow

	ADC	#$80			; adjust exponent
	STA	FAC1_e		; save FAC1 exponent
	BNE	LAB_268B		; branch if not zero

	JMP	LAB_24F5		; save FAC1 sign and return

LAB_268B
	LDA	FAC_sc		; get sign compare (FAC1 EOR FAC2)
	STA	FAC1_s		; save FAC1 sign (b7)
LAB_268F
	RTS

; handle overflow and underflow

LAB_2690
	LDA	FAC1_s		; get FAC1 sign (b7)
	BPL	LAB_269B		; do overflow error

					; handle underflow
LAB_2696
	PLA				; pop return address low byte
	PLA				; pop return address high byte
	JMP	LAB_24F1		; clear FAC1 exponent and sign and return

; multiply by 10

LAB_269E
	JSR	LAB_27AB		; round and copy FAC1 to FAC2
	TAX				; copy exponent (set the flags)
	BEQ	LAB_268F		; exit if zero

	CLC				; clear carry for add
	ADC	#$02			; add two to exponent (*4)
	BCS	LAB_269B		; do overflow error if > $FF

	LDX	#$00			; clear byte
	STX	FAC_sc		; clear sign compare (FAC1 EOR FAC2)
	JSR	LAB_247C		; add FAC2 to FAC1 (*5)
	INC	FAC1_e		; increment FAC1 exponent (*10)
	BNE	LAB_268F		; if non zero just do RTS

LAB_269B
	JMP	LAB_2564		; do overflow error and warm start

; divide by 10

LAB_26B9
	JSR	LAB_27AB		; round and copy FAC1 to FAC2
	LDA	#<LAB_26B5		; set pointer to 10d low addr
	LDY	#>LAB_26B5		; set pointer to 10d high addr
	LDX	#$00			; clear sign

; divide by (AY) (X=sign)

LAB_26C2
	STX	FAC_sc		; save sign compare (FAC1 EOR FAC2)
	JSR	LAB_UFAC		; unpack memory (AY) into FAC1
	JMP	LAB_DIVIDE		; do FAC2/FAC1

					; Perform divide-by
; convert AY and do (AY)/FAC1

LAB_26CA
	JSR	LAB_264D		; unpack memory (AY) into FAC2

					; Perform divide-into
LAB_DIVIDE
	BEQ	LAB_2737		; if zero go do /0 error

	JSR	LAB_27BA		; round FAC1
	LDA	#$00			; clear A
	SEC				; set carry for subtract
	SBC	FAC1_e		; subtract FAC1 exponent (2s complement)
	STA	FAC1_e		; save FAC1 exponent
	JSR	LAB_2673		; test and adjust accumulators
	INC	FAC1_e		; increment FAC1 exponent
	BEQ	LAB_269B		; if zero do overflow error

	LDX	#$FF			; set index for pre increment
	LDA	#$01			; set bit to flag byte save
LAB_26E4
	LDY	FAC2_1		; get FAC2 mantissa1
	CPY	FAC1_1		; compare FAC1 mantissa1
	BNE	LAB_26F4		; branch if <>

	LDY	FAC2_2		; get FAC2 mantissa2
	CPY	FAC1_2		; compare FAC1 mantissa2
	BNE	LAB_26F4		; branch if <>

	LDY	FAC2_3		; get FAC2 mantissa3
	CPY	FAC1_3		; compare FAC1 mantissa3
LAB_26F4
	PHP				; save FAC2-FAC1 compare status
	ROL				; shift the result byte
	BCC	LAB_2702		; if no carry skip the byte save

	LDY	#$01			; set bit to flag byte save
	INX				; else increment the index to FACt
	CPX	#$02			; compare with the index to FACt_3
	BMI	LAB_2701		; if not last byte just go save it

	BNE	LAB_272B		; if all done go save FAC1 rounding byte, normalise and
					; return

	LDY	#$40			; set bit to flag byte save for the rounding byte
LAB_2701
	STA	FACt_1,X		; write result byte to FACt_1 + index
	TYA				; copy the next save byte flag
LAB_2702
	PLP				; restore FAC2-FAC1 compare status
	BCC	LAB_2704		; if FAC2 < FAC1 then skip the subtract

	TAY				; save FAC2-FAC1 compare status
	LDA	FAC2_3		; get FAC2 mantissa3
	SBC	FAC1_3		; subtract FAC1 mantissa3
	STA	FAC2_3		; save FAC2 mantissa3
	LDA	FAC2_2		; get FAC2 mantissa2
	SBC	FAC1_2		; subtract FAC1 mantissa2
	STA	FAC2_2		; save FAC2 mantissa2
	LDA	FAC2_1		; get FAC2 mantissa1
	SBC	FAC1_1		; subtract FAC1 mantissa1
	STA	FAC2_1		; save FAC2 mantissa1
	TYA				; restore FAC2-FAC1 compare status

					; FAC2 = FAC2*2
LAB_2704
	ASL	FAC2_3		; shift FAC2 mantissa3
	ROL	FAC2_2		; shift FAC2 mantissa2
	ROL	FAC2_1		; shift FAC2 mantissa1
	BCS	LAB_26F4		; loop with no compare

	BMI	LAB_26E4		; loop with compare

	BPL	LAB_26F4		; loop always with no compare

; do A<<6, save as FAC1 rounding byte, normalise and return

LAB_272B
	LSR				; shift b1 - b0 ..
	ROR				; ..
	ROR				; .. to b7 - b6
	STA	FAC1_r		; save FAC1 rounding byte
	PLP				; dump FAC2-FAC1 compare status
	JMP	LAB_273C		; copy temp to FAC1, normalise and return

; do "Divide by zero" error

LAB_2737
	LDX	#$14			; error code $14 ("Divide by zero" error)
	JMP	LAB_XERR		; do error #X, then warm start

; copy temp to FAC1 and normalise

LAB_273C
	LDA	FACt_1		; get temp mantissa1
	STA	FAC1_1		; save FAC1 mantissa1
	LDA	FACt_2		; get temp mantissa2
	STA	FAC1_2		; save FAC1 mantissa2
	LDA	FACt_3		; get temp mantissa3
	STA	FAC1_3		; save FAC1 mantissa3
	JMP	LAB_24D5		; normalise FAC1 and return

; unpack memory (AY) into FAC1

LAB_UFAC
	STA	ut1_pl		; save pointer low byte
	STY	ut1_ph		; save pointer high byte
	LDY	#$03			; 4 bytes to do
	LDA	(ut1_pl),Y		; get last byte
	STA	FAC1_3		; save FAC1 mantissa3
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get last-1 byte
	STA	FAC1_2		; save FAC1 mantissa2
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get second byte
	STA	FAC1_s		; save FAC1 sign (b7)
	ORA	#$80			; set 1xxx xxxx (add normal bit)
	STA	FAC1_1		; save FAC1 mantissa1
	DEY				; decrement index
	LDA	(ut1_pl),Y		; get first byte (exponent)
	STA	FAC1_e		; save FAC1 exponent
	STY	FAC1_r		; clear FAC1 rounding byte
	RTS

; pack FAC1 into Adatal

LAB_276E
	LDX	#<Adatal		; set pointer low byte
LAB_2770
	LDY	#>Adatal		; set pointer high byte
	BEQ	LAB_2778		; pack FAC1 into (XY) and return

; pack FAC1 into (Lvarpl)

LAB_PFAC
	LDX	Lvarpl		; get destination pointer low byte
	LDY	Lvarph		; get destination pointer high byte

; pack FAC1 into (XY)

LAB_2778
	JSR	LAB_27BA		; round FAC1
	STX	ut1_pl		; save pointer low byte
	STY	ut1_ph		; save pointer high byte
	LDY	#$03			; set index
	LDA	FAC1_3		; get FAC1 mantissa3
	STA	(ut1_pl),Y		; store in destination
	DEY				; decrement index
	LDA	FAC1_2		; get FAC1 mantissa2
	STA	(ut1_pl),Y		; store in destination
	DEY				; decrement index
	LDA	FAC1_s		; get FAC1 sign (b7)
	ORA	#$7F			; set bits x111 1111
	AND	FAC1_1		; AND in FAC1 mantissa1
	STA	(ut1_pl),Y		; store in destination
	DEY				; decrement index
	LDA	FAC1_e		; get FAC1 exponent
	STA	(ut1_pl),Y		; store in destination
	STY	FAC1_r		; clear FAC1 rounding byte
	RTS

; round and copy FAC1 to FAC2

LAB_27AB
	JSR	LAB_27BA		; round FAC1

; copy FAC1 to FAC2

LAB_27AE
	LDX	#$05			; 5 bytes to copy
LAB_27B0
	LDA	FAC1_e-1,X		; get byte from FAC1,X
	STA	FAC1_o,X		; save byte at FAC2,X
	DEX				; decrement count
	BNE	LAB_27B0		; loop if not all done

	STX	FAC1_r		; clear FAC1 rounding byte
LAB_27B9
	RTS

; round FAC1

LAB_27BA
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_27B9		; exit if zero

	ASL	FAC1_r		; shift FAC1 rounding byte
	BCC	LAB_27B9		; exit if no overflow

; round FAC1 (no check)

LAB_27C2
	JSR	LAB_2559		; increment FAC1 mantissa
	BNE	LAB_27B9		; branch if no overflow

	JMP	LAB_252A		; normalise FAC1 for C=1 and return

; get FAC1 sign
; return A=FF,C=1/-ve A=01,C=0/+ve

LAB_27CA
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_27D7		; exit if zero (already correct SGN(0)=0)

; return A=FF,C=1/-ve A=01,C=0/+ve
; no = 0 check

LAB_27CE
	LDA	FAC1_s		; else get FAC1 sign (b7)

; return A=FF,C=1/-ve A=01,C=0/+ve
; no = 0 check, sign in A

LAB_27D0
	ROL				; move sign bit to carry
	LDA	#$FF			; set byte for -ve result
	BCS	LAB_27D7		; return if sign was set (-ve)

	LDA	#$01			; else set byte for +ve result
LAB_27D7
	RTS

; perform SGN()

LAB_SGN
	JSR	LAB_27CA		; get FAC1 sign
					; return A=$FF/-ve A=$01/+ve
; save A as integer byte

LAB_27DB
	STA	FAC1_1		; save FAC1 mantissa1
	LDA	#$00			; clear A
	STA	FAC1_2		; clear FAC1 mantissa2
	LDX	#$88			; set exponent

; set exp=X, clearFAC1 mantissa3 and normalise

LAB_27E3
	LDA	FAC1_1		; get FAC1 mantissa1
	EOR	#$FF			; complement it
	ROL				; sign bit into carry

; set exp=X, clearFAC1 mantissa3 and normalise

LAB_STFA
	LDA	#$00			; clear A
	STA	FAC1_3		; clear FAC1 mantissa3
	STX	FAC1_e		; set FAC1 exponent
	STA	FAC1_r		; clear FAC1 rounding byte
	STA	FAC1_s		; clear FAC1 sign (b7)
	JMP	LAB_24D0		; do ABS and normalise FAC1

; perform ABS()

LAB_ABS
	LSR	FAC1_s		; clear FAC1 sign (put zero in b7)
	RTS

; compare FAC1 with (AY)
; returns A=$00 if FAC1 = (AY)
; returns A=$01 if FAC1 > (AY)
; returns A=$FF if FAC1 < (AY)

LAB_27F8
	STA	ut2_pl		; save pointer low byte
LAB_27FA
	STY	ut2_ph		; save pointer high byte
	LDY	#$00			; clear index
	LDA	(ut2_pl),Y		; get exponent
	INY				; increment index
	TAX				; copy (AY) exponent to X
	BEQ	LAB_27CA		; branch if (AY) exponent=0 and get FAC1 sign
					; A=FF,C=1/-ve A=01,C=0/+ve

	LDA	(ut2_pl),Y		; get (AY) mantissa1 (with sign)
	EOR	FAC1_s		; EOR FAC1 sign (b7)
	BMI	LAB_27CE		; if signs <> do return A=FF,C=1/-ve
					; A=01,C=0/+ve and return

	CPX	FAC1_e		; compare (AY) exponent with FAC1 exponent
	BNE	LAB_2828		; branch if different

	LDA	(ut2_pl),Y		; get (AY) mantissa1 (with sign)
	ORA	#$80			; normalise top bit
	CMP	FAC1_1		; compare with FAC1 mantissa1
	BNE	LAB_2828		; branch if different

	INY				; increment index
	LDA	(ut2_pl),Y		; get mantissa2
	CMP	FAC1_2		; compare with FAC1 mantissa2
	BNE	LAB_2828		; branch if different

	INY				; increment index
	LDA	#$7F			; set for 1/2 value rounding byte
	CMP	FAC1_r		; compare with FAC1 rounding byte (set carry)
	LDA	(ut2_pl),Y		; get mantissa3
	SBC	FAC1_3		; subtract FAC1 mantissa3
	BEQ	LAB_2850		; exit if mantissa3 equal

; gets here if number <> FAC1

LAB_2828
	LDA	FAC1_s		; get FAC1 sign (b7)
	BCC	LAB_282E		; branch if FAC1 > (AY)

	EOR	#$FF			; else toggle FAC1 sign
LAB_282E
	JMP	LAB_27D0		; return A=FF,C=1/-ve A=01,C=0/+ve

; convert FAC1 floating-to-fixed

LAB_2831
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_287F		; if zero go clear FAC1 and return

	SEC				; set carry for subtract
	SBC	#$98			; subtract maximum integer range exponent
	BIT	FAC1_s		; test FAC1 sign (b7)
	BPL	LAB_2845		; branch if FAC1 +ve

					; FAC1 was -ve
	TAX				; copy subtracted exponent
	LDA	#$FF			; overflow for -ve number
	STA	FAC1_o		; set FAC1 overflow byte
	JSR	LAB_253D		; twos complement FAC1 mantissa
	TXA				; restore subtracted exponent
LAB_2845
	LDX	#FAC1_e		; set index to FAC1
	CMP	#$F9			; compare exponent result
	BPL	LAB_2851		; if < 8 shifts shift FAC1 A times right and return

	JSR	LAB_257B		; shift FAC1 A times right (> 8 shifts)
	STY	FAC1_o		; clear FAC1 overflow byte
LAB_2850
	RTS

; shift FAC1 A times right

LAB_2851
	TAY				; copy shift count
	LDA	FAC1_s		; get FAC1 sign (b7)
	AND	#$80			; mask sign bit only (x000 0000)
	LSR	FAC1_1		; shift FAC1 mantissa1
	ORA	FAC1_1		; OR sign in b7 FAC1 mantissa1
	STA	FAC1_1		; save FAC1 mantissa1
	JSR	LAB_2592		; shift FAC1 Y times right
	STY	FAC1_o		; clear FAC1 overflow byte
	RTS

; perform INT()

LAB_INT
	LDA	FAC1_e		; get FAC1 exponent
	CMP	#$98			; compare with max int
	BCS	LAB_2886		; exit if >= (already int, too big for fractional part!)

	JSR	LAB_2831		; convert FAC1 floating-to-fixed
	STY	FAC1_r		; save FAC1 rounding byte
	LDA	FAC1_s		; get FAC1 sign (b7)
	STY	FAC1_s		; save FAC1 sign (b7)
	EOR	#$80			; toggle FAC1 sign
	ROL				; shift into carry
	LDA	#$98			; set new exponent
	STA	FAC1_e		; save FAC1 exponent
	LDA	FAC1_3		; get FAC1 mantissa3
	STA	Temp3			; save for EXP() function
	JMP	LAB_24D0		; do ABS and normalise FAC1

; clear FAC1 and return

LAB_287F
	STA	FAC1_1		; clear FAC1 mantissa1
	STA	FAC1_2		; clear FAC1 mantissa2
	STA	FAC1_3		; clear FAC1 mantissa3
	TAY				; clear Y
LAB_2886
	RTS

; get FAC1 from string
; this routine now handles hex and binary values from strings
; starting with "$" and "%" respectively

LAB_2887
	LDY	#$00			; clear Y
	STY	Dtypef		; clear data type flag, $FF=string, $00=numeric
	LDX	#$09			; set index
LAB_288B
	STY	numexp,X		; clear byte
	DEX				; decrement index
	BPL	LAB_288B		; loop until numexp to negnum (and FAC1) = $00

	BCC	LAB_28FE		; branch if 1st character numeric

; get FAC1 from string .. first character wasn't numeric

	CMP	#'-'			; else compare with "-"
	BNE	LAB_289A		; branch if not "-"

	STX	negnum		; set flag for -ve number (X = $FF)
	BEQ	LAB_289C		; branch always (go scan and check for hex/bin)

; get FAC1 from string .. first character wasn't numeric or -

LAB_289A
	CMP	#'+'			; else compare with "+"
	BNE	LAB_289D		; branch if not "+" (go check for hex/bin)

; was "+" or "-" to start, so get next character

LAB_289C
	JSR	LAB_IGBY		; increment and scan memory
	BCC	LAB_28FE		; branch if numeric character

; code here for hex and binary numbers

LAB_289D
	CMP	#'$'			; else compare with "$"
	BNE	LAB_NHEX		; branch if not "$"

	JMP	LAB_CHEX		; branch if "$"

LAB_NHEX
	CMP	#'%'			; else compare with "%"
	BNE	LAB_28A3		; branch if not "%" (continue original code)

	JMP	LAB_CBIN		; branch if "%"

LAB_289E
	JSR	LAB_IGBY		; increment and scan memory (ignore + or get next number)
LAB_28A1
	BCC	LAB_28FE		; branch if numeric character

; get FAC1 from string .. character wasn't numeric, -, +, hex or binary

LAB_28A3
	CMP	#'.'			; else compare with "."
	BEQ	LAB_28D5		; branch if "."

; get FAC1 from string .. character wasn't numeric, -, + or .

	CMP	#'E'			; else compare with "E"
	BNE	LAB_28DB		; branch if not "E"

					; was "E" so evaluate exponential part
	JSR	LAB_IGBY		; increment and scan memory
	BCC	LAB_28C7		; branch if numeric character

	CMP	#TK_MINUS		; else compare with token for -
	BEQ	LAB_28C2		; branch if token for -

	CMP	#'-'			; else compare with "-"
	BEQ	LAB_28C2		; branch if "-"

	CMP	#TK_PLUS		; else compare with token for +
	BEQ	LAB_28C4		; branch if token for +

	CMP	#'+'			; else compare with "+"
	BEQ	LAB_28C4		; branch if "+"

	BNE	LAB_28C9		; branch always

LAB_28C2
	ROR	expneg		; set exponent -ve flag (C, which=1, into b7)
LAB_28C4
	JSR	LAB_IGBY		; increment and scan memory
LAB_28C7
	BCC	LAB_2925		; branch if numeric character

LAB_28C9
	BIT	expneg		; test exponent -ve flag
	BPL	LAB_28DB		; if +ve go evaluate exponent

					; else do exponent = -exponent 
	LDA	#$00			; clear result
	SEC				; set carry for subtract
	SBC	expcnt		; subtract exponent byte
	JMP	LAB_28DD		; go evaluate exponent

LAB_28D5
	ROR	numdpf		; set decimal point flag
	BIT	numdpf		; test decimal point flag
	BVC	LAB_289E		; branch if only one decimal point so far

					; evaluate exponent
LAB_28DB
	LDA	expcnt		; get exponent count byte
LAB_28DD
	SEC				; set carry for subtract
	SBC	numexp		; subtract numerator exponent
	STA	expcnt		; save exponent count byte
	BEQ	LAB_28F6		; branch if no adjustment

	BPL	LAB_28EF		; else if +ve go do FAC1*10^expcnt

					; else go do FAC1/10^(0-expcnt)
LAB_28E6
	JSR	LAB_26B9		; divide by 10
	INC	expcnt		; increment exponent count byte
	BNE	LAB_28E6		; loop until all done

	BEQ	LAB_28F6		; branch always

LAB_28EF
	JSR	LAB_269E		; multiply by 10
	DEC	expcnt		; decrement exponent count byte
	BNE	LAB_28EF		; loop until all done

LAB_28F6
	LDA	negnum		; get -ve flag
	BMI	LAB_28FB		; if -ve do - FAC1 and return

	RTS

; do - FAC1 and return

LAB_28FB
	JMP	LAB_GTHAN		; do - FAC1 and return

; do unsigned FAC1*10+number

LAB_28FE
	PHA				; save character
	BIT	numdpf		; test decimal point flag
	BPL	LAB_2905		; skip exponent increment if not set

	INC	numexp		; else increment number exponent
LAB_2905
	JSR	LAB_269E		; multiply FAC1 by 10
	PLA				; restore character
	AND	#$0F			; convert to binary
	JSR	LAB_2912		; evaluate new ASCII digit
	JMP	LAB_289E		; go do next character

; evaluate new ASCII digit

LAB_2912
	PHA				; save digit
	JSR	LAB_27AB		; round and copy FAC1 to FAC2
	PLA				; restore digit
	JSR	LAB_27DB		; save A as integer byte
	LDA	FAC2_s		; get FAC2 sign (b7)
	EOR	FAC1_s		; toggle with FAC1 sign (b7)
	STA	FAC_sc		; save sign compare (FAC1 EOR FAC2)
	LDX	FAC1_e		; get FAC1 exponent
	JMP	LAB_ADD		; add FAC2 to FAC1 and return

; evaluate next character of exponential part of number

LAB_2925
	LDA	expcnt		; get exponent count byte
	CMP	#$0A			; compare with 10 decimal
	BCC	LAB_2934		; branch if less

	LDA	#$64			; make all -ve exponents = -100 decimal (causes underflow)
	BIT	expneg		; test exponent -ve flag
	BMI	LAB_2942		; branch if -ve

	JMP	LAB_2564		; else do overflow error

LAB_2934
	ASL				; * 2
	ASL				; * 4
	ADC	expcnt		; * 5
	ASL				; * 10
	LDY	#$00			; set index
	ADC	(Bpntrl),Y		; add character (will be $30 too much!)
	SBC	#'0'-1		; convert character to binary
LAB_2942
	STA	expcnt		; save exponent count byte
	JMP	LAB_28C4		; go get next character

; print " in line [LINE #]"

LAB_2953
	LDA	#<LAB_LMSG		; point to " in line " message low byte
	LDY	#>LAB_LMSG		; point to " in line " message high byte
	JSR	LAB_18C3		; print null terminated string from memory

					; print Basic line #
	LDA	Clineh		; get current line high byte
	LDX	Clinel		; get current line low byte

; print XA as unsigned integer

LAB_295E
	STA	FAC1_1		; save low byte as FAC1 mantissa1
	STX	FAC1_2		; save high byte as FAC1 mantissa2
	LDX	#$90			; set exponent to 16d bits
	SEC				; set integer is +ve flag
	JSR	LAB_STFA		; set exp=X, clearFAC1 mantissa3 and normalise
	LDY	#$00			; clear index
	TYA				; clear A
	JSR	LAB_297B		; convert FAC1 to string, skip sign character save
	JMP	LAB_18C3		; print null terminated string from memory and return

; convert FAC1 to ASCII string result in (AY)
; not any more, moved scratchpad to page 0

LAB_296E
	LDY	#$01			; set index = 1
	LDA	#$20			; character = " " (assume +ve)
	BIT	FAC1_s		; test FAC1 sign (b7)
	BPL	LAB_2978		; branch if +ve

	LDA	#$2D			; else character = "-"
LAB_2978
	STA	Decss,Y		; save leading character (" " or "-")
LAB_297B
	STA	FAC1_s		; clear FAC1 sign (b7)
	STY	Sendl			; save index
	INY				; increment index
	LDX	FAC1_e		; get FAC1 exponent
	BNE	LAB_2989		; branch if FAC1<>0

					; exponent was $00 so FAC1 is 0
	LDA	#'0'			; set character = "0"
	JMP	LAB_2A89		; save last character, [EOT] and exit

					; FAC1 is some non zero value
LAB_2989
	LDA	#$00			; clear (number exponent count)
	CPX	#$81			; compare FAC1 exponent with $81 (>1.00000)

	BCS	LAB_299A		; branch if FAC1=>1

					; FAC1<1
	LDA	#<LAB_294F		; set pointer low byte to 1,000,000
	LDY	#>LAB_294F		; set pointer high byte to 1,000,000
	JSR	LAB_25FB		; do convert AY, FCA1*(AY)
	LDA	#$FA			; set number exponent count (-6)
LAB_299A
	STA	numexp		; save number exponent count
LAB_299C
	LDA	#<LAB_294B		; set pointer low byte to 999999.4375 (max before sci note)
	LDY	#>LAB_294B		; set pointer high byte to 999999.4375
	JSR	LAB_27F8		; compare FAC1 with (AY)
	BEQ	LAB_29C3		; exit if FAC1 = (AY)

	BPL	LAB_29B9		; go do /10 if FAC1 > (AY)

					; FAC1 < (AY)
LAB_29A7
	LDA	#<LAB_2947		; set pointer low byte to 99999.9375
	LDY	#>LAB_2947		; set pointer high byte to 99999.9375
	JSR	LAB_27F8		; compare FAC1 with (AY)
	BEQ	LAB_29B2		; branch if FAC1 = (AY) (allow decimal places)

	BPL	LAB_29C0		; branch if FAC1 > (AY) (no decimal places)

					; FAC1 <= (AY)
LAB_29B2
	JSR	LAB_269E		; multiply by 10
	DEC	numexp		; decrement number exponent count
	BNE	LAB_29A7		; go test again (branch always)

LAB_29B9
	JSR	LAB_26B9		; divide by 10
	INC	numexp		; increment number exponent count
	BNE	LAB_299C		; go test again (branch always)

; now we have just the digits to do

LAB_29C0
	JSR	LAB_244E		; add 0.5 to FAC1 (round FAC1)
LAB_29C3
	JSR	LAB_2831		; convert FAC1 floating-to-fixed
	LDX	#$01			; set default digits before dp = 1
	LDA	numexp		; get number exponent count
	CLC				; clear carry for add
	ADC	#$07			; up to 6 digits before point
	BMI	LAB_29D8		; if -ve then 1 digit before dp

	CMP	#$08			; A>=8 if n>=1E6
	BCS	LAB_29D9		; branch if >= $08

					; carry is clear
	ADC	#$FF			; take 1 from digit count
	TAX				; copy to A
	LDA	#$02			;.set exponent adjust
LAB_29D8
	SEC				; set carry for subtract
LAB_29D9
	SBC	#$02			; -2
	STA	expcnt		;.save exponent adjust
	STX	numexp		; save digits before dp count
	TXA				; copy to A
	BEQ	LAB_29E4		; branch if no digits before dp

	BPL	LAB_29F7		; branch if digits before dp

LAB_29E4
	LDY	Sendl			; get output string index
	LDA	#$2E			; character "."
	INY				; increment index
	STA	Decss,Y		; save to output string
	TXA				;.
	BEQ	LAB_29F5		;.

	LDA	#'0'			; character "0"
	INY				; increment index
	STA	Decss,Y		; save to output string
LAB_29F5
	STY	Sendl			; save output string index
LAB_29F7
	LDY	#$00			; clear index (point to 100,000)
	LDX	#$80			; 
LAB_29FB
	LDA	FAC1_3		; get FAC1 mantissa3
	CLC				; clear carry for add
	ADC	LAB_2A9C,Y		; add -ve LSB
	STA	FAC1_3		; save FAC1 mantissa3
	LDA	FAC1_2		; get FAC1 mantissa2
	ADC	LAB_2A9B,Y		; add -ve NMSB
	STA	FAC1_2		; save FAC1 mantissa2
	LDA	FAC1_1		; get FAC1 mantissa1
	ADC	LAB_2A9A,Y		; add -ve MSB
	STA	FAC1_1		; save FAC1 mantissa1
	INX				; 
	BCS	LAB_2A18		; 

	BPL	LAB_29FB		; not -ve so try again

	BMI	LAB_2A1A		; 

LAB_2A18
	BMI	LAB_29FB		; 

LAB_2A1A
	TXA				; 
	BCC	LAB_2A21		; 

	EOR	#$FF			; 
	ADC	#$0A			; 
LAB_2A21
	ADC	#'0'-1		; add "0"-1 to result
	INY				; increment index ..
	INY				; .. to next less ..
	INY				; .. power of ten
	STY	Cvaral		; save as current var address low byte
	LDY	Sendl			; get output string index
	INY				; increment output string index
	TAX				; copy character to X
	AND	#$7F			; mask out top bit
	STA	Decss,Y		; save to output string
	DEC	numexp		; decrement # of characters before the dp
	BNE	LAB_2A3B		; branch if still characters to do

					; else output the point
	LDA	#$2E			; character "."
	INY				; increment output string index
	STA	Decss,Y		; save to output string
LAB_2A3B
	STY	Sendl			; save output string index
	LDY	Cvaral		; get current var address low byte
	TXA				; get character back
	EOR	#$FF			; 
	AND	#$80			; 
	TAX				; 
	CPY	#$12			; compare index with max
	BNE	LAB_29FB		; loop if not max

					; now remove trailing zeroes
	LDY	Sendl			; get output string index
LAB_2A4B
	LDA	Decss,Y		; get character from output string
	DEY				; decrement output string index
	CMP	#'0'			; compare with "0"
	BEQ	LAB_2A4B		; loop until non "0" character found

	CMP	#'.'			; compare with "."
	BEQ	LAB_2A58		; branch if was dp

					; restore last character
	INY				; increment output string index
LAB_2A58
	LDA	#$2B			; character "+"
	LDX	expcnt		; get exponent count
	BEQ	LAB_2A8C		; if zero go set null terminator and exit

					; exponent isn't zero so write exponent
	BPL	LAB_2A68		; branch if exponent count +ve

	LDA	#$00			; clear A
	SEC				; set carry for subtract
	SBC	expcnt		; subtract exponent count adjust (convert -ve to +ve)
	TAX				; copy exponent count to X
	LDA	#'-'			; character "-"
LAB_2A68
	STA	Decss+2,Y		; save to output string
	LDA	#$45			; character "E"
	STA	Decss+1,Y		; save exponent sign to output string
	TXA				; get exponent count back
	LDX	#'0'-1		; one less than "0" character
	SEC				; set carry for subtract
LAB_2A74
	INX				; increment 10's character
	SBC	#$0A			;.subtract 10 from exponent count
	BCS	LAB_2A74		; loop while still >= 0

	ADC	#':'			; add character ":" ($30+$0A, result is 10 less that value)
	STA	Decss+4,Y		; save to output string
	TXA				; copy 10's character
	STA	Decss+3,Y		; save to output string
	LDA	#$00			; set null terminator
	STA	Decss+5,Y		; save to output string
	BEQ	LAB_2A91		; go set string pointer (AY) and exit (branch always)

					; save last character, [EOT] and exit
LAB_2A89
	STA	Decss,Y		; save last character to output string

					; set null terminator and exit
LAB_2A8C
	LDA	#$00			; set null terminator
	STA	Decss+1,Y		; save after last character

					; set string pointer (AY) and exit
LAB_2A91
	LDA	#<Decssp1		; set result string low pointer
	LDY	#>Decssp1		; set result string high pointer
	RTS

; perform power function

LAB_POWER
	BEQ	LAB_EXP		; go do  EXP()

	LDA	FAC2_e		; get FAC2 exponent
	BNE	LAB_2ABF		; branch if FAC2<>0

	JMP	LAB_24F3		; clear FAC1 exponent and sign and return

LAB_2ABF
	LDX	#<func_l		; set destination pointer low byte
	LDY	#>func_l		; set destination pointer high byte
	JSR	LAB_2778		; pack FAC1 into (XY)
	LDA	FAC2_s		; get FAC2 sign (b7)
	BPL	LAB_2AD9		; branch if FAC2>0

					; else FAC2 is -ve and can only be raised to an
					; integer power which gives an x +j0 result
	JSR	LAB_INT		; perform INT
	LDA	#<func_l		; set source pointer low byte
	LDY	#>func_l		; set source pointer high byte
	JSR	LAB_27F8		; compare FAC1 with (AY)
	BNE	LAB_2AD9		; branch if FAC1 <> (AY) to allow Function Call error
					; this will leave FAC1 -ve and cause a Function Call
					; error when LOG() is called

	TYA				; clear sign b7
	LDY	Temp3			; save mantissa 3 from INT() function as sign in Y
					; for possible later negation, b0
LAB_2AD9
	JSR	LAB_279D		; save FAC1 sign and copy ABS(FAC2) to FAC1
	TYA				; copy sign back ..
	PHA				; .. and save it
	JSR	LAB_LOG		; do LOG(n)
	LDA	#<garb_l		; set pointer low byte
	LDY	#>garb_l		; set pointer high byte
	JSR	LAB_25FB		; do convert AY, FCA1*(AY) (square the value)
	JSR	LAB_EXP		; go do EXP(n)
	PLA				; pull sign from stack
	LSR				; b0 is to be tested, shift to Cb
	BCC	LAB_2AF9		; if no bit then exit

					; Perform negation
; do - FAC1

LAB_GTHAN
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_2AF9		; exit if FAC1_e = $00

	LDA	FAC1_s		; get FAC1 sign (b7)
	EOR	#$FF			; complement it
	STA	FAC1_s		; save FAC1 sign (b7)
LAB_2AF9
	RTS

; perform EXP()	(x^e)

LAB_EXP
	LDA	#<LAB_2AFA		; set 1.443 pointer low byte
	LDY	#>LAB_2AFA		; set 1.443 pointer high byte
	JSR	LAB_25FB		; do convert AY, FCA1*(AY)
	LDA	FAC1_r		; get FAC1 rounding byte
	ADC	#$50			; +$50/$100
	BCC	LAB_2B2B		; skip rounding if no carry

	JSR	LAB_27C2		; round FAC1 (no check)
LAB_2B2B
	STA	FAC2_r		; save FAC2 rounding byte
	JSR	LAB_27AE		; copy FAC1 to FAC2
	LDA	FAC1_e		; get FAC1 exponent
	CMP	#$88			; compare with EXP limit (256d)
	BCC	LAB_2B39		; branch if less

LAB_2B36
	JSR	LAB_2690		; handle overflow and underflow
LAB_2B39
	JSR	LAB_INT		; perform INT
	LDA	Temp3			; get mantissa 3 from INT() function
	CLC				; clear carry for add
	ADC	#$81			; normalise +1
	BEQ	LAB_2B36		; if $00 go handle overflow

	SEC				; set carry for subtract
	SBC	#$01			; now correct for exponent
	PHA				; save FAC2 exponent

					; swap FAC1 and FAC2
	LDX	#$04			; 4 bytes to do
LAB_2B49
	LDA	FAC2_e,X		; get FAC2,X
	LDY	FAC1_e,X		; get FAC1,X
	STA	FAC1_e,X		; save FAC1,X
	STY	FAC2_e,X		; save FAC2,X
	DEX				; decrement count/index
	BPL	LAB_2B49		; loop if not all done

	LDA	FAC2_r		; get FAC2 rounding byte
	STA	FAC1_r		; save as FAC1 rounding byte
	JSR	LAB_SUBTRACT	; perform subtraction, FAC2 from FAC1
	JSR	LAB_GTHAN		; do - FAC1
	LDA	#<LAB_2AFE		; set counter pointer low byte
	LDY	#>LAB_2AFE		; set counter pointer high byte
	JSR	LAB_2B84		; go do series evaluation
	LDA	#$00			; clear A
	STA	FAC_sc		; clear sign compare (FAC1 EOR FAC2)
	PLA				;.get saved FAC2 exponent
	JMP	LAB_2675		; test and adjust accumulators and return

; ^2 then series evaluation

LAB_2B6E
	STA	Cptrl			; save count pointer low byte
	STY	Cptrh			; save count pointer high byte
	JSR	LAB_276E		; pack FAC1 into Adatal
	LDA	#<Adatal		; set pointer low byte (Y already $00)
	JSR	LAB_25FB		; do convert AY, FCA1*(AY)
	JSR	LAB_2B88		; go do series evaluation
	LDA	#<Adatal		; pointer to original # low byte
	LDY	#>Adatal		; pointer to original # high byte
	JMP	LAB_25FB		; do convert AY, FCA1*(AY) and return

; series evaluation

LAB_2B84
	STA	Cptrl			; save count pointer low byte
	STY	Cptrh			; save count pointer high byte
LAB_2B88
	LDX	#<numexp		; set pointer low byte
	JSR	LAB_2770		; set pointer high byte and pack FAC1 into numexp
	LDA	(Cptrl),Y		; get constants count
	STA	numcon		; save constants count
	LDY	Cptrl			; get count pointer low byte
	INY				; increment it (now constants pointer)
	TYA				; copy it
	BNE	LAB_2B97		; skip next if no overflow

	INC	Cptrh			; else increment high byte
LAB_2B97
	STA	Cptrl			; save low byte
	LDY	Cptrh			; get high byte
LAB_2B9B
	JSR	LAB_25FB		; do convert AY, FCA1*(AY)
	LDA	Cptrl			; get constants pointer low byte
	LDY	Cptrh			; get constants pointer high byte
	CLC				; clear carry for add
	ADC	#$04			; +4 to  low pointer (4 bytes per constant)
	BCC	LAB_2BA8		; skip next if no overflow

	INY				; increment high byte
LAB_2BA8
	STA	Cptrl			; save pointer low byte
	STY	Cptrh			; save pointer high byte
	JSR	LAB_246C		; add (AY) to FAC1
	LDA	#<numexp		; set pointer low byte to partial @ numexp
	LDY	#>numexp		; set pointer high byte to partial @ numexp
	DEC	numcon		; decrement constants count
	BNE	LAB_2B9B		; loop until all done

	RTS

; RND(n), 32 bit Galoise version. make n=0 for 19th next number in sequence or n<>0
; to get 19th next number in sequence after seed n. This version of the PRNG uses
; the Galois method and a sample of 65536 bytes produced gives the following values.

; Entropy = 7.997442 bits per byte
; Optimum compression would reduce these 65536 bytes by 0 percent

; Chi square distribution for 65536 samples is 232.01, and
; randomly would exceed this value 75.00 percent of the time

; Arithmetic mean value of data bytes is 127.6724, 127.5 would be random
; Monte Carlo value for Pi is 3.122871269, error 0.60 percent
; Serial correlation coefficient is -0.000370, totally uncorrelated would be 0.0

LAB_RND
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	NextPRN		; do next random # if zero

					; else get seed into random number store
	LDX	#Rbyte4		; set PRNG pointer low byte
	LDY	#$00			; set PRNG pointer high byte
	JSR	LAB_2778		; pack FAC1 into (XY)
NextPRN
	LDX	#$AF			; set EOR byte
	LDY	#$13			; do this nineteen times
LoopPRN
	ASL	Rbyte1		; shift PRNG most significant byte
	ROL	Rbyte2		; shift PRNG middle byte
	ROL	Rbyte3		; shift PRNG least significant byte
	ROL	Rbyte4		; shift PRNG extra byte
	BCC	Ninc1			; branch if bit 32 clear

	TXA				; set EOR byte
	EOR	Rbyte1		; EOR PRNG extra byte
	STA	Rbyte1		; save new PRNG extra byte
Ninc1
	DEY				; decrement loop count
	BNE	LoopPRN		; loop if not all done

	LDX	#$02			; three bytes to copy
CopyPRNG
	LDA	Rbyte1,X		; get PRNG byte
	STA	FAC1_1,X		; save FAC1 byte
	DEX
	BPL	CopyPRNG		; loop if not complete

	LDA	#$80			; set the exponent
	STA	FAC1_e		; save FAC1 exponent

	ASL				; clear A
	STA	FAC1_s		; save FAC1 sign

	JMP	LAB_24D5		; normalise FAC1 and return

; perform COS()

LAB_COS
	LDA	#<LAB_2C78		; set (pi/2) pointer low byte
	LDY	#>LAB_2C78		; set (pi/2) pointer high byte
	JSR	LAB_246C		; add (AY) to FAC1

; perform SIN()

LAB_SIN
	JSR	LAB_27AB		; round and copy FAC1 to FAC2
	LDA	#<LAB_2C7C		; set (2*pi) pointer low byte
	LDY	#>LAB_2C7C		; set (2*pi) pointer high byte
	LDX	FAC2_s		; get FAC2 sign (b7)
	JSR	LAB_26C2		; divide by (AY) (X=sign)
	JSR	LAB_27AB		; round and copy FAC1 to FAC2
	JSR	LAB_INT		; perform INT
	LDA	#$00			; clear byte
	STA	FAC_sc		; clear sign compare (FAC1 EOR FAC2)
	JSR	LAB_SUBTRACT	; perform subtraction, FAC2 from FAC1
	LDA	#<LAB_2C80		; set 0.25 pointer low byte
	LDY	#>LAB_2C80		; set 0.25 pointer high byte
	JSR	LAB_2455		; perform subtraction, (AY) from FAC1
	LDA	FAC1_s		; get FAC1 sign (b7)
	PHA				; save FAC1 sign
	BPL	LAB_2C35		; branch if +ve

					; FAC1 sign was -ve
	JSR	LAB_244E		; add 0.5 to FAC1
	LDA	FAC1_s		; get FAC1 sign (b7)
	BMI	LAB_2C38		; branch if -ve

	LDA	Cflag			; get comparison evaluation flag
	EOR	#$FF			; toggle flag
	STA	Cflag			; save comparison evaluation flag
LAB_2C35
	JSR	LAB_GTHAN		; do - FAC1
LAB_2C38
	LDA	#<LAB_2C80		; set 0.25 pointer low byte
	LDY	#>LAB_2C80		; set 0.25 pointer high byte
	JSR	LAB_246C		; add (AY) to FAC1
	PLA				; restore FAC1 sign
	BPL	LAB_2C45		; branch if was +ve

					; else correct FAC1
	JSR	LAB_GTHAN		; do - FAC1
LAB_2C45
	LDA	#<LAB_2C84		; set pointer low byte to counter
	LDY	#>LAB_2C84		; set pointer high byte to counter
	JMP	LAB_2B6E		; ^2 then series evaluation and return

; perform TAN()

LAB_TAN
	JSR	LAB_276E		; pack FAC1 into Adatal
	LDA	#$00			; clear byte
	STA	Cflag			; clear comparison evaluation flag
	JSR	LAB_SIN		; go do SIN(n)
	LDX	#<func_l		; set sin(n) pointer low byte
	LDY	#>func_l		; set sin(n) pointer high byte
	JSR	LAB_2778		; pack FAC1 into (XY)
	LDA	#<Adatal		; set n pointer low addr
	LDY	#>Adatal		; set n pointer high addr
	JSR	LAB_UFAC		; unpack memory (AY) into FAC1
	LDA	#$00			; clear byte
	STA	FAC1_s		; clear FAC1 sign (b7)
	LDA	Cflag			; get comparison evaluation flag
	JSR	LAB_2C74		; save flag and go do series evaluation

	LDA	#<func_l		; set sin(n) pointer low byte
	LDY	#>func_l		; set sin(n) pointer high byte
	JMP	LAB_26CA		; convert AY and do (AY)/FAC1

LAB_2C74
	PHA				; save comparison evaluation flag
	JMP	LAB_2C35		; go do series evaluation

; perform USR()

LAB_USR
	JSR	Usrjmp		; call user code
	JMP	LAB_1BFB		; scan for ")", else do syntax error then warm start

; perform ATN()

LAB_ATN
	LDA	FAC1_s		; get FAC1 sign (b7)
	PHA				; save sign
	BPL	LAB_2CA1		; branch if +ve

	JSR	LAB_GTHAN		; else do - FAC1
LAB_2CA1
	LDA	FAC1_e		; get FAC1 exponent
	PHA				; push exponent
	CMP	#$81			; compare with 1
	BCC	LAB_2CAF		; branch if FAC1<1

	LDA	#<LAB_259C		; set 1 pointer low byte
	LDY	#>LAB_259C		; set 1 pointer high byte
	JSR	LAB_26CA		; convert AY and do (AY)/FAC1
LAB_2CAF
	LDA	#<LAB_2CC9		; set pointer low byte to counter
	LDY	#>LAB_2CC9		; set pointer high byte to counter
	JSR	LAB_2B6E		; ^2 then series evaluation
	PLA				; restore old FAC1 exponent
	CMP	#$81			; compare with 1
	BCC	LAB_2CC2		; branch if FAC1<1

	LDA	#<LAB_2C78		; set (pi/2) pointer low byte
	LDY	#>LAB_2C78		; set (pi/2) pointer high byte
	JSR	LAB_2455		; perform subtraction, (AY) from FAC1
LAB_2CC2
	PLA				; restore FAC1 sign
	BPL	LAB_2D04		; exit if was +ve

	JMP	LAB_GTHAN		; else do - FAC1 and return

; perform BITSET

LAB_BITSET
	JSR	LAB_GADB		; get two parameters for POKE or WAIT
	CPX	#$08			; only 0 to 7 are allowed
	BCS	FCError		; branch if > 7

	LDA	#$00			; clear A
	SEC				; set the carry
S_Bits
	ROL				; shift bit
	DEX				; decrement bit number
	BPL	S_Bits		; loop if still +ve

	INX				; make X = $00
	ORA	(Itempl,X)		; or with byte via temporary integer (addr)
	STA	(Itempl,X)		; save byte via temporary integer (addr)
LAB_2D04
	RTS

; perform BITCLR

LAB_BITCLR
	JSR	LAB_GADB		; get two parameters for POKE or WAIT
	CPX	#$08			; only 0 to 7 are allowed
	BCS	FCError		; branch if > 7

	LDA	#$FF			; set A
S_Bitc
	ROL				; shift bit
	DEX				; decrement bit number
	BPL	S_Bitc		; loop if still +ve

	INX				; make X = $00
	AND	(Itempl,X)		; and with byte via temporary integer (addr)
	STA	(Itempl,X)		; save byte via temporary integer (addr)
	RTS

FCError
	JMP	LAB_FCER		; do function call error then warm start

; perform BITTST()

LAB_BTST
	JSR	LAB_IGBY		; increment BASIC pointer
	JSR	LAB_GADB		; get two parameters for POKE or WAIT
	CPX	#$08			; only 0 to 7 are allowed
	BCS	FCError		; branch if > 7

	JSR	LAB_GBYT		; get next BASIC byte
	CMP	#')'			; is next character ")"
	BEQ	TST_OK		; if ")" go do rest of function

	JMP	LAB_SNER		; do syntax error then warm start

TST_OK
	JSR	LAB_IGBY		; update BASIC execute pointer (to character past ")")
	LDA	#$00			; clear A
	SEC				; set the carry
T_Bits
	ROL				; shift bit
	DEX				; decrement bit number
	BPL	T_Bits		; loop if still +ve

	INX				; make X = $00
	AND	(Itempl,X)		; AND with byte via temporary integer (addr)
	BEQ	LAB_NOTT		; branch if zero (already correct)

	LDA	#$FF			; set for -1 result
LAB_NOTT
	JMP	LAB_27DB		; go do SGN tail

; perform BIN$()

LAB_BINS
	CPX	#$19			; max + 1
	BCS	BinFErr		; exit if too big ( > or = )

	STX	TempB			; save # of characters ($00 = leading zero remove)
	LDA	#$18			; need A byte long space
	JSR	LAB_MSSP		; make string space A bytes long
	LDY	#$17			; set index
	LDX	#$18			; character count
NextB1
	LSR	nums_1		; shift highest byte
	ROR	nums_2		; shift middle byte
	ROR	nums_3		; shift lowest byte bit 0 to carry
	TXA				; load with "0"/2
	ROL				; shift in carry
	STA	(str_pl),Y		; save to temp string + index
	DEY				; decrement index
	BPL	NextB1		; loop if not done

	LDA	TempB			; get # of characters
	BEQ	EndBHS		; branch if truncate

	TAX				; copy length to X
	SEC				; set carry for add !
	EOR	#$FF			; 1's complement
	ADC	#$18			; add 24d
	BEQ	GoPr2			; if zero print whole string

	BNE	GoPr1			; else go make output string
	
; this is the exit code and is also used by HEX$()
; truncate string to remove leading "0"s

EndBHS
	TAY				; clear index (A=0, X=length here)
NextB2
	LDA	(str_pl),Y		; get character from string
	CMP	#'0'			; compare with "0"
	BNE	GoPr			; if not "0" then go print string from here

	DEX				; decrement character count
	BEQ	GoPr3			; if zero then end of string so go print it

	INY				; else increment index
	BPL	NextB2		; loop always

; make fixed length output string - ignore overflows!

GoPr3
	INX				; need at least 1 character
GoPr
	TYA				; copy result
GoPr1
	CLC				; clear carry for add
	ADC	str_pl		; add low address
	STA	str_pl		; save low address
	LDA	#$00			; do high byte
	ADC	str_ph		; add high address
	STA	str_ph		; save high address
GoPr2
	STX	str_ln		; X holds string length
	JSR	LAB_IGBY		; update BASIC execute pointer (to character past ")")
	JMP	LAB_RTST		; check for space on descriptor stack then put address
					; and length on descriptor stack and update stack pointers

BinFErr
	JMP	LAB_FCER		; do function call error then warm start

; perform HEX$()

LAB_HEXS
	CPX	#$07			; max + 1
	BCS	BinFErr		; exit if too big ( > or = )

	STX	TempB			; save # of characters

	LDA	#$06			; need 6 bytes for string
	JSR	LAB_MSSP		; make string space A bytes long
	LDY	#$05			; set string index

	SED				; need decimal mode for nibble convert
	LDA	nums_3		; get lowest byte
	JSR	LAB_A2HX		; convert A to ASCII hex byte and output
	LDA	nums_2		; get middle byte
	JSR	LAB_A2HX		; convert A to ASCII hex byte and output
	LDA	nums_1		; get highest byte
	JSR	LAB_A2HX		; convert A to ASCII hex byte and output
	CLD				; back to binary

	LDX	#$06			; character count
	LDA	TempB			; get # of characters
	BEQ	EndBHS		; branch if truncate

	TAX				; copy length to X
	SEC				; set carry for add !
	EOR	#$FF			; 1's complement
	ADC	#$06			; add 6d
	BEQ	GoPr2			; if zero print whole string

	BNE	GoPr1			; else go make output string (branch always)

; convert A to ASCII hex byte and output .. note set decimal mode before calling

LAB_A2HX
	TAX				; save byte
	AND	#$0F			; mask off top bits
	JSR	LAB_AL2X		; convert low nibble to ASCII and output
	TXA				; get byte back
	LSR				; /2	shift high nibble to low nibble
	LSR				; /4
	LSR				; /8
	LSR				; /16
LAB_AL2X
	CMP	#$0A			; set carry for +1 if >9
	ADC	#'0'			; add ASCII "0"
	STA	(str_pl),Y		; save to temp string
	DEY				; decrement counter
	RTS

LAB_NLTO
	STA	FAC1_e		; save FAC1 exponent
	LDA	#$00			; clear sign compare
LAB_MLTE
	STA	FAC_sc		; save sign compare (FAC1 EOR FAC2)
	TXA				; restore character
	JSR	LAB_2912		; evaluate new ASCII digit

; gets here if the first character was "$" for hex
; get hex number

LAB_CHEX
	JSR	LAB_IGBY		; increment and scan memory
	BCC	LAB_ISHN		; branch if numeric character

	ORA	#$20			; case convert, allow "A" to "F" and "a" to "f"
	SBC	#'a'			; subtract "a" (carry set here)
	CMP	#$06			; compare normalised with $06 (max+1)
	BCS	LAB_EXCH		; exit if >"f" or <"0"

	ADC	#$0A			; convert to nibble
LAB_ISHN
	AND	#$0F			; convert to binary
	TAX				; save nibble
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_MLTE		; skip multiply if zero

	ADC	#$04			; add four to exponent (*16 - carry clear here)
	BCC	LAB_NLTO		; if no overflow do evaluate digit

LAB_MLTO
	JMP	LAB_2564		; do overflow error and warm start

LAB_NXCH
	TAX				; save bit
	LDA	FAC1_e		; get FAC1 exponent
	BEQ	LAB_MLBT		; skip multiply if zero

	INC	FAC1_e		; increment FAC1 exponent (*2)
	BEQ	LAB_MLTO		; do overflow error if = $00

	LDA	#$00			; clear sign compare
LAB_MLBT
	STA	FAC_sc		; save sign compare (FAC1 EOR FAC2)
	TXA				; restore bit
	JSR	LAB_2912		; evaluate new ASCII digit

; gets here if the first character was  "%" for binary
; get binary number

LAB_CBIN
	JSR	LAB_IGBY		; increment and scan memory
	EOR	#'0'			; convert "0" to 0 etc.
	CMP	#$02			; compare with max+1
	BCC	LAB_NXCH		; branch exit if < 2

LAB_EXCH
	JMP	LAB_28F6		; evaluate -ve flag and return

; ctrl-c check routine. includes limited "life" byte save for INGET routine
; now also the code that checks to see if an interrupt has occurred

CTRLC
	LDA	ccflag		; get [CTRL-C] check flag
	BNE	LAB_FBA2		; exit if inhibited

	JSR	V_INPT		; scan input device
	BCC	LAB_FBA0		; exit if buffer empty

	STA	ccbyte		; save received byte
	LDX	#$20			; "life" timer for bytes
	STX	ccnull		; set countdown
	JMP	LAB_1636		; return to BASIC

LAB_FBA0
	LDX	ccnull		; get countdown byte
	BEQ	LAB_FBA2		; exit if finished

	DEC	ccnull		; else decrement countdown
LAB_FBA2
	LDX	#NmiBase		; set pointer to NMI values
	JSR	LAB_CKIN		; go check interrupt
	LDX	#IrqBase		; set pointer to IRQ values
	JSR	LAB_CKIN		; go check interrupt
LAB_CRTS
	RTS

; check whichever interrupt is indexed by X

LAB_CKIN
	LDA	PLUS_0,X		; get interrupt flag byte
	BPL	LAB_CRTS		; branch if interrupt not enabled

; we disable the interrupt here and make two new commands RETIRQ and RETNMI to
; automatically enable the interrupt when we exit

	ASL				; move happened bit to setup bit
	AND	#$40			; mask happened bits
	BEQ	LAB_CRTS		; if no interrupt then exit

	STA	PLUS_0,X		; save interrupt flag byte

	TXA				; copy index ..
	TAY				; .. to Y

	PLA				; dump return address low byte, call from CTRL-C
	PLA				; dump return address high byte

	LDA	#$05			; need 5 bytes for GOSUB
	JSR	LAB_1212		; check room on stack for A bytes
	LDA	Bpntrh		; get BASIC execute pointer high byte
	PHA				; push on stack
	LDA	Bpntrl		; get BASIC execute pointer low byte
	PHA				; push on stack
	LDA	Clineh		; get current line high byte
	PHA				; push on stack
	LDA	Clinel		; get current line low byte
	PHA				; push on stack
	LDA	#TK_GOSUB		; token for GOSUB
	PHA				; push on stack

	LDA	PLUS_1,Y		; get interrupt code pointer low byte
	STA	Bpntrl		; save as BASIC execute pointer low byte
	LDA	PLUS_2,Y		; get interrupt code pointer high byte
	STA	Bpntrh		; save as BASIC execute pointer high byte

	JMP	LAB_15C2		; go do interpreter inner loop
					; can't RTS, we used the stack! the RTS from the ctrl-c
					; check will be taken when the RETIRQ/RETNMI/RETURN is
					; executed at the end of the subroutine

; get byte from input device, no waiting
; returns with carry set if byte in A

INGET
	JSR	V_INPT		; call scan input device
	BCS	LAB_FB95		; if byte go reset timer

	LDA	ccnull		; get countdown
	BEQ	LAB_FB96		; exit if empty

	LDA	ccbyte		; get last received byte
	SEC				; flag we got a byte
LAB_FB95
	LDX	#$00			; clear X
	STX	ccnull		; clear timer because we got a byte
LAB_FB96
	RTS

; these routines only enable the interrupts if the set-up flag is set
; if not they have no effect

; perform IRQ {ON|OFF|CLEAR}

LAB_IRQ
	LDX	#IrqBase		; set pointer to IRQ values
	.byte	$2C			; make next line BIT abs.

; perform NMI {ON|OFF|CLEAR}

LAB_NMI
	LDX	#NmiBase		; set pointer to NMI values
	CMP	#TK_ON		; compare with token for ON
	BEQ	LAB_INON		; go turn on interrupt

	CMP	#TK_OFF		; compare with token for OFF
	BEQ	LAB_IOFF		; go turn off interrupt

	EOR	#TK_CLEAR		; compare with token for CLEAR, A = $00 if = TK_CLEAR
	BEQ	LAB_INEX		; go clear interrupt flags and return

	JMP	LAB_SNER		; do syntax error then warm start

LAB_IOFF
	LDA	#$7F			; clear A
	AND	PLUS_0,X		; AND with interrupt setup flag
	BPL	LAB_INEX		; go clear interrupt enabled flag and return

LAB_INON
	LDA	PLUS_0,X		; get interrupt setup flag
	ASL				; Shift bit to enabled flag
	ORA	PLUS_0,X		; OR with flag byte
LAB_INEX
	STA	PLUS_0,X		; save interrupt flag byte
	JMP	LAB_IGBY		; update BASIC execute pointer and return

; these routines set up the pointers and flags for the interrupt routines
; note that the interrupts are also enabled by these commands

; perform ON IRQ

LAB_SIRQ
	CLI				; enable interrupts
	LDX	#IrqBase		; set pointer to IRQ values
	.byte	$2C			; make next line BIT abs.

; perform ON NMI

LAB_SNMI
	LDX	#NmiBase		; set pointer to NMI values

	STX	TempB			; save interrupt pointer
	JSR	LAB_IGBY		; increment and scan memory (past token)
	JSR	LAB_GFPN		; get fixed-point number into temp integer
	LDA	Smeml			; get start of mem low byte
	LDX	Smemh			; get start of mem high byte
	JSR	LAB_SHLN		; search Basic for temp integer line number from AX
	BCS	LAB_LFND		; if carry set go set-up interrupt

	JMP	LAB_16F7		; else go do "Undefined statement" error and warm start

LAB_LFND
	LDX	TempB			; get interrupt pointer
	LDA	Baslnl		; get pointer low byte
	SBC	#$01			; -1 (carry already set for subtract)
	STA	PLUS_1,X		; save as interrupt pointer low byte
	LDA	Baslnh		; get pointer high byte
	SBC	#$00			; subtract carry
	STA	PLUS_2,X		; save as interrupt pointer high byte

	LDA	#$C0			; set interrupt enabled/setup bits
	STA	PLUS_0,X		; set interrupt flags
LAB_IRTS
	RTS

; return from IRQ service, restores the enabled flag.

; perform RETIRQ

LAB_RETIRQ
	BNE	LAB_IRTS		; exit if following token (to allow syntax error)

	LDA	IrqBase		; get interrupt flags
	ASL				; copy setup to enabled (b7)
	ORA	IrqBase		; OR in setup flag
	STA	IrqBase		; save enabled flag
	JMP	LAB_16E8		; go do rest of RETURN

; return from NMI service, restores the enabled flag.

; perform RETNMI

LAB_RETNMI
	BNE	LAB_IRTS		; exit if following token (to allow syntax error)

	LDA	NmiBase		; get set-up flag
	ASL				; copy setup to enabled (b7)
	ORA	NmiBase		; OR in setup flag
	STA	NmiBase		; save enabled flag
	JMP	LAB_16E8		; go do rest of RETURN

; MAX() MIN() pre process

LAB_MMPP
	JSR	LAB_EVEZ		; process expression
	JMP	LAB_CTNM		; check if source is numeric, else do type mismatch

; perform MAX()

LAB_MAX
	JSR	LAB_PHFA		; push FAC1, evaluate expression,
					; pull FAC2 and compare with FAC1
	BPL	LAB_MAX		; branch if no swap to do

	LDA	FAC2_1		; get FAC2 mantissa1
	ORA	#$80			; set top bit (clear sign from compare)
	STA	FAC2_1		; save FAC2 mantissa1
	JSR	LAB_279B		; copy FAC2 to FAC1
	BEQ	LAB_MAX		; go do next (branch always)

; perform MIN()

LAB_MIN
	JSR	LAB_PHFA		; push FAC1, evaluate expression,
					; pull FAC2 and compare with FAC1
	BMI	LAB_MIN		; branch if no swap to do

	BEQ	LAB_MIN		; branch if no swap to do

	LDA	FAC2_1		; get FAC2 mantissa1
	ORA	#$80			; set top bit (clear sign from compare)
	STA	FAC2_1		; save FAC2 mantissa1
	JSR	LAB_279B		; copy FAC2 to FAC1
	BEQ	LAB_MIN		; go do next (branch always)

; exit routine. don't bother returning to the loop code
; check for correct exit, else so syntax error

LAB_MMEC
	CMP	#')'			; is it end of function?
	BNE	LAB_MMSE		; if not do MAX MIN syntax error

	PLA				; dump return address low byte
	PLA				; dump return address high byte
	JMP	LAB_IGBY		; update BASIC execute pointer (to chr past ")")

LAB_MMSE
	JMP	LAB_SNER		; do syntax error then warm start

; check for next, evaluate and return or exit
; this is the routine that does most of the work

LAB_PHFA
	JSR	LAB_GBYT		; get next BASIC byte
	CMP	#','			; is there more ?
	BNE	LAB_MMEC		; if not go do end check

					; push FAC1
	JSR	LAB_27BA		; round FAC1
	LDA	FAC1_s		; get FAC1 sign
	ORA	#$7F			; set all non sign bits
	AND	FAC1_1		; AND FAC1 mantissa1 (AND in sign bit)
	PHA				; push on stack
	LDA	FAC1_2		; get FAC1 mantissa2
	PHA				; push on stack
	LDA	FAC1_3		; get FAC1 mantissa3
	PHA				; push on stack
	LDA	FAC1_e		; get FAC1 exponent
	PHA				; push on stack

	JSR	LAB_IGBY		; scan and get next BASIC byte (after ",")
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch

					; pop FAC2 (MAX/MIN expression so far)
	PLA				; pop exponent
	STA	FAC2_e		; save FAC2 exponent
	PLA				; pop mantissa3
	STA	FAC2_3		; save FAC2 mantissa3
	PLA				; pop mantissa1
	STA	FAC2_2		; save FAC2 mantissa2
	PLA				; pop sign/mantissa1
	STA	FAC2_1		; save FAC2 sign/mantissa1
	STA	FAC2_s		; save FAC2 sign

					; compare FAC1 with (packed) FAC2
	LDA	#<FAC2_e		; set pointer low byte to FAC2
	LDY	#>FAC2_e		; set pointer high byte to FAC2
	JMP	LAB_27F8		; compare FAC1 with FAC2 (AY) and return
					; returns A=$00 if FAC1 = (AY)
					; returns A=$01 if FAC1 > (AY)
					; returns A=$FF if FAC1 < (AY)

; perform WIDTH

LAB_WDTH
	CMP	#','			; is next byte ","
	BEQ	LAB_TBSZ		; if so do tab size

	JSR	LAB_GTBY		; get byte parameter
	TXA				; copy width to A
	BEQ	LAB_NSTT		; branch if set for infinite line

	CPX	#$10			; else make min width = 16d
	BCC	TabErr		; if less do function call error and exit

; this next compare ensures that we can't exit WIDTH via an error leaving the
; tab size greater than the line length.

	CPX	TabSiz		; compare with tab size
	BCS	LAB_NSTT		; branch if >= tab size

	STX	TabSiz		; else make tab size = terminal width
LAB_NSTT
	STX	TWidth		; set the terminal width
	JSR	LAB_GBYT		; get BASIC byte back
	BEQ	WExit			; exit if no following

	CMP	#','			; else is it ","
	BNE	LAB_MMSE		; if not do syntax error

LAB_TBSZ
	JSR	LAB_SGBY		; scan and get byte parameter
	TXA				; copy TAB size
	BMI	TabErr		; if >127 do function call error and exit

	CPX	#$01			; compare with min-1
	BCC	TabErr		; if <=1 do function call error and exit

	LDA	TWidth		; set flags for width
	BEQ	LAB_SVTB		; skip check if infinite line

	CPX	TWidth		; compare TAB with width
	BEQ	LAB_SVTB		; ok if =

	BCS	TabErr		; branch if too big

LAB_SVTB
	STX	TabSiz		; save TAB size

; calculate tab column limit from TAB size. The Iclim is set to the last tab
; position on a line that still has at least one whole tab width between it
; and the end of the line.

WExit
	LDA	TWidth		; get width
	BEQ	LAB_SULP		; branch if infinite line

	CMP	TabSiz		; compare with tab size
	BCS	LAB_WDLP		; branch if >= tab size

	STA	TabSiz		; else make tab size = terminal width
LAB_SULP
	SEC				; set carry for subtract
LAB_WDLP
	SBC	TabSiz		; subtract tab size
	BCS	LAB_WDLP		; loop while no borrow

	ADC	TabSiz		; add tab size back
	CLC				; clear carry for add
	ADC	TabSiz		; add tab size back again
	STA	Iclim			; save for now
	LDA	TWidth		; get width back
	SEC				; set carry for subtract
	SBC	Iclim			; subtract remainder
	STA	Iclim			; save tab column limit
LAB_NOSQ
	RTS

TabErr
	JMP	LAB_FCER		; do function call error then warm start

; perform SQR()

LAB_SQR
	LDA	FAC1_s		; get FAC1 sign
	BMI	TabErr		; if -ve do function call error

	LDA	FAC1_e		; get exponent
	BEQ	LAB_NOSQ		; if zero just return

					; else do root
	JSR	LAB_27AB		; round and copy FAC1 to FAC2
	LDA	#$00			; clear A

	STA	FACt_3		; clear remainder
	STA	FACt_2		; ..
	STA	FACt_1		; ..
	STA	TempB			; ..

	STA	FAC1_3		; clear root
	STA	FAC1_2		; ..
	STA	FAC1_1		; ..

	LDX	#$18			; 24 pairs of bits to do
	LDA	FAC2_e		; get exponent
	LSR				; check odd/even
	BCS	LAB_SQE2		; if odd only 1 shift first time

LAB_SQE1
	ASL	FAC2_3		; shift highest bit of number ..
	ROL	FAC2_2		; ..
	ROL	FAC2_1		; ..
	ROL	FACt_3		; .. into remainder
	ROL	FACt_2		; ..
	ROL	FACt_1		; ..
	ROL	TempB			; .. never overflows
LAB_SQE2
	ASL	FAC2_3		; shift highest bit of number ..
	ROL	FAC2_2		; ..
	ROL	FAC2_1		; ..
	ROL	FACt_3		; .. into remainder
	ROL	FACt_2		; ..
	ROL	FACt_1		; ..
	ROL	TempB			; .. never overflows

	ASL	FAC1_3		; root = root * 2
	ROL	FAC1_2		; ..
	ROL	FAC1_1		; .. never overflows

	LDA	FAC1_3		; get root low byte
	ROL				; *2
	STA	Temp3			; save partial low byte
	LDA	FAC1_2		; get root low mid byte
	ROL				; *2
	STA	Temp3+1		; save partial low mid byte
	LDA	FAC1_1		; get root high mid byte
	ROL				; *2
	STA	Temp3+2		; save partial high mid byte
	LDA	#$00			; get root high byte (always $00)
	ROL				; *2
	STA	Temp3+3		; save partial high byte

					; carry clear for subtract +1
	LDA	FACt_3		; get remainder low byte
	SBC	Temp3			; subtract partial low byte
	STA	Temp3			; save partial low byte

	LDA	FACt_2		; get remainder low mid byte
	SBC	Temp3+1		; subtract partial low mid byte
	STA	Temp3+1		; save partial low mid byte

	LDA	FACt_1		; get remainder high mid byte
	SBC	Temp3+2		; subtract partial high mid byte
	TAY				; copy partial high mid byte

	LDA	TempB			; get remainder high byte
	SBC	Temp3+3		; subtract partial high byte
	BCC	LAB_SQNS		; skip sub if remainder smaller

	STA	TempB			; save remainder high byte

	STY	FACt_1		; save remainder high mid byte

	LDA	Temp3+1		; get remainder low mid byte
	STA	FACt_2		; save remainder low mid byte

	LDA	Temp3			; get partial low byte
	STA	FACt_3		; save remainder low byte

	INC	FAC1_3		; increment root low byte (never any rollover)
LAB_SQNS
	DEX				; decrement bit pair count
	BNE	LAB_SQE1		; loop if not all done

	SEC				; set carry for subtract
	LDA	FAC2_e		; get exponent
	SBC	#$80			; normalise
	ROR				; /2 and re-bias to $80
	ADC	#$00			; add bit zero back in (allow for half shift)
	STA	FAC1_e		; save it
	JMP	LAB_24D5		; normalise FAC1 and return

; perform VARPTR()

LAB_VARPTR
	JSR	LAB_IGBY		; increment and scan memory
	JSR	LAB_GVAR		; get var address
	JSR	LAB_1BFB		; scan for ")" , else do syntax error then warm start
	LDY	Cvaral		; get var address low byte
	LDA	Cvarah		; get var address high byte
	JMP	LAB_AYFC		; save and convert integer AY to FAC1 and return

; perform PI

LAB_PI
	LDA	#<LAB_2C7C		; set (2*pi) pointer low byte
	LDY	#>LAB_2C7C		; set (2*pi) pointer high byte
	JSR	LAB_UFAC		; unpack memory (AY) into FAC1
	DEC	FAC1_e		; make result = PI
	RTS

; perform TWOPI

LAB_TWOPI
	LDA	#<LAB_2C7C		; set (2*pi) pointer low byte
	LDY	#>LAB_2C7C		; set (2*pi) pointer high byte
	JMP	LAB_UFAC		; unpack memory (AY) into FAC1 and return

; system dependant i/o vectors
; these are in RAM and are set by the monitor at start-up

V_INPT
	JMP	(VEC_IN)		; non halting scan input device
V_OUTP
	JMP	(VEC_OUT)		; send byte to output device
V_LOAD
	JMP	(VEC_LD)		; load BASIC program
V_SAVE
	JMP	(VEC_SV)		; save BASIC program

LAB_BYE:
;	nat
	.byte	$42	; WDM
	xce
	cpu		rtf65002
	jmp		(ExitTask>>2)
	cpu		W65C02

; The rest are tables messages and code for RAM

; the rest of the code is tables and BASIC start-up code

PG2_TABS
	.byte	$00			; ctrl-c flag		-	$00 = enabled
	.byte	$00			; ctrl-c byte		-	GET needs this
	.byte	$00			; ctrl-c byte timeout	-	GET needs this
	.word	CTRLC			; ctrl c check vector
;	.word	xxxx			; non halting key input	-	monitor to set this
;	.word	xxxx			; output vector		-	monitor to set this
;	.word	xxxx			; load vector		-	monitor to set this
;	.word	xxxx			; save vector		-	monitor to set this
PG2_TABE

; character get subroutine for zero page

; For a 1.8432MHz 6502 including the JSR and RTS
; fastest (>=":")	=  29 cycles =  15.7uS
; slowest (<":")	=  40 cycles =  21.7uS
; space skip	= +21 cycles = +11.4uS
; inc across page	=  +4 cycles =  +2.2uS

; the target address for the LDA at LAB_2CF4 becomes the BASIC execute pointer once the
; block is copied to it's destination, any non zero page address will do at assembly
; time, to assemble a three byte instruction.

; page 0 initialisation table from $BC
; increment and scan memory

LAB_2CEE
	INC	Bpntrl		; increment BASIC execute pointer low byte
	BNE	LAB_2CF4		; branch if no carry
					; else
	INC	Bpntrh		; increment BASIC execute pointer high byte

; page 0 initialisation table from $C2
; scan memory

LAB_2CF4
	LDA	$FFFF			; get byte to scan (addr set by call routine)
	CMP	#TK_ELSE		; compare with the token for ELSE
	BEQ	LAB_2D05		; exit if ELSE, not numeric, carry set

	CMP	#':'			; compare with ":"
	BCS	LAB_2D05		; exit if >= ":", not numeric, carry set

	CMP	#' '			; compare with " "
	BEQ	LAB_2CEE		; if " " go do next

	SEC				; set carry for SBC
	SBC	#'0'			; subtract "0"
	SEC				; set carry for SBC
	SBC	#$D0			; subtract -"0"
					; clear carry if byte = "0"-"9"
LAB_2D05
	RTS

; page zero initialisation table $00-$12 inclusive

StrTab
	.byte	$4C			; JMP opcode
	.word LAB_COLD		; initial warm start vector (cold start)

	.byte	$00			; these bytes are not used by BASIC
	.word	$0000			; 
	.word	$0000			; 
	.word	$0000			; 

	.byte	$4C			; JMP opcode
	.word	LAB_FCER		; initial user function vector ("Function call" error)
	.byte	$00			; default NULL count
	.byte	$00			; clear terminal position
	.byte	$00			; default terminal width byte
	.byte	$F2			; default limit for TAB = 14
	.word	Ram_base		; start of user RAM
EndTab

LAB_MSZM
	.byte	$0D,$0A,"Memory size ",$00

LAB_SMSG
	.byte	" Bytes free",$0D,$0A,$0A
	.byte	"Enhanced BASIC 2.22",$0A,$00

; numeric constants and series

					; constants and series for LOG(n)
LAB_25A0
	.byte	$02			; counter
	.byte	$80,$19,$56,$62	; 0.59898
	.byte	$80,$76,$22,$F3	; 0.96147
;##	.byte	$80,$76,$22,$F1	; 0.96147
	.byte	$82,$38,$AA,$40	; 2.88539
;##	.byte	$82,$38,$AA,$45	; 2.88539

LAB_25AD
	.byte	$80,$35,$04,$F3	; 0.70711	1/root 2
LAB_25B1
	.byte	$81,$35,$04,$F3	; 1.41421	root 2
LAB_25B5
	.byte	$80,$80,$00,$00	; -0.5
LAB_25B9
	.byte	$80,$31,$72,$18	; 0.69315	LOG(2)

					; numeric PRINT constants
LAB_2947
	.byte	$91,$43,$4F,$F8	; 99999.9375 (max value with at least one decimal)
LAB_294B
	.byte	$94,$74,$23,$F7	; 999999.4375 (max value before scientific notation)
LAB_294F
	.byte	$94,$74,$24,$00	; 1000000

					; EXP(n) constants and series
LAB_2AFA
	.byte	$81,$38,$AA,$3B	; 1.4427	(1/LOG base 2 e)
LAB_2AFE
	.byte	$06			; counter
	.byte	$74,$63,$90,$8C	; 2.17023e-4
	.byte	$77,$23,$0C,$AB	; 0.00124
	.byte	$7A,$1E,$94,$00	; 0.00968
	.byte	$7C,$63,$42,$80	; 0.05548
	.byte	$7E,$75,$FE,$D0	; 0.24023
	.byte	$80,$31,$72,$15	; 0.69315
	.byte	$81,$00,$00,$00	; 1.00000

;##	.byte	$07			; counter
;##	.byte	$74,$94,$2E,$40	; -1/7! (-1/5040)
;##	.byte	$77,$2E,$4F,$70	;  1/6! ( 1/720)
;##	.byte	$7A,$88,$02,$6E	; -1/5! (-1/120)
;##	.byte	$7C,$2A,$A0,$E6	;  1/4! ( 1/24)
;##	.byte	$7E,$AA,$AA,$50	; -1/3! (-1/6)
;##	.byte	$7F,$7F,$FF,$FF	;  1/2! ( 1/2)
;##	.byte	$81,$80,$00,$00	; -1/1! (-1/1)
;##	.byte	$81,$00,$00,$00	;  1/0! ( 1/1)

					; trigonometric constants and series
LAB_2C78
	.byte	$81,$49,$0F,$DB	; 1.570796371 (pi/2) as floating #
LAB_2C84
	.byte	$04			; counter
	.byte	$86,$1E,$D7,$FB	; 39.7109
;##	.byte	$86,$1E,$D7,$BA	; 39.7109
	.byte	$87,$99,$26,$65	;-76.575
;##	.byte	$87,$99,$26,$64	;-76.575
	.byte	$87,$23,$34,$58	; 81.6022
	.byte	$86,$A5,$5D,$E1	;-41.3417
;##	.byte	$86,$A5,$5D,$E0	;-41.3417
LAB_2C7C
	.byte	$83,$49,$0F,$DB	; 6.28319 (2*pi) as floating #
;##	.byte	$83,$49,$0F,$DA	; 6.28319 (2*pi) as floating #

LAB_2CC9
	.byte	$08			; counter
	.byte	$78,$3A,$C5,$37	; 0.00285
	.byte	$7B,$83,$A2,$5C	;-0.0160686
	.byte	$7C,$2E,$DD,$4D	; 0.0426915
	.byte	$7D,$99,$B0,$1E	;-0.0750429
	.byte	$7D,$59,$ED,$24	; 0.106409
	.byte	$7E,$91,$72,$00	;-0.142036
	.byte	$7E,$4C,$B9,$73	; 0.199926
	.byte	$7F,$AA,$AA,$53	;-0.333331

;##	.byte	$08			; counter
;##	.byte	$78,$3B,$D7,$4A	; 1/17
;##	.byte	$7B,$84,$6E,$02	;-1/15
;##	.byte	$7C,$2F,$C1,$FE	; 1/13
;##	.byte	$7D,$9A,$31,$74	;-1/11
;##	.byte	$7D,$5A,$3D,$84	; 1/9
;##	.byte	$7E,$91,$7F,$C8	;-1/7
;##	.byte	$7E,$4C,$BB,$E4	; 1/5
;##	.byte	$7F,$AA,$AA,$6C	;-1/3

LAB_1D96	= *+1			; $00,$00 used for undefined variables
LAB_259C
	.byte	$81,$00,$00,$00	; 1.000000, used for INC
LAB_2AFD
	.byte	$81,$80,$00,$00	; -1.00000, used for DEC. must be on the same page as +1.00

					; misc constants
LAB_1DF7
	.byte	$90			;-32768 (uses first three bytes from 0.5)
LAB_2A96
	.byte	$80,$00,$00,$00	; 0.5
LAB_2C80
	.byte	$7F,$00,$00,$00	; 0.25
LAB_26B5
	.byte	$84,$20,$00,$00	; 10.0000 divide by 10 constant

; This table is used in converting numbers to ASCII.

LAB_2A9A
LAB_2A9B = LAB_2A9A+1
LAB_2A9C = LAB_2A9B+1
	.byte	$FE,$79,$60		; -100000
	.byte	$00,$27,$10		; 10000
	.byte	$FF,$FC,$18		; -1000
	.byte	$00,$00,$64		; 100
	.byte	$FF,$FF,$F6		; -10
	.byte	$00,$00,$01		; 1

LAB_CTBL
	.word	LAB_END-1		; END
	.word	LAB_FOR-1		; FOR
	.word	LAB_NEXT-1		; NEXT
	.word	LAB_DATA-1		; DATA
	.word	LAB_INPUT-1		; INPUT
	.word	LAB_DIM-1		; DIM
	.word	LAB_READ-1		; READ
	.word	LAB_LET-1		; LET
	.word	LAB_DEC-1		; DEC			new command
	.word	LAB_GOTO-1		; GOTO
	.word	LAB_RUN-1		; RUN
	.word	LAB_IF-1		; IF
	.word	LAB_RESTORE-1	; RESTORE		modified command
	.word	LAB_GOSUB-1		; GOSUB
	.word	LAB_RETIRQ-1	; RETIRQ		new command
	.word	LAB_RETNMI-1	; RETNMI		new command
	.word	LAB_RETURN-1	; RETURN
	.word	LAB_REM-1		; REM
	.word	LAB_STOP-1		; STOP
	.word	LAB_ON-1		; ON			modified command
	.word	LAB_NULL-1		; NULL		modified command
	.word	LAB_INC-1		; INC			new command
	.word	LAB_WAIT-1		; WAIT
	.word	V_LOAD-1		; LOAD
	.word	V_SAVE-1		; SAVE
	.word	LAB_DEF-1		; DEF
	.word	LAB_POKE-1		; POKE
	.word	LAB_DOKE-1		; DOKE		new command
	.word	LAB_CALL-1		; CALL		new command
	.word	LAB_DO-1		; DO			new command
	.word	LAB_LOOP-1		; LOOP		new command
	.word	LAB_PRINT-1		; PRINT
	.word	LAB_CONT-1		; CONT
	.word	LAB_LIST-1		; LIST
	.word	LAB_CLEAR-1		; CLEAR
	.word	LAB_NEW-1		; NEW
	.word	LAB_WDTH-1		; WIDTH		new command
	.word	LAB_GET-1		; GET			new command
	.word	LAB_SWAP-1		; SWAP		new command
	.word	LAB_BITSET-1	; BITSET		new command
	.word	LAB_BITCLR-1	; BITCLR		new command
	.word	LAB_IRQ-1		; IRQ			new command
	.word	LAB_NMI-1		; NMI			new command
	.word	LAB_BYE-1		; BYE		new command

; function pre process routine table

LAB_FTPL
LAB_FTPM	= LAB_FTPL+$01
	.word	LAB_PPFN-1		; SGN(n)	process numeric expression in ()
	.word	LAB_PPFN-1		; INT(n)		"
	.word	LAB_PPFN-1		; ABS(n)		"
	.word	LAB_EVEZ-1		; USR(x)	process any expression
	.word	LAB_1BF7-1		; FRE(x)		"
	.word	LAB_1BF7-1		; POS(x)		"
	.word	LAB_PPFN-1		; SQR(n)	process numeric expression in ()
	.word	LAB_PPFN-1		; RND(n)		"
	.word	LAB_PPFN-1		; LOG(n)		"
	.word	LAB_PPFN-1		; EXP(n)		"
	.word	LAB_PPFN-1		; COS(n)		"
	.word	LAB_PPFN-1		; SIN(n)		"
	.word	LAB_PPFN-1		; TAN(n)		"
	.word	LAB_PPFN-1		; ATN(n)		"
	.word	LAB_PPFN-1		; PEEK(n)		"
	.word	LAB_PPFN-1		; DEEK(n)		"
	.word	$0000			; SADD()	none
	.word	LAB_PPFS-1		; LEN($)	process string expression in ()
	.word	LAB_PPFN-1		; STR$(n)	process numeric expression in ()
	.word	LAB_PPFS-1		; VAL($)	process string expression in ()
	.word	LAB_PPFS-1		; ASC($)		"
	.word	LAB_PPFS-1		; UCASE$($)		"
	.word	LAB_PPFS-1		; LCASE$($)		"
	.word	LAB_PPFN-1		; CHR$(n)	process numeric expression in ()
	.word	LAB_BHSS-1		; HEX$(n)		"
	.word	LAB_BHSS-1		; BIN$(n)		"
	.word	$0000			; BITTST()	none
	.word	LAB_MMPP-1		; MAX()	process numeric expression
	.word	LAB_MMPP-1		; MIN()		"
	.word	LAB_PPBI-1		; PI		advance pointer
	.word	LAB_PPBI-1		; TWOPI		"
	.word	$0000			; VARPTR()	none
	.word	LAB_LRMS-1		; LEFT$()	process string expression
	.word	LAB_LRMS-1		; RIGHT$()		"
	.word	LAB_LRMS-1		; MID$()		"

; action addresses for functions

LAB_FTBL
LAB_FTBM	= LAB_FTBL+$01
	.word	LAB_SGN-1		; SGN()
	.word	LAB_INT-1		; INT()
	.word	LAB_ABS-1		; ABS()
	.word	LAB_USR-1		; USR()
	.word	LAB_FRE-1		; FRE()
	.word	LAB_POS-1		; POS()
	.word	LAB_SQR-1		; SQR()
	.word	LAB_RND-1		; RND()		modified function
	.word	LAB_LOG-1		; LOG()
	.word	LAB_EXP-1		; EXP()
	.word	LAB_COS-1		; COS()
	.word	LAB_SIN-1		; SIN()
	.word	LAB_TAN-1		; TAN()
	.word	LAB_ATN-1		; ATN()
	.word	LAB_PEEK-1		; PEEK()
	.word	LAB_DEEK-1		; DEEK()		new function
	.word	LAB_SADD-1		; SADD()		new function
	.word	LAB_LENS-1		; LEN()
	.word	LAB_STRS-1		; STR$()
	.word	LAB_VAL-1		; VAL()
	.word	LAB_ASC-1		; ASC()
	.word	LAB_UCASE-1		; UCASE$()		new function
	.word	LAB_LCASE-1		; LCASE$()		new function
	.word	LAB_CHRS-1		; CHR$()
	.word	LAB_HEXS-1		; HEX$()		new function
	.word	LAB_BINS-1		; BIN$()		new function
	.word	LAB_BTST-1		; BITTST()		new function
	.word	LAB_MAX-1		; MAX()		new function
	.word	LAB_MIN-1		; MIN()		new function
	.word	LAB_PI-1		; PI			new function
	.word	LAB_TWOPI-1		; TWOPI		new function
	.word	LAB_VARPTR-1	; VARPTR()		new function
	.word	LAB_LEFT-1		; LEFT$()
	.word	LAB_RIGHT-1		; RIGHT$()
	.word	LAB_MIDS-1		; MID$()

; hierarchy and action addresses for operator

LAB_OPPT
	.byte	$79			; +
	.word	LAB_ADD-1
	.byte	$79			; -
	.word	LAB_SUBTRACT-1
	.byte	$7B			; *
	.word	LAB_MULTIPLY-1
	.byte	$7B			; /
	.word	LAB_DIVIDE-1
	.byte	$7F			; ^
	.word	LAB_POWER-1
	.byte	$50			; AND
	.word	LAB_AND-1
	.byte	$46			; EOR			new operator
	.word	LAB_EOR-1
	.byte	$46			; OR
	.word	LAB_OR-1
	.byte	$56			; >>			new operator
	.word	LAB_RSHIFT-1
	.byte	$56			; <<			new operator
	.word	LAB_LSHIFT-1
	.byte	$7D			; >
	.word	LAB_GTHAN-1
	.byte	$5A			; =
	.word	LAB_EQUAL-1
	.byte	$64			; <
	.word	LAB_LTHAN-1

; keywords start with ..
; this is the first character table and must be in alphabetic order

TAB_1STC
	.byte	"*"
	.byte	"+"
	.byte	"-"
	.byte	"/"
	.byte	"<"
	.byte	"="
	.byte	">"
	.byte	"?"
	.byte	"A"
	.byte	"B"
	.byte	"C"
	.byte	"D"
	.byte	"E"
	.byte	"F"
	.byte	"G"
	.byte	"H"
	.byte	"I"
	.byte	"L"
	.byte	"M"
	.byte	"N"
	.byte	"O"
	.byte	"P"
	.byte	"R"
	.byte	"S"
	.byte	"T"
	.byte	"U"
	.byte	"V"
	.byte	"W"
	.byte	"^"
	.byte	$00			; table terminator

; pointers to keyword tables

TAB_CHRT
	.word	TAB_STAR		; table for "*"
	.word	TAB_PLUS		; table for "+"
	.word	TAB_MNUS		; table for "-"
	.word	TAB_SLAS		; table for "/"
	.word	TAB_LESS		; table for "<"
	.word	TAB_EQUL		; table for "="
	.word	TAB_MORE		; table for ">"
	.word	TAB_QEST		; table for "?"
	.word	TAB_ASCA		; table for "A"
	.word	TAB_ASCB		; table for "B"
	.word	TAB_ASCC		; table for "C"
	.word	TAB_ASCD		; table for "D"
	.word	TAB_ASCE		; table for "E"
	.word	TAB_ASCF		; table for "F"
	.word	TAB_ASCG		; table for "G"
	.word	TAB_ASCH		; table for "H"
	.word	TAB_ASCI		; table for "I"
	.word	TAB_ASCL		; table for "L"
	.word	TAB_ASCM		; table for "M"
	.word	TAB_ASCN		; table for "N"
	.word	TAB_ASCO		; table for "O"
	.word	TAB_ASCP		; table for "P"
	.word	TAB_ASCR		; table for "R"
	.word	TAB_ASCS		; table for "S"
	.word	TAB_ASCT		; table for "T"
	.word	TAB_ASCU		; table for "U"
	.word	TAB_ASCV		; table for "V"
	.word	TAB_ASCW		; table for "W"
	.word	TAB_POWR		; table for "^"

; tables for each start character, note if a longer keyword with the same start
; letters as a shorter one exists then it must come first, else the list is in
; alphabetical order as follows ..

; [keyword,token
; [keyword,token]]
; end marker (#$00)

TAB_STAR
	.byte TK_MUL,$00		; *
TAB_PLUS
	.byte TK_PLUS,$00		; +
TAB_MNUS
	.byte TK_MINUS,$00	; -
TAB_SLAS
	.byte TK_DIV,$00		; /
TAB_LESS
LBB_LSHIFT
	.byte	"<",TK_LSHIFT	; <<	note - "<<" must come before "<"
	.byte TK_LT			; <
	.byte	$00
TAB_EQUL
	.byte TK_EQUAL,$00	; =
TAB_MORE
LBB_RSHIFT
	.byte	">",TK_RSHIFT	; >>	note - ">>" must come before ">"
	.byte TK_GT			; >
	.byte	$00
TAB_QEST
	.byte TK_PRINT,$00	; ?
TAB_ASCA
LBB_ABS
	.byte	"BS(",TK_ABS	; ABS(
LBB_AND
	.byte	"ND",TK_AND		; AND
LBB_ASC
	.byte	"SC(",TK_ASC	; ASC(
LBB_ATN
	.byte	"TN(",TK_ATN	; ATN(
	.byte	$00
TAB_ASCB
LBB_BINS
	.byte	"IN$(",TK_BINS	; BIN$(
LBB_BITCLR
	.byte	"ITCLR",TK_BITCLR	; BITCLR
LBB_BITSET
	.byte	"ITSET",TK_BITSET	; BITSET
LBB_BITTST
	.byte	"ITTST(",TK_BITTST
					; BITTST(
LBB_BYE
	.byte "YE", TK_BYE    ; BYE
	.byte	$00
TAB_ASCC
LBB_CALL
	.byte	"ALL",TK_CALL	; CALL
LBB_CHRS
	.byte	"HR$(",TK_CHRS	; CHR$(
LBB_CLEAR
	.byte	"LEAR",TK_CLEAR	; CLEAR
LBB_CONT
	.byte	"ONT",TK_CONT	; CONT
LBB_COS
	.byte	"OS(",TK_COS	; COS(
	.byte	$00
TAB_ASCD
LBB_DATA
	.byte	"ATA",TK_DATA	; DATA
LBB_DEC
	.byte	"EC",TK_DEC		; DEC
LBB_DEEK
	.byte	"EEK(",TK_DEEK	; DEEK(
LBB_DEF
	.byte	"EF",TK_DEF		; DEF
LBB_DIM
	.byte	"IM",TK_DIM		; DIM
LBB_DOKE
	.byte	"OKE",TK_DOKE	; DOKE note - "DOKE" must come before "DO"
LBB_DO
	.byte	"O",TK_DO		; DO
	.byte	$00
TAB_ASCE
LBB_ELSE
	.byte	"LSE",TK_ELSE	; ELSE
LBB_END
	.byte	"ND",TK_END		; END
LBB_EOR
	.byte	"OR",TK_EOR		; EOR
LBB_EXP
	.byte	"XP(",TK_EXP	; EXP(
	.byte	$00
TAB_ASCF
LBB_FN
	.byte	"N",TK_FN		; FN
LBB_FOR
	.byte	"OR",TK_FOR		; FOR
LBB_FRE
	.byte	"RE(",TK_FRE	; FRE(
	.byte	$00
TAB_ASCG
LBB_GET
	.byte	"ET",TK_GET		; GET
LBB_GOSUB
	.byte	"OSUB",TK_GOSUB	; GOSUB
LBB_GOTO
	.byte	"OTO",TK_GOTO	; GOTO
	.byte	$00
TAB_ASCH
LBB_HEXS
	.byte	"EX$(",TK_HEXS	; HEX$(
	.byte	$00
TAB_ASCI
LBB_IF
	.byte	"F",TK_IF		; IF
LBB_INC
	.byte	"NC",TK_INC		; INC
LBB_INPUT
	.byte	"NPUT",TK_INPUT	; INPUT
LBB_INT
	.byte	"NT(",TK_INT	; INT(
LBB_IRQ
	.byte	"RQ",TK_IRQ		; IRQ
	.byte	$00
TAB_ASCL
LBB_LCASES
	.byte	"CASE$(",TK_LCASES
					; LCASE$(
LBB_LEFTS
	.byte	"EFT$(",TK_LEFTS	; LEFT$(
LBB_LEN
	.byte	"EN(",TK_LEN	; LEN(
LBB_LET
	.byte	"ET",TK_LET		; LET
LBB_LIST
	.byte	"IST",TK_LIST	; LIST
LBB_LOAD
	.byte	"OAD",TK_LOAD	; LOAD
LBB_LOG
	.byte	"OG(",TK_LOG	; LOG(
LBB_LOOP
	.byte	"OOP",TK_LOOP	; LOOP
	.byte	$00
TAB_ASCM
LBB_MAX
	.byte	"AX(",TK_MAX	; MAX(
LBB_MIDS
	.byte	"ID$(",TK_MIDS	; MID$(
LBB_MIN
	.byte	"IN(",TK_MIN	; MIN(
	.byte	$00
TAB_ASCN
LBB_NEW
	.byte	"EW",TK_NEW		; NEW
LBB_NEXT
	.byte	"EXT",TK_NEXT	; NEXT
LBB_NMI
	.byte	"MI",TK_NMI		; NMI
LBB_NOT
	.byte	"OT",TK_NOT		; NOT
LBB_NULL
	.byte	"ULL",TK_NULL	; NULL
	.byte	$00
TAB_ASCO
LBB_OFF
	.byte	"FF",TK_OFF		; OFF
LBB_ON
	.byte	"N",TK_ON		; ON
LBB_OR
	.byte	"R",TK_OR		; OR
	.byte	$00
TAB_ASCP
LBB_PEEK
	.byte	"EEK(",TK_PEEK	; PEEK(
LBB_PI
	.byte	"I",TK_PI		; PI
LBB_POKE
	.byte	"OKE",TK_POKE	; POKE
LBB_POS
	.byte	"OS(",TK_POS	; POS(
LBB_PRINT
	.byte	"RINT",TK_PRINT	; PRINT
	.byte	$00
TAB_ASCR
LBB_READ
	.byte	"EAD",TK_READ	; READ
LBB_REM
	.byte	"EM",TK_REM		; REM
LBB_RESTORE
	.byte	"ESTORE",TK_RESTORE
					; RESTORE
LBB_RETIRQ
	.byte	"ETIRQ",TK_RETIRQ	; RETIRQ
LBB_RETNMI
	.byte	"ETNMI",TK_RETNMI	; RETNMI
LBB_RETURN
	.byte	"ETURN",TK_RETURN	; RETURN
LBB_RIGHTS
	.byte	"IGHT$(",TK_RIGHTS
					; RIGHT$(
LBB_RND
	.byte	"ND(",TK_RND	; RND(
LBB_RUN
	.byte	"UN",TK_RUN		; RUN
	.byte	$00
TAB_ASCS
LBB_SADD
	.byte	"ADD(",TK_SADD	; SADD(
LBB_SAVE
	.byte	"AVE",TK_SAVE	; SAVE
LBB_SGN
	.byte	"GN(",TK_SGN	; SGN(
LBB_SIN
	.byte	"IN(",TK_SIN	; SIN(
LBB_SPC
	.byte	"PC(",TK_SPC	; SPC(
LBB_SQR
	.byte	"QR(",TK_SQR	; SQR(
LBB_STEP
	.byte	"TEP",TK_STEP	; STEP
LBB_STOP
	.byte	"TOP",TK_STOP	; STOP
LBB_STRS
	.byte	"TR$(",TK_STRS	; STR$(
LBB_SWAP
	.byte	"WAP",TK_SWAP	; SWAP
	.byte	$00
TAB_ASCT
LBB_TAB
	.byte	"AB(",TK_TAB	; TAB(
LBB_TAN
	.byte	"AN(",TK_TAN	; TAN(
LBB_THEN
	.byte	"HEN",TK_THEN	; THEN
LBB_TO
	.byte	"O",TK_TO		; TO
LBB_TWOPI
	.byte	"WOPI",TK_TWOPI	; TWOPI
	.byte	$00
TAB_ASCU
LBB_UCASES
	.byte	"CASE$(",TK_UCASES
					; UCASE$(
LBB_UNTIL
	.byte	"NTIL",TK_UNTIL	; UNTIL
LBB_USR
	.byte	"SR(",TK_USR	; USR(
	.byte	$00
TAB_ASCV
LBB_VAL
	.byte	"AL(",TK_VAL	; VAL(
LBB_VPTR
	.byte	"ARPTR(",TK_VPTR	; VARPTR(
	.byte	$00
TAB_ASCW
LBB_WAIT
	.byte	"AIT",TK_WAIT	; WAIT
LBB_WHILE
	.byte	"HILE",TK_WHILE	; WHILE
LBB_WIDTH
	.byte	"IDTH",TK_WIDTH	; WIDTH
	.byte	$00
TAB_POWR
	.byte	TK_POWER,$00	; ^

; new decode table for LIST
; Table is ..
; byte - keyword length, keyword first character
; word - pointer to rest of keyword from dictionary

; note if length is 1 then the pointer is ignored

LAB_KEYT
	.byte	3,'E'
	.word	LBB_END		; END
	.byte	3,'F'
	.word	LBB_FOR		; FOR
	.byte	4,'N'
	.word	LBB_NEXT		; NEXT
	.byte	4,'D'
	.word	LBB_DATA		; DATA
	.byte	5,'I'
	.word	LBB_INPUT		; INPUT
	.byte	3,'D'
	.word	LBB_DIM		; DIM
	.byte	4,'R'
	.word	LBB_READ		; READ
	.byte	3,'L'
	.word	LBB_LET		; LET
	.byte	3,'D'
	.word	LBB_DEC		; DEC
	.byte	4,'G'
	.word	LBB_GOTO		; GOTO
	.byte	3,'R'
	.word	LBB_RUN		; RUN
	.byte	2,'I'
	.word	LBB_IF		; IF
	.byte	7,'R'
	.word	LBB_RESTORE		; RESTORE
	.byte	5,'G'
	.word	LBB_GOSUB		; GOSUB
	.byte	6,'R'
	.word	LBB_RETIRQ		; RETIRQ
	.byte	6,'R'
	.word	LBB_RETNMI		; RETNMI
	.byte	6,'R'
	.word	LBB_RETURN		; RETURN
	.byte	3,'R'
	.word	LBB_REM		; REM
	.byte	4,'S'
	.word	LBB_STOP		; STOP
	.byte	2,'O'
	.word	LBB_ON		; ON
	.byte	4,'N'
	.word	LBB_NULL		; NULL
	.byte	3,'I'
	.word	LBB_INC		; INC
	.byte	4,'W'
	.word	LBB_WAIT		; WAIT
	.byte	4,'L'
	.word	LBB_LOAD		; LOAD
	.byte	4,'S'
	.word	LBB_SAVE		; SAVE
	.byte	3,'D'
	.word	LBB_DEF		; DEF
	.byte	4,'P'
	.word	LBB_POKE		; POKE
	.byte	4,'D'
	.word	LBB_DOKE		; DOKE
	.byte	4,'C'
	.word	LBB_CALL		; CALL
	.byte	2,'D'
	.word	LBB_DO		; DO
	.byte	4,'L'
	.word	LBB_LOOP		; LOOP
	.byte	5,'P'
	.word	LBB_PRINT		; PRINT
	.byte	4,'C'
	.word	LBB_CONT		; CONT
	.byte	4,'L'
	.word	LBB_LIST		; LIST
	.byte	5,'C'
	.word	LBB_CLEAR		; CLEAR
	.byte	3,'N'
	.word	LBB_NEW		; NEW
	.byte	5,'W'
	.word	LBB_WIDTH		; WIDTH
	.byte	3,'G'
	.word	LBB_GET		; GET
	.byte	4,'S'
	.word	LBB_SWAP		; SWAP
	.byte	6,'B'
	.word	LBB_BITSET		; BITSET
	.byte	6,'B'
	.word	LBB_BITCLR		; BITCLR
	.byte	3,'I'
	.word	LBB_IRQ		; IRQ
	.byte	3,'N'
	.word	LBB_NMI		; NMI
	.byte	3,'B'
	.word	LBB_BYE		; BYE

; secondary commands (can't start a statement)

	.byte	4,'T'
	.word	LBB_TAB		; TAB
	.byte	4,'E'
	.word	LBB_ELSE		; ELSE
	.byte	2,'T'
	.word	LBB_TO		; TO
	.byte	2,'F'
	.word	LBB_FN		; FN
	.byte	4,'S'
	.word	LBB_SPC		; SPC
	.byte	4,'T'
	.word	LBB_THEN		; THEN
	.byte	3,'N'
	.word	LBB_NOT		; NOT
	.byte	4,'S'
	.word	LBB_STEP		; STEP
	.byte	5,'U'
	.word	LBB_UNTIL		; UNTIL
	.byte	5,'W'
	.word	LBB_WHILE		; WHILE
	.byte	3,'O'
	.word	LBB_OFF		; OFF

; opperators

	.byte	1,'+'
	.word	$0000			; +
	.byte	1,'-'
	.word	$0000			; -
	.byte	1,'*'
	.word	$0000			; *
	.byte	1,'/'
	.word	$0000			; /
	.byte	1,'^'
	.word	$0000			; ^
	.byte	3,'A'
	.word	LBB_AND		; AND
	.byte	3,'E'
	.word	LBB_EOR		; EOR
	.byte	2,'O'
	.word	LBB_OR		; OR
	.byte	2,'>'
	.word	LBB_RSHIFT		; >>
	.byte	2,'<'
	.word	LBB_LSHIFT		; <<
	.byte	1,'>'
	.word	$0000			; >
	.byte	1,'='
	.word	$0000			; =
	.byte	1,'<'
	.word	$0000			; <

; functions

	.byte	4,'S'			;
	.word	LBB_SGN		; SGN
	.byte	4,'I'			;
	.word	LBB_INT		; INT
	.byte	4,'A'			;
	.word	LBB_ABS		; ABS
	.byte	4,'U'			;
	.word	LBB_USR		; USR
	.byte	4,'F'			;
	.word	LBB_FRE		; FRE
	.byte	4,'P'			;
	.word	LBB_POS		; POS
	.byte	4,'S'			;
	.word	LBB_SQR		; SQR
	.byte	4,'R'			;
	.word	LBB_RND		; RND
	.byte	4,'L'			;
	.word	LBB_LOG		; LOG
	.byte	4,'E'			;
	.word	LBB_EXP		; EXP
	.byte	4,'C'			;
	.word	LBB_COS		; COS
	.byte	4,'S'			;
	.word	LBB_SIN		; SIN
	.byte	4,'T'			;
	.word	LBB_TAN		; TAN
	.byte	4,'A'			;
	.word	LBB_ATN		; ATN
	.byte	5,'P'			;
	.word	LBB_PEEK		; PEEK
	.byte	5,'D'			;
	.word	LBB_DEEK		; DEEK
	.byte	5,'S'			;
	.word	LBB_SADD		; SADD
	.byte	4,'L'			;
	.word	LBB_LEN		; LEN
	.byte	5,'S'			;
	.word	LBB_STRS		; STR$
	.byte	4,'V'			;
	.word	LBB_VAL		; VAL
	.byte	4,'A'			;
	.word	LBB_ASC		; ASC
	.byte	7,'U'			;
	.word	LBB_UCASES		; UCASE$
	.byte	7,'L'			;
	.word	LBB_LCASES		; LCASE$
	.byte	5,'C'			;
	.word	LBB_CHRS		; CHR$
	.byte	5,'H'			;
	.word	LBB_HEXS		; HEX$
	.byte	5,'B'			;
	.word	LBB_BINS		; BIN$
	.byte	7,'B'			;
	.word	LBB_BITTST		; BITTST
	.byte	4,'M'			;
	.word	LBB_MAX		; MAX
	.byte	4,'M'			;
	.word	LBB_MIN		; MIN
	.byte	2,'P'			;
	.word	LBB_PI		; PI
	.byte	5,'T'			;
	.word	LBB_TWOPI		; TWOPI
	.byte	7,'V'			;
	.word	LBB_VPTR		; VARPTR
	.byte	6,'L'			;
	.word	LBB_LEFTS		; LEFT$
	.byte	7,'R'			;
	.word	LBB_RIGHTS		; RIGHT$
	.byte	5,'M'			;
	.word	LBB_MIDS		; MID$

; BASIC messages, mostly error messages

LAB_BAER
	.word	ERR_NF		;$00 NEXT without FOR
	.word	ERR_SN		;$02 syntax
	.word	ERR_RG		;$04 RETURN without GOSUB
	.word	ERR_OD		;$06 out of data
	.word	ERR_FC		;$08 function call
	.word	ERR_OV		;$0A overflow
	.word	ERR_OM		;$0C out of memory
	.word	ERR_US		;$0E undefined statement
	.word	ERR_BS		;$10 array bounds
	.word	ERR_DD		;$12 double dimension array
	.word	ERR_D0		;$14 divide by 0
	.word	ERR_ID		;$16 illegal direct
	.word	ERR_TM		;$18 type mismatch
	.word	ERR_LS		;$1A long string
	.word	ERR_ST		;$1C string too complex
	.word	ERR_CN		;$1E continue error
	.word	ERR_UF		;$20 undefined function
	.word ERR_LD		;$22 LOOP without DO

; I may implement these two errors to force definition of variables and
; dimensioning of arrays before use.

;	.word ERR_UV		;$24 undefined variable

; the above error has been tested and works (see code and comments below LAB_1D8B)

;	.word ERR_UA		;$26 undimensioned array

ERR_NF	.byte	"NEXT without FOR",$00
ERR_SN	.byte	"Syntax",$00
ERR_RG	.byte	"RETURN without GOSUB",$00
ERR_OD	.byte	"Out of DATA",$00
ERR_FC	.byte	"Function call",$00
ERR_OV	.byte	"Overflow",$00
ERR_OM	.byte	"Out of memory",$00
ERR_US	.byte	"Undefined statement",$00
ERR_BS	.byte	"Array bounds",$00
ERR_DD	.byte	"Double dimension",$00
ERR_D0	.byte	"Divide by zero",$00
ERR_ID	.byte	"Illegal direct",$00
ERR_TM	.byte	"Type mismatch",$00
ERR_LS	.byte	"String too long",$00
ERR_ST	.byte	"String too complex",$00
ERR_CN	.byte	"Can't continue",$00
ERR_UF	.byte	"Undefined function",$00
ERR_LD	.byte	"LOOP without DO",$00

;ERR_UV	.byte	"Undefined variable",$00

; the above error has been tested and works (see code and comments below LAB_1D8B)

;ERR_UA	.byte	"Undimensioned array",$00

LAB_BMSG	.byte	$0D,$0A,"Break",$00
LAB_EMSG	.byte	" Error",$00
LAB_LMSG	.byte	" in line ",$00
LAB_RMSG	.byte	$0D,$0A,"Ready",$0D,$0A,$00

LAB_IMSG	.byte	" Extra ignored",$0D,$0A,$00
LAB_REDO	.byte	" Redo from start",$0D,$0A,$00

AA_end_basic

vecbrki=$0102

	org		$F000

	cpu	rtf65002
	jsr		(RequestIOFocus>>2)
	jsr		(ClearScreen>>2)
	jsr		(HomeCursor>>2)
	lda		#0		; turn off keyboard echoing
	jsr		(SetKeyboardEcho>>2)
	emm
	cpu		W65C02
	LDA	#<V__INPT
	STA VEC_IN
	LDA #>V__INPT
	STA VEC_IN+1
	LDA #<V__OUTP
	STA VEC_OUT
	LDA #>V__OUTP
	STA VEC_OUT+1
	LDA #<LOAD3
	STA VEC_LD
	LDA #>LOAD3
	STA VEC_LD+1
	LDA #<SAVE3
	STA VEC_SV
	LDA #>SAVE3
	STA VEC_SV+1
	JMP	LAB_COLD

; ===== Output character to the console from register r1
;	(Preserves all registers.)
; Does a far indirect subroutine call to native code.
;
V__OUTP:
	nat
	cpu		rtf65002
	pha
	jsr		(DisplayChar>>2)		; should not trash char
	pla
	emm
	cpu		W65C02
	and		#$FF			; set Z, N according to char in accumulator
	rts

; ===== Output character to the console from register r1
;	(Preserves all registers.)
; Does a far indirect subroutine call to native code.
;
V__OUTP816:
	nat
	cpu		rtf65002
	pha
	jsr		(DisplayChar>>2)		; should not trash char
	pla
	clc
	xce
	cpu		W65C02
	rts


; ===== Input a character from the console into register R1
; set C if a char is available
; clear C if no char is available
;	
;
V__INPT:
	nat
	cpu		rtf65002
	jsr		(KeybdGetChar>>2)
	cmp		#-1
	beq		.0001
	emm
	cpu		W65C02
	sec
	rts
.0001:
	cpu		rtf65002
	emm
	cpu		W65C02
	clc
	rts

; ===== Input a character from the console into register R1
; clear C if a char is available
; set C if no char is available
;	
;
V__INPT816:
	nat
	cpu		rtf65002
	jsr		(KeybdGetChar>>2)
	cmp		#-1
	beq		.001
	clc
	xce
	cpu		W65C02
	clc
	rts
.001:
	cpu		rtf65002
	clc
	xce
	cpu		W65C02
	sec
	rts

Resched816:
	nat
	cpu		rtf65002
	int		#2
	clc
	xce
	cpu		W65C816S
	rts

;*
;* ===== Input a character from the host into register r1 (or
;*	return Zero status if there's no character available).
;*
	cpu		rtf65002
AUXIN_INIT:
	stz		INPNDX
	lda		#FILENAME
	ldx		#FILEBUF<<2
	ldy		#$3800			; max length
	jsr		(LoadFile>>2)
	rts

	cpu		W65C02
AUXIN:
	nat
	cpu		RTF65002
	phx
	ldx		INPNDX
	lb		r1,FILEBUF<<2,x
	cmp		#$1A			; end of file ?
	bne		AUXIN1
	sec
	xce
	cpu		W65C02
	; restore the regular output
	lda		$E0
	sta		VEC_IN
	lda		$E1
	sta		VEC_IN+1
	lda		#$0D
	sec
	rts
	cpu		RTF65002
AUXIN1:
	inx
	stx		INPNDX
	plx
	emm
	cpu		W65C02
	sec
	rts
	
; ===== Output character to the host (Port 2) from register r1
;	(Preserves all registers.)
;
AUXOUT_INIT:
	stz		OUTNDX
	rts

AUXOUT:
	cpu		W65C02
	nat
	cpu		RTF65002
	phx
	ldx		OUTNDX
	sb		r1,FILEBUF<<2,x
	inx
	stx		OUTNDX
	plx
	emm
	cpu		W65C02
	rts

	cpu		RTF65002
AUXOUT_FLUSH:
	lda		#FILENAME
	ldx		#FILEBUF<<2
	ldy		OUTNDX
	jsr		(SaveFile>>2)
	rts

LOAD3:
	jsr		LAB_EVEZ		; get a string parameter
	lda		Dtypef
	bpl		LOAD4
	ldy		#0
	lda		(des_pl),y
	sta		str_ln
	iny
	lda		(des_pl),y
	sta		str_pl
	iny
	lda		(des_ph),y
	sta		str_ph
	nat
	cpu		RTF65002
	lb		r4,str_ph		; r4 = pointer to file name
	asl		r4,r4,#8
	orb		r4,r4,str_pl
	lda		#8				; 8 words to zero out
	ldx		#0				; the value we want to use
	ldy		#FILENAME		; the target address
	stos					; zap the memory
	lda		str_ln			; number of bytes to move
	ld		r2,r4			; x = source
	ldy		#FILENAME		; y = dest
LOAD2:
	lb		r4,0,r2
	sb		r4,0,r3
	inx
	iny
	dea
	bne		LOAD2
	jsr		AUXIN_INIT		; initialize for file input (get the file)
	emm
	cpu		W65C02
	; Save off the output vector and switch output to the
	; auxiallry output routine.
	sei
	lda		VEC_IN		; save off the output vector to $E0
	sta		$E0
	lda		VEC_IN+1
	sta		$E1
	lda		#<AUXIN		; switch to the file output routine
	sta		VEC_IN
	lda		#>AUXIN
	sta		VEC_IN+1
	jsr		LAB_22B6		; pop string descriptor from stack
LOAD4:
	rts

SAVE3:
	JSR		LAB_EVEZ	; get string parameter
	lda		Dtypef
	bpl		SAVE4		; branch if not a string
	ldy		#0
	lda		(des_pl),y
	sta		str_ln
	iny
	lda		(des_pl),y
	sta		str_pl
	iny
	lda		(des_ph),y
	sta		str_ph
	nat
	cpu		RTF65002
	jsr		AUXOUT_INIT		; initialize for file output
	lb		r4,str_ph		; r4 = pointer to file name
	asl		r4,r4,#8
	orb		r4,r4,str_pl
	lda		#8				; 8 words to zero out
	ldx		#0				; the value we want to use
	ldy		#FILENAME		; the target address
	stos					; zap the memory
	lda		str_ln			; number of bytes to move
	ld		r2,r4			; x = source
	ldy		#FILENAME		; y = dest
SAVE2:
	lb		r4,0,r2
	sb		r4,0,r3
	inx
	iny
	dea
	bne		SAVE2

	emm
	cpu		W65C02
	; Save off the output vector and switch output to the
	; auxiallry output routine.
	sei
	lda		VEC_OUT		; save off the output vector to $E0
	sta		$E0
	lda		VEC_OUT+1
	sta		$E1
	lda		#<AUXOUT	; switch to the file output routine
	sta		VEC_OUT
	lda		#>AUXOUT
	sta		VEC_OUT+1
	; Invoke the LIST command
	lda		#0
	jsr		LAB_LIST
	lda		#$1A		; spit out end-of-file marker
	jsr		AUXOUT
	; restore the regular output
	lda		$E0
	sta		VEC_OUT
	lda		$E1
	sta		VEC_OUT+1
	nat
	cpu		RTF65002
	jsr		AUXOUT_FLUSH
	emm
	cpu		W65C02
	jsr		LAB_22B6	; pop string descriptor from stack
SAVE4:
	rts
	
	cpu		rtf65002
outchar:
	jsr		(DisplayChar>>2)		; should not trash char
	rts
	cpu		rtf65002

ICacheIA816:
	nat
	jsr		(ICacheInvalidateAll>>2)
	emm816
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------	

ICacheIL816:
	nat
	jsr		(ICacheInvalidateLine>>2)
	emm816
	rts

;==============================================================================
;==============================================================================
SPIMASTER	EQU		0xFFDC0500
SPI_MASTER_VERSION_REG	EQU	0x00
SPI_MASTER_CONTROL_REG	EQU	0x01
SPI_TRANS_TYPE_REG	EQU		0x02
SPI_TRANS_CTRL_REG	EQU		0x03
SPI_TRANS_STATUS_REG	EQU	0x04
SPI_TRANS_ERROR_REG		EQU	0x05
SPI_DIRECT_ACCESS_DATA_REG		EQU	0x06
SPI_SD_SECT_7_0_REG		EQU	0x07
SPI_SD_SECT_15_8_REG	EQU	0x08
SPI_SD_SECT_23_16_REG	EQU	0x09
SPI_SD_SECT_31_24_REG	EQU	0x0a
SPI_RX_FIFO_DATA_REG	EQU	0x10
SPI_RX_FIFO_DATA_COUNT_MSB	EQU	0x12
SPI_RX_FIFO_DATA_COUNT_LSB  EQU 0x13
SPI_RX_FIFO_CTRL_REG		EQU	0x14
SPI_TX_FIFO_DATA_REG	EQU	0x20
SPI_TX_FIFO_CTRL_REG	EQU	0x24
SPI_RESP_BYTE1			EQU	0x30
SPI_RESP_BYTE2			EQU	0x31
SPI_RESP_BYTE3			EQU	0x32
SPI_RESP_BYTE4			EQU	0x33
SPI_INIT_SD			EQU		0x01
SPI_TRANS_START		EQU		0x01
SPI_TRANS_BUSY		EQU		0x01
SPI_INIT_NO_ERROR	EQU		0x00
SPI_READ_NO_ERROR	EQU		0x00
SPI_WRITE_NO_ERROR	EQU		0x00
RW_READ_SD_BLOCK	EQU		0x02
RW_WRITE_SD_BLOCK	EQU		0x03
;
; Initialize the SD card
; Returns
; acc = 0 if successful, 1 otherwise
; Z=1 if successful, otherwise Z=0
;
message "spi_init"
spi_init
	lda		#SPI_INIT_SD
	sta		SPIMASTER+SPI_TRANS_TYPE_REG
	lda		#SPI_TRANS_START
	sta		SPIMASTER+SPI_TRANS_CTRL_REG
	nop
spi_init1
	lda		SPIMASTER+SPI_TRANS_STATUS_REG
	nop
	nop
	cmp		#SPI_TRANS_BUSY
	beq		spi_init1
	lda		SPIMASTER+SPI_TRANS_ERROR_REG
	and		#3
	cmp		#SPI_INIT_NO_ERROR
	bne		spi_error
;	lda		#spi_init_ok_msg
;	jsr		DisplayStringB
	lda		#0
	rts
spi_error
;	jsr		DisplayByte
;	lda		#spi_init_error_msg
;	jsr		DisplayStringB
;	lda		SPIMASTER+SPI_RESP_BYTE1
;	jsr		DisplayByte
;	lda		SPIMASTER+SPI_RESP_BYTE2
;	jsr		DisplayByte
;	lda		SPIMASTER+SPI_RESP_BYTE3
;	jsr		DisplayByte
;	lda		SPIMASTER+SPI_RESP_BYTE4
;	jsr		DisplayByte
	lda		#1
	rts

spi_delay:
	nop
	nop
	rts


; SPI read sector
;
; r1= sector number to read
; r2= address to place read data
; Returns:
; r1 = 0 if successful
;
spi_read_sector:
	phx
	phy
	push	r4
	
	sta		SPIMASTER+SPI_SD_SECT_7_0_REG
	lsr		r1,r1,#8
	sta		SPIMASTER+SPI_SD_SECT_15_8_REG
	lsr		r1,r1,#8
	sta		SPIMASTER+SPI_SD_SECT_23_16_REG
	lsr		r1,r1,#8
	sta		SPIMASTER+SPI_SD_SECT_31_24_REG

	ld		r4,#20	; retry count

spi_read_retry:
	; Force the reciever fifo to be empty, in case a prior error leaves it
	; in an unknown state.
	lda		#1
	sta		SPIMASTER+SPI_RX_FIFO_CTRL_REG

	lda		#RW_READ_SD_BLOCK
	sta		SPIMASTER+SPI_TRANS_TYPE_REG
	lda		#SPI_TRANS_START
	sta		SPIMASTER+SPI_TRANS_CTRL_REG
	nop
spi_read_sect1:
	lda		SPIMASTER+SPI_TRANS_STATUS_REG
	jsr		spi_delay			; just a delay between consecutive status reg reads
	cmp		#SPI_TRANS_BUSY
	beq		spi_read_sect1
	lda		SPIMASTER+SPI_TRANS_ERROR_REG
	lsr
	lsr
	and		#3
	cmp		#SPI_READ_NO_ERROR
	bne		spi_read_error
	ldy		#512		; read 512 bytes from fifo
spi_read_sect2:
	lda		SPIMASTER+SPI_RX_FIFO_DATA_REG
	sb		r1,0,x
	inx
	dey
	bne		spi_read_sect2
	lda		#0
	bra		spi_read_ret
spi_read_error:
	dec		r4
	bne		spi_read_retry
;	jsr		DisplayByte
;	lda		#spi_read_error_msg
;	jsr		DisplayStringB
	lda		#1
spi_read_ret:
	pop		r4
	ply
	plx
	rts

; SPI write sector
;
; r1= sector number to write
; r2= address to get data from
; Returns:
; r1 = 0 if successful
;
spi_write_sector:
	phx
	phy
	pha
	; Force the transmitter fifo to be empty, in case a prior error leaves it
	; in an unknown state.
	lda		#1
	sta		SPIMASTER+SPI_TX_FIFO_CTRL_REG
	nop			; give I/O time to respond
	nop

	; now fill up the transmitter fifo
	ldy		#512
spi_write_sect1:
	lb		r1,0,x
	sta		SPIMASTER+SPI_TX_FIFO_DATA_REG
	nop			; give the I/O time to respond
	nop
	inx
	dey
	bne		spi_write_sect1

	; set the sector number in the spi master address registers
	pla
	sta		SPIMASTER+SPI_SD_SECT_7_0_REG
	lsr		r1,r1,#8
	sta		SPIMASTER+SPI_SD_SECT_15_8_REG
	lsr		r1,r1,#8
	sta		SPIMASTER+SPI_SD_SECT_23_16_REG
	lsr		r1,r1,#8
	sta		SPIMASTER+SPI_SD_SECT_31_24_REG

	; issue the write command
	lda		#RW_WRITE_SD_BLOCK
	sta		SPIMASTER+SPI_TRANS_TYPE_REG
	lda		#SPI_TRANS_START
	sta		SPIMASTER+SPI_TRANS_CTRL_REG
	nop
spi_write_sect2:
	lda		SPIMASTER+SPI_TRANS_STATUS_REG
	nop							; just a delay between consecutive status reg reads
	nop
	cmp		#SPI_TRANS_BUSY
	beq		spi_write_sect2
	lda		SPIMASTER+SPI_TRANS_ERROR_REG
	lsr		r1,r1,#4
	and		#3
	cmp		#SPI_WRITE_NO_ERROR
	bne		spi_write_error
	lda		#0
	bra		spi_write_ret
spi_write_error:
;	jsr		DisplayByte
;	lda		#spi_write_error_msg
;	jsr		DisplayStringB
	lda		#1

spi_write_ret:
	ply
	plx
	rts


	cpu		W65C816S
brk_rout:
	phb				          ;save DB
	phd			              ;save DP
	rep		#%00110000        ;16 bit registers
	pha
	phx
	phy
	jmp		(vecbrki)         ;indirect vector
brk1:
	rep		#%00110000        ;16 bit registers
	ply
	plx
	pla
	pld
	plb
	rti

	cpu	W65C02
	org		$F400
	jmp		V__INPT816
	jmp		LAB_BYE
	jmp		V__OUTP816
	jmp		Resched816

	cpu		RTF65002
	org		$F500
	jsr		(RequestIOFocus>>2)
	jsr		(ClearScreen>>2)
	jsr		(HomeCursor>>2)
	lda		#0		; turn off keyboard echoing
	jsr		(SetKeyboardEcho>>2)
;	trs		r0,cc	; turn caches off
	clc
	xce
	cpu		W65C816S
	rep		#%00110000	        ;16 bit registers
	mem		16
	ndx		16
	lda		#brk1				; initialize the break routine vector
	sta		vecbrki
	jmp		$008000

	org		$FFE6
	dw		brk_rout

