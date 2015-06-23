; ============================================================================
;        __
;   \\__/ o\    (C) 2012-2013  Robert Finch, Stratford
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

EX_IRQ	EQU	449

DATA_PRESENT	EQU	0x01		; there is data preset at the serial port bc_uart3
XMIT_NOT_FULL	EQU	0x20

BUFLEN	EQU	80	;	length of keyboard input buffer

; Initial stack tops for contexts
; Each context gets 1k from the special 16k startup stack memory
;
STACKTOP0	EQU		0xFFFF_FFFF_FFFE_FFF8
STACKTOP1	EQU		0xFFFF_FFFF_FFFE_FBF8
STACKTOP2	EQU		0xFFFF_FFFF_FFFE_F7F8
STACKTOP3	EQU		0xFFFF_FFFF_FFFE_F3F8
STACKTOP4	EQU		0xFFFF_FFFF_FFFE_EFF8
STACKTOP5	EQU		0xFFFF_FFFF_FFFE_EBF8
STACKTOP6	EQU		0xFFFF_FFFF_FFFE_E7F8
STACKTOP7	EQU		0xFFFF_FFFF_FFFE_E3F8
STACKTOP8	EQU		0xFFFF_FFFF_FFFE_DFF8
STACKTOP9	EQU		0xFFFF_FFFF_FFFE_DBF8
STACKTOP10	EQU		0xFFFF_FFFF_FFFE_D7F8
STACKTOP11	EQU		0xFFFF_FFFF_FFFE_D3F8
STACKTOP12	EQU		0xFFFF_FFFF_FFFE_CFF8
STACKTOP13	EQU		0xFFFF_FFFF_FFFE_CBF8
STACKTOP14	EQU		0xFFFF_FFFF_FFFE_C7F8
STACKTOP15	EQU		0xFFFF_FFFF_FFFE_C3F8


; BOOT ROM routines

TCBSize		EQU		0x200			; 512 bytes per TCB
TCBBase		EQU		0x00000001_00000000			; TCB pages
TCBr1		EQU		0x00
TCBr2		EQU		0x08
TCBr3		EQU		0x10
TCBr4		EQU		0x18
TCBr5		EQU		0x20
TCBr6		EQU		0x28
TCBr7		EQU		0x30
TCBr8		EQU		0x38
TCBr9		EQU		0x40
TCBr10		EQU		0x48
TCBr11		EQU		0x50
TCBr12		EQU		0x58
TCBr13		EQU		0x60
TCBr14		EQU		0x68
TCBr15		EQU		0x70
TCBr16		EQU		0x78
TCBr17		EQU		0x80
TCBr18		EQU		0x88
TCBr19		EQU		0x90
TCBr20		EQU		0x98
TCBr21		EQU		0xA0
TCBr22		EQU		0xA8
TCBr23		EQU		0xB0
TCBr24		EQU		0xB8
TCBr25		EQU		0xC0
TCBr26		EQU		0xC8
TCBr27		EQU		0xD0
TCBr28		EQU		0xD8
TCBr29		EQU		0xE0
TCBr30		EQU		0xE8
TCBr31		EQU		0xF0

SCREENGATE	EQU		0x00
KEYBDGATE	EQU		0x01
VIDEOGATE	EQU		0x02
CARDGATE	EQU		0x03
warmStart   EQU     0x1020
usrJmp      EQU     0x1028
TickIRQAddr		EQU		0x1030
TaskBlock		EQU		0x1038
Milliseconds	EQU		0x1400
Lastloc			EQU		0x1408
CharColor	EQU		0x1410
ScreenColor	EQU		0x1414
CursorRow	EQU		0x1417
CursorCol	EQU		0x1418
CursorFlash	EQU		0x141A
KeybdEcho	EQU		0x141C
KeybdBuffer	EQU		0x1440
KeybdHead	EQU		0x1450
KeybdTail	EQU		0x1451
sp_save		EQU		0x1460
lr_save		EQU		0x1468
r1_save		EQU		0x1470
r2_save		EQU		0x1478
r26_save	EQU		0x1480
Score		EQU		0x1500
Manpos		EQU		0x1508
MissileActive	EQU		0x1510
MissileX	EQU		0x1512
MissileY	EQU		0x1514
InvadersRow1	EQU		0x1520
InvadersRow2	EQU		0x1530
InvadersRow3	EQU		0x1540
InvadersRow4	EQU		0x1550
InvadersRow5	EQU		0x1560
InvadersColpos	EQU		0x1570
InvadersRowpos	EQU		0x1571
Uart_rxfifo		EQU		0x1600
Uart_rxhead		EQU		0x1800
Uart_rxtail		EQU		0x1802
Uart_ms			EQU		0x1808
Uart_rxrts		EQU		0x1809
Uart_rxdtr		EQU		0x180A
Uart_rxxon		EQU		0x180B
Uart_rxflow		EQU		0x180C
Uart_fon		EQU		0x180E
Uart_foff		EQU		0x1810
Uart_txrts		EQU		0x1812
Uart_txdtr		EQU		0x1813
Uart_txxon		EQU		0x1814
Uart_txxonoff	EQU		0x1815
TaskList		EQU		0x2000
ReadyList1		EQU		0x2000
ReadyList2		EQU		0x2020
ReadyList3		EQU		0x2040
ReadyList4		EQU		0x2060
ReadyList5		EQU		0x2080
ReadyNdx1		EQU		0x20A0
ReadyNdx2		EQU		0x20A1
ReadyNdx3		EQU		0x20A2
ReadyNdx4		EQU		0x20A3
ReadyNdx5		EQU		0x20A4
RunningTCB		EQU		0x20A6
NextToRunTCB	EQU		0x20A8
r1save			EQU		0x20B0
r2save			EQU		0x20B8
AXCstart		EQU		0x20C0

; Context startup address table
;
ctx0start		EQU		0x20D0
ctx1start		EQU		0x20D8
ctx2start		EQU		0x20E0
ctx3start		EQU		0x20E8
ctx4start		EQU		0x20F0
ctx5start		EQU		0x20F8
ctx6start		EQU		0x2100
ctx7start		EQU		0x2108
ctx8start		EQU		0x2110
ctx9start		EQU		0x2118
ctx10start		EQU		0x2120
ctx11start		EQU		0x2128
ctx12start		EQU		0x2130
ctx13start		EQU		0x2138
ctx14start		EQU		0x2140
ctx15start		EQU		0x2148
sp_saves		EQU		0x2200
sp_saves_end	EQU		0x2280
p100IRQvec		EQU		0x3000
keybdIRQvec		EQU		0x3008
serialIRQvec	EQU		0x3010
rasterIRQvec	EQU		0x3018

startSector	EQU		0x30F8
BPB			EQU		0x3100

TEXTSCR		EQU		0xD0_0000
COLORSCR	EQU		0xD1_0000
TEXTREG		EQU		0xDA_0000
TEXT_COLS	EQU		0x0
TEXT_ROWS	EQU		0x2
TEXT_CURPOS	EQU		0x16
KEYBD		EQU		0xDC_0000
KEYBDCLR	EQU		0xDC_0002

UART		EQU		0xDC_0A00
UART_LS		EQU		0xDC_0A01
UART_MS		EQU		0xDC_0A02
UART_IS		EQU		0xDC_0A03
UART_IE		EQU		0xDC_0A04
UART_MC		EQU		0xDC_0A06
DATETIME	EQU		0xDC_0400

SPIMASTER	EQU		0xDC_0500
SPI_MASTER_VERSION_REG	EQU	0x00
SPI_MASTER_CONTROL_REG	EQU	0x01
SPI_TRANS_TYPE_REG	EQU		0x02
SPI_TRANS_CTRL_REG	EQU		0x03
SPI_TRANS_STATUS_REG	EQU	0x04
SPI_TRANS_ERROR_REG		EQU	0x05
SPI_DIRECT_ACCESS_DATA_REG		EQU	0x06
SPI_SD_ADDR_7_0_REG		EQU	0x07
SPI_SD_ADDR_15_8_REG	EQU	0x08
SPI_SD_ADDR_23_16_REG	EQU	0x09
SPI_SD_ADDR_31_24_REG	EQU	0x0a
SPI_RX_FIFO_DATA_REG	EQU	0x10
SPI_RX_FIFO_DATA_COUNT_MSB	EQU	0x12
SPI_RX_FIFO_DATA_COUNT_LSB  EQU 0x13
SPI_RX_FIFO_CTRL_REG		EQU	0x14
SPI_TX_FIFO_DATA_REG	EQU	0x20
SPI_TX_FIFO_CTRL_REG	EQU	0x24
SPI_INIT_SD			EQU		0x01
SPI_TRANS_START		EQU		0x01
SPI_TRANS_BUSY		EQU		0x01
SPI_INIT_NO_ERROR	EQU		0x00
SPI_READ_NO_ERROR	EQU		0x00
RW_READ_SD_BLOCK	EQU		0x02
RW_WRITE_SD_BLOCK	EQU		0x03


PIC			EQU		0xDC_0FF0
PIC_IE		EQU		0xDC_0FF2

PSG			EQU		0xD5_0000
PSGFREQ0	EQU		0xD5_0000
PSGPW0		EQU		0xD5_0002
PSGCTRL0	EQU		0xD5_0004
PSGADSR0	EQU		0xD5_0006

SPRRAM		EQU		0xD8_0000
AC97		EQU		0xDC_1000
TMP			EQU		0xDC_0300
LED			EQU		0xDC_0600
ETHMAC		EQU		0xDC_2000
CONFIGREC	EQU		0xDC_FFFF
MIIMODER	EQU		0x28
MIIADDRESS	EQU		0x30
GACCEL		EQU		0xDA_E000
RASTERIRQ	EQU		0xDA_0100
BOOT_STACK	EQU		0xFFFF_FFFF_FFFE_FFF8
SPRITEREGS	EQU		0xDA_D000
BITMAPSCR	EQU		0x00000001_00200000

BOOTJMP		EQU		0x100800204

txempty	EQU		0x40
rxfull	EQU		0x01

;
; Internal variables follow:
;
		bss
		org		0x1048
txtWidth	db	0		; BIOS var =56
txtHeight	db	0		; BIOS var =31
cursx	db		0		; cursor x position
cursy	db		0		; cursor y position
pos		dh		0		; text screen position
charToPrint		dc		0
fgColor			db		0
bkColor			db		0
cursFlash		db		0	; flash the cursor ?

lineLinkTbl		fill.b	47,0	; screen line link table
typef   db      0   ; variable / expression type
        align   8
OSSP	dw	1	; OS value of sp
CURRNT	dw	1	;	Current line pointer
STKGOS	dw	1	;	Saves stack pointer in 'GOSUB'
STKINP	dw	1	;	Saves stack pointer during 'INPUT'
LOPVAR	dw	1	;	'FOR' loop save area
LOPINC	dw	1	;	increment
LOPLMT	dw	1	;	limit
LOPLN	dw	1	;	line number
LOPPT	dw	1	;	text pointer
TXTUNF	dw	1	;	points to unfilled text area
VARBGN	dw	1	;	points to variable area
IVARBGN dw  1   ;   points to integer variable area
SVARBGN dw  1   ;   points to string variable area
FVARBGN dw  1   ;   points to float variable area
STKBOT	dw	1	;	holds lower limit for stack growth
NUMWKA	fill.b	24,0			; numeric work area
BUFFER	fill.b	BUFLEN,0x00		;		Keyboard input buffer

        bss
        org     0x1_00600000
TXT		equ		0x1_00600000	; Beginning of program area

;	org 0x070
;	iret
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;
	code
	org 0xFFFF_FFFF_FFFF_B000

; jump table
;
	jmp		SerialGetChar
	jmp		SerialPutChar
	jmp		SetKeyboardEcho
	jmp		KeybdCheckForKey
	jmp		KeybdGetChar
	jmp		DisplayChar
	jmp		DisplayString
	jmp		DisplayNum
	jmp		CalcScreenLoc
	jmp		ClearScreen
	jmp		DisplayWord

start:
;	lea		MSGRAM,a1
;	jsr		DisplayString

ColdStart:
	icache_off				; turn on the ICache
	dcache_off				; turn on the DCache

; Make sure semaphores are available by closing the gates.
; We don't know what power up state is.

	cmgi	#KEYBDGATE
	cmgi	#VIDEOGATE

; Initialize the context startup address table with NULL

	xor		r1,r1,r1
	sw		r1,ctx0start
	sw		r1,ctx1start
	sw		r1,ctx2start
	sw		r1,ctx3start
	sw		r1,ctx4start
	sw		r1,ctx5start
	sw		r1,ctx6start
	sw		r1,ctx7start
	sw		r1,ctx8start
	sw		r1,ctx9start
	sw		r1,ctx10start
	sw		r1,ctx11start
	sw		r1,ctx12start
	sw		r1,ctx13start
	sw		r1,ctx14start
	sw		r1,ctx15start

; Initialize the context schedule with all contexts treated equally
; There are only 16 contexts, but 256 schedule slots. Each context is
; given 16 slots distributed evenly throughout the execution pattern
; table.
;
	xor		r1,r1,r1	; r1 = 0
ict1:
	mtep	r1,r1		; only the low order four bits of r1 will move to the pattern table
	addui	r1,r1,#1
	cmpi	r2,r1,#255
	bne		r2,r0,ict1

; Point the interrupt return address register of the context to the 
; context startup code. The context will start up when an interrupt return
; occurs.
;
; We cannot use a loop for this. Fortunately there's only 16 contexts.
;
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP0
	iepp
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP1
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP2
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP3
	iepp		

	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP4
	iepp
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP5
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP6
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP7
	iepp		
	
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP8
	iepp
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP9
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP10
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP11
	iepp		
	
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP12
	iepp
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP13
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP14
	iepp		
	lea		r25,ctxstart
	mtspr	IPC,r25
	lea		r30,STACKTOP15
	iepp		

; Ensure that context zero is the active context
;
ctxstart3:
	mfspr	r1,AXC			
	beq		r1,r0,ctxstart2
	iepp
	bra		ctxstart3
ctxstart2:	
	sb		r1,AXCstart		; save off the startup context which should be context zero

; Entry point for context startup
;
; Avoid repeating all the system initialization when a context starts up by testing whether
; or not the context is the starting context.
;
ctxstart:
	mfspr	r1,AXC
	lbu		r2,AXCstart
	bne		r1,r2,ctxstart1
	
;
; set system vectors
; TBA defaults to zero on reset
;
	setlo	r3,#0
	setlo	r2,#511
	lea		r1,nmirout
csj5:
	sw		r1,[r3]
	addui	r3,r3,#8
	loop	r2,csj5
	lea		r1,VideoSC		; Video BIOS vector
	sw		r1,0xCD0
	lea		r1,SCCARDSC		; SD Card BIOS vector
	sw		r1,0xCE8
	lea		r1,RTCSC		; Real time clock vector
	sw		r1,0xD00
	lea		r1,KeybdSC		; keyboard BIOS vector
	sw		r1,0xD08
	lea		r1,irqrout
	sw		r1,0xE08		; set IRQ vector
	lea		r1,ui_irout
	sw		r1,0xF78		; set unimplemented instruction vector
	lea		r1,dberr_rout
	sw		r1,0xFE0		; set Bus error vector
	lea		r1,iberr_rout
	sw		r1,0xFE8		; set Bus error vector
	lea		r1,nmirout
	sw		r1,0xFF0		; set NMI vector

; set system interrupt hook vectors

	lea		r1,KeybdIRQ
	sw		r1,keybdIRQvec
	lea		r1,Pulse100
	sw		r1,p100IRQvec
	lea		r1,SerialIRQ
	sw		r1,serialIRQvec
	lea		r1,RasterIRQfn
	sw		r1,rasterIRQvec

	;-------------------------------
	; Initialize I/O devices
	;-------------------------------
	inbu	r1,CONFIGREC
	bfext	r1,r1,#4,#4
	beq		r1,r0,skip5
	call	tmp_init
skip5:
	inbu	r1,CONFIGREC
	bfext	r1,r1,#5,#5
	beq		r1,r0,skip4
	call	SerialInit
skip4:
	call	KeybdInit
	call	PICInit
	call	SetupRasterIRQ
	cli						; enable interrupts
;	call	HelloWorld
	setlo	r3,#0xCE		; blue on blue
	sc		r3,ScreenColor
	sc		r3,CharColor
	lc		r3,0x1414
	setlo	r3,#32
	sc		r3,0x1416		; we do a store, then a load through the dcache
	lc		r2,0x1416		;
	beq		r2,r3,dcokay
	dcache_off				; data cache failed
dcokay:
	sc		r0,NextToRunTCB
	sc		r0,RunningTCB
	lw		r1,#2			; get rid of startup keyboard glitchs by trying to get a character
	syscall	#417
	lw		r1,#2			; get rid of startup keyboard glitchs by trying to get a character
	syscall	#417

	; wait for screen to be available
	call	ClearScreen
	call	ClearBmpScreen

; Test whether or not the sprite controller is present. Skip
; Initialization if it isn't.

	inb		r1,CONFIGREC
	bfext	r1,r1,#0,#0
	beq		r1,r0,skip1
	call	RandomizeSprram
skip1:

	sb		r0,CursorRow
	sb		r0,CursorCol
	lw		r1,#1
	sb		r1,CursorFlash
	lea		r1,MSGSTART
	call	DisplayStringCRLF

; Test whether or not sound generator is present
; skip initialization and beep if not present

	inb		r1,CONFIGREC
	bfext	r1,r1,#2,#2
	beq		r1,r0,skip2
	call	SetupAC97		; and Beep
	lw		r1,#4
	outb	r1,LED
	call	Beep
skip2:

	lea		r1,context1disp	; start a display
	sw		r1,ctx1start

; Startup Ethernet access ?
;
	inb		r1,CONFIGREC
	bfext	r1,r1,#1,#1
	beq		r1,r0,skip3
	lea		r1,eth_main
	sw		r1,ctx2start
skip3:

	lea		r1,RandomLines
	sw		r1,ctx3start
	call	spi_init
	bne		r1,r0,skip_spi_read
	call	spi_read_boot
	call	loadBootFile
skip_spi_read:
	jmp		Monitor

j4:
	jmp		Monitor
	bra		j4

; The contexts wait for a context startup address to be placed in the
; startup table. Once an address is in the table, a call to the context
; code will be made. The default is a NULL pointer, which
; causes the context to loop around back to here while waiting for a
; code to run.
;
ctxstart1:
	lea		r1,ctx0start	; r1 = context start table base
	mfspr	r2,AXC			; r2 = index into start table
	lw		r1,[r1+r2*8]	; r1 = context start address
	beq		r1,r0,ctx12
	jal		lr,[r1]			; perform a call to the context code

; We might as well move to the next context, since there's nothing
; to do. This can be accomplished by tirggering a IRQ interrupt.
; We can't just increment the excution pattern pointer, because that
; would only switch the register set and not the program counter.
; An interrupt saves the program counter, and restores it from the
; IPC context register.
;
ctx12:
	sei					; causes a priv violation. don't allow interrupts during syscall
	nop					; wait for sei to take effect
	nop
	nop
	syscall	#EX_IRQ	
	bra		ctxstart1

;	call	ramtest

context1disp:

; once we've started, clear the start vector so that the context
; isn't continuously restarted.
;
	sw		r0,ctx1start
	lea		r3,TEXTSCR
	lw		r1,#'V'
	lw		r2,#330
	lw		r4,#47
	call	AsciiToScreen
ctx11:
	inch	r1,[r3+r2]
	addui	r1,r1,#1
	outc	r1,[r3+r2]
	addui	r2,r2,#168
	loop	r4,ctx11
	bra		context1disp

;-----------------------------------------
; Hello World!
;-----------------------------------------
HelloWorld:
	subui	r30,r30,#24
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		lr,16[sp]
	lea		r2,MSG
j3:
	lb		r1,[r2]
	beq		r1,r0,j2
	call	SerialPutChar
	addui	r2,r2,#1
	bra		j3
j2:
	sw		lr,16[sp]
	sw		r2,8[sp]
	sw		r1,[sp]
	ret		#24


	align	16
MSG:	
	db	"Hello World!",0
MSGSTART:
	db	"Raptor64 system starting....",0

	align 16

;----------------------------------------------------------
; Initialize programmable interrupt controller (PIC)
;  0 = nmi (parity error)
;  1 = keyboard reset
;  2 = 1000Hz pulse (context switcher)
;  3 = 100Hz pulse (cursor flash)
;  4 = ethmac
;  8 = uart
; 13 = raster interrupt
; 15 = keyboard char
;----------------------------------------------------------
PICInit:
	lea		r1,PICret
	sw		r1,TickIRQAddr
	; enable: raster irq,
	setlo	r1,#0x800F	; enable nmi,kbd_rst,and kbd_irq
	; A10F enable serial IRQ
	outc	r1,PIC_IE
PICret:
	ret

;==============================================================================
; Serial port
;==============================================================================
;-----------------------------------------
; Initialize the serial port
;-----------------------------------------
;
SerialInit:
	sc		r0,Uart_rxhead		; reset buffer indexes
	sc		r0,Uart_rxtail
	setlo	r1,#0x1f0
	sc		r1,Uart_foff		; set threshold for XOFF
	setlo	r1,#0x010
	sc		r1,Uart_fon			; set threshold for XON
	setlo	r1,#1
	outb	r1,UART_IE			; enable receive interrupt only
	sb		r0,Uart_rxrts		; no RTS/CTS signals available
	sb		r0,Uart_txrts		; no RTS/CTS signals available
	sb		r0,Uart_txdtr		; no DTR signals available
	sb		r0,Uart_rxdtr		; no DTR signals available
	setlo	r1,#1
	sb		r1,Uart_txxon		; for now
	ret

;---------------------------------------------------------------------------------
; Get character directly from serial port. Blocks until a character is available.
;---------------------------------------------------------------------------------
;
SerialGetCharDirect:
sgc1:
	inb		r1,UART_LS		; uart status
	andi	r1,r1,#rxfull	; is there a char available ?
	beq		r1,r0,sgc1
	inb		r1,UART
	ret

;------------------------------------------------
; Check for a character at the serial port
; returns r1 = 1 if char available, 0 otherwise
;------------------------------------------------
;
SerialCheckForCharDirect:
	inb		r1,UART_LS		; uart status
	andi	r1,r1,#rxfull	; is there a char available ?
	sne		r1,r1,r0
	ret

;-----------------------------------------
; Put character to serial port
; r1 = char to put
;-----------------------------------------
;
SerialPutChar:
	subui	sp,sp,#32
	sw		r2,[sp]
	sw		r3,8[sp]
	sw		r4,16[sp]
	sw		r5,24[sp]
	inb		r2,UART_MC
	ori		r2,r2,#3		; assert DTR / RTS
	outb	r2,UART_MC
	lb		r2,Uart_txrts
	beq		r2,r0,spcb1
	lw		r4,Milliseconds
	setlo	r3,#100			; delay count (1 s)
spcb3:
	inb		r2,UART_MS
	andi	r2,r2,#10		; is CTS asserted ?
	bne		r2,r0,spcb1
	lw		r5,Milliseconds
	beq		r4,r5,spcb3
	mov		r4,r5
	loop	r3,spcb3
	bra		spcabort
spcb1:
	lb		r2,Uart_txdtr
	beq		r2,r0,spcb2
	lw		r4,Milliseconds
	setlo	r3,#100			; delay count
spcb4:
	inb		r2,UART_MS
	andi	r2,r2,#20		; is DSR asserted ?
	bne		r2,r0,spcb2
	lw		r5,Milliseconds
	beq		r4,r5,spcb4
	mov		r4,r5
	loop	r3,spcb4
	bra		spcabort
spcb2:	
	lb		r2,Uart_txxon
	beq		r2,r0,spcb5
spcb6:
	lb		r2,Uart_txxonoff
	beq		r2,r0,spcb5
	inb		r4,UART_MS
	andi	r4,r4,#0x80			; DCD ?
	bne		r4,r0,spcb6
spcb5:
	lw		r4,Milliseconds
	setlo	r3,#100				; wait up to 1s
spcb8:
	inb		r2,UART_LS
	andi	r2,r2,#0x20			; tx not full ?
	bne		r2,r0,spcb7
	lw		r5,Milliseconds
	beq		r4,r5,spcb8
	mov		r4,r5
	loop	r3,spcb8
	bra		spcabort
spcb7:
	outb	r1,UART
spcabort:
	lw		r2,[sp]
	lw		r3,8[sp]
	lw		r4,16[sp]
	lw		r5,24[sp]
	ret		#32

;-------------------------------------------------
; Compute number of characters in recieve buffer.
; r4 = number of chars
;-------------------------------------------------
CharsInRxBuf:
	lc		r4,Uart_rxhead
	lc		r2,Uart_rxtail
	subu	r4,r4,r2
	bgt		r4,r0,cirxb1
	setlo	r4,#0x200
	addu	r4,r4,r2
	lc		r2,Uart_rxhead
	subu	r4,r4,r2
cirxb1:
	ret

;----------------------------------------------
; Get character from rx fifo
; If the fifo is empty enough then send an XON
;----------------------------------------------
;
SerialGetChar:
	subui	sp,sp,#32
	sw		r2,[sp]
	sw		r3,8[sp]
	sw		r4,16[sp]
	sw		lr,24[sp]
	lc		r3,Uart_rxhead
	lc		r2,Uart_rxtail
	beq		r2,r3,sgcfifo1	; is there a char available ?
	lea		r3,Uart_rxfifo
	lb		r1,[r2+r3]		; get the char from the fifo into r1
	addui	r2,r2,#1		; increment the fifo pointer
	andi	r2,r2,#0x1ff
	sc		r2,Uart_rxtail
	lb		r2,Uart_rxflow	; using flow control ?
	beq		r2,r0,sgcfifo2
	lc		r3,Uart_fon		; enough space in Rx buffer ?
	call	CharsInRxBuf
	bgt		r4,r3,sgcfifo2
	sb		r0,Uart_rxflow	; flow off
	lb		r4,Uart_rxrts
	beq		r4,r0,sgcfifo3
	inb		r4,UART_MC		; set rts bit in MC
	ori		r4,r4,#2
	outb	r4,UART_MC
sgcfifo3:
	lb		r4,Uart_rxdtr
	beq		r4,r0,sgcfifo4
	inb		r4,UART_MC		; set DTR
	ori		r4,r4,#1
	outb	r4,UART_MC
sgcfifo4:
	lb		r4,Uart_rxxon
	beq		r4,r0,sgcfifo5
	setlo	r4,#XON
	outb	r4,UART
sgcfifo5:
sgcfifo2:					; return with char in r1
	lw		r2,[sp]
	lw		r3,8[sp]
	lw		r4,16[sp]
	lw		lr,24[sp]
	ret		#32
sgcfifo1:
	setlo	r1,#-1			; no char available
	lw		r2,[sp]
	lw		r3,8[sp]
	lw		r4,16[sp]
	lw		lr,24[sp]
	ret		#32

;-----------------------------------------
; Serial port IRQ
;-----------------------------------------
;
SerialIRQ:
	subui	sp,sp,#40
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		r4,24[sp]
	sw		lr,32[sp]
	inb		r1,UART_IS		; get interrupt status
	bge		r1,r0,sirq1
	andi	r1,r1,#0x7f		; switch on interrupt type
	beqi	r1,#4,srxirq
	beqi	r1,#0xC,stxirq
	beqi	r1,#0x10,smsirq
sirq1:
	lw		r1,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	lw		r4,24[sp]
	lw		lr,32[sp]
	ret		#40

; Get the modem status and record it
smsirq:
	inb		r1,UART_MS
	sb		r1,Uart_ms
	bra		sirq1

stxirq:
	bra		sirq1

; Get a character from the uart and store it in the rx fifo
srxirq:
srxirq1:
	inb		r1,UART				; get the char (clears interrupt)
	lb		r2,Uart_txxon
	beq		r2,r0,srxirq3
	bnei	r1,#XOFF,srxirq2
	setlo	r1,#1
	sb		r1,Uart_txxonoff
	bra		srxirq5
srxirq2:
	bnei	r1,#XON,srxirq3
	sb		r0,Uart_txxonoff
	bra		srxirq5
srxirq3:
	sb		r0,Uart_txxonoff
	lc		r2,Uart_rxhead
	lea		r3,Uart_rxfifo
	sb		r1,[r3+r2]			; store in buffer
	addui	r2,r2,#1
	andi	r2,r2,#0x1ff
	sc		r2,Uart_rxhead
srxirq5:
	inb		r1,UART_LS			; check for another ready character
	andi	r1,r1,#rxfull
	bne		r1,r0,srxirq1
	lb		r1,Uart_rxflow		; are we using flow controls?
	bne		r1,r0,srxirq8
	call	CharsInRxBuf
	lc		r1,Uart_foff
	blt		r4,r1,srxirq8
	setlo	r1,#1
	sb		r1,Uart_rxflow
	lb		r1,Uart_rxrts
	beq		r1,r0,srxirq6
	inb		r1,UART_MC
	andi	r1,r1,#0xFD		; turn off RTS
	outb	r1,UART_MC
srxirq6:
	lb		r1,Uart_rxdtr
	beq		r1,r0,srxirq7
	inb		r1,UART_MC
	andi	r1,r1,#0xFE		; turn off DTR
	outb	r1,UART_MC
srxirq7:
	lb		r1,Uart_rxxon
	beq		r1,r0,srxirq8
	setlo	r1,#XOFF
	outb	r1,UART
srxirq8:
	bra		sirq1

;==============================================================================
; Video BIOS
; Video interrupt #410
;
; Function in R1
; 0x02 = Set Cursor Position	r2 = row, r3 = col 
; 0x03 = Get Cursor position	returns r1 = row, r2 = col
; 0x06 = Scroll screen up
; 0x09 = Display character+attribute, r2=char, r3=attrib, r4=#times
; 0x0A = Display character, r2 = char, r3 = # times
; 0x0C = Display Pixel r2 = x, r3 = y, r4 = color
; 0x0D = Get pixel  r2 = x, r3 = y
; 0x14 = Display String	r2 = pointer to string
; 0x15 = Display number r2 = number, r3 = # digits
; 0x16 = Display String + CRLF   r2 = pointer to string
; 0x17 = Display Word r2 as hex = word
; 0x18 = Display Half word as hex r2 = half word
; 0x19 = Display Charr char in hex r2 = char
; 0x1A = Display Byte in hex r2 = byte
;==============================================================================
;
VideoSC:
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	sw		sp,sp_saves[r26]	; save sp in save area
	shlui	r26,r26,#8			; 2k for stack
	mov		sp,r26
	addui	sp,sp,#0x100008000	; base stacks address
	subui	sp,sp,#8
	sw		lr,[sp]
Video1:
	omgi	lr,#VIDEOGATE
	bne		lr,r0,Video1
	beqi	r1,#0x02,Video_x02
	beqi	r1,#0x03,Video_x03
	beqi	r1,#0x06,Video_x06
	beqi	r1,#0x09,Video_x09
	beqi	r1,#0x0A,Video_x0A
	beqi	r1,#0x0C,Video_x0C
	beqi	r1,#0x0C,Video_x0D
	beqi	r1,#0x14,Video_x14
	beqi	r1,#0x15,Video_x15
	beqi	r1,#0x16,Video_x16
	beqi	r1,#0x17,Video_x17
	beqi	r1,#0x1A,Video_x1A
	bra		VideoRet

Video_x02:
	sb		r2,CursorRow
	sb		r3,CursorCol
	call	CalcScreenLoc
	bra		VideoRet

Video_x03:
	lbu		r1,CursorRow
	lbu		r2,CursorCol
	bra		VideoRet

Video_x06:
	call	ScrollUp
	bra		VideoRet

Video_x09:
	sc		r3,CharColor
	mov		r1,r2
Video_x09a:
	call	DisplayChar
	loop	r4,Video_x09a
	bra		VideoRet

Video_x0A:
	mov		r1,r2
Video_x0Aa:
	call	DisplayChar
	loop	r3,Video_x0Aa
	bra		VideoRet

Video_x0C:
	sh		r2,GACCEL+8		; x0
	sh		r3,GACCEL+12	; y0
	sh		r4,GACCEL+0		; color
	lw		r1,#1
	sh		r1,GACCEL+60	; DRAW PIXEL command
	bra		VideoRet

Video_x0D:
	sh		r2,GACCEL+8		; x0
	sh		r3,GACCEL+12	; y0
	lw		r1,#8
	sh		r1,GACCEL+60	; GET PIXEL command
	nop						; let command start
	nop
	nop
vxd1:
	lhu		r1,GACCEL+56	; wait for state = IDLE
	bne		r1,r0,vxd1
	lhu		r1,GACCEL+52
	bra		VideoRet

Video_x14:
	mov		r1,r2
	call	DisplayString
	bra		VideoRet

Video_x15:
	mov		r1,r2
	mov		r2,r3
	call	DisplayNum
	bra		VideoRet

Video_x16:
	mov		r1,r2
	call	DisplayStringCRLF
	bra		VideoRet

Video_x17:
	mov		r1,r2
	call	DisplayWord
	bra		VideoRet

Video_x1A:
	mov		r1,r2
	call	DisplayByte
	bra		VideoRet

VideoRet:
	cmgi	#VIDEOGATE
	lw		lr,[sp]
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	lw		sp,sp_saves[r26]	; get back the stack
	eret

;==============================================================================
; BIOS interrupt #413
; 0x00  initialize
; 0x01	read sector		r2 = sector #, r3 = pointer to buffer
; 0x02	write sector
;==============================================================================
;
SDCARDSC:
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	sw		sp,sp_saves[r26]	; save sp in save area
	shlui	r26,r26,#8			; 2k for stack
	mov		sp,r26
	addui	sp,sp,#0x100008000	; base stacks address
	subui	sp,sp,#8
	sw		lr,[sp]
SDC_1:
	omgi	lr,#CARDGATE
	bne		lr,r0,SDC_1
	beqi	r1,#0,SDC_x00
	beqi	r1,#1,SDC_x01
	beqi	r1,#2,SDC_x02
	bra		SDCRet
SDC_x00:
	call	spi_init
	bra		SDCRet
SDC_x01:
	mov		r1,r2
	mov		r2,r3
	call	spi_read_sector
	bra		SDCRet
SDC_x02:
SDCRet:
	cmgi	#CARDGATE
	lw		lr,[sp]
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	lw		sp,sp_saves[r26]	; get back the stack
	eret

;==============================================================================
; Real time clock BIOS
; BIOS interrupt #416
;
; Function
; 0x00 = get system tick
; 0x01 = get date/time
; 0x02 = set date/time
;==============================================================================
;
RTCSC:
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	sw		sp,sp_saves[r26]	; save sp in save area
	shlui	r26,r26,#8			; 2k for stack
	mov		sp,r26
	addui	sp,sp,#0x100008000	; base stacks address
	subui	sp,sp,#8
	sw		lr,[sp]
	;
	beqi	r1,#0x00,RTC_x00
	beqi	r1,#0x01,RTC_x01
RTC_x00:
	mfspr	r1,TICK
	bra		RTCRet
RTC_x01:
	outw	r0,DATETIME+24		; trigger a snapshot
	nop
	inw		r1,DATETIME			; get the snapshotted date and time
	bra		RTCRet
RTCRet:
	lw		lr,[sp]
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	lw		sp,sp_saves[r26]	; get back the stack
	eret

;==============================================================================
; Keyboard BIOS
; BIOS interrupt #417
;
; Function in R1
; 0x00 = initialize keyboard
; 0x01 = set keyboard echo
; 0x02 = get keyboard character from buffer
; 0x03 = check for key available in buffer
; 0x04 = check for key directly at keyboard port
; 0x05 = get keyboard character directly from keyboard port (blocks)
;==============================================================================
;
KeybdSC:
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	sw		sp,sp_saves[r26]	; save sp in save area
	shlui	r26,r26,#8			; 2k for stack
	mov		sp,r26
	addui	sp,sp,#0x100008000	; base stacks address
	subui	sp,sp,#8
	sw		lr,[sp]
kbdsc5:
	omgi	lr,#KEYBDGATE
	bne		lr,r0,kbdsc5
	beqi	r1,#0,kbd_x00
	beqi	r1,#1,kbd_x01
	beqi	r1,#2,kbd_x02
	beqi	r1,#3,kbd_x03
	beqi	r1,#4,kbd_x04
	beqi	r1,#5,kbd_x05
	bra		kbdscRet
kbd_x00:
	call	KeybdInit
	bra		kbdscRet
kbd_x01:
	mov		r1,r2
	call	SetKeyboardEcho
	bra		kbdscRet
kbd_x02:
	call	KeybdGetChar
	bra		kbdscRet
kbd_x03:
	call	KeybdCheckForKey
	bra		kbdscRet
kbd_x04:
	call	KeybdCheckForKeyDirect
	bra		kbdscRet
kbd_x05:
	call	KeybdGetCharDirect
	bra		kbdscRet
kbdscRet:
	cmgi	#KEYBDGATE
	lw		lr,[sp]
	mfspr	r26,AXC				; get context
	shlui	r26,r26,#3			; *8
	lw		sp,sp_saves[r26]	; get back the stack
	eret

;------------------------------------------------------------------------------
; Initialize keyboard
;------------------------------------------------------------------------------
KeybdInit:
	sb		r0,KeybdHead
	sb		r0,KeybdTail
	setlo	r1,#1			; turn on keyboard echo
	sb		r1,KeybdEcho
	ret

;------------------------------------------------------------------------------
; Normal keyboard interrupt, the lowest priority interrupt in the system.
; Grab the character from the keyboard device and store it in a buffer.
;------------------------------------------------------------------------------
;
KeybdIRQ:
	subui	sp,sp,#8
	sw		r2,[sp]
	lbu		r1,KeybdHead
	andi	r1,r1,#0x0f				; r1 = index into buffer
KeybdIRQa:
	inch	r2,KEYBD				; get keyboard character
	outc	r0,KEYBD+2				; clear keyboard strobe (turns off the IRQ)
	sb		r2,KeybdBuffer[r1]		; store character in buffer
	addui	r1,r1,#1				; increment head index
	andi	r1,r1,#0x0f
	sb		r1,KeybdHead
KeybdIRQb:
	lbu		r2,KeybdTail			; check to see if we've collided
	bne		r1,r2,KeybdIRQc			; with the tail
	addui	r2,r2,#1				; if so, increment the tail index
	andi	r2,r2,#0x0f				; the oldest character will be lost
	sb		r2,KeybdTail
KeybdIRQc:
	lw		r2,[sp]
	ret		#8

;------------------------------------------------------------------------------
; r1 0=echo off, non-zero = echo on
;------------------------------------------------------------------------------
SetKeyboardEcho:
	sb		r1,KeybdEcho
	ret

;-----------------------------------------
; Get character from keyboard buffer
;-----------------------------------------
KeybdGetChar:
	subui	sp,sp,#16
	sw		r2,[sp]
	sw		lr,8[sp]
	lbu		r2,KeybdTail
	lbu		r1,KeybdHead
	beq		r1,r2,nochar
	lbu		r1,KeybdBuffer[r2]
	addui	r2,r2,#1
	andi	r2,r2,#0x0f
	sb		r2,KeybdTail
	lb		r2,KeybdEcho
	beq		r2,r0,kgc3
	bnei	r1,#CR,kgc2
	call	CRLF			; convert CR keystroke into CRLF
	bra		kgc3
kgc2:
	call	DisplayChar
	bra		kgc3
nochar:
	setlo	r1,#-1
kgc3:
	lw		lr,8[sp]
	lw		r2,[sp]
	ret		#16

;------------------------------------------------------------------------------
; Check if there is a keyboard character available in the keyboard buffer.
;------------------------------------------------------------------------------
;
KeybdCheckForKey:
	lbu		r1,KeybdTail
	lbu		r2,KeybdHead
	sne		r1,r1,r2
	ret

;------------------------------------------------------------------------------
; Check if there is a keyboard character available. If so return true (1)
; otherwise return false (0) in r1.
;------------------------------------------------------------------------------
;
KeybdCheckForKeyDirect:
	inch	r1,KEYBD
	slt		r1,r1,r0
	ret

;------------------------------------------------------------------------------
; Get character directly from keyboard. This routine blocks until a key is
; available.
;------------------------------------------------------------------------------
;
KeybdGetCharDirect:
	subui	sp,sp,#16
	sw		r2,[sp]
	sw		lr,8[sp]
	setlo	r2,KEYBD
kgc1:
	inch	r1,KEYBD
	bge		r1,r0,kgc1
	outc	r0,KEYBD+2		; clear keyboard strobe
	andi	r1,r1,#0xff		; remove strobe bit
	lb		r2,KeybdEcho	; is keyboard echo on ?
	beq		r2,r0,gk1
	bnei	r1,#'\r',gk2	; convert CR keystroke into CRLF
	call	CRLF
	bra		gk1
gk2:
	call	DisplayChar
gk1:
	lw		r2,[sp]
	lw		lr,8[sp]
	ret		#16

;==============================================================================
;==============================================================================
tmp_init:
	; wait for the rst1626 to go low
	lw		r2,#10000000	; retry for up to several seconds
tmp_init4:
	beq		r2,r0,tmp_init5
	subui	r2,r2,#1
	inch	r1,TMP+2	; read the status reg
	blt		r1,r0,tmp_init4
tmp_init5:

	lw		r1,#0x51	; Start temperature conversion
	outc	r1,TMP

	; wait a bit for the trigger to take effect
	lw		r1,#2500
tmp_init1:
	loop	r1,tmp_init1

	; wait for the rst1626 to go low
	lw		r2,#10000000	; retry for up to several seconds
tmp_init2:
	beq		r2,r0,tmp_init3
	subui	r2,r2,#1
	inch	r1,TMP+2	; read the status reg
	blt		r1,r0,tmp_init2
tmp_init3:
	ret

tmp_read:
	subui	sp,sp,#24
	sw		lr,[sp]
	sw		r1,8[sp]
	sw		r2,16[sp]

	lw		r1,#25000000	; wait about 1 second or so
tmp_read1:
	loop	r1,tmp_read1
	lw		r1,#0xAC	; issue read temperature conversion
	outc	r1,TMP

	; wait a bit for the trigger to take effect
	lw		r1,#2500
tmp_read3:
	loop	r1,tmp_read3

	; wait for the rst1626 to go low
	lw		r2,#10000000
tmp_read2:
	inch	r1,TMP+2	; read the status reg
	beq		r2,r0,tmp_read4
	subui	r2,r2,#1
	blt		r1,r0,tmp_read2
tmp_read4:
	inch	r1,TMP+2		; read the temperature
	lw		r2,#5			; five digits
	call	DisplayNum
	lw		lr,[sp]
	lw		r1,8[sp]
	lw		r2,16[sp]
	ret		#24

;==============================================================================
;==============================================================================
;------------------------------------------------------------------------------
; 100 Hz interrupt
; - takes care of "flashing" the cursor
;------------------------------------------------------------------------------
;
Pulse100:
	subui	sp,sp,#8
	sw		lr,[sp]
	lea		r2,TEXTSCR
	inch	r1,334[r2]
	addui	r1,r1,#1
	outc	r1,334[r2]
;	call	DisplayDatetime
	call	SelectNextToRunTCB
	call	SwitchTask
	outb	r0,0xDCFFFC		; clear interrupt
;	lw		r1,TickIRQAddr
;	jal		r31,[r1]
;	lw		r1,Milliseconds
;	andi	r1,r1,#0x0f
;	bnei	r1,#5,p1001
;	call	FlashCursor
p1001:
	lw		lr,[sp]
	ret		#8

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
SelectNextToRunTCB:
	sc		r0,NextToRunTCB
	ret

;------------------------------------------------------------------------------
; Switch from the RunningTCB to the NextToRunTCB
;------------------------------------------------------------------------------
SwitchTask:
	sw		r1,r1save
	sw		r2,r2save
	lcu		r1,NextToRunTCB
	lcu		r2,RunningTCB
	bne		r1,r2,swtsk1		; are we already running this TCB ?
	lw		r1,r1save
	lw		r2,r2save
	ret
swtsk1:
	andi	r2,r2,#0x1ff		; max 512 TCB's
	mului	r2,r2,#TCBSize
	addui	r2,r2,#TCBBase
	lw		r1,r1save			; get back r1
	sw		r1,TCBr1[r2]
	lw		r1,r2save			; get back r2
	sw		r1,TCBr2[r2]
	sw		r3,TCBr3[r2]
	sw		r4,TCBr4[r2]
	sw		r5,TCBr5[r2]
	sw		r6,TCBr6[r2]
	sw		r7,TCBr7[r2]
	sw		r8,TCBr8[r2]
	sw		r9,TCBr9[r2]
	sw		r10,TCBr10[r2]
	sw		r11,TCBr11[r2]
	sw		r12,TCBr12[r2]
	sw		r13,TCBr13[r2]
	sw		r14,TCBr14[r2]
	sw		r15,TCBr15[r2]
	sw		r16,TCBr16[r2]
	sw		r17,TCBr17[r2]
	sw		r18,TCBr18[r2]
	sw		r19,TCBr19[r2]
	sw		r20,TCBr20[r2]
	sw		r21,TCBr21[r2]
	sw		r22,TCBr22[r2]
	sw		r23,TCBr23[r2]
	sw		r24,TCBr24[r2]
	sw		r25,TCBr25[r2]
	sw		r26,TCBr26[r2]
	sw		r27,TCBr27[r2]
	sw		r28,TCBr28[r2]
	sw		r29,TCBr29[r2]
	sw		r30,TCBr30[r2]
	sw		r31,TCBr31[r2]

	lcu		r2,NextToRunTCB
	sc		r2,RunningTCB
	mului	r2,r2,#TCBSize
	addui	r2,r2,#TCBBase

	lw		r1,TCBr1[r2]
	lw		r3,TCBr3[r2]
	lw		r4,TCBr4[r2]
	lw		r5,TCBr5[r2]
	lw		r6,TCBr6[r2]
	lw		r7,TCBr7[r2]
	lw		r8,TCBr8[r2]
	lw		r9,TCBr9[r2]
	lw		r10,TCBr10[r2]
	lw		r11,TCBr11[r2]
	lw		r12,TCBr12[r2]
	lw		r13,TCBr13[r2]
	lw		r14,TCBr14[r2]
	lw		r15,TCBr15[r2]
	lw		r16,TCBr16[r2]
	lw		r17,TCBr17[r2]
	lw		r18,TCBr18[r2]
	lw		r19,TCBr19[r2]
	lw		r20,TCBr20[r2]
	lw		r21,TCBr21[r2]
	lw		r22,TCBr22[r2]
	lw		r23,TCBr23[r2]
	lw		r24,TCBr24[r2]
	lw		r25,TCBr25[r2]
	lw		r26,TCBr26[r2]
	lw		r27,TCBr27[r2]
	lw		r28,TCBr28[r2]
	lw		r29,TCBr29[r2]
	lw		r30,TCBr30[r2]
	lw		r31,TCBr31[r2]
	lw		r2,TCBr2[r2]
	ret

;------------------------------------------------------------------------------
; Flash Cursor
;------------------------------------------------------------------------------
;
FlashCursor:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	call	CalcScreenLoc
	addui	r1,r1,#0x10000
	lb		r2,CursorFlash
	beq		r2,r0,flshcrsr2
	; causes screen colors to flip around
	inch	r2,[r1]
	addui	r2,r2,#1
	outc	r2,[r1]
flshcrsr3:
	lw		r2,Lastloc
	beq		r1,r2,flshcrsr1
	; restore the screen colors of the previous cursor location
	lc		r3,ScreenColor
	outc	r3,[r2]
	sw		r1,Lastloc
flshcrsr1:
	lw		r1,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	lw		lr,24[sp]
	ret		#32
flshcrsr2:
	lc		r3,ScreenColor
	outc	r3,[r1]
	bra		flshcrsr3

CursorOff:
	lw		r1,#0xA0
	outc	r1,TEXTREG+16		; turn off cursor
	ret
CursorOn:
	lw		r1,#0xE0
	outc	r1,TEXTREG+16		; turn on cursor
	ret

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
ClearBmpScreen:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	lw		r2,#1364*768
	shrui	r2,r2,#3			; r2 = # words to clear
	lea		r1,0x2929292929292929	; r1 = color for eight pixels
	lea		r3,BITMAPSCR		; r3 = screen address
csj4:
	sw		r1,[r3]				; store pixel data
	addui	r3,r3,#8			; advance screen address by eight
	loop	r2,csj4				; decrement pixel count and loop back
	lw		r1,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	ret		#24

;------------------------------------------------------------------------------
; Clear the screen and the screen color memory
; We clear the screen to give a visual indication that the system
; is working at all.
;------------------------------------------------------------------------------
;
ClearScreen:
	subui	sp,sp,#40
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		r4,24[sp]
	sw		lr,32[sp]
	lea		r3,TEXTREG
	inch	r1,TEXT_COLS[r3]	; calc number to clear
	inch	r2,TEXT_ROWS[r3]
	mulu	r2,r1,r2			; r2 = # chars to clear
	setlo	r1,#32			; space char
	lc		r4,ScreenColor
	call	AsciiToScreen
	lea		r3,TEXTSCR		; text screen address
csj4:
	outc	r1,[r3]
	outc	r4,0x10000[r3]	; color screen is 0x10000 higher
	addui	r3,r3,#2
	loop	r2,csj4
	lw		lr,32[sp]
	lw		r4,24[sp]
	lw		r3,16[sp]
	lw		r2,8[sp]
	lw		r1,[sp]
	ret		#40

;------------------------------------------------------------------------------
; Scroll text on the screen upwards
;------------------------------------------------------------------------------
;
ScrollUp:
	subui	sp,sp,#40
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		r4,24[sp]
	sw		lr,32[sp]
	lea		r3,TEXTREG
	inch	r1,TEXT_COLS[r3]	; r1 = # text columns
	inch	r2,TEXT_ROWS[r3]
	mulu	r2,r1,r2			; calc number of chars to scroll
	subu	r2,r2,r1			; one less row
	lea		r3,TEXTSCR
scrup1:
	inch	r4,[r3+r1*2]		; indexed addressing example
	outc	r4,[r3]
	addui	r3,r3,#2
	loop	r2,scrup1

	lea		r3,TEXTREG
	inch	r1,TEXT_ROWS[r3]
	subui	r1,r1,#1
	call	BlankLine
	lw		r1,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	lw		r4,24[sp]
	lw		lr,32[sp]
	ret		#40

;------------------------------------------------------------------------------
; Blank out a line on the display
; line number to blank is in r1
;------------------------------------------------------------------------------
;
BlankLine:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	lea		r3,TEXTREG			; r3 = text register address
	inch	r2,TEXT_COLS[r3]	; r2 = # chars to blank out
	mulu	r3,r2,r1
	shli	r3,r3,#1
	addui	r3,r3,#TEXTSCR		; r3 = screen address
	setlo	r1,#' '
blnkln1:
	outc	r1,[r3]
	addui	r3,r3,#2
	loop	r2,blnkln1
	lw		r1,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	ret		#24

;------------------------------------------------------------------------------
; Convert ASCII character to screen display character.
;------------------------------------------------------------------------------
;
AsciiToScreen:
	andi	r1,r1,#0x00ff
	bltui	r1,#'A',atoscr1
	bleui	r1,#'Z',atoscr1
	bgtui   r1,#'z',atoscr1
	bltui	r1,#'a',atoscr1
	subui	r1,r1,#0x60
atoscr1:
	ori		r1,r1,#0x100
	ret

;------------------------------------------------------------------------------
; Convert screen character to ascii character
;------------------------------------------------------------------------------
;
ScreenToAscii:
	andi	r1,r1,#0xff
	bgtui	r1,#26,stasc1
	addui	r1,r1,#60
stasc1:
	ret

;------------------------------------------------------------------------------
; Calculate screen memory location from CursorRow,CursorCol.
; Also refreshes the cursor location.
; Destroys r1,r2,r3
; r1 = screen location
;------------------------------------------------------------------------------
;
CalcScreenLoc:
	lbu		r1,CursorRow
	andi	r1,r1,#0x7f
	lea		r3,TEXTREG
	inch	r2,TEXT_COLS[r3]
	mulu	r2,r2,r1
	lbu		r1,CursorCol
	andi	r1,r1,#0x7f
	addu	r2,r2,r1
	outc	r2,TEXT_CURPOS[r3]
	shlui	r2,r2,#1
	addui	r1,r2,#TEXTSCR			; r1 = screen location
	ret

;------------------------------------------------------------------------------
; Display a character on the screen
; d1.b = char to display
;------------------------------------------------------------------------------
;
DisplayChar:
	bnei	r1,#'\r',dccr		; carriage return ?
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	sb		r0,CursorCol		; just set cursor column to zero on a CR
	bra		dcx7
dccr:
;	beqi	r1,#CTRLK,dccr1
	bnei	r1,#0x91,dcx6		; cursor right ?
dccr1:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	lbu		r2,CursorCol
	beqi	r2,#56,dcx7
	addui	r2,r2,#1
	sb		r2,CursorCol
dcx7:
	call	CalcScreenLoc
	lw		lr,24[sp]
	lw		r3,16[sp]
	lw		r2,8[sp]
	lw		r1,[sp]
	ret		#32
dcx6:
;	beqi	r1,#CTRLI,dccu1
	bnei	r1,#0x90,dcx8		; cursor up ?
dccu1:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	lbu		r2,CursorRow
	beqi	r2,#0,dcx7
	subui	r2,r2,#1
	sb		r2,CursorRow
	bra		dcx7
dcx8:
;	beqi	r1,#CTRLJ,dccl1
	bnei	r1,#0x93,dcx9		; cursor left ?
dccl1:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	lbu		r2,CursorCol
	beqi	r2,#0,dcx7
	subui	r2,r2,#1
	sb		r2,CursorCol
	bra		dcx7
dcx9:
;	beqi	r1,#CTRLM,dccd1
	bnei	r1,#0x92,dcx10		; cursor down ?
dccd1:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	lbu		r2,CursorRow
	beqi	r2,#30,dcx7
	addui	r2,r2,#1
	sb		r2,CursorRow
	bra		dcx7
dcx10:
	bnei	r1,#0x94,dcx11			; cursor home ?
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	lbu		r2,CursorCol
	beq		r2,r0,dcx12
	sb		r0,CursorCol
	bra		dcx7
dcx12:
	sb		r0,CursorRow
	bra		dcx7
dcx11:
	subui	sp,sp,#48
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		r4,24[sp]
	sw		r5,32[sp]
	sw		lr,40[sp]
	bnei	r1,#0x99,dcx13		; delete ?
	call	CalcScreenLoc
	mov		r3,r1				; r3 = screen location
	lbu		r1,CursorCol		; r1 = cursor column
	bra		dcx5
dcx13:
	bnei	r1,#CTRLH,dcx3		; backspace ?
	lbu		r2,CursorCol
	beq		r2,r0,dcx4
	subui	r2,r2,#1
	sb		r2,CursorCol
	call	CalcScreenLoc		; a0 = screen location
	mov		r3,r1				; r3 = screen location
	lbu		r1,CursorCol
dcx5:
	inch	r2,2[r3]
	outc	r2,[r3]
	addui	r3,r3,#2
	addui	r1,r1,#1
	lea		r4,TEXTREG
	inch	r5,TEXT_COLS[r4]
	bltu	r1,r5,dcx5
	setlo	r1,#' '
	call	AsciiToScreen
	outc	r1,-2[r3]
	bra		dcx4
dcx3:
	beqi	r1,#'\n',dclf	; linefeed ?
	mov		r4,r1			; save r1 in r4
	call	CalcScreenLoc	; r1 = screen location
	mov		r3,r1			; r3 = screen location
	mov		r1,r4			; restore r1
	call	AsciiToScreen	; convert ascii char to screen char
	outc	r1,[r3]
	lc		r1,CharColor
	outc	r1,0x10000[r3]
	call	IncCursorPos
	bra		dcx4
dclf:
	call	IncCursorRow
dcx4:
	lw		lr,40[sp]
	lw		r5,32[sp]
	lw		r4,24[sp]
	lw		r3,16[sp]
	lw		r2,8[sp]
	lw		r1,[sp]
	ret		#48


;------------------------------------------------------------------------------
; Increment the cursor position, scroll the screen if needed.
;------------------------------------------------------------------------------
;
IncCursorPos:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
	lbu		r1,CursorCol
	addui	r1,r1,#1
	sb		r1,CursorCol
	inch	r2,TEXTREG+TEXT_COLS
	bleu	r1,r2,icc1
	sb		r0,CursorCol		; column = 0
	bra		icr1
IncCursorRow:
	subui	sp,sp,#32
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		lr,24[sp]
icr1:
	lbu		r1,CursorRow
	addui	r1,r1,#1
	sb		r1,CursorRow
	inch	r2,TEXTREG+TEXT_ROWS
	bleu	r1,r2,icc1
	subui	r2,r2,#1			; backup the cursor row, we are scrolling up
	sb		r2,CursorRow
	call	ScrollUp
icc1:
	call	CalcScreenLoc
	lw		lr,24[sp]
	lw		r3,16[sp]
	lw		r2,8[sp]
	lw		r1,[sp]
	ret		#32

;------------------------------------------------------------------------------
; Display a string on the screen.
;------------------------------------------------------------------------------
;
DisplayString:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		lr,16[sp]
	mov		r2,r1			; r2 = pointer to string
dspj1:
	lbu		r1,[r2]			; move string char into r1
	addui	r2,r2,#1		; increment pointer
	beq		r1,r0,dsret		; is it end of string ?
	call	DisplayChar		; display character
	bra		dspj1			; go back for next character
dsret:
	lw		lr,16[sp]
	lw		r2,8[sp]
	lw		r1,[sp]
	ret		#24

DisplayStringCRLF:
	subui	r30,r30,#8
	sw		r31,[r30]
	call	DisplayString
	lw		r31,[r30]
	addui	r30,r30,#8

CRLF:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	setlo	r1,#'\r'
	call	DisplayChar
	setlo	r1,#'\n'
	call	DisplayChar
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

; Call the Tiny BASIC routine to display a number
;
DisplayNum:
	jmp		PRTNUM

;------------------------------------------------------------------------------
; Display nybble in r1
;------------------------------------------------------------------------------
;
DisplayNybble:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	andi	r1,r1,#0x0F
	addui	r1,r1,#'0'
	bleui	r1,#'9',dispnyb1
	addui	r1,r1,#7
dispnyb1:
	call	DisplayChar
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;------------------------------------------------------------------------------
; Display the byte in r1
;------------------------------------------------------------------------------
;
DisplayByte:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	rori	r1,r1,#4	
	call	DisplayNybble
	roli	r1,r1,#4
	call	DisplayNybble
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;------------------------------------------------------------------------------
; Display the char in r1
;------------------------------------------------------------------------------
;
DisplayCharr:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	rori	r1,r1,#8	
	call	DisplayByte
	roli	r1,r1,#8
	call	DisplayByte
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;------------------------------------------------------------------------------
; Display the half-word in r1
;------------------------------------------------------------------------------
;
DisplayHalf:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	rori	r1,r1,#16
	call	DisplayCharr
	roli	r1,r1,#16
	call	DisplayCharr
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;------------------------------------------------------------------------------
; Display the 64 bit word in r1
;------------------------------------------------------------------------------
;
DisplayWord:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r3,8[sp]
	sw		lr,16[sp]
	setlo	r3,#7
dspwd1:
	roli	r1,r1,#8
	call	DisplayByte
	loop	r3,dspwd1
	lw		lr,16[sp]
	lw		r3,8[sp]
	lw		r1,[sp]
	ret		#24

;------------------------------------------------------------------------------
; Display memory pointed to by r2.
; destroys r1,r3
;------------------------------------------------------------------------------
;
DisplayMemB:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r3,8[sp]
	sw		lr,16[sp]
	setlo	r1,#':'
	call	DisplayChar
	mov		r1,r2
	call	DisplayWord
	setlo	r3,#7
dspmem1:
	setlo	r1,#' '
	call	DisplayChar
	lbu		r1,[r2]
	call	DisplayByte
	addui	r2,r2,#1
	loop	r3,dspmem1
	call	CRLF
	lw		lr,16[sp]
	lw		r3,8[sp]
	lw		r1,[sp]
	ret		#24

DisplayMemC:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r3,8[sp]
	sw		lr,16[sp]
	setlo	r1,#':'
	call	DisplayChar
	mov		r1,r2
	call	DisplayWord
	setlo	r3,#3
dspmemc1:
	setlo	r1,#' '
	call	DisplayChar
	lcu		r1,[r2]
	call	DisplayCharr
	addui	r2,r2,#2
	loop	r3,dspmemc1
	call	CRLF
	lw		lr,16[sp]
	lw		r3,8[sp]
	lw		r1,[sp]
	ret		#24

DisplayMemW:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		lr,16[sp]
	setlo	r1,#':'
	call	DisplayChar
	mov		r1,r2
	call	DisplayWord
	setlo	r1,#' '
	call	DisplayChar
	lw		r1,[r2]
	call	DisplayWord
	addui	r2,r2,#8
	call	CRLF
	lw		lr,16[sp]
	lw		r1,[sp]
	ret		#24

;------------------------------------------------------------------------------
; Converts binary number in r1 into BCD number in r2 and r1.
;------------------------------------------------------------------------------
;
BinToBCD:
	subui	sp,sp,#48
	sw		r3,[sp]
	sw		r4,8[sp]
	sw		r5,16[sp]
	sw		r6,24[sp]
	sw		r7,32[sp]
	sw		r8,40[sp]
	setlo	r2,#10
	setlo	r8,#19		; number of digits to produce - 1
bta1:
	modu	r3,r1,r2
	shli	r3,r3,#60	; shift result to uppermost bits
	shli	r7,r5,#60	; copy low order nybble of r5 to r4 topmost nybble
	shrui	r4,r4,#4
	or		r4,r4,r7
	shrui	r5,r5,#4
	or		r5,r5,r3	; copy new bcd digit into uppermost bits of r5
	divui	r1,r1,r2	; r1=r1/10
	loop	r8,bta1
	shrui	r4,r4,#48	; right align number in register
	shli	r6,r5,#16
	or		r4,r4,r6	; copy bits into r4
	shrui	r5,r5,#48
	mov		r1,r4
	mov		r2,r5
	lw		r3,[sp]
	lw		r4,8[sp]
	lw		r5,16[sp]
	lw		r6,24[sp]
	lw		r7,32[sp]
	lw		r8,40[sp]
	ret		#48

;------------------------------------------------------------------------------
; Converts BCD number in r1 into Ascii number in r2 and r1.
;------------------------------------------------------------------------------
;
BCDToAscii:
	subui	sp,sp,#32
	sw		r3,[sp]
	sw		r4,8[sp]
	sw		r5,16[sp]
	sw		r8,24[sp]
	setlo	r8,#15
bta2:
	andi	r2,r1,#0x0F
	ori		r2,r2,#0x30
	shli	r2,r2,#56
	shrui	r4,r4,#8
	shli	r5,r3,#56
	or		r4,r4,r5
	shrui	r3,r3,#8
	or		r3,r3,r2
	shrui	r1,r1,#4
	loop	r8,bta2
	mov		r1,r4
	mov		r2,r3
	lw		r3,[sp]
	lw		r4,8[sp]
	lw		r5,16[sp]
	lw		r8,24[sp]
	ret		#32

;------------------------------------------------------------------------------
; Convert a binary number into a 20 character ascii string.
; r1 = number to convert
; r2 = address of string buffer
;------------------------------------------------------------------------------
;
BinToStr:
	subui	sp,sp,#56
	sw		r3,[sp]
	sw		r7,8[sp]
	sw		r8,16[sp]
	sw		r9,24[sp]
	sw		r10,32[sp]
	sw		r11,40[sp]
	sw		lr,48[sp]
	mov		r11,r2
	call	BinToBCD
	mov		r10,r2	; save off r2
	call	BCDToAscii
	setlo	r9,#1
btos3:
	setlo	r8,#7
btos1:
	shli	r7,r9,#3
	addui	r7,r7,r8
	addui	r7,r7,#4
	andi	r3,r1,#0xff
	sb		r3,[r7+r11]
	shrui	r1,r1,#8
	loop	r8,btos1
	mov		r1,r2
	loop	r9,btos3
; the last four digits
	mov		r1,r10	; get back r2
	call	BCDToAscii
	setlo	r8,#3
btos2:
	andi	r3,r1,#0xff
	sb		r3,[r8+r11]
	shrui	r1,r1,#8
	loop	r8,btos2
	sb		r0,20[r11]	; null terminate
	lw		r3,[sp]
	lw		r7,8[sp]
	lw		r8,16[sp]
	lw		r9,24[sp]
	lw		r10,32[sp]
	lw		r11,40[sp]
	lw		lr,48[sp]
	ret		#56


;==============================================================================
; System Monitor Program
;==============================================================================
;
Monitor:
	lea		sp,STACKTOP0	; top of stack; reset the stack pointer
	sb		r0,KeybdEcho	; turn off keyboard echo
PromptLn:
	call	CRLF
	setlo	r1,#'$'
	call	DisplayChar

; Get characters until a CR is keyed
;
Prompt3:
;	lw		r1,#2			; get keyboard character
;	syscall	#417
	call	KeybdGetChar
	beqi	r1,#-1,Prompt3	; wait for a character
	beqi	r1,#CR,Prompt1
	call	DisplayChar
	bra		Prompt3

; Process the screen line that the CR was keyed on
;
Prompt1:
	sb		r0,CursorCol	; go back to the start of the line
	call	CalcScreenLoc	; r1 = screen memory location
	mov		r3,r1
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	bnei	r1,#'$',Prompt2	; skip over '$' prompt character
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii

; Dispatch based on command character
;
Prompt2:
	beqi	r1,#':',Editmem		; $: - edit memory
	beqi	r1,#'D',Dumpmem		; $D - dump memory
	beqi	r1,#'F',Fillmem		; $F - fill memory
Prompt7:
	bnei	r1,#'B',Prompt4		; $B - start tiny basic
	jmp		CSTART
Prompt4:
	beqi	r1,#'J',ExecuteCode	; $J - execute code
	bnei	r1,#'L',Prompt9	; $L - load S19 file
	jmp		LoadSector
Prompt9:
	bnei	r1,#'?',Prompt10	; $? - display help
	lea		r1,HelpMsg
	call	DisplayString
	jmp		Monitor
Prompt10:
	beqi	r1,#'C',TestCLS		; $C - clear screen
	bnei	r1,#'R',Prompt12
	jmp		RandomLinesCall
Prompt12:
	bnei	r1,#'I',Prompt13
	jmp		Invaders
Prompt13:
	bnei	r1,#'P',Prompt14
	jmp		Piano
Prompt14:
	bnei	r1,#'T',Prompt15
	call	tmp_read
Prompt15:
	jmp		Monitor

RandomLinesCall:
	call	RandomLines
	jmp		Monitor

TestCLS:
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	bnei	r1,#'L',Monitor
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	bnei	r1,#'S',Monitor
	call	ClearScreen
	sb		r0,CursorCol
	sb		r0,CursorRow
	call	CalcScreenLoc
	jmp		Monitor
	
HelpMsg:
	db	"? = Display help",CR,LF
	db	"CLS = clear screen",CR,LF
	db	": = Edit memory bytes",CR,LF
	db	"L = Load S19 file",CR,LF
	db	"D[B|C|H|W] = Dump memory",CR,LF
	db	"F[B|C|H|W] = Fill memory",CR,LF
	db	"B = start tiny basic",CR,LF
	db	"J = Jump to code",CR,LF
	db	"I = Invaders",CR,LF
	db	"R = Random lines",CR,LF
	db	"T = get temperature",CR,LF
	db	"P = Piano",CR,LF,0
	align	4

;------------------------------------------------------------------------------
; Ignore blanks in the input
; r3 = text pointer
; r1 destroyed
;------------------------------------------------------------------------------
;
ignBlanks:
	subui	sp,sp,#8
	sw		r31,[sp]
ignBlanks1:
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	beqi	r1,#' ',ignBlanks1
	subui	r3,r3,#2
	lw		r31,[sp]
	ret		#8

;------------------------------------------------------------------------------
; Edit memory byte(s).
;------------------------------------------------------------------------------
;
EditMem:
	call	ignBlanks
	call	GetHexNumber
	or		r5,r1,r0
	setlo	r4,#7
edtmem1:
	call	ignBlanks
	call	GetHexNumber
	sb		r1,[r5]
	addui	r5,r5,#1
	loop	r4,edtmem1
	jmp		Monitor

;------------------------------------------------------------------------------
; Execute code at the specified address.
;------------------------------------------------------------------------------
;
ExecuteCode:
	call	ignBlanks
	call	GetHexNumber
	jal		r31,[r1]
	jmp     Monitor

LoadSector:
	call	ignBlanks
	call	GetHexNumber
	lw		r2,#0x3800
	call	spi_read_sector
	jmp		Monitor

;------------------------------------------------------------------------------
; Do a memory dump of the requested location.
;------------------------------------------------------------------------------
;
DumpMem:
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	mov		r6,r1			; r6 = fill type character
	call	ignBlanks
	call	GetHexNumber	; get start address of dump
	mov		r2,r1
	call	ignBlanks
	call	GetHexNumber	; get number of bytes to dump
	shrui	r1,r1,#3		; 1/8 as many dump rows
	bnei	r1,#0,Dumpmem2
	lw		r1,#1			; dump at least one row
Dumpmem2:
	call	CRLF
	beqi	r6,#'W',DumpmemW
;	beqi	r6,#'H',DumpmemH
	beqi	r6,#'C',DumpmemC
DumpmemB:
	call	DisplayMemB
	loop	r1,DumpmemB
	jmp		Monitor
DumpmemC:
	call	DisplayMemC
	loop	r1,DumpmemC
	jmp		Monitor
DumpmemW:
	call	DisplayMemW
	loop	r1,DumpmemW
	jmp		Monitor

;	call	DisplayMem
;	call	DisplayMem
;	call	DisplayMem
;	call	DisplayMem
;	call	DisplayMem
;	call	DisplayMem
;	call	DisplayMem
	bra		Monitor

Fillmem:
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	mov		r6,r1			; r6 = fill type character
	call	ignBlanks
	call	GetHexNumber	; get start address of dump
	mov		r2,r1
	call	ignBlanks
	call	GetHexNumber	; get number of bytes to fill
	mov		r5,r1
	call	ignBlanks
	call	GetHexNumber	; get the fill byte
	beqi	r6,#'C',FillmemC
	beqi	r6,#'H',FillmemH
	beqi	r6,#'W',FillmemW
FillmemB:
	sb		r1,[r2]
	addui	r2,r2,#1
	loop	r5,FillmemB
	jmp		Monitor
FillmemC:
	sc		r1,[r2]
	addui	r2,r2,#2
	loop	r5,FillmemC
	jmp		Monitor
FillmemH:
	sh		r1,[r2]
	addui	r2,r2,#4
	loop	r5,FillmemH
	jmp		Monitor
FillmemW:
	sw		r1,[r2]
	addui	r2,r2,#8
	loop	r5,FillmemW
	jmp		Monitor

;------------------------------------------------------------------------------
; Get a hexidecimal number. Maximum of sixteen digits.
; R3 = text pointer (updated)
; R1 = hex number
;------------------------------------------------------------------------------
;
GetHexNumber:
	subui	sp,sp,#24
	sw		r2,[sp]
	sw		r4,8[sp]
	sw		lr,16[sp]
	setlo	r2,#0
	setlo	r4,#15
gthxn2:
	inch	r1,[r3]
	addui	r3,r3,#2
	call	ScreenToAscii
	call	AsciiToHexNybble
	beqi	r1,#-1,gthxn1
	shli	r2,r2,#4
	andi	r1,r1,#0x0f
	or		r2,r2,r1
	loop	r4,gthxn2
gthxn1:
	mov		r1,r2
	lw		lr,16[sp]
	lw		r4,8[sp]
	lw		r2,[sp]
	ret		#24

;------------------------------------------------------------------------------
; Convert ASCII character in the range '0' to '9', 'a' to 'f' or 'A' to 'F'
; to a hex nybble.
;------------------------------------------------------------------------------
;
AsciiToHexNybble:
	bltui	r1,#'0',gthx3
	bgtui	r1,#'9',gthx5
	subui	r1,r1,#'0'
	ret
gthx5:
	bltui	r1,#'A',gthx3
	bgtui	r1,#'F',gthx6
	subui	r1,r1,#'A'
	addui	r1,r1,#10
	ret
gthx6:
	bltui	r1,#'a',gthx3
	bgtui	r1,#'f',gthx3
	subui	r1,r1,#'a'
	addui	r1,r1,#10
	ret
gthx3:
	setlo	r1,#-1		; not a hex number
	ret

;==============================================================================
; Load an S19 format file
;==============================================================================
;
LoadS19:
	bra		ProcessRec
NextRec:
	call	sGetChar
	bne		r1,#LF,NextRec
ProcessRec:
	call	sGetChar
	beqi	r1,#26,Monitor	; CTRL-Z ?
	bnei	r1,#'S',NextRec
	call	sGetChar
	blt		r1,#'0',NextRec
	bgt		r1,#'9',NextRec
	or		r4,r1,r0		; r4 = record type
	call	sGetChar
	call	AsciiToHexNybble
	or		r2,r1,r0
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1		; r2 = byte count
	or		r3,r2,r1		; r3 = byte count
	beqi	r4,#'0',NextRec	; manufacturer ID record, ignore
	beqi	r4,#'1',ProcessS1
	beqi	r4,#'2',ProcessS2
	beqi	r4,#'3',ProcessS3
	beqi	r4,#'5',NextRec	; record count record, ignore
	beqi	r4,#'7',ProcessS7
	beqi	r4,#'8',ProcessS8
	beqi	r4,#'9',ProcessS9
	bra		NextRec

pcssxa:
	andi	r3,r3,#0xff
	subui	r3,r3,#1		; one less for loop
pcss1a:
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	sb		r2,[r5]
	addui	r5,r5,#1
	loop	r3,pcss1a
; Get the checksum byte
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	bra		NextRec

ProcessS1:
	call	S19Get16BitAddress
	bra		pcssxa
ProcessS2:
	call	S19Get24BitAddress
	bra		pcssxa
ProcessS3:
	call	S19Get32BitAddress
	bra		pcssxa
ProcessS7:
	call	S19Get32BitAddress
	sw		r5,S19StartAddress
	bra		Monitor
ProcessS8:
	call	S19Get24BitAddress
	sw		r5,S19StartAddress
	bra		Monitor
ProcessS9:
	call	S19Get16BitAddress
	sw		r5,S19StartAddress
	jmp		Monitor

S19Get16BitAddress:
	subui	sp,sp,#8
	sw		r31,[sp]
	call	sGetChar
	call	AsciiToHexNybble
	or		r2,r1,r0
	bra		S1932b

S19Get24BitAddress:
	subui	sp,sp,#8
	sw		r31,[sp]
	call	sGetChar
	call	AsciiToHexNybble
	or		r2,r1,r0
	bra		S1932a

S19Get32BitAddress:
	subui	sp,sp,#8
	sw		r31,[sp]
	call	sGetChar
	call	AsciiToHexNybble
	or		r2,r1,r0
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r1,r2
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
S1932a:
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
S1932b:
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	call	sGetChar
	call	AsciiToHexNybble
	shli	r2,r2,#4
	or		r2,r2,r1
	xor		r4,r4,r4
	or		r5,r2,r0
	lw		r31,[sp]
	addui	sp,sp,#8
	ret

;------------------------------------------------------------------------------
; Get a character from auxillary input, checking the keyboard status for a
; CTRL-C
;------------------------------------------------------------------------------
;
sGetChar:
	subui	sp,sp,#8
	sw		r31,[sp]
sgc2:
	call	KeybdCheckForKey
	beq		r1,r0,sgc1
	call	KeybdGetchar
	beqi	r1,#CRTLC,Monitor
sgc1:
	call	AUXIN
	ble		r1,r0,sgc2
	lw		r31,[sp]
	ret		#8

;--------------------------------------------------------------------------
; Draw random lines on the bitmap screen.
;--------------------------------------------------------------------------
;
RandomLines:
	subui	sp,sp,#24
	sw		r1,[sp]
	sw		r3,8[sp]
	sw		lr,16[sp]
	sw		r0,ctx3start	; prevent restarting context over and over again
rl5:
	gran
	mfspr	r1,rand			; select a random color
	outh	r1,GACCEL
rl1:						; random X0
	gran
	mfspr	r1,rand
	lw		r3,#1364
	modu	r1,r1,r3
	outh	r1,GACCEL+8
rl2:						; random X1
	gran
	mfspr	r1,rand
	lw		r3,#1364
	modu	r1,r1,r3
	outh	r1,GACCEL+16
rl3:						; random Y0
	gran
	mfspr	r1,rand
	lw		r3,#768
	modu	r1,r1,r3
	outh	r1,GACCEL+12
rl4:						; random Y1
	gran
	mfspr	r1,rand
	lw		r3,#768
	modu	r1,r1,r3
	outh	r1,GACCEL+20
	setlo	r1,#2			; draw line command
	outh	r1,GACCEL+60
rl8:
;	call	KeybdGetChar
;	beqi	r1,#CTRLC,rl7
	inch	r1,GACCEL+56	; ensure controller is in IDLE state
	bne		r1,r0,rl8
	bra		rl5
rl7:
	lw		lr,16[sp]
	lw		r3,8[sp]
	lw		r1,[sp]
	ret		#24

;--------------------------------------------------------------------------
; Initialize sprite image caches with random data.
;--------------------------------------------------------------------------
RandomizeSprram:
	lea		r2,SPRRAM
	setlo	r4,#14335		; number of chars to initialize
rsr1:
	gran
	mfspr	r1,rand
	outc	r1,[r2]
	addui	r2,r2,#2
	loop	r4,rsr1
	ret
	
;--------------------------------------------------------------------------
; Setup the AC97/LM4550 audio controller. Check keyboard for a CTRL-C
; interrupt which may be necessary if the audio controller isn't 
; responding.
;--------------------------------------------------------------------------
;
SetupAC97:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
sac974:
	outc	r0,AC97+0x26	; trigger a read of register 26 (status reg)
sac971:						; wait for status to register 0xF (all ready)
	call	KeybdGetChar	; see if we needed to CTRL-C
	beqi	r1,#CTRLC,sac973
	inch	r1,AC97+0x68	; wait for dirty bit to clear
	bne		r1,r0,sac971
	inch	r1,AC97+0x26	; check status at reg h26, wait for
	andi	r1,r1,#0x0F		; analogue to be ready
	bnei	r1,#0x0F,sac974
sac973:
	outc	r0,AC97+2		; master volume, 0db attenuation, mute off
	outc	r0,AC97+4		; headphone volume, 0db attenuation, mute off
	outc	r0,AC97+0x18	; PCM gain (mixer) mute off, no attenuation
	outc	r0,AC97+0x0A	; mute PC beep
	setlo	r1,#0x8000		; bypass 3D sound
	outc	r1,AC97+0x20
sac972:
	call	KeybdGetChar
	beqi	r1,#CTRLC,sac975
	inch	r1,AC97+0x68	; wait for dirty bits to clear
	bne		r1,r0,sac972	; wait a while for the settings to take effect
sac975:
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;--------------------------------------------------------------------------
; Sound a 800 Hz beep
;--------------------------------------------------------------------------
;
Beep:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	setlo	r1,#8
	outb	r1,LED
	ori		r1,r0,#15		; master volume to max
	outc	r1,PSG+128
	ori		r1,r0,#13422	; 800Hz
	outc	r1,PSGFREQ0
	setlo	r1,#9
	outb	r1,LED
	; decay  (16.384 ms)2
	; attack (8.192 ms)1
	; release (1.024 s)A
	; sustain level C
	setlo	r1,#0xCA12
	outc	r1,PSGADSR0
	ori		r1,r0,#0x1104	; gate, output enable, triangle waveform
	outc	r1,PSGCTRL0
	ori		r1,r0,#2500000	; delay about 1s
beep1:
	loop	r1,beep1
	setlo	r1,#13
	outb	r1,LED
	ori		r1,r0,#0x0104	; gate off, output enable, triangle waveform
	outc	r1,PSGCTRL0
	ori		r1,r0,#2500000	; delay about 1s
beep2:
	loop	r1,beep2
	setlo	r1,#16
	outb	r1,LED
	ori		r1,r0,#0x0000	; gate off, output enable off, no waveform
	outc	r1,PSGCTRL0
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; 
Piano:
	ori		r1,r0,#15		; master volume to max
	outc	r1,PSG+128
playnt:
	call	KeybdGetChar
	beqi	r1,#CTRLC,Monitor
	beqi	r1,#'a',playnt1a
	beqi	r1,#'b',playnt1b
	beqi	r1,#'c',playnt1c
	beqi	r1,#'d',playnt1d
	beqi	r1,#'e',playnt1e
	beqi	r1,#'f',playnt1f
	beqi	r1,#'g',playnt1g
	bra		playnt

playnt1a:
	setlo	r1,#7217
	call	Tone
	bra		playnt
playnt1b:
	setlo	r1,#8101
	call	Tone
	bra		playnt
playnt1c:
	setlo	r1,#4291
	call	Tone
	bra		playnt
playnt1d:
	setlo	r1,#4817
	call	Tone
	bra		playnt
playnt1e:
	setlo	r1,#5407
	call	Tone
	bra		playnt
playnt1f:
	setlo	r1,#5728
	call	Tone
	bra		playnt
playnt1g:
	setlo	r1,#6430
	call	Tone
	bra		playnt

Tone:
	subui	sp,sp,#16
	sw		r1,[sp]
	sw		lr,8[sp]
	outc	r1,PSGFREQ0
	; decay  (16.384 ms)2
	; attack (8.192 ms)1
	; release (1.024 s)A
	; sustain level C
	setlo	r1,#0xCA12
	outc	r1,PSGADSR0
	ori		r1,r0,#0x1104	; gate, output enable, triangle waveform
	outc	r1,PSGCTRL0
	ori		r1,r0,#250000	; delay about 10ms
tone1:
	loop	r1,tone1
	ori		r1,r0,#0x0104	; gate off, output enable, triangle waveform
	outc	r1,PSGCTRL0
	ori		r1,r0,#250000	; delay about 10ms
tone2:
	loop	r1,tone2
	ori		r1,r0,#0x0000	; gate off, output enable off, no waveform
	outc	r1,PSGCTRL0
	lw		lr,8[sp]
	lw		r1,[sp]
	ret		#16

;==============================================================================
;==============================================================================
SetupRasterIRQ:
	subui	sp,sp,#8
	sw		r1,[sp]
	setlo	r1,#200
	outc	r1,RASTERIRQ
	setlo	r1,#240
	outc	r1,RASTERIRQ+2
	setlo	r1,#280
	outc	r1,RASTERIRQ+4
	setlo	r1,#320
	outc	r1,RASTERIRQ+6
	setlo	r1,#360
	outc	r1,RASTERIRQ+8
	lw		r1,[sp]
	ret		#8

RasterIRQfn:
	inch	r1,RASTERIRQ+30		; get the raster compare register # (clears IRQ)
	beqi	r1,#1,rirq1
	beqi	r1,#2,rirq2
	beqi	r1,#3,rirq3
	beqi	r1,#4,rirq4
	beqi	r1,#5,rirq5
	beqi	r1,#6,rirq6
	beqi	r1,#7,rirq7
	beqi	r1,#8,rirq8
	ret
rirq1:
rirq2:
rirq3:
rirq4:
rirq5:
rirq6:
rirq7:
rirq8:
	mului	r1,r1,#40
	addui	r1,r1,#204
	outc	r1,SPRITEREGS+2
	outc	r1,SPRITEREGS+18
	outc	r1,SPRITEREGS+34
	outc	r1,SPRITEREGS+50
	outc	r1,SPRITEREGS+66
	outc	r1,SPRITEREGS+82
	outc	r1,SPRITEREGS+98
	outc	r1,SPRITEREGS+114
	ret

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
DisplayDatetime:
	subui	sp,sp,#48
	sw		r1,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		r4,24[sp]
	sw		r5,32[sp]
	sw		lr,24[sp]
	call	CursorOff
	lw		r1,#3				; get cursor position
	syscall	#410
	mov		r4,r1				; r4 = row
	mov		r5,r2				; r5 = col
	lw		r1,#2				; set cursor position
	lw		r2,#46				; move cursor down to last display line
	lw		r3,#64
	syscall	#410
	lw		r1,#1				; get the snapshotted date and time
	syscall	#416
	call	DisplayWord			; display on screen
	lw		r1,#2				; restore cursor position
	mov		r2,r4				; r2 = row
	mov		r3,r5				; r3 = col
	syscall	#410
	call	CursorOn
	lw		lr,24[sp]
	lw		r3,16[sp]
	lw		r2,8[sp]
	lw		r1,[sp]
	lw		r4,24[sp]
	lw		r5,32[sp]
	ret		#48

;==============================================================================
;==============================================================================
InitializeGame:
	subui	sp,sp,#16
	sm		[sp],r3/lr
	setlo	r3,#320
	sc		r3,Manpos
	sc		r0,Score
	sb		r0,MissileActive
	sc		r0,MissileX
	sc		r0,MissileY
	lm		[sp],r3/lr
	ret		#16

DrawScore:
	subui	sp,sp,#24
	sm		[sp],r1/r3/lr
	setlo	r3,#1
	sb		r3,CursorRow
	setlo	r3,#40
	sb		r3,CursorCol
	lb		r1,Score
	call	DisplayByte
	lb		r1,Score+1
	call	DisplayByte
	lm		[sp],r1/r3/lr
	ret		#24

DrawMissile:
	subui	sp,sp,#16
	sm		[sp],r1/lr
	lc		r1,MissileY
	bleu	r1,#2,MissileOff
	lc		r1,MissileX
	shrui	r1,r1,#3
	sb		r1,CursorCol
	lc		r1,MissileY
	sb		r1,CursorRow
	subui	r1,r1,#1
	sc		r1,MissileY
	setlo	r1,#'^'
	call	DisplayChar
	lb		r1,CursorCol
	subui	r1,r1,#1
	sb		r1,CursorCol
	lb		r1,CursorRow
	subui	r1,r1,#1
	sb		r1,CursorRow
	setlo	r1,#' '
	call	DisplayChar
	lm		[sp],r1/lr
	ret		#16
MissileOff:
	sb		r0,MissileActive
	lc		r1,MissileX
	shrui	r1,r1,#3
	sb		r1,CursorCol
	lc		r1,MissileY
	sb		r1,CursorRow
	setlo	r1,#' '
	call	DisplayChar
	lm		[sp],r1/lr
	ret		#16

DrawMan:
	subui	sp,sp,#24
	sm		[sp],r1/r3/lr
	setlo	r3,#46
	sb		r3,CursorRow
	lc		r3,Manpos
	shrui	r3,r3,#3
	sb		r3,CursorCol
	setlo	r1,#' '
	call	DisplayChar
	setlo	r1,#'#'
	call	DisplayChar
	setlo	r1,#'A'
	call	DisplayChar
	setlo	r1,#'#'
	call	DisplayChar
	setlo	r1,#' '
	call	DisplayChar
	lm		[sp],r1/r3/lr
	ret		#24

DrawInvader:
	lw		r3,InvaderPos
	lw		r1,#233
	sc		r1,[r3]
	lw		r1,#242
	sc		r1,1[r3]
	lw		r1,#223
	sc		r1,2[r3]
	ret

DrawInvaders:
	subui	sp,sp,#40
	sm		[sp],r1/r2/r3/r4/lr
	lc		r1,InvadersRow1
	lc		r4,InvadersColpos
	andi	r2,r1,#1
	beq		r2,r0,dinv1
	lb		r3,InvadersRowpos
	sb		r3,CursorRow
	sb		r4,CursorCol
	setlo	r1,#' '
	call	DisplayByte
	setlo	r1,#'#'
	call	DisplayByte
	setlo	r1,#'#'
	call	DisplayByte
	setlo	r1,#'#'
	call	DisplayByte
	setlo	r1,#' '
	call	DisplayByte
	lb		r1,CursorRow
	addui	r1,r1,#1
	sb		r1,CursorRow
	lb		r1,CursorCol
	subui	r1,r1,#5
	setlo	r1,#' '
	call	DisplayByte
	setlo	r1,#'X'
	call	DisplayByte
	setlo	r1,#' '
	call	DisplayByte
	setlo	r1,#'X'
	call	DisplayByte
	setlo	r1,#' '
	call	DisplayByte
dinv1:
	lm		[sp],r1/r2/r3/r4/lr
	ret		#40
DrawBombs:
	ret

Invaders:
	subui	sp,#240
	sm		[sp],r1/r2/r3/r4/lr
	call	InitializeGame
InvadersLoop:
	call	DrawScore
	call	DrawInvaders
	call	DrawBombs
	call	DrawMissile
	call	DrawMan
TestMoveMan:
	call	KeybdGetChar
	beqi	r1,#'k',MoveManRight
	beqi	r1,#'j',MoveManLeft
	beqi	r1,#' ',FireMissile
	bra		Invaders1
MoveManRight:
	lc		r2,Manpos
	bgtu	r2,#640,Invaders1
	addui	r2,r2,#8
	sc		r2,Manpos
	bra		Invaders1
MoveManLeft:
	lc		r2,Manpos
	ble		r2,r0,Invaders1
	subui	r2,r2,#8
	sc		r2,Manpos
	bra		Invaders1
FireMissile:
	lb		r2,MissileActive
	bne		r2,r0,Invaders1
	setlo	r2,#1
	sb		r2,MissileActive
	lc		r2,Manpos
	sc		r2,MissileX
	setlo	r2,#46
	sc		r2,MissileY
	bra		Invaders1
Invaders1:
	beqi	r1,#CTRLC,InvadersEnd
	bra		InvadersLoop
InvadersEnd:
	lm		[sp],r1/r2/r3/r4/lr
	addui	sp,sp,#240
	bra		Monitor

;==============================================================================
;==============================================================================
;
; Initialize the SD card
; Returns
; r = 0 if successful, 1 otherwise
;
spi_init:
	subui	sp,sp,#24
	sw		lr,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	lea		r3,SPIMASTER
	lw		r1,#SPI_INIT_SD
	outb	r1,SPI_TRANS_TYPE_REG[r3]
	lw		r1,#SPI_TRANS_START
	outb	r1,SPI_TRANS_CTRL_REG[r3]
	nop
spi_init1:
	inb		r1,SPI_TRANS_STATUS_REG[r3]
	mov		r2,r1							; note: some time needs to be wasted
	mov		r1,r2							; between status reads.
	beqi	r1,#SPI_TRANS_BUSY,spi_init1
	inb		r1,SPI_TRANS_ERROR_REG[r3]
	bfext	r1,r1,#1,#0
	bne		r1,#SPI_INIT_NO_ERROR,spi_error
	lea		r1,spi_init_ok_msg
	call	DisplayString
	xor		r1,r1,r1
	bra		spi_init_exit
spi_error:
	call	DisplayByte
	lea		r1,spi_init_error_msg
	call	DisplayString
	lw		r1,#1
spi_init_exit:
	lw		lr,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	ret		#24


; SPI read sector
;
; r1= sector number to read
; r2= address to place read data
; Returns:
; r1 = 0 if successful
;
spi_read_sector:
	subui	sp,sp,#40
	sw		lr,[sp]
	sw		r5,8[sp]
	sw		r2,16[sp]
	sw		r3,24[sp]
	sw		r4,32[sp]
	lea		r3,SPIMASTER

	; spi master wants a byte address, so we multiply the sector number
	; by 512.
	shlui	r1,r1,#9
	outb	r1,SPI_SD_ADDR_7_0_REG[r3]
	shrui	r1,r1,#8
	outb	r1,SPI_SD_ADDR_15_8_REG[r3]
	shrui	r1,r1,#8
	outb	r1,SPI_SD_ADDR_23_16_REG[r3]
	shrui	r1,r1,#8
	outb	r1,SPI_SD_ADDR_31_24_REG[r3]
	
	; Force the reciever fifo to be empty, in case a prior error leaves it
	; in an unknown state.
	lw		r1,#1
	outb	r1,SPI_RX_FIFO_CTRL_REG[r3]

	lw		r1,#RW_READ_SD_BLOCK
	outb	r1,SPI_TRANS_TYPE_REG[r3]
	lw		r1,#SPI_TRANS_START
	outb	r1,SPI_TRANS_CTRL_REG[r3]
	nop
spi_read_sect1:
	inb		r1,SPI_TRANS_STATUS_REG[r3]
	mov		r4,r1							; just a delay between consecutive status reg reads
	mov		r1,r4
	beqi	r1,#SPI_TRANS_BUSY,spi_read_sect1
	inb		r1,SPI_TRANS_ERROR_REG[r3]
	bfext	r1,r1,#3,#2
	bnei	r1,#SPI_READ_NO_ERROR,spi_read_error
	lw		r4,#512		; read 512 bytes from fifo
spi_read_sect2:
	inb		r1,SPI_RX_FIFO_DATA_REG[r3]
	sb		r1,[r2]
	addui	r2,r2,#1
	loop	r4,spi_read_sect2
	xor		r1,r1,r1
	bra		spi_read_ret
spi_read_error:
	call	DisplayByte
	lea		r1,spi_read_error_msg
	call	DisplayString
	lw		r1,#1
spi_read_ret:
	lw		lr,[sp]
	lw		r5,8[sp]
	lw		r2,16[sp]
	lw		r3,24[sp]
	lw		r4,32[sp]
	ret		#40

; Read the boot sector from the disk.
; Must find it first by looking for the signature bytes 'EB' and '55AA'.
;
spi_read_boot:
	subui	sp,sp,#32
	sw		lr,[sp]
	sw		r2,8[sp]
	sw		r3,16[sp]
	sw		r5,24[sp]
	sw		r0,startSector					; default starting sector
	lw		r3,#500	;1934720						; number of sectors to read (up to 1GB)
	lw		r5,#0							; r5 = starting address
spi_read_boot1:
	mov		r1,r5							; r1 = sector number
	lw		r2,#8							; eight digits
	sb		r0,CursorCol
	call	DisplayNum						; Display the sector number being checked
	mov		r1,r5							; r1 = sector number
	lw		r2,#0x100800000					; r2 = target address
	call	spi_read_sector

; The following displays the contents of the sector
;	lw		r1,#0x10
;	lw		r2,#0x3800
;spi_read_boot5:
;	call	DisplayMemB
;	loop	r1,spi_read_boot5

	addui	r5,r5,#1						; move to next sector
	lbu		r1,0x100800000
	cmpui	r2,r1,#0xEB
	beq		r2,r0,spi_read_boot2
spi_read_boot3:
	loop	r3,spi_read_boot1
	lw		r1,#1							; r1 = 1 for error
	bra		spi_read_boot4
spi_read_boot2:
	lea		r1,msgFoundEB
	call	DisplayString
	lbu		r1,0x1008001FE					; check for 0x55AA signature
	bnei	r1,#0x55,spi_read_boot3
	lbu		r1,0x1008001FF
	bnei	r1,#0xAA,spi_read_boot3
	subui	r1,r5,#1
	sw		r1,startSector
	xor		r1,r1,r1						; r1 = 0, for okay status
spi_read_boot4:
	lw		lr,[sp]
	lw		r2,8[sp]
	lw		r3,16[sp]
	lw		r5,24[sp]
	ret		#32

msgFoundEB:
	db	"Found EB code.",CR,LF,0
	.align 4

; Load the FAT tables into memory
;
loadFAT:
	subui	sp,sp,#8
	sw		lr,[sp]
	lcu		r3,0x100800016					; sectors per FAT
	lbu		r2,0x100800010					; number of FATs
	mulu	r3,r3,r2						; offset
	lea		r2,0x100800200					; where to place FAT
	lcu		r5,0x10080000E					; r5 = # reserved sectors before FAT
	lw		r6,startSector
	addu	r5,r5,r6
loadFAT1:
	mov		r1,r5							; r1 = sector #
	call	spi_read_sector
	addui	r5,r5,#1
	addui	r2,r2,#512						; advance 512 bytes
	loop	r3,loadFAT1
	lw		lr,[sp]
	ret		#8

; Load the root directory from disk
; r2 = where to place root directory in memory
;
loadRootDirectory:
	lcu		r3,0x100800016					; sectors per FAT
	lbu		r4,0x100800010					; number of FATs
	mulu	r3,r3,r4						; offset
	lcu		r4,0x10080000E					; r2 = # reserved sectors before FAT
	addu	r3,r3,r4						; r3 = root directory sector number
	lw		r6,startSector
	addu	r5,r3,r6						; r5 = root directory sector number
	; we have to use two byte loads here because the number is at an unaligned data address
	lbu		r7,0x100800011					; r7 <= number of root directory entries
	lbu		r8,0x100800012
	shlui	r8,r8,#8
	or		r7,r7,r8
	mov		r8,r7							; r8 = number of root directory entries
	shlui	r7,r7,#5						; r7 *=32 = size of root directory table (bytes)
	shrui	r7,r7,#9						; r7 /= 512 = number of sectors in root directory
	mov		r3,r7
loadRootDir1:
	mov		r1,r5
	call	spi_read_sector
	addui	r5,r5,#1
	addui	r2,r2,#512
	loop	r3,loadRootDir1

loadBootFile:
	; For now we cheat and just go directly to sector 512.
	bra		loadBootFileTmp

	lcu		r3,0x100800016					; sectors per FAT
	lbu		r2,0x100800010					; number of FATs
	mulu	r3,r3,r2						; offset
	lcu		r2,0x10080000E					; r2 = # reserved sectors before FAT
	addu	r3,r3,r2						; r3 = root directory sector number
	; we have to use two byte loads here because the number is at an unaligned data address
	lbu		r7,0x100800011					; r7 <= number of root directory entries
	lbu		r8,0x100800012
	shlui	r8,r8,#8
	or		r7,r7,r8
	mov		r8,r7							; r8 = number of root directory entries
	shlui	r7,r7,#5						; r7 *=32 = size of root directory table (bytes)
	shrui	r7,r7,#9						; r7 /= 512 = number of sectors in root directory

; now we need to fetch the sectors of the root directory and put them somewhere in
; memory
;
loadBootFile4:
	lw		r1,[r3]							; get filename
	cmpui	r1,r1,#0x454C4946544F4F42		; "BOOTFILE"
	beq		r1,r0,loadBootFile5
loadBootFile3:
	addui	r3,r3,#32						; move to next directory entry
	loop	r7,loadBootFile4
; boot file not found

; here we found the file in the directory
;
loadBootFile5:
	lcu		r2,0x1a[r3]						; get starting cluster
	lcu		r7,0x100800011					; r7 = number of root directory entries
	shlui	r7,r7,#5						; r7 *=32 = size of root directory table (bytes)
	shrui	r7,r7,#9						; r7 /= 512 = number of sectors in root directory

loadBootFileTmp:
	; We load the number of sectors per cluster, then load a single cluster of the file.
	; This is 16kib
	lbu		r3,0x10080000D					; sectors per cluster
	lea		r2,0x100800200					; where to place FAT in memory
	lw		r5,startSector					; r5=start sector of disk
	addui	r5,r5,#512						; r5= sector 512
loadBootFile1:
	mov		r1,r5							; r1=sector to read
	call	spi_read_sector
	addui	r5,r5,#1						; r5 = next sector
	addui	r2,r2,#512
	loop	r3,loadBootFile1
	lhu		r1,0x100800200					; make sure it's bootable
	bnei	r1,#0x544F4F42,loadBootFile2
	lw		r1,#0x16
	lea		r1,msgJumpingToBoot
	call	DisplayString
	lw		r1,#0x100800204
	jal		lr,[r1]
	jmp		Monitor
loadBootFile2:
	lea		r1,msgNotBootable
	call	DisplayString
	jmp		Monitor

msgJumpingToBoot:
	db	"Jumping to boot",0	
msgNotBootable:
	db	"SD card not bootable.",0
spi_init_ok_msg:
	db "SD card initialized okay.",0
spi_init_error_msg:
	db	": error occurred initializing the SD card.",0
spi_boot_error_msg:
	db	"SD card boot error",0
spi_read_error_msg:
	db	"SD card read error",0

	.align	4

;==============================================================================
; Ethernet
;==============================================================================
my_MAC1	EQU	0x00
my_MAC2	EQU	0xFF
my_MAC3	EQU	0xEE
my_MAC4	EQU	0xF0
my_MAC5	EQU	0xDA
my_MAC6	EQU	0x42

	.bss
eth_unique_id	dw		0

	.code

; Initialize the ethmac controller.
; Supply a MAC address, set MD clock
;
eth_init:
	lea		r3,ETHMAC
	lw		r1,#0x64			; 100
	sh		r1,MIIMODER[r3]
	lw		r1,#7				; PHY address
	sh		r1,MIIADDRESS[r3]
	lw		r1,#0xEEF0DA42
	sh		r1,0x40[r3]			; MAC0
	lw		r1,#0x00FF
	sh		r1,0x44[r3]			; MAC1
	ret

; Request a packet and display on screen
; r1 = address where to put packet
;
eth_request_packet:
	subui	sp,sp,#24
	sw		r3,[sp]
	sw		r2,8[sp]
	sw		r4,16[sp]
	lea		r3,ETHMAC
	lw		r2,#4				; clear rx interrupt
	sh		r2,4[r3]
	sh		r1,0x604[r3]		; storage address
	lw		r2,#0xe000			; enable interrupt
	sh		r2,0x600[r3]
eth1:
	nop
	inh		r2,4[r3]
	bfext	r2,r2,#2,#2			; get bit #2
	beq		r2,r0,eth1
	inh		r2,0x600[r3]		; get from descriptor
	shrui	r2,r2,#16
	lw		r3,#0
	lea		r4,TEXTSCR+7560		; second last line of screen
eth20:
	lbu		r2,[r1+r3]			; get byte
	sc		r2,[r4+r3*2]		; store to screen
	addui	r3,r3,#1
	cmpui	r2,r3,#83
	bne		r2,r0,eth20
	lw		r3,[sp]
	lw		r2,8[sp]
	lw		r4,16[sp]
	ret		#24

; r1 = packet address
;
eth_interpret_packet:
	subui	sp,sp,#16
	sw		r3,[sp]
	sw		r2,8[sp]
	lbu		r2,12[r1]
	lbu		r3,13[r1]
	bnei	r2,#8,eth2			; 0x806 ?
	bnei	r3,#6,eth2
	lw		r1,#2				; return r1 = 2 for ARP
eth5:
	lw		r3,[sp]
	lw		r2,8[sp]
	ret		#16
eth2:
	bnei	r2,#8,eth3			; 0x800 ?
	bnei	r3,#0,eth3
	lbu		r2,23[r1]
	bnei	r2,#1,eth4
	lw		r1,#1
	bra		eth5				; return 1 ICMP
eth4:
	bnei	r2,#0x11,eth6
	lw		r1,#3				; return 3 for UDP
	bra		eth5
eth6:
	bnei	r2,#6,eth7
	lw		r1,#4				; return 4 for TCP
	bra		eth5
eth7:
eth3:
	xor		r1,r1,r1			; return zero for unknown
	lw		r3,[sp]
	lw		r2,8[sp]
	ret		#16

; r1 = address of packet to send
; r2 = packet length
;
eth_send_packet:
	subui	sp,sp,#16
	sw		r3,[sp]
	sw		r4,8[sp]
	lea		r3,ETHMAC
	; wait for tx buffer to be clear
eth8:
	inh		r4,0x400[r3]
	bfext	r4,r4,#15,#15
	beqi	r4,#1,eth8
	lw		r4,#1			; clear tx interrupt
	sh		r4,4[r3]
	; set address
	sh		r1,0x404[r3]
	; set the packet length field and enable interrupts
	shlui	r2,r2,#16
	ori		r2,r2,#0xF000
	sh		r2,0x400[r3]
	lw		r4,8[sp]
	lw		r3,[sp]
	ret		#16

; Only for IP type packets (not ARP)
; r1 = rx buffer address
; r2 = swap flag
; Returns:
; r1 = data start index
;
eth_build_packet:
	subui	sp,sp,#64
	sw		r3,[sp]
	sw		r4,8[sp]
	sw		r5,16[sp]
	sw		r6,24[sp]
	sw		r7,32[sp]
	sw		r8,40[sp]
	sw		r9,48[sp]
	sw		r10,56[sp]
	lbu		r3,6[r1]
	lbu		r4,7[r1]
	lbu		r5,8[r1]
	lbu		r6,9[r1]
	lbu		r7,10[r1]
	lbu		r8,11[r1]
	; write to destination header
	sb		r3,[r1]
	sb		r4,1[r1]
	sb		r5,2[r1]
	sb		r6,3[r1]
	sb		r7,4[r1]
	sb		r8,5[r1]
	; write to source header
	lw		r3,#my_MAC1
	sb		r3,6[r1]
	lw		r3,#my_MAC2
	sb		r3,7[r1]
	lw		r3,#my_MAC3
	sb		r3,8[r1]
	lw		r3,#my_MAC4
	sb		r3,9[r1]
	lw		r3,#my_MAC5
	sb		r3,10[r1]
	lw		r3,#my_MAC6
	sb		r3,11[r1]
	bnei	r2,#1,eth16			// if (swap)
	lbu		r3,26[r1]
	lbu		r4,27[r1]
	lbu		r5,28[r1]
	lbu		r6,29[r1]
	; read destination
	lbu		r7,30[r1]
	lbu		r8,31[r1]
	lbu		r9,32[r1]
	lbu		r10,33[r1]
	; write to sender
	sb		r7,26[r1]
	sb		r8,27[r1]
	sb		r9,28[r1]
	sb		r10,29[r1]
	; write destination
	sb		r3,30[r1]
	sb		r4,31[r1]
	sb		r5,32[r1]
	sb		r6,33[r1]
eth16:
	lw		r3,eth_unique_id
	addui	r3,r3,#1
	sw		r3,eth_unique_id
	sb		r3,19[r1]
	shrui	r3,r3,#8
	sb		r3,18[r1]
	lbu		r3,14[r1]
	andi	r3,r3,#0xF
	shlui	r3,r3,#2		; *4
	addui	r1,r3,#14		; return datastart in r1
	lw		r3,[sp]
	lw		r4,8[sp]
	lw		r5,16[sp]
	lw		r6,24[sp]
	lw		r7,32[sp]
	lw		r8,40[sp]
	lw		r9,48[sp]
	lw		r10,56[sp]
	ret		#64

; Compute IPv4 checksum of header
; r1 = packet address
; r2 = data start
;
eth_checksum:
	subui	sp,sp,#24
	sw		r3,[sp]
	sw		r4,8[sp]
	sw		r5,16[sp]
	; set checksum to zero
	sb		r0,24[r1]
	sb		r0,25[r1]
	xor		r3,r3,r3		; r3 = sum = zero
	lw		r4,#14
eth15:
	mov		r5,r2
	subui	r5,r5,#1		; r5 = datastart - 1
	bge		r4,r5,eth14
	lbu		r5,[r1+r4]		; shi = [rx_addr+i]
	lbu		r6,1[r1+r4]		; slo = [rx_addr+i+1]
	shlui	r5,r5,#8
	or		r5,r5,r6		; shilo
	addu	r3,r3,r5		; sum = sum + shilo
	addui	r4,r4,#2		; i = i + 2
	bra		eth15
eth14:
	mov		r5,r3			; r5 = sum
	andi	r3,r3,#0xffff
	shrui	r5,r5,#16
	addu	r3,r3,r5
	com		r3,r3
	sb		r3,25[r1]		; low byte
	shrui	r3,r3,#8
	sb		r3,24[r1]		; high byte
	sw		r3,[sp]
	sw		r4,8[sp]
	sw		r5,16[sp]
	ret		#24	

; r1 = packet address
; returns r1 = 1 if this IP
;	
eth_verifyIP:
	subui	sp,sp,#32
	sw		r2,[sp]
	sw		r3,8[sp]
	sw		r4,16[sp]
	sw		r5,24[sp]
	lbu		r2,30[r1]
	lbu		r3,31[r1]
	lbu		r4,32[r1]
	lbu		r5,33[r1]
	; Check for general broadcast
	bnei	r2,#0xFF,eth11
	bnei	r3,#0xFF,eth11
	bnei	r4,#0xFF,eth11
	bnei	r5,#0xFF,eth11
eth12:
	lw		r1,#1
eth13:
	lw		r2,[sp]
	lw		r3,8[sp]
	lw		r4,16[sp]
	lw		r5,24[sp]
	ret		#32
eth11:
	mov		r1,r2
	shlui	r1,r1,#8
	or		r1,r1,r3
	shlui	r1,r1,#8
	or		r1,r1,r4
	shlui	r1,r1,#8
	or		r1,r1,r5
	beqi	r1,#0xC0A8012A,eth12
	xor		r1,r1,r1
	bra		eth13


eth_main:
	call	eth_init
eth_loop:
	xor		r1,r1,r1		
	lw		r1,#0x1_00000000		; memory address zero
	call	eth_request_packet
	call	eth_interpret_packet	; r1 = packet type

	bnei	r1,#1,eth10
	mov		r2,r1					; save off r1, r2 = packet type
	lw		r1,#0x1_00000000		; memory address zero
	call	eth_verifyIP
	mov     r3,r1
	mov     r1,r2					; r1 = packet type again
	bnei	r3,#1,eth10

	lw		r1,#0x1_00000000		; memory address zero
	lw		r2,#1
	call	eth_build_packet
	mov		r3,r1					; r3 = icmpstart
	lw		r1,#0x1_00000000		; memory address zero
	sb		r0,[r1+r3]				; [rx_addr+icmpstart] = 0
	lbu		r2,17[r1]
	addui	r2,r2,#14				; r2 = len
	mov		r6,r2					; r6 = len
	lbu		r4,2[r1+r3]				; shi
	lbu		r5,3[r1+r3]				; slo
	shlui	r4,r4,#8
	or		r4,r4,r5				; sum = {shi,slo};
	com		r4,r4					; sum = ~sum
	subui	r4,r4,#0x800			; sum = sum - 0x800
	com		r4,r4					; sum = ~sum
	sb		r4,3[r1+r3]
	shrui	r4,r4,#8
	sb		r4,2[r1+r3]
	mov		r2,r3
	call	eth_checksum
	lw		r1,#0x1_00000000		; memory address zero
	mov		r2,r6
	call	eth_send_packet
	jmp		eth_loop
eth10:
	; r2 = rx_addr
	bnei	r1,#2,eth_loop		; Do we have ARP ?
;	xor		r2,r2,r2			; memory address zero
	lw		r2,#1_00000000
	; get the opcode
	lbu		r13,21[r2]
	bnei	r13,#1,eth_loop		; ARP request
	; get destination IP address
	lbu		r9,38[r2]
	lbu		r10,39[r2]
	lbu		r11,40[r2]
	lbu		r12,41[r2]
	; set r15 = destination IP
	mov		r15,r9
	shlui	r15,r15,#8
	or		r15,r15,r10
	shlui	r15,r15,#8
	or		r15,r15,r11
	shlui	r15,r15,#8
	or		r15,r15,r12
	; Is it our IP ?
	bnei	r15,#0xC0A8012A,eth_loop; //192.168.1.42
	; get source IP address
	lbu		r5,28[r2]
	lbu		r6,29[r2]
	lbu		r7,30[r2]
	lbu		r8,31[r2]
	; set r14 = source IP
	mov		r14,r5
	shlui	r14,r14,#8
	or		r14,r14,r6
	shlui	r14,r14,#8
	or		r14,r14,r7
	shlui	r14,r14,#8
	or		r14,r14,r8
	; Get the source MAC address
	lbu		r16,22[r2]
	lbu		r17,23[r2]
	lbu		r18,24[r2]
	lbu		r19,25[r2]
	lbu		r20,26[r2]
	lbu		r21,27[r2]
	; write to destination header
	sb		r16,[r2]
	sb		r17,1[r2]
	sb		r18,2[r2]
	sb		r19,3[r2]
	sb		r20,4[r2]
	sb		r21,5[r2]
	; and write to ARP destination
	sb		r16,32[r2]
	sb		r17,33[r2]
	sb		r18,34[r2]
	sb		r19,35[r2]
	sb		r20,36[r2]
	sb		r21,37[r2]
	; write to source header
;	stbc	#0x00,6[r2]
;	stbc	#0xFF,7[r2]
;	stbc	#0xEE,8[r2]
;	stbc	#0xF0,9[r2]
;	stbc	#0xDA,10[r2]
;	stbc	#0x42,11[r2]
	sb		r0,6[r2]
	lw		r1,#0xFF
	sb		r1,7[r2]
	lw		r1,#0xEE
	sb		r1,8[r2]
	lw		r1,#0xF0
	sb		r1,9[r2]
	lw		r1,#0xDA
	sb		r1,10[r2]
	lw		r1,#0x42
	sb		r1,11[r2]
	; write to ARP source
;	stbc	#0x00,22[r2]
;	stbc	#0xFF,23[r2]
;	stbc	#0xEE,24[r2]
;	stbc	#0xF0,25[r2]
;	stbc	#0xDA,26[r2]
;	stbc	#0x42,27[r2]
	sb		r0,22[r2]
	lw		r1,#0xFF
	sb		r1,23[r2]
	lw		r1,#0xEE
	sb		r1,24[r2]
	lw		r1,#0xF0
	sb		r1,25[r2]
	lw		r1,#0xDA
	sb		r1,26[r2]
	lw		r1,#0x42
	sb		r1,27[r2]
	; swap sender / destination IP
	; write sender
	sb		r9,28[r2]
	sb		r10,29[r2]
	sb		r11,30[r2]
	sb		r12,31[r2]
	; write destination
	sb		r5,38[r2]
	sb		r6,39[r2]
	sb		r7,40[r2]
	sb		r8,41[r2]
	; change request to reply
;	stbc	#2,21[r2]
	lw		r1,#2
	sb		r1,21[r2]
	mov		r1,r2			; r1 = packet address
	lw		r2,#0x2A		; r2 = packet length
	call	eth_send_packet
	jmp		eth_loop

	
;==============================================================================
;==============================================================================
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
; Adapted to the Raptor64 by:                                    ;
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
GOSTART:	
		jmp	CSTART	;	Cold Start entry point
GOWARM:	
		jmp	WSTART	;	Warm Start entry point
GOOUT:	
		jmp	OUTC	;	Jump to character-out routine
GOIN:	
		jmp	INC		;Jump to character-in routine
GOAUXO:	
		jmp	AUXOUT	;	Jump to auxiliary-out routine
GOAUXI:	
		jmp	AUXIN	;	Jump to auxiliary-in routine
GOBYE:	
		jmp	BYEBYE	;	Jump to monitor, DOS, etc.
;
; Modifiable system constants:
;
		align	8
TXTBGN	dw	0x000000001_00600000	;TXT		;beginning of program memory
ENDMEM	dw	0x000000001_07FFFFF8	;	end of available memory
;
; The main interpreter starts here:
;
; Usage
; r1 = temp
; r8 = text buffer pointer
; r12 = end of text in text buffer
;
	align	16
CSTART:
	; First save off the link register and OS sp value
	subui	sp,sp,#8
	sw		lr,[sp]
	sw		sp,OSSP
	lw		sp,ENDMEM	; initialize stack pointer
	subui	sp,sp,#8
	sw      lr,[sp]    ; save off return address
	sb		r0,CursorRow	; set screen output
	sb		r0,CursorCol
	sb		r0,CursorFlash
	sh		r0,pos
	lw		r2,#0x10000020	; black chars, yellow background
;	sh		r2,charToPrint
	call	ClearScreen
	lea		r1,msgInit	;	tell who we are
;	call	PRMESGAUX
	lea		r1,msgInit	;	tell who we are
	call	PRMESG
	lw		r1,TXTBGN	;	init. end-of-program pointer
	sw		r1,TXTUNF
	lw		r1,ENDMEM	;	get address of end of memory
	subui	r1,r1,#4096	; 	reserve 4K for the stack
	sw		r1,STKBOT
	subui   r1,r1,#16384 ;   1000 vars
	sw      r1,VARBGN
	call    clearVars   ; clear the variable area
	lw      r1,VARBGN   ; calculate number of bytes free
	lw		r3,TXTUNF
	subu    r1,r1,r3
	setlo	r2,#0
	call	PRTNUM
	lea		r1,msgBytesFree
	call	PRMESG
WSTART:
	sw		r0,LOPVAR   ; initialize internal variables
	sw		r0,STKGOS
	sw		r0,CURRNT	;	current line number pointer = 0
	lw		sp,ENDMEM	;	init S.P. again, just in case
	lea		r1,msgReady	;	display "Ready"
	call	PRMESG
ST3:
	setlo	r1,#'>'		; Prompt with a '>' and
	call	GETLN		; read a line.
	call	TOUPBUF 	; convert to upper case
	mov		r12,r8		; save pointer to end of line
	lea		r8,BUFFER	; point to the beginning of line
	call	TSTNUM		; is there a number there?
	call	IGNBLK		; skip trailing blanks
; does line no. exist? (or nonzero?)
	beq		r1,r0,DIRECT		; if not, it's a direct statement
	bleu	r1,#0xFFFF,ST2	; see if line no. is <= 16 bits
	lea		r1,msgLineRange	; if not, we've overflowed
	bra		ERROR
ST2:
    ; ugliness - store a character at potentially an
    ; odd address (unaligned).
	mov		r2,r1       ; r2 = line number
	sb		r2,-2[r8]
	shrui	r2,r2,#8
	sb		r2,-1[r8]	; store the binary line no.
	subui	r8,r8,#2
	call	FNDLN		; find this line in save area
	mov		r13,r9		; save possible line pointer
	beq		r1,r0,ST4	; if not found, insert
	; here we found the line, so we're replacing the line
	; in the text area
	; first step - delete the line
	setlo	r1,#0
	call	FNDNXT		; find the next line (into r9)
	bne		r1,r0,ST7
	beq		r9,r0,ST6	; no more lines
ST7:
	mov		r1,r9		; r1 = pointer to next line
	mov		r2,r13		; pointer to line to be deleted
	lw		r3,TXTUNF	; points to top of save area
	call	MVUP		; move up to delete
	sw		r2,TXTUNF	; update the end pointer
	; we moved the lines of text after the line being
	; deleted down, so the pointer to the next line
	; needs to be reset
	mov		r9,r13
	bra		ST4
	; here there were no more lines, so just move the
	; end of text pointer down
ST6:
	sw		r13,TXTUNF
	mov		r9,r13
ST4:
	; here we're inserting because the line wasn't found
	; or it was deleted	from the text area
	mov		r1,r12		; calculate the length of new line
	sub		r1,r1,r8
	blei	r1,#3,ST3	; is it just a line no. & CR? if so, it was just a delete

	lw		r11,TXTUNF	; compute new end of text
	mov		r10,r11		; r10 = old TXTUNF
	add		r11,r11,r1		; r11 = new top of TXTUNF (r1=line length)

	lw		r1,VARBGN	; see if there's enough room
	bltu	r11,r1,ST5
	lea		r1,msgTooBig	; if not, say so
	jmp		ERROR

	; open a space in the text area
ST5:
	sw		r11,TXTUNF	; if so, store new end position
	mov		r1,r10		; points to old end of text
	mov		r2,r11		; points to new end of text
	mov		r3,r9       ; points to start of line after insert line
	call	MVDOWN		; move things out of the way

	; copy line into text space
	mov		r1,r8		; set up to do the insertion; move from buffer
	mov		r2,r13		; to vacated space
	mov		r3,r12		; until end of buffer
	call	MVUP		; do it
	bra		ST3			; go back and get another line

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
	db	"POKE",'C'+0x80
	db	"POKE",'H'+0x80
	db	"POKE",'W'+0x80
	db	"POK",'E'+0x80
	db	"STO",'P'+0x80
	db	"BY",'E'+0x80
	db	"SY",'S'+0x80
	db	"CL",'S'+0x80
    db  "CL",'R'+0x80
    db	"RDC",'F'+0x80
	db	0
TAB4:
	db	"PEEK",'C'+0x80        ;Functions
	db	"PEEK",'H'+0x80        ;Functions
	db	"PEEK",'W'+0x80        ;Functions
	db	"PEE",'K'+0x80         ;Functions
	db	"RN",'D'+0x80
	db	"AB",'S'+0x80
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

	.align	8

;* Execution address tables:
TAB1_1:
	dw	LISTX			;Direct commands
	dw	LOAD
	dw	NEW
	dw	RUN
	dw	SAVE
TAB2_1:
	dw	NEXT		;	Direct / statement
	dw	LET
	dw	IF
	dw	GOTO
	dw	GOSUB
	dw	RETURN
	dw	IF2			; REM
	dw	FOR
	dw	INPUT
	dw	PRINT
	dw	POKEC
	dw	POKEH
	dw	POKEW
	dw	POKE
	dw	STOP
	dw	GOBYE
	dw	SYSX
	dw	_cls
	dw  _clr
	dw	_rdcf
	dw	DEFLT
TAB4_1:
	dw  PEEKC
	dw  PEEKH
	dw  PEEKW
	dw	PEEK			;Functions
	dw	RND
	dw	ABS
	dw	SIZEX
	dw  USRX
	dw	XP40
TAB5_1
	dw	FR1			;"TO" in "FOR"
	dw	QWHAT
TAB6_1
	dw	FR2			;"STEP" in "FOR"
	dw	FR3
TAB8_1
	dw	XP11	;>=		Relational operators
	dw	XP12	;<>
	dw	XP13	;>
	dw	XP15	;=
	dw	XP14	;<=
	dw	XP16	;<
	dw	XP17
TAB9_1
    dw  XP_AND
    dw  XP_ANDX
TAB10_1
    dw  XP_OR
    dw  XP_ORX

	.align	4

;*
; r3 = match flag (trashed)
; r9 = text table
; r10 = exec table
; r11 = trashed
DIRECT:
	lea		r9,TAB1
	lea		r10,TAB1_1
EXEC:
	mov		r11,lr		; save link reg
	call	IGNBLK		; ignore leading blanks
	mov		lr,r11		; restore link reg
	mov		r11,r8		; save the pointer
	setlo	r3,#0		; clear match flag
EXLP:
	lbu		r1,[r8]		; get the program character
	addui	r8,r8,#1
	lbu		r2,[r9]		; get the table character
	bne		r2,r0,EXNGO		; If end of table,
	mov		r8,r11		;	restore the text pointer and...
	bra		EXGO		;   execute the default.
EXNGO:
	beq		r1,r3,EXGO	; Else check for period... if so, execute
	andi	r2,r2,#0x7f	; ignore the table's high bit
	beq		r2,r1,EXMAT;		is there a match?
	addui	r10,r10,#8	;if not, try the next entry
	mov		r8,r11		; reset the program pointer
	setlo	r3,#0		; sorry, no match
EX1:
	addui	r9,r9,#1
	lb		r1,-1[r9]	; get to the end of the entry
	bgt		r1,r0,EX1
	bra		EXLP		; back for more matching
EXMAT:
	setlo	r3,#'.'		; we've got a match so far
	addui	r9,r9,#1
	lb		r1,-1[r9]	; end of table entry?
	bgt		r1,r0,EXLP		; if not, go back for more
EXGO:
	lw		r11,[r10]	; execute the appropriate routine
	jal		r0,[r11]

;    lb      r1,[r8]     ; get token from text space
;    bpl
;    and     r1,#0x7f
;    shl     r1,#2       ; * 4 - word offset
;    add     r1,r1,#TAB1_1
;    lw      r1,[r1]
;    jmp     [r1]

    
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
; 'STOP<CR>' goes back to WSTART
;
; 'RUN<CR>' finds the first stored line, stores its address
; in CURRNT, and starts executing it. Note that only those
; commands in TAB2 are legal for a stored program.
;
; There are 3 more entries in 'RUN':
; 'RUNNXL' finds next line, stores it's address and executes it.
; 'RUNTSL' stores the address of this line and executes it.
; 'RUNSML' continues the execution on same line.
;
; 'GOTO expr<CR>' evaluates the expression, finds the target
; line, and jumps to 'RUNTSL' to do it.
;
NEW:
	call	ENDCHK
	lw		r1,TXTBGN
	sw		r1,TXTUNF	;	set the end pointer
	call    clearVars

STOP:
	call	ENDCHK
	bra		WSTART		; WSTART will reset the stack

RUN:
	call	ENDCHK
	lw		r8,TXTBGN	;	set pointer to beginning
	sw		r8,CURRNT
	call    clearVars

RUNNXL:					; RUN <next line>
	lw		r1,CURRNT	; executing a program?
	beq		r1,r0,WSTART	; if not, we've finished a direct stat.
	setlo	r1,#0	    ; else find the next line number
	mov		r9,r8
	call	FNDLNP		; search for the next line
	bne		r1,r0,RUNTSL
	bne		r9,r0,RUNTSL
	bra		WSTART		; if we've fallen off the end, stop

RUNTSL:					; RUN <this line>
	sw		r9,CURRNT	; set CURRNT to point to the line no.
	lea		r8,2[r9]	; set the text pointer to

RUNSML:                 ; RUN <same line>
	call	CHKIO		; see if a control-C was pressed
	lea		r9,TAB2		; find command in TAB2
	lea		r10,TAB2_1
	bra		EXEC		; and execute it

GOTO:
	call	OREXPR		;evaluate the following expression
	mov     r5,r1
	call	ENDCHK		;must find end of line
	mov     r1,r5
	call	FNDLN		; find the target line
	bne		r1,r0,RUNTSL		; go do it
	lea		r1,msgBadGotoGosub
	bra		ERROR		; no such line no.

_clr:
    call    clearVars
    bra     FINISH

; Clear the variable area of memory
clearVars:
    subui   sp,sp,#16
    sw		r6,[sp]
    sw		lr,8[sp]
    setlo   r6,#2048    ; number of words to clear
    lw      r1,VARBGN
cv1:
    sw      r0,[r1]
    add     r1,r1,#8
    loop	r6,cv1
    lw		lr,8[sp]
    lw		r6,[sp]
    ret		#16


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
	call	TSTNUM		; see if there's a line no.
	mov     r5,r1
	call	ENDCHK		; if not, we get a zero
	mov     r1,r5
	call	FNDLN		; find this or next line
LS1:
	bne		r1,r0,LS4
	beq		r9,r0,WSTART	; warm start if we passed the end
LS4:
	mov		r1,r9
	call	PRTLN		; print the line
	mov		r9,r1		; set pointer for next
	call	CHKIO		; check for listing halt request
	beq		r1,r0,LS3
	bnei	r1,#CTRLS,LS3	; pause the listing?
LS2:
	call	CHKIO		; if so, wait for another keypress
	beq		r1,r0,LS2
LS3:
	setlo	r1,#0
	call	FNDLNP		; find the next line
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
	lw		r5,#11		; D4 = number of print spaces
	setlo	r3,#':'
	lea		r4,PR2
	call	TSTC		; if null list and ":"
	call	CRLF		; give CR-LF and continue
	bra		RUNSML		;		execution on the same line
PR2:
	setlo	r3,#CR
	lea		r4,PR0
	call	TSTC		;if null list and <CR>
	call	CRLF		;also give CR-LF and
	bra		RUNNXL		;execute the next line
PR0:
	setlo	r3,#'#'
	lea		r4,PR1
	call	TSTC		;else is it a format?
	call	OREXPR		; yes, evaluate expression
	lw		r5,r1		; and save it as print width
	bra		PR3		; look for more to print
PR1:
	setlo	r3,#'$'
	lea		r4,PR4
	call	TSTC	;	is character expression? (MRL)
	call	OREXPR	;	yep. Evaluate expression (MRL)
	call	GOOUT	;	print low byte (MRL)
	bra		PR3		;look for more. (MRL)
PR4:
	call	QTSTG	;	is it a string?
	; the following branch must occupy only two bytes!
	bra		PR8		;	if not, must be an expression
PR3:
	setlo	r3,#','
	lea		r4,PR6
	call	TSTC	;	if ",", go find next
	call	FIN		;in the list.
	bra		PR0
PR6:
	call	CRLF		;list ends here
	bra		FINISH
PR8:
	call	OREXPR		; evaluate the expression
	lw		r2,r5		; set the width
	call	PRTNUM		; print its value
	bra		PR3			; more to print?

FINISH:
	call	FIN		; Check end of command
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
	call	PUSHA		; save the current 'FOR' parameters
	call	OREXPR		; get line number
	call	FNDLN		; find the target line
	bne		r1,r0,gosub1
	lea		r1,msgBadGotoGosub
	bra		ERROR		; if not there, say "How?"
gosub1:
	sub		sp,sp,#24
	sw		r8,[sp]		; save text pointer
	lw		r1,CURRNT
	sw		r1,8[sp]	; found it, save old 'CURRNT'...
	lw		r1,STKGOS
	sw		r1,16[sp]	; and 'STKGOS'
	sw		r0,LOPVAR	; load new values
	sw		sp,STKGOS
	bra		RUNTSL


;******************************************************************
; 'RETURN<CR>' undoes everything that 'GOSUB' did, and thus
; returns the execution to the command after the most recent
; 'GOSUB'.  If 'STKGOS' is zero, it indicates that we never had
; a 'GOSUB' and is thus an error.
;******************************************************************
;
RETURN:
	call	ENDCHK		; there should be just a <CR>
	lw		r1,STKGOS	; get old stack pointer
	bne		r1,r0,return1
	lea		r1,msgRetWoGosub
	bra		ERROR		; if zero, it doesn't exist
return1:
	mov		sp,r1		; else restore it
	lw		r1,16[sp]
	sw		r1,STKGOS	; and the old 'STKGOS'
	lw		r1,8[sp]
	sw		r1,CURRNT	; and the old 'CURRNT'
	lw		r8,[sp]		; and the old text pointer
	add		sp,sp,#24
	call	POPA		;and the old 'FOR' parameters
	bra		FINISH		;and we are back home

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
	call	PUSHA		; save the old 'FOR' save area
	call	SETVAL		; set the control variable
	sw		r1,LOPVAR	; save its address
	lea		r9,TAB5
	lea		r10,TAB5_1; use 'EXEC' to test for 'TO'
	jmp		EXEC
FR1:
	call	OREXPR		; evaluate the limit
	sw		r1,LOPLMT	; save that
	lea		r9,TAB6
	lea		r10,TAB6_1	; use 'EXEC' to test for the word 'STEP
	jmp		EXEC
FR2:
	call	OREXPR		; found it, get the step value
	bra		FR4
FR3:
	setlo	r1,#1		; not found, step defaults to 1
FR4:
	sw		r1,LOPINC	; save that too
FR5:
	lw		r2,CURRNT
	sw		r2,LOPLN	; save address of current line number
	sw		r8,LOPPT	; and text pointer
	lw		r3,sp		; dig into the stack to find 'LOPVAR'
	lw		r6,LOPVAR
	bra		FR7
FR6:
	addui	r3,r3,#40	; look at next stack frame
FR7:
	lw		r2,[r3]		; is it zero?
	beq		r2,r0,FR8	; if so, we're done
	bne		r2,r6,FR6	; same as current LOPVAR? nope, look some more

    lw      r1,r3       ; Else remove 5 long words from...
	addui	r2,r3,#40   ; inside the stack.
	lw		r3,sp		
	call	MVDOWN
	add		sp,sp,#40	; set the SP 5 long words up
FR8:
    bra	    FINISH		; and continue execution


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
	setlo	r1,#0		; don't allocate it
	call	TSTV		; get address of variable
	bne		r1,r0,NX4
	lea		r1,msgNextVar
	bra		ERROR		; if no variable, say "What?"
NX4:
	mov		r9,r1		; save variable's address
NX0:
	lw		r1,LOPVAR	; If 'LOPVAR' is zero, we never...
	bne		r1,r0,NX5   ; had a FOR loop
	lea		r1,msgNextFor
	bra		ERROR
NX5:
	beq		r1,r9,NX2	; else we check them OK, they agree
	call	POPA		; nope, let's see the next frame
	bra		NX0
NX2:
	lw		r1,[r9]		; get control variable's value
	lw		r2,LOPINC
	addu	r1,r1,r2	; add in loop increment
;	BVS.L	QHOW		say "How?" for 32-bit overflow
	sw		r1,[r9]		; save control variable's new value
	lw		r3,LOPLMT	; get loop's limit value
	bgt		r2,r0,NX1	; check loop increment, branch if loop increment is positive
	blt		r1,r3,NXPurge	; test against limit
	bra     NX3
NX1:
	bgt		r1,r3,NXPurge
NX3:
	lw		r8,LOPLN	; Within limit, go back to the...
	sw		r8,CURRNT
	lw		r8,LOPPT	; saved 'CURRNT' and text pointer.
	bra		FINISH
NXPurge:
    call    POPA        ; purge this loop
    bra     FINISH


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
    call	OREXPR		; evaluate the expression
IF1:
    bne	    r1,r0,RUNSML		; is it zero? if not, continue
IF2:
    mov		r9,r8		; set lookup pointer
	setlo	r1,#0		; find line #0 (impossible)
	call	FNDSKP		; if so, skip the rest of the line
	bgt		r1,r0,WSTART	; if no next line, do a warm start
IF3:
	bra		RUNTSL		; run the next line


;******************************************************************
; INPUT is called first and establishes a stack frame
INPERR:
	lw		sp,STKINP	; restore the old stack pointer
	lw		r8,16[sp]
	sw		r8,CURRNT	; and old 'CURRNT'
	lw		r8,8[sp]	; and old text pointer
	addui	sp,sp,#40	; fall through will subtract 40

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
	subui	sp,sp,#40	; allocate stack frame
	sw      r5,32[sp]
IP6:
	sw		r8,[sp]		; save in case of error
	call	QTSTG		; is next item a string?
	bra		IP2			; nope - this branch must take only two bytes
	setlo	r1,#1		; allocate var
	call	TSTV		; yes, but is it followed by a variable?
	beq     r1,r0,IP4   ; if not, brnch
	mov		r10,r1		; put away the variable's address
	bra		IP3			; if so, input to variable
IP2:
	sw		r8,8[sp]	; save for 'PRTSTG'
	setlo	r1,#1
	call	TSTV		; must be a variable now
	bne		r1,r0,IP7
	lea		r1,msgInputVar
	bra		ERROR		; "What?" it isn't?
IP7:
	mov		r10,r1		; put away the variable's address
	lb		r5,[r8]		; get ready for 'PRTSTG' by null terminating
	sb		r0,[r8]
	lw		r1,8[sp]	; get back text pointer
	call	PRTSTG		; print string as prompt
	sb		r5,[r8]		; un-null terminate
IP3
	sw		r8,8[sp]	; save in case of error
	lw		r1,CURRNT
	sw		r1,16[sp]	; also save 'CURRNT'
	setlo	r1,#-1
	sw		r1,CURRNT	; flag that we are in INPUT
	sw		sp,STKINP	; save the stack pointer too
	sw		r10,24[sp]	; save the variable address
	setlo	r1,#':'		; print a colon first
	call	GETLN		; then get an input line
	lea		r8,BUFFER	; point to the buffer
	call	OREXPR		; evaluate the input
	lw		r10,24[sp]	; restore the variable address
	sw		r1,[r10]	; save value in variable
	lw		r1,16[sp]	; restore old 'CURRNT'
	sw		r1,CURRNT
	lw		r8,8[sp]	; and the old text pointer
IP4:
	setlo	r3,#','
	lea		r4,IP5		; is the next thing a comma?
	call	TSTC
	bra		IP6			; yes, more items
IP5:
    lw      r5,32[sp]
	add		sp,sp,#40	; clean up the stack
	jmp		FINISH


DEFLT:
    lb      r1,[r8]
	beq	    r1,#CR,FINISH	    ; empty line is OK else it is 'LET'


;******************************************************************
; 'LET' is followed by a list of items separated by commas.
; Each item consists of a variable, an equals sign, and an
; expression.  The interpreter evaluates the expression and sets
; the variable to that value.  The interpreter will also handle
; 'LET' commands without the word 'LET'.  This is done by 'DEFLT'.
;******************************************************************
;
LET:
    call	SETVAL		; do the assignment
    setlo	r3,#','
    lea		r4,FINISH
	call	TSTC		; check for more 'LET' items
	bra	    LET
LT1:
    bra	    FINISH		; until we are finished.


;******************************************************************
; *** LOAD *** & SAVE ***
;
; These two commands transfer a program to/from an auxiliary
; device such as a cassette, another computer, etc.  The program
; is converted to an easily-stored format: each line starts with
; a colon, the line no. as 4 hex digits, and the rest of the line.
; At the end, a line starting with an '@' sign is sent.  This
; format can be read back with a minimum of processing time by
; the Butterfly.
;******************************************************************
;
LOAD
	lw		r8,TXTBGN	; set pointer to start of prog. area
	setlo	r1,#CR		; For a CP/M host, tell it we're ready...
	call	GOAUXO		; by sending a CR to finish PIP command.
LOD1:
	call	GOAUXI		; look for start of line
	ble		r1,r0,LOD1
	beq		r1,#'@',LODEND	; end of program?
	beq     r1,#0x1A,LODEND	; or EOF marker
	bne		r1,#':',LOD1	; if not, is it start of line? if not, wait for it
	call	GCHAR		; get line number
	sb		r1,[r8]		; store it
	shrui	r1,r1,#8
	sb		r1,1[r8]
	addui	r8,r8,#2
LOD2:
	call	GOAUXI		; get another text char.
	ble		r1,r0,LOD2
	sb		r1,[r8]
	addui	r8,r8,#1	; store it
	bne		r1,#CR,LOD2		; is it the end of the line? if not, go back for more
	bra		LOD1		; if so, start a new line
LODEND:
	sw		r8,TXTUNF	; set end-of program pointer
	bra		WSTART		; back to direct mode


; get character from input (16 bit value)
GCHAR:
	subui	sp,sp,#24
	sw		r5,[sp]
	sw		r6,8[sp]
	sw		lr,16[sp]
	setlo   r6,#3       ; repeat four times
	setlo	r5,#0
GCHAR1:
	call	GOAUXI		; get a char
	ble		r1,r0,GCHAR1
	call	asciiToHex
	shli	r5,r5,#4
	or		r5,r5,r1
	loop	r6,GCHAR1
	mov		r1,r5
	lw		lr,16[sp]
	lw		r6,8[sp]
	lw		r5,[sp]
	ret		#24


; convert an ascii char to hex code
; input
;	r1 = char to convert

asciiToHex:
	blei	r1,#'9',a2h1	; less than '9'
	subui	r1,r1,#7	; shift 'A' to '9'+1
a2h1:
	subui	r1,r1,#'0'	;
	andi	r1,r1,#15	; make sure a nybble
	ret



SAVE:
	lw		r8,TXTBGN	;set pointer to start of prog. area
	lw		r9,TXTUNF	;set pointer to end of prog. area
SAVE1:
	call    AUXOCRLF    ; send out a CR & LF (CP/M likes this)
	bgeu	r8,r9,SAVEND	; are we finished?
	setlo	r1,#':'		; if not, start a line
	call	GOAUXO
	lbu		r1,[r8]		; get line number
	lbu		r2,1[r8]
	shli	r2,r2,#8
	or		r1,r1,r2
	addui	r8,r8,#2
	call	PWORD       ; output line number as 4-digit hex
SAVE2:
	lb		r1,[r8]		; get a text char.
	addui	r8,r8,#1
	beqi	r1,#CR,SAVE1		; is it the end of the line? if so, send CR & LF and start new line
	call	GOAUXO		; send it out
	bra		SAVE2		; go back for more text
SAVEND:
	setlo	r1,#'@'		; send end-of-program indicator
	call	GOAUXO
	call    AUXOCRLF    ; followed by a CR & LF
	setlo	r1,#0x1A	; and a control-Z to end the CP/M file
	call	GOAUXO
	bra		WSTART		; then go do a warm start


; output a CR LF sequence to auxillary output
; Registers Affected
;   r3 = LF
AUXOCRLF:
    subui   sp,sp,#8
    sw      lr,[sp]
    setlo   r1,#CR
    call    GOAUXO
    setlo   r1,#LF
    call    GOAUXO
    lw      lr,[sp]
    ret		#8


; output a word in hex format
; tricky because of the need to reverse the order of the chars
PWORD:
	sub		sp,sp,#16
	sw		lr,[sp]
	sw		r5,8[sp]
	lea		r5,NUMWKA+15
	mov		r4,r1		; r4 = value
pword1:
    mov     r1,r4	    ; r1 = value
    shrui	r4,r4,#4	; shift over to next nybble
    call    toAsciiHex  ; convert LS nybble to ascii hex
    sb      r1,[r5]     ; save in work area
    subui   r5,r5,#1
    cmpui   r1,r5,#NUMWKA
    bge     r1,r0,pword1
pword2:
    addui   r5,r5,#1
    lb      r1,[r5]     ; get char to output
	call	GOAUXO		; send it
	cmpui   r1,r5,#NUMWKA+15
	blt     r1,r0,pword2
	lw		r5,8[sp]
	lw		lr,[sp]
	ret		#16


; convert nybble in r2 to ascii hex char2
; r2 = character to convert

toAsciiHex:
	andi	r1,r1,#15	; make sure it's a nybble
	blti	r1,#10,tah1	; > 10 ?
	addi	r1,r1,#7	; bump it up to the letter 'A'
tah1:
	addui	r1,r1,#'0'	; bump up to ascii '0'
	ret



;******************************************************************
; *** POKE *** & SYSX ***
;
; 'POKE expr1,expr2' stores the byte from 'expr2' into the memory
; address specified by 'expr1'.
;
; 'SYSX expr' jumps to the machine language subroutine whose
; starting address is specified by 'expr'.  The subroutine can use
; all registers but must leave the stack the way it found it.
; The subroutine returns to the interpreter by executing an RET.
;******************************************************************
;
POKE:
	subui	sp,sp,#8
	call	OREXPR		; get the memory address
	setlo	r3,#','
	lea		r4,PKER		; it must be followed by a comma
	call	TSTC		; it must be followed by a comma
	sw		r1,[sp]	    ; save the address
	call	OREXPR		; get the byte to be POKE'd
	lw		r2,[sp]	    ; get the address back
	sb		r1,[r2]		; store the byte in memory
	addui	sp,sp,#8
	bra		FINISH
PKER:
	lea		r1,msgComma
	bra		ERROR		; if no comma, say "What?"

POKEC:
	subui	sp,sp,#8
	call	OREXPR		; get the memory address
	setlo	r3,#','
	lea		r4,PKER		; it must be followed by a comma
	call	TSTC		; it must be followed by a comma
	sw		r1,[sp]	    ; save the address
	call	OREXPR		; get the byte to be POKE'd
	lw		r2,[sp]	    ; get the address back
	sc		r1,[r2]		; store the char in memory
	addui	sp,sp,#8
	jmp		FINISH

POKEH:
	subui	sp,sp,#8
	call	OREXPR		; get the memory address
	setlo	r3,#','
	lea		r4,PKER		; it must be followed by a comma
	call	TSTC
	sw		r1,[sp]	    ; save the address
	call	OREXPR		; get the byte to be POKE'd
	lw		r2,[sp]	    ; get the address back
	sh		r1,[r2]		; store the word in memory
	addui	sp,sp,#8
	jmp		FINISH

POKEW:
	subui	sp,sp,#8
	call	OREXPR		; get the memory address
	setlo	r3,#','
	lea		r4,PKER		; it must be followed by a comma
	call	TSTC
	sw		r1,[sp]	    ; save the address
	call	OREXPR		; get the word to be POKE'd
	lw		r2,[sp]	    ; get the address back
	sw		r1,[r2]		; store the word in memory
	addui	sp,sp,#8
	jmp		FINISH

SYSX:
	subui	sp,sp,#8
	call	OREXPR		; get the subroutine's address
	bne		r1,r0,sysx1	; make sure we got a valid address
	lea		r1,msgSYSBad
	bra		ERROR
sysx1:
	sw		r8,[sp]	    ; save the text pointer
	jal		r31,[r1]	; jump to the subroutine
	lw		r8,[sp]	    ; restore the text pointer
	addui	sp,sp,#8
	bra		FINISH

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
	subui	sp,sp,#16
	sw		lr,[sp]
	call	ANDEXPR		; get first <ANDEXPR>
XP_OR1:
	sw		r1,4[sp]	; save <ANDEXPR> value
	lea		r9,TAB10	; look up a logical operator
	lea		r10,TAB10_1
	jmp		EXEC		; go do it
XP_OR:
    call    ANDEXPR
    lw      r2,8[sp]
    or      r1,r1,r2
    bra     XP_OR1
XP_ORX:
	lw		r1,8[sp]
    lw      lr,[sp]
    ret		#16


; <ANDEXPR>::=<EXPR> AND <EXPR> ...
;
ANDEXPR:
	subui	sp,sp,#16
	sw		lr,[sp]
	call	EXPR		; get first <EXPR>
XP_AND1:
	sw		r1,8[sp]	; save <EXPR> value
	lea		r9,TAB9		; look up a logical operator
	lea		r10,TAB9_1
	jmp		EXEC		; go do it
XP_AND:
    call    EXPR
    lw      r2,8[sp]
    and     r1,r1,r2
    bra     XP_AND1
XP_ANDX:
	lw		r1,8[sp]
    lw      lr,[sp]
    ret		#16


; Determine if the character is a digit
;   Parameters
;       r1 = char to test
;   Returns
;       r1 = 1 if digit, otherwise 0
;
isDigit:
    blt     r1,#'0',isDigitFalse
    bgt     r1,#'9',isDigitFalse
    setlo   r1,#1
    ret
isDigitFalse:
    setlo   r1,#0
    ret


; Determine if the character is a alphabetic
;   Parameters
;       r1 = char to test
;   Returns
;       r1 = 1 if alpha, otherwise 0
;
isAlpha:
    blt     r1,#'A',isAlphaFalse
    ble     r1,#'Z',isAlphaTrue
    blt     r1,#'a',isAlphaFalse
    bgt     r1,#'z',isAlphaFalse
isAlphaTrue:
    setlo   r1,#1
    ret
isAlphaFalse:
    setlo   r1,#0
    ret


; Determine if the character is a alphanumeric
;   Parameters
;       r1 = char to test
;   Returns
;       r1 = 1 if alpha, otherwise 0
;
isAlnum:
    subui   sp,sp,#8
    sw      lr,[sp]
    or      r2,r1,r0		; save test char
    call    isDigit
    bne		r1,r0,isDigitx	; if it is a digit
    or      r1,r2,r0		; get back test char
    call    isAlpha
isDigitx:
    lw      lr,[sp]
    ret		#8


EXPR:
	subui	sp,sp,#16
	sw		lr,[sp]
	call	EXPR2
	sw		r1,8[sp]	; save <EXPR2> value
	lea		r9,TAB8		; look up a relational operator
	lea		r10,TAB8_1
	jmp		EXEC		; go do it
XP11:
	lw		r1,8[sp]
	call	XP18	; is it ">="?
	bge		r2,r1,XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP12:
	lw		r1,8[sp]
	call	XP18	; is it "<>"?
	bne		r2,r1,XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP13:
	lw		r1,8[sp]
	call	XP18	; is it ">"?
	bgt		r2,r1,XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP14:
	lw		r1,8[sp]
	call	XP18	; is it "<="?
	ble		r2,r1,XPRT1	; no, return r2=1
	bra		XPRT0	; else return r2=0
XP15:
	lw		r1,8[sp]
	call	XP18	; is it "="?
	beq		r2,r1,XPRT1	; if not, return r2=1
	bra		XPRT0	; else return r2=0
XP16:
	lw		r1,8[sp]
	call	XP18	; is it "<"?
	blt		r2,r1,XPRT1	; if not, return r2=1
	bra		XPRT0	; else return r2=0
XPRT0:
	lw		lr,[sp]
	setlo	r1,#0   ; return r1=0 (false)
	ret		#16
XPRT1:
	lw		lr,[sp]
	setlo	r1,#1	; return r1=1 (true)
	ret		#16

XP17:				; it's not a rel. operator
	lw		r1,8[sp]	; return r2=<EXPR2>
	lw		lr,[sp]
	ret		#16

XP18:
	subui	sp,sp,#16
	sw		lr,[sp]
	sw		r1,8[sp]
	call	EXPR2		; do a second <EXPR2>
	lw		r2,8[sp]
	lw		lr,[sp]
	ret		#16

; <EXPR2>::=(+ or -)<EXPR3>(+ or -)<EXPR3>(...

EXPR2:
	subui	sp,sp,#16
	sw		lr,[sp]
	setlo	r3,#'-'
	lea		r4,XP21
	call	TSTC		; negative sign?
	setlo	r1,#0		; yes, fake '0-'
	sw		r0,8[sp]
	bra		XP26
XP21:
	setlo	r3,#'+'
	lea		r4,XP22
	call	TSTC		; positive sign? ignore it
XP22:
	call	EXPR3		; first <EXPR3>
XP23:
	sw		r1,8[sp]	; yes, save the value
	setlo	r3,#'+'
	lea		r4,XP25
	call	TSTC		; add?
	call	EXPR3		; get the second <EXPR3>
XP24:
	lw		r2,8[sp]
	add		r1,r1,r2	; add it to the first <EXPR3>
;	BVS.L	QHOW		brnch if there's an overflow
	bra		XP23		; else go back for more operations
XP25:
	setlo	r3,#'-'
	lea		r4,XP45
	call	TSTC		; subtract?
XP26:
	call	EXPR3		; get second <EXPR3>
	neg		r1,r1		; change its sign
	bra		XP24		; and do an addition
XP45:
	lw		r1,8[sp]
	lw		lr,[sp]
	ret		#16


; <EXPR3>::=<EXPR4>( <* or /><EXPR4> )(...

EXPR3:
	subui	sp,sp,#16
	sw		lr,[sp]
	call	EXPR4		; get first <EXPR4>
XP31:
	sw		r1,8[sp]	; yes, save that first result
	setlo	r3,#'*'
	lea		r4,XP34
	call	TSTC		; multiply?
	call	EXPR4		; get second <EXPR4>
	lw		r2,8[sp]
	muls	r1,r1,r2	; multiply the two
	bra		XP31        ; then look for more terms
XP34:
	setlo	r3,#'/'
	lea		r4,XP47
	call	TSTC		; divide?
	call	EXPR4		; get second <EXPR4>
	or      r2,r1,r0
	lw		r1,8[sp]
	divs	r1,r1,r2	; do the division
	bra		XP31		; go back for any more terms
XP47:
	lw		r1,8[sp]
	lw		lr,[sp]
	ret		#16


; Functions are called through EXPR4
; <EXPR4>::=<variable>
;	    <function>
;	    (<EXPR>)

EXPR4:
    subui   sp,sp,#24
    sw      lr,[sp]
    lea		r9,TAB4		; find possible function
    lea		r10,TAB4_1
	jmp		EXEC        ; branch to function which does subsequent ret for EXPR4
XP40:                   ; we get here if it wasn't a function
	setlo	r1,#0
	call	TSTV		
	beq     r1,r0,XP41  ; nor a variable
	lw		r1,[r1]		; if a variable, return its value in r1
	lw      lr,[sp]
	ret		#24
XP41:
	call	TSTNUM		; or is it a number?
	bne		r2,r0,XP46	; (if not, # of digits will be zero) if so, return it in r1
	call    PARN        ; check for (EXPR)
XP46:
	lw      lr,[sp]
	ret		#24


; Check for a parenthesized expression
PARN:
	subui	sp,sp,#8
	sw		lr,[sp]
	setlo	r3,#'('
	lea		r4,XP43
	call	TSTC		; else look for ( OREXPR )
	call	OREXPR
	setlo	r3,#')'
	lea		r4,XP43
	call	TSTC
XP42:
	lw		lr,[sp]
	ret		#8
XP43:
	lea		r1,msgWhat
	bra		ERROR


; ===== Test for a valid variable name.  Returns Z=1 if not
;	found, else returns Z=0 and the address of the
;	variable in r1.
; Parameters
;	r1 = 1 = allocate if not found
; Returns
;	r1 = address of variable, zero if not found

TSTV:
	subui	sp,sp,#24
	sw		lr,[sp]
	sw		r5,8[sp]
	or		r5,r1,r0	; allocate flag
	call	IGNBLK
	lbu		r1,[r8]		; look at the program text
	blt     r1,#'@',tstv_notfound   ; C=1: not a variable
	bne		r1,#'@',TV1	; brnch if not "@" array
	addui	r8,r8,#1	; If it is, it should be
	call	PARN		; followed by (EXPR) as its index.
	shli	r1,r1,#3
;	BCS.L	QHOW		say "How?" if index is too big
	subui	sp,sp,#24
    sw      r1,8[sp]    ; save the index
    sw		lr,[sp]
	call	SIZEX		; get amount of free memory
	lw		lr,[sp]
	lw      r2,8[sp]    ; get back the index
	bltu	r2,r1,TV2	; see if there's enough memory
	jmp    	QSORRY		; if not, say "Sorry"
TV2:
	lea		r1,VARBGN   ; put address of array element...
	subu    r1,r1,r2       ; into r1 (neg. offset is used)
	bra     TSTVRT
TV1:	
    call    getVarName      ; get variable name
    beq     r1,r0,TSTVRT    ; if not, return r1=0
    mov		r2,r5
    call    findVar     ; find or allocate
TSTVRT:
	lw		r5,8[sp]
	lw		lr,[sp]
	ret		#24			; r1<>0 (found)
tstv_notfound:
	lw		r5,8[sp]
    lw      lr,[sp]
    setlo   r1,#0       ; r1=0 if not found
    ret		#24


; Returns
;   r1 = 6 character variable name + type
;
getVarName:
    subui   sp,sp,#24
    sw      lr,[sp]
    sw		r5,16[sp]

    lb      r1,[r8]     ; get first character
    sw		r1,8[sp]	; save off current name
    call    isAlpha
    beq     r1,r0,gvn1
    setlo   r5,#5       ; loop six more times

	; check for second/third character
gvn4:
	addui   r8,r8,#1
	lb      r1,[r8]     ; do we have another char ?
	call    isAlnum
	beq     r1,r0,gvn2  ; nope
	lw      r1,8[sp]    ; get varname
	shli	r1,r1,#8
	lb      r2,[r8]
	or      r1,r1,r2   ; add in new char
    sw      r1,8[sp]   ; save off name again
    loop	r5,gvn4

    ; now ignore extra variable name characters
gvn6:
    addui   r8,r8,#1
    lb      r1,[r8]
    call    isAlnum
    bne     r1,r0,gvn6	; keep looping as long as we have identifier chars

    ; check for a variable type
gvn2:
	lb		r1,[r8]
    beq     r1,#'%',gvn3
    beq     r1,#'$',gvn3
    setlo   r1,#0
    subui   r8,r8,#1

    ; insert variable type indicator and return
gvn3:
    addui   r8,r8,#1
    lw      r2,8[sp]
    shli	r2,r2,#8
    or      r1,r1,r2    ; add in variable type
    lw      lr,[sp]
    lw		r5,16[sp]
    ret		#24			; return Z = 0, r1 = varname

    ; not a variable name
gvn1:
    lw      lr,[sp]
    lw		r5,16[sp]
    setlo   r1,#0       ; return Z = 1 if not a varname
    ret		#24


; Find variable
;   r1 = varname
;	r2 = allocate flag
; Returns
;   r1 = variable address, Z =0 if found / allocated, Z=1 if not found

findVar:
    subui   sp,sp,#16
    sw      lr,[sp]
    sw      r7,8[sp]
    lw      r3,VARBGN
fv4:
    lw      r7,[r3]     ; get varname / type
    beq     r7,r0,fv3   ; no more vars ?
    beq     r1,r7,fv1	; match ?
    add     r3,r3,#8    ; move to next var
    lw      r7,STKBOT
    blt     r3,r7,fv4   ; loop back to look at next var

    ; variable not found
    ; no more memory
    setlo	r1,#<msgVarSpace
    sethi	r1,#>msgVarSpace
    bra     ERROR
;    lw      lr,[sp]
;    lw      r7,4[sp]
;    add     sp,sp,#8
;    lw      r1,#0
;    ret

    ; variable not found
    ; allocate new ?
fv3:
	beq		r2,r0,fv2
    sw      r1,[r3]     ; save varname / type
    ; found variable
    ; return address
fv1:
    addui   r1,r3,#8
    lw      lr,[sp]
    lw      r7,8[sp]
    ret		#16    ; Z = 0, r1 = address

    ; didn't find var and not allocating
fv2:
    lw      lr,[sp]
    lw      r7,8[sp]
    addui   sp,sp,#16   ; Z = 0, r1 = address
	setlo	r1,#0		; Z = 1, r1 = 0
    ret


; ===== Multiplies the 32 bit values in r1 and r2, returning
;	the 32 bit result in r1.
;

; ===== Divide the 32 bit value in r2 by the 32 bit value in r3.
;	Returns the 32 bit quotient in r1, remainder in r2
;
; r2 = a
; r3 = b
; r6 = remainder
; r7 = iteration count
; r8 = sign
;

; q = a / b
; a = r1
; b = r2
; q = r2


; ===== The PEEK function returns the byte stored at the address
;	contained in the following expression.
;
PEEK:
	call	PARN		; get the memory address
	lbu		r1,[r1]		; get the addressed byte
	lw		lr,[sp]		; and return it
	ret		#24

; ===== The PEEK function returns the byte stored at the address
;	contained in the following expression.
;
PEEKC:
	call	PARN		; get the memory address
	andi	r1,r1,#-2	; align to char address
	lcu		r1,[r1]		; get the addressed char
	lw		lr,[sp]		; and return it
	ret		#24

; ===== The PEEK function returns the byte stored at the address
;	contained in the following expression.
;
PEEKH:
	call	PARN		; get the memory address
	andi	r1,r1,#-4	; align to half-word address
	lhu		r1,[r1]		; get the addressed char
	lw		lr,[sp]		; and return it
	ret		#24

; ===== The PEEK function returns the byte stored at the address
;	contained in the following expression.
;
PEEKW:
	call	PARN		; get the memory address
	andi	r1,r1,#-8		; align to word address
	lw		r1,[r1]		; get the addressed word
	lw		lr,[sp]		; and return it
	ret		#24

; user function call
; call the user function with argument in r1
USRX:
	call	PARN		; get expression value
	sw		r8,8[sp]	; save the text pointer
	lw      r2,usrJmp   ; get usr vector
	jal		r31,[r2]	; jump to the subroutine
	lw		r8,8[sp]	; restore the text pointer
	lw		lr,[sp]
	ret		#24


; ===== The RND function returns a random number from 1 to
;	the value of the following expression in D0.
;
RND:
	call	PARN		; get the upper limit
	beq		r1,r0,rnd2	; it must be positive and non-zero
	blt		r1,r0,rnd1
	lw		r2,r1
	gran				; generate a random number
	mfspr	r1,rand		; get the number
	call	modu4		; RND(n)=MOD(number,n)+1
	addui	r1,r1,#1
	lw		lr,[sp]
	ret		#24
rnd1:
	lea		r1,msgRNDBad
	bra		ERROR
rnd2:
	gran
	mfspr	r1,rand
	lw		lr,[sp]
	ret		#24


; r = a mod b
; a = r1
; b = r2 
; r = r6
modu4:
	subui	sp,sp,#32
	sw		r3,[sp]
	sw		r5,8[sp]
	sw		r6,16[sp]
	sw		r7,24[sp]
	lw      r7,#63		; n = 64
	xor		r5,r5,r5	; w = 0
	xor		r6,r6,r6	; r = 0
mod2:
	roli	r1,r1,#1	; a <<= 1
	andi	r3,r1,#1
	shli	r6,r6,#1	; r <<= 1
	or		r6,r6,r3
	andi	r1,r1,#-2
	bgtu	r2,r6,mod1	; b < r ?
	subu	r6,r6,r2	; r -= b
mod1:
    loop	r7,mod2		; n--
	mov		r1,r6
	lw		r3,[sp]
	lw		r5,8[sp]
	lw		r6,16[sp]
	lw		r7,24[sp]
	ret		#32


; ===== The ABS function returns an absolute value in r2.
;
ABS:
	call	PARN		; get the following expr.'s value
	abs		r1,r1
	lw		lr,[sp]
	ret		#24

; ===== The SGN function returns the sign in r1. +1,0, or -1
;
SGN:
	call	PARN		; get the following expr.'s value
	sgn		r1,r1
	lw		lr,[sp]
	ret		#24

; ===== The SIZE function returns the size of free memory in r1.
;
SIZEX:
	lw		r1,VARBGN	; get the number of free bytes...
	lw		r2,TXTUNF	; between 'TXTUNF' and 'VARBGN'
	subu	r1,r1,r2
	lw		lr,[sp]
	ret		#24			; return the number in r2


;******************************************************************
;
; *** SETVAL *** FIN *** ENDCHK *** ERROR (& friends) ***
;
; 'SETVAL' expects a variable, followed by an equal sign and then
; an expression.  It evaluates the expression and sets the variable
; to that value.
;
; 'FIN' checks the end of a command.  If it ended with ":",
; execution continues.	If it ended with a CR, it finds the
; the next line and continues from there.
;
; 'ENDCHK' checks if a command is ended with a CR. This is
; required in certain commands, such as GOTO, RETURN, STOP, etc.
;
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

; returns
; r2 = variable's address
;
SETVAL:
    subui   sp,sp,#16
    sw      lr,[sp]
    setlo	r1,#1		; allocate var
    call	TSTV		; variable name?
    bne		r1,r0,sv2
   	lea		r1,msgVar
   	bra		ERROR 
sv2:
	sw      r1,8[sp]    ; save the variable's address
	setlo	r3,#'='
	lea		r4,SV1
	call	TSTC		; get past the "=" sign
	call	OREXPR		; evaluate the expression
	lw      r2,8[sp]    ; get back the variable's address
	sw      r1,[r2]     ; and save value in the variable
	lw		r1,r2		; return r1 = variable address
	lw      lr,[sp]
	ret		#16
SV1:
    bra	    QWHAT		; if no "=" sign


FIN:
	subui	sp,sp,#8
	sw		lr,[sp]
	setlo	r3,#':'
	lea		r4,FI1
	call	TSTC		; *** FIN ***
	addui	sp,sp,#8	; if ":", discard return address
	bra		RUNSML		; continue on the same line
FI1:
	setlo	r3,#CR
	lea		r4,FI2
	call	TSTC		; not ":", is it a CR?
	lw		lr,[sp]	; else return to the caller
	addui	sp,sp,#8	; yes, purge return address
	bra		RUNNXL		; execute the next line
FI2:
	lw		lr,[sp]	; else return to the caller
	ret		#8


; Check that there is nothing else on the line
; Registers Affected
;   r1
;
ENDCHK:
	subui	sp,sp,#8
	sw		lr,[sp]
	call	IGNBLK
	lb		r1,[r8]
	beq		r1,#CR,ec1	; does it end with a CR?
	setlo	r1,#<msgExtraChars
	sethi	r1,#>msgExtraChars
	jmp		ERROR
ec1:
	lw		lr,[sp]
	ret		#8


TOOBIG:
	lea		r1,msgTooBig
	bra		ERROR
QSORRY:
    lea		r1,SRYMSG
	bra	    ERROR
QWHAT:
	lea		r1,msgWhat
ERROR:
	call	PRMESG		; display the error message
	lw		r1,CURRNT	; get the current line number
	beq		r1,r0,WSTART	; if zero, do a warm start
	beq		r1,#-1,INPERR		; is the line no. pointer = -1? if so, redo input
	lb		r5,[r8]		; save the char. pointed to
	sb		r0,[r8]		; put a zero where the error is
	lw		r1,CURRNT	; point to start of current line
	call	PRTLN		; display the line in error up to the 0
	or      r6,r1,r0    ; save off end pointer
	sb		r5,[r8]		; restore the character
	setlo	r1,#'?'		; display a "?"
	call	GOOUT
	setlo   r2,#0       ; stop char = 0
	subui	r1,r6,#1	; point back to the error char.
	call	PRTSTG		; display the rest of the line
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
	subui	sp,sp,#16
	sw		lr,[sp]
	sw		r5,8[sp]
	call	GOOUT		; display the prompt
	setlo	r1,#1		; turn on cursor flash
	sb		r1,cursFlash
	setlo	r1,#' '		; and a space
	call	GOOUT
	setlo	r8,#<BUFFER	; r8 is the buffer pointer
	sethi	r8,#>BUFFER
GL1:
	call	CHKIO		; check keyboard
	beq		r1,r0,GL1	; wait for a char. to come in
	beq		r1,#CTRLH,GL3	; delete last character? if so
	beq		r1,#CTRLX,GL4	; delete the whole line?
	beq		r1,#CR,GL2	; accept a CR
	bltu	r1,#' ',GL1	; if other control char., discard it
GL2:
	sb		r1,[r8]		; save the char.
	add		r8,r8,#1
	call	GOOUT		; echo the char back out
	lb      r1,-1[r8]   ; get char back (GOOUT destroys r1)
	beq		r1,#CR,GL7	; if it's a CR, end the line
	cmpui	r1,r8,#BUFFER+BUFLEN-1	; any more room?
	blt		r1,r0,GL1	; yes: get some more, else delete last char.
GL3:
	setlo	r1,#CTRLH	; delete a char. if possible
	call	GOOUT
	setlo	r1,#' '
	call	GOOUT
	cmpui	r1,r8,#BUFFER	; any char.'s left?
	ble		r1,r0,GL1		; if not
	setlo	r1,#CTRLH	; if so, finish the BS-space-BS sequence
	call	GOOUT
	sub		r8,r8,#1	; decrement the text pointer
	bra		GL1			; back for more
GL4:
	or		r1,r8,r0		; delete the whole line
	subui	r5,r1,#BUFFER   ; figure out how many backspaces we need
	beq		r5,r0,GL6		; if none needed, brnch
GL5:
	setlo	r1,#CTRLH	; and display BS-space-BS sequences
	call	GOOUT
	setlo	r1,#' '
	call	GOOUT
	setlo	r1,#CTRLH
	call	GOOUT
	loop	r5,GL5
GL6:
	lea		r8,BUFFER	; reinitialize the text pointer
	bra		GL1			; and go back for more
GL7:
	setlo	r1,#0		; turn off cursor flash
	sb		r1,cursFlash
	setlo	r1,#LF		; echo a LF for the CR
	call	GOOUT
	lw		lr,[sp]
	lw		r5,8[sp]
	ret		#16


; 'FNDLN' finds a line with a given line no. (in r1) in the
; text save area.  r9 is used as the text pointer. If the line
; is found, r9 will point to the beginning of that line
; (i.e. the high byte of the line no.), and flags are Z.
; If that line is not there and a line with a higher line no.
; is found, r9 points there and flags are NC & NZ. If we reached
; the end of the text save area and cannot find the line, flags
; are C & NZ.
; Z=1 if line found
; N=1 if end of text save area
; Z=0 & N=0 if higher line found
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
	bleui	r1,#0xFFFF,fl1	; line no. must be < 65535
	lea		r1,msgLineRange
	bra		ERROR
fl1:
	lw		r9,TXTBGN	; init. the text save pointer

FNDLNP:
	lw		r10,TXTUNF	; check if we passed the end
	subui	r10,r10,#1
	bgtu	r9,r10,FNDRET1		; if so, return with r9=0,r1=0
	lbu		r3,[r9]		; get low order byte of line number
	lbu		r2,1[r9]	; get high order byte
	shli	r2,r2,#8
	or		r2,r2,r3	; build whole line number
	bgtu	r1,r2,FNDNXT	; is this the line we want? no, not there yet
	beq		r1,r2,FNDRET2
FNDRET:
	xor		r1,r1,r1	; line not found, but r9=next line pointer
	ret			; return the cond. codes
FNDRET1:
	xor		r9,r9,r9	; no higher line
	xor		r1,r1,r1	; line not found
	ret
FNDRET2:
	setlo	r1,#1		; line found
	ret

FNDNXT:
	addui	r9,r9,#2	; find the next line

FNDSKP:
	lbu		r2,[r9]
	addui	r9,r9,#1
	bnei	r2,#CR,FNDSKP		; try to find a CR, keep looking
	bra		FNDLNP		; check if end of text


;******************************************************************
; 'MVUP' moves a block up from where r1 points to where r2 points
; until r1=r3
;
MVUP1:
	lb		r4,[r1]
	sb		r4,[r2]
	add		r1,r1,#1
	add		r2,r2,#1
MVUP:
	bne		r1,r3,MVUP1
MVRET:
	ret


; 'MVDOWN' moves a block down from where r1 points to where r2
; points until r1=r3
;
MVDOWN1:
	sub		r1,r1,#1
	sub		r2,r2,#1
	lb		r4,[r1]
	sb		r4,[r2]
MVDOWN:
	bne		r1,r3,MVDOWN1
	ret


; 'POPA' restores the 'FOR' loop variable save area from the stack
;
; 'PUSHA' stacks for 'FOR' loop variable save area onto the stack
;
; Note: a single zero word is stored on the stack in the
; case that no FOR loops need to be saved. This needs to be
; done because PUSHA / POPA is called all the time.

POPA:
	lw		r1,[sp]		; restore LOPVAR, but zero means no more
	sw		r1,LOPVAR
	beq		r1,r0,PP1
	lw		r1,32[sp]	; if not zero, restore the rest
	sw		r1,LOPPT
	lw		r1,24[sp]
	sw		r1,LOPLN
	lw		r1,16[sp]
	sw		r1,LOPLMT
	lw		r1,8[sp]
	sw		r1,LOPINC
	ret		#40
PP1:
	ret		#8


PUSHA:
	lw		r1,STKBOT	; Are we running out of stack room?
	addui	r1,r1,#40	; we might need this many bytes
	bltu	sp,r1,QSORRY	; out of stack space
	lw		r1,LOPVAR	; save loop variables
	beq		r1,r0,PU1	; if LOPVAR is zero, that's all
	subui	sp,sp,#40
	sw		r1,[sp]
	lw		r1,LOPPT
	sw		r1,32[sp]	; else save all the others
	lw		r1,LOPLN
	sw		r1,24[sp]
	lw		r1,LOPLMT
	sw		r1,16[sp]
	lw		r1,LOPINC
	sw		r1,8[sp]
	ret
PU1:
	subui	sp,sp,#8
	sw		r1,[sp]
	ret


;******************************************************************
;
; *** PRTSTG *** QTSTG *** PRTNUM *** PRTLN ***
;
; 'PRTSTG' prints a string pointed to by r3. It stops printing
; and returns to the caller when either a CR is printed or when
; the next byte is the same as what was passed in r4 by the
; caller.
;
; 'QTSTG' looks for an underline (back-arrow on some systems),
; single-quote, or double-quote.  If none of these are found, returns
; to the caller.  If underline, outputs a CR without a LF.  If single
; or double quote, prints the quoted string and demands a matching
; end quote.  After the printing, the next i-word of the caller is
; skipped over (usually a branch instruction).
;
; 'PRTNUM' prints the 32 bit number in r3, leading blanks are added if
; needed to pad the number of spaces to the number in r4.
; However, if the number of digits is larger than the no. in
; r4, all digits are printed anyway. Negative sign is also
; printed and counted in, positive sign is not.
;
; 'PRTLN' prints the saved text line pointed to by r3
; with line no. and all.
;

; r1 = pointer to string
; r2 = stop character
; return r1 = pointer to end of line + 1

PRTSTG:
    subui   sp,sp,#32
    sw		r5,[sp]
    sw		r5,8[sp]
    sw		r7,16[sp]
    sw		lr,24[sp]
    mov     r5,r1       ; r5 = pointer
    mov     r6,r2       ; r6 = stop char
PS1:
    lbu     r7,[r5]     ; get a text character
    addui   r5,r5,#1
	beq	    r7,r6,PRTRET		; same as stop character? if so, return
	mov     r1,r7
	call	GOOUT		; display the char.
	bnei    r7,#CR,PS1  ; is it a C.R.? no, go back for more
	setlo   r1,#LF      ; yes, add a L.F.
	call	GOOUT
PRTRET:
    mov     r2,r7       ; return r2 = stop char
	mov		r1,r5		; return r1 = line pointer
    lw		lr,24[sp]
    lw		r7,16[sp]
    lw		r5,8[sp]
    lw		r5,[sp]
    ret		#32	        ; then return


QTSTG:
	subui	sp,sp,#8
	sw		lr,[sp]
	setlo	r3,#'"'
	lea		r4,QT3
	call	TSTC		; *** QTSTG ***
	setlo	r2,#'"'		; it is a "
QT1:
	or		r1,r8,r0
	call	PRTSTG		; print until another
	lw		r8,r1
	bne		r2,#LF,QT2	; was last one a CR?
	addui	sp,sp,#8
	bra		RUNNXL		; if so, run next line
QT3:
	setlo	r3,#''''
	lea		r4,QT4
	call	TSTC		; is it a single quote?
	setlo	r2,#''''	; if so, do same as above
	bra		QT1
QT4:
	setlo	r3,#'_'
	lea		r4,QT5
	call	TSTC		; is it an underline?
	setlo	r1,#CR		; if so, output a CR without LF
	call	GOOUT
QT2:
	lw		lr,[sp]
	addui	sp,sp,#8
	jal		r0,4[lr]		; skip over next i-word when returning
QT5:						; not " ' or _
	lw		lr,[sp]
	ret		#8


; Output a CR LF sequence
;
prCRLF:
	subui	sp,sp,#8
	sw		lr,[sp]
	setlo	r1,#CR
	call	GOOUT
	setlo	r1,#LF
	call	GOOUT
	lw		lr,[sp]
	ret		#8


; r1 = number to print
; r2 = number of digits
; Register Usage
;	r5 = number of padding spaces
PRTNUM:
	subui	sp,sp,#40
	sw		r3,[sp]
	sw		r5,8[sp]
	sw		r6,16[sp]
	sw		r7,24[sp]
	sw		lr,32[sp]
	lea		r7,NUMWKA	; r7 = pointer to numeric work area
	mov		r6,r1		; save number for later
	mov		r5,r2		; r5 = min number of chars
	bgt		r1,r0,PN2	; is it negative? if not
	neg		r1,r1		; else make it positive
	subui	r5,r5,#1	; one less for width count
PN2:
	lw		r3,#10
PN1:
	modu	r2,r1,r3	; r2 = r1 mod 10
	divui	r1,r1,#10	; r1 /= 10 divide by 10
	addui	r2,r2,#'0'	; convert remainder to ascii
	sb		r2,[r7]		; and store in buffer
	addui	r7,r7,#1
	subui	r5,r5,#1	; decrement width
	bne		r1,r0,PN1
PN6:
	ble		r5,r0,PN4	; test pad count, skip padding if not needed
PN3:
	setlo	r1,#' '		; display the required leading spaces
	call	GOOUT
	loop	r5,PN3
PN4:
	bge		r6,r0,PN5	; is number negative?
	setlo	r1,#'-'		; if so, display the sign
	call	GOOUT
PN5:
	subui	r7,r7,#1
	lb		r1,[r7]		; now unstack the digits and display
	call	GOOUT
	cmpui	r1,r7,#NUMWKA
	bgtu	r1,r0,PN5
PNRET:
	lw		lr,32[sp]
	lw		r7,24[sp]
	lw		r6,16[sp]
	lw		r5,8[sp]
	lw		r3,[sp]
	ret		#40


; r1 = number to print
; r2 = number of digits
PRTHEXNUM:
	subui	sp,sp,#40
	sw		r5,[sp]
	sw		r6,8[sp]
	sw		r7,16[sp]
	sw		r8,24[sp]
	sw		lr,32[sp]
	lea		r7,NUMWKA	; r7 = pointer to numeric work area
	or		r6,r1,r0	; save number for later
	setlo	r5,#20		; r5 = min number of chars
	mov		r4,r1
	bgt		r4,r0,PHN1		; is it negative? if not
	neg		r4,r4			; else make it positive
	subui	r5,r5,#1	; one less for width count
	setlo	r8,#20		; maximum of 10 digits
PHN1:
	mov		r1,r4
	andi	r1,r1,#15
	blt		r1,#10,PHN7
	addui	r1,r1,#'A'-10
	bra		PHN8
PHN7:
	add		r1,r1,#'0'		; convert remainder to ascii
PHN8:
	sb		r1,[r7]		; and store in buffer
	addui	r7,r7,#1
	subui	r5,r5,#1	; decrement width
	shrui	r4,r4,#4
	beq		r4,r0,PHN6			; is it zero yet ?
	loop	r8,PHN1		; safety
PHN6:	; test pad count
	ble		r5,r0,PHN4	; skip padding if not needed
PHN3:
	setlo	r1,#' '		; display the required leading spaces
	call	GOOUT
	loop	r5,PHN3
PHN4:
	bgt		r6,r0,PHN5	; is number negative?
	setlo	r1,#'-'		; if so, display the sign
	call	GOOUT
PHN5:
	subui	r7,r7,#1
	lb		r1,[r7]		; now unstack the digits and display
	call	GOOUT
	cmpui	r1,r7,#NUMWKA
	bgt		r1,r0,PHN5
PHNRET:
	lw		lr,32[sp]
	lw		r8,24[sp]
	lw		r7,16[sp]
	lw		r6,8[sp]
	lw		r5,[sp]
	ret		#40


; r1 = pointer to line
; returns r1 = pointer to end of line + 1
PRTLN:
    subui   sp,sp,#16
    sw		r5,[sp]
    sw		lr,8[sp]
    addi    r5,r1,#2
    lbu		r1,-2[r5]	; get the binary line number
    lbu		r2,-1[r5]
    shli	r2,r2,#8
    or		r1,r1,r2
    setlo   r2,#0       ; display a 0 or more digit line no.
	call	PRTNUM
	setlo   r1,#' '     ; followed by a blank
	call	GOOUT
	setlo   r2,#0       ; stop char. is a zero
	or      r1,r5,r0
	call    PRTSTG		; display the rest of the line
	lw		lr,8[sp]
	lw		r5,[sp]
	ret		#16


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
	subui	sp,sp,#16
	sw		lr,[sp]
	sw		r1,8[sp]
	call	IGNBLK		; ignore leading blanks
	lb		r1,[r8]
	beq		r3,r1,TC1	; is it = to what r8 points to? if so
	lw		r1,8[sp]
	lw		lr,[sp]
	addui	sp,sp,#16
	jal		r0,[r4]		; jump to the routine
TC1:
	addui	r8,r8,#1	; if equal, bump text pointer
	lw		r1,8[sp]
	lw		lr,[sp]
	ret		#16

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
	subui	sp,sp,#8
	sw		lr,[sp]
	call	IGNBLK		; skip over blanks
	setlo	r1,#0		; initialize return parameters
	setlo	r2,#0
TN1:
	lb		r3,[r8]
	bltui	r3,#'0',TSNMRET	; is it less than zero?
	bgtui	r3,#'9',TSNMRET	; is it greater than nine?
	lw		r4,#0x07FFFFFF_FFFFFFFF
	bleu	r1,r4,TN2	; see if there's room for new digit
	lea		r1,msgNumTooBig
	bra		ERROR		; if not, we've overflowd
TN2:
	mului	r1,r1,#10	; quickly multiply result by 10
	addui	r8,r8,#1	; adjust text pointer
	andi	r3,r3,#0x0F	; add in the new digit
	addu	r1,r1,r3
	addui	r2,r2,#1	; increment the no. of digits
	bra		TN1
TSNMRET:
	lw		lr,[sp]
	ret		#8


;===== Skip over blanks in the text pointed to by r8.
;
; Registers Affected:
;	r8
; Returns
;	r8 = pointer updateded past any spaces or tabs
;
IGNBLK:
	subui	sp,sp,#8
	sw		r1,[sp]
IGB2:
	lb		r1,[r8]			; get char
	beqi	r1,#' ',IGB1	; see if it's a space
	bnei	r1,#'\t',IGBRET	; or a tab
IGB1:
	addui	r8,r8,#1		; increment the text pointer
	bra		IGB2
IGBRET:
	lw		r1,[sp]
	ret		#8


; ===== Convert the line of text in the input buffer to upper
;	case (except for stuff between quotes).
;
; Registers Affected
;   r1,r3
; Returns
;	r8 = pointing to end of text in buffer
;
TOUPBUF:
	subui	sp,sp,#8
	sw		lr,[sp]
	lea		r8,BUFFER	; set up text pointer
	setlo	r3,#0		; clear quote flag
TOUPB1:
	lb		r1,[r8]		; get the next text char.
	addui	r8,r8,#1
	beqi	r1,#CR,TOUPBRT		; is it end of line?
	beqi	r1,#'"',DOQUO	; a double quote?
	beqi	r1,#'''',DOQUO	; or a single quote?
	bne		r3,r0,TOUPB1	; inside quotes?
	call	toUpper 	; convert to upper case
	sb		r1,-1[r8]	; store it
	bra		TOUPB1		; and go back for more
DOQUO:
	bne		r3,r0,DOQUO1; are we inside quotes?
	mov		r3,r1		; if not, toggle inside-quotes flag
	bra		TOUPB1
DOQUO1:
	bne		r3,r1,TOUPB1		; make sure we're ending proper quote
	setlo	r3,#0		; else clear quote flag
	bra		TOUPB1
TOUPBRT:
	lw		lr,[sp]
	ret		#8


; ===== Convert the character in r1 to upper case
;
toUpper
	blti	r1,#'a',TOUPRET	; is it < 'a'?
	bgti	r1,#'z',TOUPRET	; or > 'z'?
	subui	r1,r1,#32	; if not, make it upper case
TOUPRET
	ret


; 'CHKIO' checks the input. If there's no input, it will return
; to the caller with the r1=0. If there is input, the input byte is in r1.
; However, if a control-C is read, 'CHKIO' will warm-start BASIC and will
; not return to the caller.
;
CHKIO:
	subui	sp,sp,#8	; save link reg
	sw		lr,[sp]
	call	GOIN		; get input if possible
	beqi	r1,#-1,CHKRET2		; if Zero, no input
	bnei	r1,#CTRLC,CHKRET	; is it control-C?
	jmp		WSTART		; if so, do a warm start
CHKRET2:
	xor		r1,r1,r1
CHKRET:
	lw		lr,[sp]		;r1=0
	ret		#8


; ===== Display a CR-LF sequence
;
CRLF:
	setlo	r1,CLMSG


; ===== Display a zero-ended string pointed to by register r1
; Registers Affected
;   r1,r2,r4
;
PRMESG:
	subui	sp,sp,#16
	sw		r5,[sp]
	sw		lr,8[sp]
	mov     r5,r1       ; r5 = pointer to message
PRMESG1:
	addui	r5,r5,#1
	lbu		r1,-1[r5]	; 	get the char.
	beq		r1,r0,PRMRET
	call	GOOUT		;else display it trashes r4
	bra		PRMESG1
PRMRET:
	mov		r1,r5
	lw		lr,8[sp]
	lw		r5,[sp]
	ret		#16


; ===== Display a zero-ended string pointed to by register r1
; Registers Affected
;   r1,r2,r3
;
PRMESGAUX:
	subui	sp,sp,#16
	sw		r5,[sp]
	sw		lr,8[sp]
	mov     r5,r1       ; r3 = pointer
PRMESGA1:
	addui	r5,r5,#1
	lb		r1,-1[r5]	; 	get the char.
	beq		r1,r0,PRMRETA
	call	GOAUXO		;else display it
	bra		PRMESGA1
PRMRETA:
	mov		r1,r5
	lw		lr,8[sp]
	lw		r5,[sp]
	ret		#16

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
INC:
	jmp		KeybdGetChar


;*
;* ===== Input a character from the host into register r1 (or
;*	return Zero status if there's no character available).
;*
AUXIN:
	call	SerialGetChar
	beqi	r1,#-1,AXIRET_ZERO
	andi	r1,r1,#0x7f		;zero out the high bit
AXIRET:
	ret
AXIRET_ZERO:
	xor		r1,r1,r1
	ret

; ===== Output character to the host (Port 2) from register r1
;	(Preserves all registers.)
;
AUXOUT
	jmp		SerialPutChar	; call boot rom routine


_cls
	call	clearScreen
	bra		FINISH

_wait10
	ret
_getATAStatus
	ret
_waitCFNotBusy
	ret
_rdcf
	br		FINISH
rdcf6
	br		ERROR


; ===== Return to the resident monitor, operating system, etc.
;
BYEBYE:
	lw		sp,OSSP
    lw      lr,[sp]
	ret		#8

;	MOVE.B	#228,D7 	return to Tutor
;	TRAP	#14

msgInit db	CR,LF,"Raptor64 Tiny BASIC v1.0",CR,LF,"(C) 2013  Robert Finch",CR,LF,LF,0
OKMSG	db	CR,LF,"OK",CR,LF,0
msgWhat	db	"What?",CR,LF,0
SRYMSG	db	"Sorry."
CLMSG	db	CR,LF,0
msgReadError	db	"Compact FLASH read error",CR,LF,0
msgNumTooBig	db	"Number is too big",CR,LF,0
msgDivZero		db	"Division by zero",CR,LF,0
msgVarSpace     db  "Out of variable space",CR,LF,0
msgBytesFree	db	" bytes free",CR,LF,0
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

	align	8
LSTROM	equ	*		; end of possible ROM area
;	END

;*
;* ===== Return to the resident monitor, operating system, etc.
;*
BYEBYE:
	jmp		Monitor
;    MOVE.B	#228,D7 	;return to Tutor
;	TRAP	#14

;==============================================================================
; Checkerboard RAM tester
;==============================================================================
;
	code
	align	16
ramtest:
	or		r8,r0,r0		; r8 = 0
	ori		r1,r0,#0xAAAA5555AAAA5555	; checkerboard pattern
ramtest2:
	sw		r1,[r8]			; save the checkerboard to memory
	lw		r2,[r8]			; read it back
	cmp		r3,r1,r2		; is it the same ?
	bne 	r3,r0,ramtest1
	addui	r8,r8,#8		; increment RAM pointer
	cmpi	r3,r8,#0x0000_0000_0400_0000
	blt		r3,r0,ramtest2
ramtest1:
	or		r10,r8,r0		; r10 = max ram address
	; readback the checkerboard pattern
	or		r8,r0,r0		; r8 = 0
ramtest4:
	lw		r2,[r8]
	cmpi	r3,r2,#0xAAAA5555AAAA5555
	bne		r3,r0,ramtest3
	addi	r8,r8,#8
	cmpi	r3,r8,#0x0000_0000_0100_0000
	blt 	r3,r0,ramtest4
ramtest3:
	bne		r8,r10,ramtest8	; check for equal maximum address

	; perform ramtest again with inverted checkerboard
	or		r8,r0,r0		; r8 = 0
	ori		r1,r0,#0x5555AAAA5555AAAA
ramtest5:
	sw		r1,[r8]
	lw		r2,[r8]
	cmp		r3,r1,r2
	bne		r3,r0,ramtest6
	addi	r8,r8,#8
	cmpi	r3,r8,#0x0000_0000_0100_0000
	blt		r3,r0,ramtest5
ramtest6:
	or		r11,r8,r0		; r11 = max ram address
	; readback checkerboard
	or		r8,r0,r0
ramtest7:
	lw		r2,[r8]
	cmpi	r3,r2,#0x5555AAAA5555AAAA
	bne		r3,r0,ramtest8
	addi	r8,r8,#8
	cmpi	r3,r8,#0x0000_0000_0100_0000
	blt		r3,r0,ramtest7
ramtest8:
	beq		r8,r11,ramtest9
	min		r8,r8,r11
ramtest9:
	beq		r8,r10,ramtest10
	min		r8,r8,r10
ramtest10:
	sw		r8,0x00000400	;memend
	ret

;-------------------------------------------
;-------------------------------------------
;
iberr_rout:
	lea		r1,msgiberr
	call	DisplayString
	mfspr	r1,EPC
	call	DisplayWord
	wait
	jmp		start
dberr_rout:
	lw		sp,#0x100200100
	lea		r1,msgdberr
	call	DisplayString
	mfspr	r1,ERRADR
	call	DisplayWord
	lea		r1,msgEPC
	call	DisplayString
	mfspr	r1,EPC
	call	DisplayWord
	call	CRLF
	lw		r2,#31
dberr1:
	mtspr	PCHI,r2
	nop
	nop
	nop
	mfspr	r1,PCHISTORIC
	call	DisplayWord
	call	CRLF
	loop	r2,dberr1
	wait
	jmp		start
	.align	16
msgdberr:
	db	"Data bus error at: ",0
msgEPC:
	db	" EPC: ",0
msgiberr:
	db	"Err fetching instruction at: ",0
	.align	4

;------------------------------------------------------------------------------
; IRQ routine
;
; Interrupts are automatically disabled at the time of the interrupt in order
; to prevent nested interrupts from occuring. Interrupts are re-enabled by
; the IRET instruction at the end of the interrupt routine. If the interrupt
; turns out to not match a hardware interrupt, then a software context
; switching interrupt is assumed.
;
; This routine uses it's own private interrupt stack; the stack of the
; interrupted context is not used at all. A couple of working registers are
; saved off not on the stack. We can get away with this because nested
; interrupts are not allowed.
;------------------------------------------------------------------------------
;
irqrout:
	sw		sp,sp_save				; use our own private stack for interrupt processing
	sw		lr,lr_save				; so, save off the sp and working registers
	sw		r26,r26_save
	sw		r1,r1_save
	sw		r2,r2_save

	lw		sp,#0x1_00001000		; the second two kbytes
	inch	r1,PIC					; r1= which IRQ line is active

; Dispatch fork, in order of required timeliness

	beqi	r1,#2,irq1000Hz
	beqi	r1,#3,irq100Hz
	beqi	r1,#8,irqSerial
	beqi	r1,#13,irqRaster
	beqi	r1,#15,irqKeybd
	beqi	r1,#1,irqColdStart		; CTRL-ALT-DEL interrupt

; Here, none of the hardware interrupts were active so
; assume software context switch interrupt
;
	lw		sp,sp_save
	lw		lr,lr_save
	lw		r26,r26_save
	lw		r1,r1_save
	lw		r2,r2_save
	iepp
	iret
	
; 1000 Hz interrupt
; This IRQ must be fast, so it's placed inline. It's also the first
; IRQ checked for in the interrupt dispatch.
; Increments the millisecond counter, and switches to the next context
;
irq1000Hz:
	outb	r0,0xDCFFFD				; acknowledge interrupt
	lw		r1,Milliseconds			; increment milliseconds count
	addui	r1,r1,#1
	sw		r1,Milliseconds
	lw		sp,sp_save
	lw		lr,lr_save
	lw		r26,r26_save
	lw		r1,r1_save
	lw		r2,r2_save
	iepp							; move to the next context
	iret							; return to the next context

; 100 Hz interrupt
; This IRQ could have some work to do, including flashing a cursor. So
; we call a subroutine.
;
irq100Hz:
	lw		r1,p100IRQvec
;	jal		lr,[r1]
	call	Pulse100
irqret:
	lw		sp,sp_save
	lw		lr,lr_save
	lw		r26,r26_save
	lw		r1,r1_save
	lw		r2,r2_save
	iret

irqSerial:
	lw		r1,serialIRQvec
	jal		lr,[r1]
	bra		irqret

irqRaster:
	lw		r1,rasterIRQvec
;	jal		lr,[r1]
	call	RasterIRQfn
	bra		irqret

irqKeybd:
	lw		r1,keybdIRQvec
	call	KeybdIRQ
;	jal		lr,[r1]
	bra		irqret

irqColdStart:
	jmp		ColdStart

;------------------------------------------------------------------------------
; NMI routine
;
; The NMI line is tied to the parity error signal. But also any non-initialized
; interrupts get sent here.
;------------------------------------------------------------------------------
;
nmirout:
	sw		sp,sp_save
	sw		r1,r1_save
	sw		r26,r26_save
	lw		sp,#0x100001000
	outb	r0,0xDCFFFE		; acknowledge interrupt
	lea		r1,msgPerr
	call	DisplayString
	mfspr	r1,IPC
	call	DisplayWord
	call	CRLF
	lw		sp,sp_save
	lw		r1,r1_save
	lw		r26,r26_save
	iret

msgPerr:
	db	"Parity error at: ",0


;-------------------------------------------
; Unimplemented instructions end up here
;-------------------------------------------
	.align 4
ui_irout:
	subui	sp,sp,#8
	sw		r1,[sp]
	lea		r1,msgUnimp
	call	DisplayString
	mfspr	r1,IPC
	call	DisplayWord
	call	CRLF
	lw		r1,[sp]
	addui	sp,sp,#8
	; hang the context
ui_irout1:
	bra		ui_irout1
	iret

msgUnimp:
	db	"Unimplemented instruction at: ",0

;-------------------------------------------
; Handle miss on Data TLB
;-------------------------------------------
	.align	4
DTLBHandler:
	sw		r1,0xFFFF_FFFF_FFFF_0000
	sw		r2,0xFFFF_FFFF_FFFF_0008
dh1:
	omgi	r1,#0		; try open mutex gate #0 (TLB protector)
	bne		r1,r0,dh1	; spinlock if gate is closed
	mfspr	r1,PTA		; get the page table address
	mfspr	r2,BadVAddr	; get the bad virtual address
	mtspr	TLBVirtPage,r2	; which virtual address to update
	shrui	r2,r2,#13	; turn va into index
	addu	r1,r1,r2
	lw		r2,[r1]		; get the physical address from the table
	and		r2,r2,#FFFF_FFFF_FFFF_E000	; mask off lower bits
	mtspr	TLBPhysPage0,r2	;
	lw		r2,8[r1]	; get the physical address from the table
	and		r2,r2,#FFFF_FFFF_FFFF_E000	; mask off lower bits
	mtspr	TLBPhysPage1,r2	;
	tlbwr				; update a random entry in the TLB
	cmgi	#0			; close the mutex gate
	lw		r1,0xFFFF_FFFF_FFFF_0000
	lw		r2,0xFFFF_FFFF_FFFF_0008
	iret
	.align	32

	org		0xFFFF_FFFF_FFFF_FFB0
	jmp		DTLBHandler
	nop
	nop
	org		0xFFFF_FFFF_FFFF_FFC0
	jmp		DTLBHandler
	nop
	nop

	org     0xFFFF_FFFF_FFFF_FFE0
	dw		0		; 
	dw		0		;
	
; RST vector
	org		0xFFFF_FFFF_FFFF_FFF0
	jmp		start

; ROM checksum goes here

	org		0xFFFF_FFFF_FFFF_FFF8
	dw		0
