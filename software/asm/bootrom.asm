
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
; ============================================================================
;
	cpu		RTF65002

CR	EQU	0x0D		;ASCII equates
LF	EQU	0x0A
TAB	EQU	0x09
CTRLC	EQU	0x03
BELL	EQU	0x07
CTRLH	EQU	0x08
CTRLI	EQU	0x09
CTRLJ	EQU	0x0A
CTRLK	EQU	0x0B
CTRLM   EQU 0x0D
CTRLS	EQU	0x13
CTRLX	EQU	0x18
ESC		EQU	0x1b
XON		EQU	0x11
XOFF	EQU	0x13

; error codes
E_Ok		=		0x00
E_Arg		=		0x01
E_BadMbx	=		0x04
E_QueFull	=		0x05
E_NoThread	=		0x06
E_NotAlloc	=		0x09
E_NoMsg		=		0x0b
E_Timeout	=		0x10
E_BadAlarm	=		0x11
E_NotOwner	=		0x12
E_QueStrategy =		0x13
E_BadDevNum	=		0x18
E_DCBInUse	=		0x19
; Device driver errors
E_BadDevNum	=		0x20
E_NoDev		=		0x21
E_BadDevOp	=		0x22
E_ReadError	=		0x23
E_WriteError =		0x24
E_BadBlockNum	=	0x25
E_TooManyBlocks	=	0x26

; resource errors
E_NoMoreMbx	=		0x40
E_NoMoreMsgBlks	=	0x41
E_NoMoreAlarmBlks	=0x44
E_NoMoreTCBs	=	0x45
E_NoMem		= 12

; task status
TS_NONE     =0
TS_TIMEOUT	=1
TS_WAITMSG	=2
TS_PREEMPT	=4
TS_RUNNING	=8
TS_READY	=16
TS_SLEEP	=32

TS_TIMEOUT_BIT	=0
TS_WAITMSG_BIT	=1
TS_RUNNING_BIT	=3
TS_READY_BIT	=4

PRI_HIGHEST	=0
PRI_HIGH	=1
PRI_NORMAL	=2
PRI_LOW		=3
PRI_LOWEST	=4

MAX_TASKNO	= 63
DRAM_BASE	= $04000000

DIRENT_NAME		=0x00	; file name
DIRENT_EXT		=0x1C	; file name extension
DIRENT_ATTR		=0x20	; attributes
DIRENT_DATETIME	=0x28
DIRENT_CLUSTER	=0x30	; starting cluster of file
DIRENT_SIZE		=0x34	; file size (6 bytes)

; One FCB is allocated and filled out for each file that is open.
;
nFCBs	= 128
FCB_DE_NAME		=0x00
FCB_DE_EXT		=0x1C
FCB_DE_ATTR		=0x20
FCB_DE_DATETIME	=0x28
FCB_DE_CLUSTER	=0x30	; starting cluster of file
FCB_DE_SIZE		=0x34	; 6 byte file size

FCB_DIR_SECTOR	=0x40	; LBA directory sector this is from
FCB_DIR_ENT		=0x44	; offset in sector for dir entry
FCB_LDRV		=0x48	; logical drive this is on
FCB_MODE		=0x49	; 0 read, 1=modify
FCB_NUSERS		=0x4A	; number of users of this file
FCB_FMOD		=0x4B	; flag: this file was modified
FCB_RESV		=0x4C	; padding out to 80 bytes
FCB_SIZE		=0x50

FUB_JOB		=0x00	; User's job umber
FUB_iFCB	=0x02	; FCB number for this file
FUB_CrntLFA	=0x04	; six byte current logical file address
FUB_pBuf	=0x0C	; pointer to buffer if in stream mode
FUB_sBuf	=0x10	; size of buffer for stream file
FUB_LFABuf	=0x14	; S-First LFA in Clstr Buffer
FUB_LFACluster	=0x18	; LFA of cluster
FUB_Clstr	= 0x20		; The last cluster read
FUB_fModified	= 0x24	; data in buffer was modified
FUB_fStream		= 0x25	; non-zero for stream mode
FUB_PAD		=0x26	
FUB_SIZE	=0x30

; Boot sector info (62 byte structure) */
BSI_JMP		= 0x00
BSI_OEMName	= 0x03
BSI_bps		= 0x0B
BSI_SecPerCluster	= 0x0D
BSI_ResSectors	= 0x0E
BSI_FATS	= 0x10
BSI_RootDirEnts	= 0x11
BSI_Sectors	= 0x13
BSI_Media	= 0x15
BSI_SecPerFAT	= 0x16
BSI_SecPerTrack	= 0x18
BSI_Heads	= 0x1A
BSI_HiddenSecs	= 0x1C
BSI_HugeSecs	= 0x1E

BSI_DriveNum	= 0x24
BSI_Rsvd1		= 0x25
BSI_BootSig		= 0x26
BSI_VolID		= 0x27
BSI_VolLabel	= 0x2B
BSI_FileSysType = 0x36

	 
MEM_CHK		=0
MEM_FLAG	=1
MEM_PREV	=2
MEM_NEXT	=3

; message queuing strategy
MQS_UNLIMITED	=0	; unlimited queue size
MQS_NEWEST		=1	; buffer queue size newest messages
MQS_OLDEST		=2	; buffer queue size oldest messages

LEDS		EQU		0xFFDC0600
TEXTSCR		EQU		0xFFD00000
COLORSCR	EQU		0xFFD10000
TEXTREG		EQU		0xFFDA0000
TEXT_COLS	EQU		0x0
TEXT_ROWS	EQU		0x1
TEXT_CURPOS	EQU		11
TEXT_CURCTL	EQU		8
BMP_CLUT	EQU		$FFDC5800
KEYBD		EQU		0xFFDC0000
KEYBDCLR	EQU		0xFFDC0001
PIC			EQU		0xFFDC0FF0
PIC_IE		EQU		0xFFDC0FF1
PIC_ES		EQU		0xFFDC0FF4
PIC_RSTE	EQU		0xFFDC0FF5
TASK_SELECT	EQU		0xFFDD0008

RQ_SEMA		EQU		0xFFDB0000
to_sema		EQU		0xFFDB0010
SERIAL_SEMA	EQU		0xFFDB0020
keybd_sema	EQU		0xFFDB0030
iof_sema	EQU		0xFFDB0040
mbx_sema	EQU		0xFFDB0050
freembx_sema	EQU		0xFFDB0060
mem_sema	EQU		0xFFDB0070
freemsg_sema	EQU	0xFFDB0080
tcb_sema	EQU		0xFFDB0090
readylist_sema	EQU	0xFFDB00A0
tolist_sema		EQU	0xFFDB00B0
msg_sema		EQU	0xFFDB00C0
freetcb_sema	EQU	0xFFDB00D0
freejcb_sema	EQU	0xFFDB00E0
jcb_sema		EQU	0xFFDB00F0
device_semas	EQU	0xFFDB1000
device_semas_end	EQU	0xFFDB1200

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

CONFIGREC	EQU		0xFFDCFFF0
CR_CLOCK	EQU		0xFFDCFFF4
GACCEL		EQU		0xFFDAE000
GA_X0		EQU		0xFFDAE002
GA_Y0		EQU		0xFFDAE003
GA_PEN		EQU		0xFFDAE000
GA_X1		EQU		0xFFDAE004
GA_Y1		EQU		0xFFDAE005
GA_STATE	EQU		0xFFDAE00E
GA_CMD		EQU		0xFFDAE00F

AC97		EQU		0xFFDC1000
PSG			EQU		0xFFD50000
PSGFREQ0	EQU		0xFFD50000
PSGPW0		EQU		0xFFD50001
PSGCTRL0	EQU		0xFFD50002
PSGADSR0	EQU		0xFFD50003

ETHMAC		EQU		0xFFDC2000
ETH_MODER		EQU		0x00
ETH_INT_SOURCE	EQU		0x01
ETH_INT_MASK	EQU		0x02
ETH_IPGT		EQU		0x03
ETH_IPGR1		EQU		0x04
ETH_IPGR2		EQU		0x05
ETH_PACKETLEN	EQU		0x06
ETH_COLLCONF	EQU		0x07
ETH_TX_BD_NUM	EQU		0x08
ETH_CTRLMODER	EQU		0x09
ETH_MIIMODER	EQU		0x0A
ETH_MIICOMMAND	EQU		0x0B
ETH_MIIADDRESS	EQU		0x0C
ETH_MIITX_DATA	EQU		0x0D
ETH_MIIRX_DATA	EQU		0x0E
ETH_MIISTATUS	EQU		0x0F
ETH_MAC_ADDR0	EQU		0x10
ETH_MAC_ADDR1	EQU		0x11
ETH_HASH0_ADDR	EQU		0x12
ETH_HASH1_ADDR	EQU		0x13
ETH_TXCTRL		EQU		0x14

ETH_WCTRLDATA	EQU		4
ETH_MIICOMMAND_RSTAT	EQU	2
ETH_MIISTATUS_BUSY	EQU		2
ETH_MIIMODER_RST	EQU		$200
ETH_MODER_RST       EQU		$800
ETH_MII_BMCR		EQU		0		; basic mode control register
ETH_MII_ADVERTISE	EQU		4
ETH_MII_EXPANSION       =6
ETH_MII_CTRL1000        =9
ETH_ADVERTISE_ALL	EQU		$1E0
ETH_ADVERTISE_1000FULL      =0x0200  ; Advertise 1000BASE-T full duplex
ETH_ADVERTISE_1000HALF      =0x0100  ; Advertise 1000BASE-T half duplex
ETH_ESTATUS_1000_TFULL	=0x2000	; Can do 1000BT Full
ETH_ESTATUS_1000_THALF	=0x1000	; Can do 1000BT Half
ETH_BMCR_ANRESTART      =    0x0200  ; Auto negotiation restart    
ETH_BMCR_ISOLATE        =    0x0400  ; Disconnect DP83840 from MII
ETH_BMCR_PDOWN          =    0x0800  ; Powerdown the DP83840     
ETH_BMCR_ANENABLE       =    0x1000  ; Enable auto negotiation    

ETH_PHY		=7

MMU			EQU		0xFFDC4000
MMU_KVMMU	EQU		0xFFDC4800
MMU_FUSE	EQU		0xFFDC4811
MMU_AKEY	EQU		0xFFDC4812
MMU_OKEY	EQU		0xFFDC4813
MMU_MAPEN	EQU		0xFFDC4814

DATETIME	EQU		0xFFDC0400
DATETIME_TIME		EQU		0xFFDC0400
DATETIME_DATE		EQU		0xFFDC0401
DATETIME_ALMTIME	EQU		0xFFDC0402
DATETIME_ALMDATE	EQU		0xFFDC0403
DATETIME_CTRL		EQU		0xFFDC0404
DATETIME_SNAPSHOT	EQU		0xFFDC0405

SPRITEREGS	EQU		0xFFDAD000
SPRRAM		EQU		0xFFD80000

THRD_AREA	EQU		0x00000000	; threading area 0x04000000-0x40FFFFF
BITMAPSCR	EQU		0x00100000
SECTOR_BUF	EQU		0x01FBEC00

BYTE_SECTOR_BUF	EQU	SECTOR_BUF<<2
PROG_LOAD_AREA	EQU		0x0300000<<2

FCBs			EQU		0x1F40000	; room for 128 FCB's

FATOFFS			EQU		0x1F50000	; offset into FAT on card
FATBUF			EQU		0x1F60000
DIRBUF			EQU		0x1F70000
eth_rx_buffer	EQU		0x1F80000
eth_tx_buffer	EQU		0x1F84000

; Mailboxes, room for 2048
			.bss
			.org		0x01F90000
NR_MBX		EQU		$800
MBX_LINK		fill.w	NR_MBX,0	; link to next mailbox in list (free list)
MBX_TQ_HEAD		fill.w	NR_MBX,0	; head of task queue
MBX_TQ_TAIL		fill.w	NR_MBX,0
MBX_MQ_HEAD		fill.w	NR_MBX,0	; head of message queue
MBX_MQ_TAIL		fill.w	NR_MBX,0
MBX_TQ_COUNT	fill.w	NR_MBX,0	; count of queued threads
MBX_MQ_SIZE		fill.w	NR_MBX,0	; number of messages that may be queued
MBX_MQ_COUNT	fill.w	NR_MBX,0	; count of messages that are queued
MBX_MQ_MISSED	fill.w	NR_MBX,0	; number of messages dropped from queue
MBX_OWNER		fill.w	NR_MBX,0	; job handle of mailbox owner
MBX_MQ_STRATEGY	fill.w	NR_MBX,0	; message queueing strategy
MBX_RESV		fill.w	NR_MBX,0

; Messages, room for 64kW (16,384) messages
			.bss
			.org		0x01FA0000
NR_MSG		EQU		16384
MSG_LINK	fill.w	NR_MSG,0	; link to next message in queue or free list
MSG_D1		fill.w	NR_MSG,0	; message data 1
MSG_D2		fill.w	NR_MSG,0	; message data 2
MSG_TYPE	fill.w	NR_MSG,0	; message type
MSG_END		EQU		MSG_TYPE + NR_MSG

MT_SEMA		EQU		0xFFFFFFFF
MT_IRQ		EQU		0xFFFFFFF0
MT_GETCHAR	EQU		0xFFFFFFEF

NR_JCB			EQU		32
JCB_Number		EQU		0
JCB_Name		EQU		1		; 32 bytes (1 len + 31)
JCB_Map			EQU		9		; memory map number associated with job
JCB_pCode		EQU		10
JCB_nCode		EQU		11		; size of code
JCB_pData		EQU		12
JCB_nData		EQU		13		; size of data
JCB_pStack		EQU		14
JCB_nStack		EQU		15
JCB_UserName	EQU		16		; 32 bytes
JCB_Path		EQU		24		; 80 bytes
JCB_ExitRF		EQU		44		; 80 bytes
JCB_CmdLine		EQU		84		; 240 bytes		
JCB_SysIn		EQU		140		; 40 chars
JCB_SysOut		EQU		150		; 40 chars
JCB_ExitError	EQU		160
JCB_pVidMem		EQU		161		; pointer to video memory
JCB_pVidMemAttr	EQU		162
JCB_pVirtVid	EQU		163		; pointer to virtual video buffer
JCB_pVirtVidAttr	EQU		164
JCB_VideoMode	EQU		165
JCB_VideoRows	EQU		166
JCB_VideoCols	EQU		167
JCB_CursorRow	EQU		168
JCB_CursorCol	EQU		169
JCB_CursorOn	EQU		170
JCB_CursorFlash	EQU		171
JCB_CursorType	EQU		172
JCB_NormAttr	EQU		173
JCB_CurrAttr	EQU		174
JCB_ScrlCnt		EQU		175
JCB_fVidPause	EQU		176
JCB_Next		EQU		177
JCB_iof_next	EQU		178		; I/O focus list
JCB_iof_prev	EQU		179
JCB_VMP_bitmap_b0	EQU		180		; 512 bits	- virtual memory page bitmap
JCB_VMP_bitmap_b1	EQU		196		; 512 bits	- virtual memory page bitmap
JCB_KeybdHead	EQU		212
JCB_KeybdTail	EQU		213
JCB_KeybdEcho	EQU		214
JCB_KeybdBad	EQU		215
JCB_KeybdAck	EQU		216
JCB_KeybdLocks	EQU		217
JCB_KeybdBuffer	EQU		218		; buffer is 16 words (chars = words)
JCB_esc			EQU		234		; escape flag for DisplayChar processing
JCB_Size		EQU		256
JCB_LogSize		EQU		8

		.bss
JCBs			fill.w	NR_JCB * JCB_Size,0
FreeJCB		dw		0

			.bss
			.org		0x01FBA000

; Task control blocks, room for 256 tasks
NR_TCB			EQU		256
TCB_NxtRdy		fill.w	NR_TCB,0	;	EQU		0x01FBE100	; next task on ready / timeout list
TCB_PrvRdy		fill.w	NR_TCB,0	;	EQU		0x01FBE200	; previous task on ready / timeout list
TCB_NxtTCB		fill.w	NR_TCB,0	;	EQU		0x01FBE300
TCB_Timeout		fill.w	NR_TCB,0	;	EQU		0x01FBE400
TCB_Priority	fill.w	NR_TCB,0	;	EQU		0x01FBE500
TCB_MSG_D1		fill.w	NR_TCB,0	;	EQU		0x01FBE600
TCB_MSG_D2		fill.w	NR_TCB,0	;	EQU		0x01FBE700
TCB_hJCB		fill.w	NR_TCB,0	;	EQU		0x01FBE800
TCB_Status		fill.w	NR_TCB,0	;	EQU		0x01FBE900
TCB_CursorRow	fill.w	NR_TCB,0	;	EQU		0x01FBD100
TCB_CursorCol	fill.w	NR_TCB,0	;	EQU		0x01FBD200
TCB_hWaitMbx	fill.w	NR_TCB,0	;	EQU		0x01FBD300	; handle of mailbox task is waiting at
TCB_mbq_next	fill.w	NR_TCB,0	;	EQU		0x01FBD400	; mailbox queue next
TCB_mbq_prev	fill.w	NR_TCB,0	;	EQU		0x01FBD500	; mailbox queue previous
TCB_SP8Save		fill.w	NR_TCB,0	;	EQU		0x01FBD800	; TCB_SP8Save area 
TCB_SPSave		fill.w	NR_TCB,0	;	EQU		0x01FBD900	; TCB_SPSave area
TCB_StackTop	fill.w	NR_TCB,0
TCB_ABS8Save	fill.w	NR_TCB,0	;	EQU		0x01FBDA00
TCB_mmu_map		fill.w	NR_TCB,0	;	EQU		0x01FBDB00
TCB_npages		fill.w	NR_TCB,0	;	EQU		0x01FBDC00
TCB_ASID		fill.w	NR_TCB,0	;	EQU		0x01FBDD00
TCB_errno		fill.w	NR_TCB,0	;	EQU		0x01FBDE00
TCB_NxtTo		fill.w	NR_TCB,0	;	EQU		0x01FBDF00
TCB_PrvTo		fill.w	NR_TCB,0	;	EQU		0x01FBE000
TCB_MbxList		fill.w	NR_TCB,0	;	EQU		0x01FBCF00	; head pointer to list of mailboxes associated with task
TCB_mbx			fill.w	NR_TCB,0	;	EQU		0x01FBCE00
TCB_HeapStart	fill.w	NR_TCB,0	;	Starting address of heap in task's memory space
TCB_HeapEnd		fill.w	NR_TCB,0	;	Ending addres of heap in task's memory space

;include "jcb.inc"

NR_MMU_MAP		EQU		32
VPM_bitmap_b0	fill.w	NR_MMU_MAP * 16,0
VPM_bitmap_b1	fill.w	NR_MMU_MAP * 16,0
nPagesFree		dw		0

message "cachInvRout"
			.bss
			.align		4096
cacheInvRout:
			fill.w		4096,0
cacheLineInvRout:
			fill.w		4096,0

message "SCREEN_SIZE"
			.bss
			.org		0x01D00000
SCREEN_SIZE		EQU		8192
BIOS_SCREENS	fill.w	SCREEN_SIZE * NR_JCB	; 0x01D00000 to 0x01EFFFFF

; Bitmap of tasks requesting the I/O focus
;
IOFocusTbl	fill.w	8,0

MAX_DEV_OP			EQU		31

; Device Control Block
;
DCB_NAME			EQU		0
DCB_NAME_LEN		EQU		3
DCB_TYPE			EQU		4
DCB_nBPB			EQU		5
DCB_last_erc		EQU		6
DCB_nBlocks			EQU		7
DCB_pDevOp			EQU		8
DCB_pDevInit		EQU		9
DCB_pDevStat		EQU		10
DCB_ReentCount		EQU		11
DCB_fSingleUser		EQU		12
DCB_hJob			EQU		13
DCB_Mbx				EQU		14
DCB_Sema			EQU		15
DCB_OSD3			EQU		16
DCB_OSD4			EQU		17
DCB_OSD5			EQU		18
DCB_OSD6			EQU		19
DCB_SIZE			EQU		20

;Standard Devices are:

;#		Device					Standard name

;0		NULL device 			NUL		(OS built-in)
;1		Keyboard (sequential)	KBD		(OS built-in)
;2		Video (sequential)		VID		(OS built-in)
;3		Printer (parallel 1)	LPT
;4		Printer (parallel 2)	LPT2
;5		RS-232 1				COM1	(OS built-in)
;6		RS-232 2				COM2
;7		RS-232 3				COM3
;8		RS-232 4				COM4
;9
;10		Floppy					FD0
;11		Floppy					FD1
;12		Hard disk				HD0
;13		Hard disk				HD1
;14
;15
;16		SDCard					CARD1 	(OS built-in)
;17
;18
;19
;20
;21
;22
;23
;24
;25
;26
;27
;28		Audio					PSG1	(OS built-in)
;29
;30
;31

NR_DCB		EQU		32
DCBs		fill	NR_DCB * DCB_SIZE,0		;	EQU		MSG_END
DCBs_END	EQU		DCBs + DCB_SIZE * NR_DCB

; preallocated stacks for TCBs
			.bss
			.org		0x01FC0000				; to 0x01FFFFFF
STACK_SIZE		EQU		$400					; 1kW
BIOS_STACKS		fill.w	STACK_SIZE * NR_TCB		; room for 256 1kW stacks


HeapStart	EQU		0x00540000
HeapEnd		EQU		BIOS_SCREENS-1

; EhBASIC vars:
;
NmiBase		EQU		0xDC
IrqBase		EQU		0xDF

; BIOS vars at the top of the 8kB scratch memory
;
; TinyBasic AREA = 0x6C0 to 0x77F

PageMap		EQU		0x600
PageMapEnd	EQU		0x63F
PageMap2	EQU		0x640
PageMap2End	EQU		0x67F
mem_pages_free	EQU		0x680

			bss
			org	0x780

QNdx0		dw		0
QNdx1		dw		0
QNdx2		dw		0
QNdx3		dw		0
QNdx4		dw		0
FreeTCB		dw		0
TimeoutList	dw		0
RunningTCB	dw		0
FreeMbxHandle		dw		0
nMailbox	dw		0
FreeMsg		dw		0
nMsgBlk		dw		0
missed_ticks	dw		0
keybdmsg_d1		dw		0
keybdmsg_d2		dw		0
keybd_mbx		dw		0
keybd_char		dw		0
keybdIsSetup	dw		0
keybdLock		dw		0
keybdInIRQ		dw		0
iof_switch		dw		0
clockmsg_d1		dw		0
clockmsg_d2		dw		0
tcbsema_d1		dw		0
tcbsema_d2		dw		0
mmu_acc_save	dw		0

; The IO focus list is a doubly linked list formed into a ring.
;
IOFocusNdx	dw		0		; really a pointer to the JCB owning the IO focus
;
test_mbx	dw		0
test_D1		dw		0
test_D2		dw		0
tone_cnt	dw		0

IrqSource	EQU		0x79F

			.align	0x10
JMPTMP		dw		0
SP8Save		dw		0
SRSave		dw		0
R1Save		dw		0
R2Save		dw		0
R3Save		dw		0
R4Save		dw		0
R5Save		dw		0
R6Save		dw		0
R7Save		dw		0
R8Save		dw		0
R9Save		dw		0
R10Save		dw		0
R11Save		dw		0
R12Save		dw		0
R13Save		dw		0
R14Save		dw		0
R15Save		dw		0
SPSave		dw		0

			.align	0x10
CharColor	dw		0
ScreenColor	dw		0
CursorRow	dw		0
CursorCol	dw		0
CursorFlash	dw		0
Milliseconds	dw		0
IRQFlag		dw		0
UserTick	dw		0
eth_unique_id	dw		0
LineColor	dw		0
QIndex		dw		0
ROMcs		dw		0
mmu_present	dw		0
TestTask	dw		0
BASIC_SESSION	dw		0
gr_cmd		dw		0
			
			.align	0x10
startSector	dw		0
disk_size	dw		0

;
; CAUTION:
; - do not use these macros.
; - there is currently a bug in the assembler that causes it to lose the
;   macro text
;
macro mStartTask pri,flags,start_addr,param,job
	lda		pri
	ldx		flags
	ldy		start_addr
	ld		r4,param
	ld		r5,job
	int		#4
	db		1
endm

macro mSleep tm
	lda		tm
	int		#4
	db		5
endm

macro mAllocMbx
	int		#4
	db		6
endm

macro mWaitMsg mbx,tmout
	lda		mbx
	ldx		tmout
	int		#4
	db		10
endm

macro mPostMsg	mbx,d1,d2
	lda		mbx
	ldx		d1
	ldy		d2
	int		#4
	db		8
endm

macro DisTimer
	pha
	lda		#3
	sta		PIC+2
	pla
endm

macro EnTimer
	pha
	lda		#3
	sta		PIC+3
	pla
endm

macro DisTmrKbd
	pha
	lda		#3
	sta		PIC+2
	lda		#15
	sta		PIC+2
	pla
endm

macro EnTmrKbd
	pha
	lda		#3
	sta		PIC+3
	lda		#15
	sta		PIC+3
	pla
endm

macro GoReschedule
	int		#2
endm

;------------------------------------------------------------------------------
; Wait for the TCB array to become available
;------------------------------------------------------------------------------
;
macro mAquireTCB
	lda		#33
	ldx		#0
	txy
	ld		r4,#-1
	jsr		WaitMsg
endm

macro mReleaseTCB
	lda		#33
	ldx		#$FFFFFFFE
	txy
	jsr		SendMsg
endm

macro mAquireMBX
	lda		#34
	ldx		#0
	txy
	ld		r4,#-1
	jsr		WaitMsg
endm

macro mReleaseMBX
	lda		#34
	ldx		#$FFFFFFFE
	txy
	jsr		SendMsg
endm


	cpu		rtf65002
	code

message "jump table"
	; jump table of popular BIOS routines
	org		$FFFF8000
ROMStart:
	dw	DisplayChar
	dw	KeybdCheckForKeyDirect
	dw	KeybdGetCharDirect
	dw	KeybdGetChar
	dw	KeybdCheckForKey
	dw	RequestIOFocus
	dw	ReleaseIOFocus
	dw	ClearScreen
	dw	HomeCursor
	dw	ExitTask
	dw	SetKeyboardEcho
	dw	Sleep
	dw	do_load
	dw	do_save
	dw		ICacheInvalidateAll
	dw		ICacheInvalidateLine

	org		$FFFF8400		; leave room for 256 vectors
message "cold start point"
KeybdRST
start
	sei						; disable interrupts
	cld						; disable decimal mode
	lda		#1
	sta		LEDS
	ldx		#BIOS_STACKS+0x03FF	; setup stack pointer top of memory
	txs
	trs		r0,abs8			; set 8 bit mode absolute address offset
	lda		#3
	trs		r1,cc			; enable dcache and icache
	jsr		ROMChecksum
	sta		ROMcs
	jsr		SetupCacheInvalidate
	jsr		InitDevices
	stz		mmu_present		; assume no mmu
	lda		CONFIGREC
	bit		#4096
	beq		st_nommu
	jsr		InitMMU			; setup the maps and enable the mmu
	lda		#1
	sta		mmu_present
st_nommu:
	jsr		MemInit			; Initialize the heap
	stz		iof_switch

	lda		#2
	sta		LEDS

	; setup interrupt vectors
	ldx		#$01FB8001		; interrupt vector table from $5FB0000 to $5FB01FF
							; also sets nmoi policy (native mode on interrupt)
	trs		r2,vbr
	and		r2,r2,#-2		; mask off policy bit
	phx
	txy						; y = pointer to vector table
	lda		#511			; 512 vectors to setup
	ldx		#brk_rout		; point vector to brk routine
	stos

	plx
	lda		#brk_rout
	sta		(x)
	lda		#slp_rout
	sta		1,x
	lda		#reschedule		; must be initialized after vectors are initialized to the break vector
	sta		2,x
	lda		#spinlock_irq
	sta		3,x
	lda		#syscall_int
	sta		4,x
	lda		#KeybdRST
	sta		448+1,x
	lda		#p1000Hz
	sta		448+2,x
	lda		#MTKTick
	sta		448+3,x
	lda		#KeybdIRQ
	sta		448+15,x
	lda		#SerialIRQ
	sta		448+8,x
	lda		#InvalidOpIRQ
	sta		495,x
	lda		#bus_err_rout
	sta		508,x
	sta		509,x

	lda		#3
	sta		LEDS

	; stay in native mode in case emulation is not supported.
	ldx		#$1FF			; set 8 bit stack pointer
	trs		r2,sp8
	
	ldx		#0
	stz		IrqBase			; support for EhBASIC's interrupt mechanism
	stz		NmiBase

	jsr		($FFFFC000>>2)		; Initialize multi-tasking
	lda		#TickRout		; setup tick routine
	sta		UserTick

	lda		#1
	sta		iof_sema

	lda		#(DCB_SIZE * NR_DCB)-1
	ldx		#0
	ldy		#DCBs
	stos

	lda		#$CE			; CE =blue on blue FB = grey on grey
	sta		ScreenColor
	sta		CharColor
	sta		CursorFlash
	jsr		ClearScreen
	jsr		InitBMP
	jsr		ClearBmpScreen
	jsr		PICInit
	; Enable interrupts
	; This will likely cause an interrupt right away because the timer
	; pulses run since power-up.
	cli						
;	mStartTask	#PRI_LOWEST,#0,#IdleTask,#0,#0
	lda		#PRI_LOWEST
	ldx		#0
	ldy		#IdleTask
	ld		r4,#0
	ld		r5,#0
	int		#4
	db		1
	lda		CONFIGREC		; do we have a serial port ?
	bit		#32
	beq		st7
	; 19200 * 16
	;-------------
	; 25MHz / 2^32
	lda		#$03254E6E		; constant for 19,200 baud at 25MHz
	jsr		SerialInit
st7:
	lda		#5
	sta		LEDS
	lda		CONFIGREC		; do we have sprites ?
	bit		#1
	beq		st8
	lda		#$3FFF			; turn on sprites
	sta		SPRITEREGS+120
	jsr		RandomizeSprram
st8:
	; Enable interrupts.
	; Keyboard initialization must take place after interrupts are
	; enabled.
	cli						
	lda		#14
	sta		LEDS
	stz		keybdIsSetup
;	mStartTask	#PRI_NORMAL,#0,#KeybdSetup,#0
	lda		#PRI_NORMAL
	ldx		#0
	ldy		#KeybdSetup
	ld		r4,#0
	ld		r5,#0
	int		#4
	db		1
;	lea		r3,KeybdStatusLEDs
;	jsr		StartTask
	lda		#6
	sta		LEDS

	; The following must be after interrupts are enabled.
	lda		#9
	sta		LEDS
	jsr		HomeCursor
	lda		#msgStart
	jsr		DisplayStringB
	jsr		ReportMemFree
	lda		#msgChecksum
	jsr		DisplayStringB
	lda		ROMcs
	jsr		DisplayWord
	jsr		CRLF
	lda		#10
	sta		LEDS

	; The AC97 setup uses the millisecond counter and the
	; keyboard.
	lda		CONFIGREC		; do we have a sound generator ?
	bit		#4
	beq		st6
	jsr		SetupAC97
	lda		#4
	ldx		#0
	ldy		#Beep
;	jsr		StartTask
st6:
	lda		#11
	sta		LEDS
	stz		BASIC_SESSION
	jmp		Monitor
st1
	jsr		KeybdGetCharDirect
	bra		st1
	stp
	bra		start
	
msgStart
	db		"RTF65002 system starting.",$0d,$0a,00

;------------------------------------------------------------------------------
; SetupCacheInvalidate:
;
;	Setup the cache invalidate routines. Cache's in the FPGA don't have
; invalidate logic as it cannot be efficiently implemented. So we handle
; cache invalidations using software. By calling a software routine, or
; accessing data in the setup cache invalidate area, the cache will be
; effectively invalidated. This works for caches up to 16kB. (4kW)
;------------------------------------------------------------------------------

message "SetupCacheInvalidate"
SetupCacheInvalidate:
	lda		#4095
	ldx		#$EAEAEAEA			; fill memory with NOP's
	ldy		#cacheInvRout
	stos
	lda		#4095
	ldx		#$60606060			; fill memory with RTS's
	ldy		#cacheLineInvRout
	stos
	rts

;------------------------------------------------------------------------------
; ICacheInvalidateAll:
;
; Call to invalidate the entire ICache
;------------------------------------------------------------------------------

ICacheInvalidateAll:
	jml		cacheInvRout<<2

;------------------------------------------------------------------------------
; ICacheInvalidateLine:
;
; Call to invalidate a specific cache line
;
; Parameters:
;	r1 = code address in line to invalidate
;------------------------------------------------------------------------------
;
ICacheInvalidateLine:
	and		#$3FFF
	add		#cacheLineInvRout<<2
	jmp		(r1)				; this will touch the cache line then RTS

;------------------------------------------------------------------------------
; DCacheInvalidateAll:
;
; Call to invalidate the entire DCache. Works by performing a data fetch from
; dummy data at each possible cache address. Works for caches up to 16kB in
; size.
;------------------------------------------------------------------------------

DCacheInvalidateAll:
	phx
	ldx		#0
.0001:
	ld		r0,cacheInvRout,x
	inx
	cpx		#$FFF
	bls		.0001
	plx
	rts

;------------------------------------------------------------------------------
; DCacheInvalidateLine:
;
; Call to invalidate a specific cache line in the data cache.
;
; Parameters:
;	r1 = data address in line to invalidate
;------------------------------------------------------------------------------
;
DCacheInvalidateLine:
	pha
	and		#$FFF
	ld		r0,cacheInvRout,r1
	pla
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
InitBMP:
	ldx		#0
ibmp1:
	tsr		LFSR,r1
	sta		BMP_CLUT,x
	inx
	cpx		#512
	bne		ibmp1
	rts


;------------------------------------------------------------------------------
; The ROM contents are summed up to ensure the ROM is okay.
;------------------------------------------------------------------------------
ROMChecksum:
	lda		#0
	ldx		#ROMStart>>2
idc1:
	add		(x)
	inx
	cpx		#$100000000>>2
	bne		idc1
	cmp		#0			; The sum of all the words in the
						; ROM should be zero.
	rts

msgChecksum:
	db	CR,LF,"ROM checksum: ",0

;----------------------------------------------------------
; Initialize programmable interrupt controller (PIC)
;  0 = nmi (parity error)
;  1 = keyboard reset
;  2 = 1000Hz pulse
;  3 = 100Hz pulse (cursor flash)
;  4 = ethmac
;  8 = uart
; 13 = raster interrupt
; 15 = keyboard char
;----------------------------------------------------------
message "PICInit"
PICInit:
	;
	lda		#$000C			; clock pulses are edge sensitive
	sta		PIC_ES
	lda		#$000F			; enable nmi,kbd_rst
	; A10F enable serial IRQ
	sta		PIC_IE
PICret:
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
message "DumpTaskList"
DumpTaskList:
	pha
	phx
	phy
	push	r4
	lda		#msgTaskList
	jsr		DisplayStringB
	ldy		#0
	spl		tcb_sema + 1
dtl2:
	lda		QNdx0,y
	ld		r4,r1
	bmi		dtl1
dtl3:
	ldx		#3
	tya
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	ld		r1,r4
	ldx		#3
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	jsr		DisplayChar
	jsr		DisplayChar
	ld		r1,r4
	lda		TCB_Status,r1
	jsr		DisplayByte
	lda		#' '
	jsr		DisplayChar
	ldx		#3
	lda		TCB_PrvRdy,r4
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	ldx		#3
	lda		TCB_NxtRdy,r4
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	lda		TCB_Timeout,r4
	jsr		DisplayWord
	jsr		CRLF
	ld		r4,TCB_NxtRdy,r4
	cmp		r4,QNdx0,y
	bne		dtl3
dtl1:
	iny
	cpy		#5
	bne		dtl2
	stz		tcb_sema + 1
	pop		r4
	ply
	plx
	pla
	rts

msgTaskList:
	db	CR,LF,"Pri Task Stat Prv Nxt Timeout",CR,LF,0

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
message "DumpTimeoutList"
DumpTimeoutList:
	pha
	phx
	phy
	push	r4
	lda		#msgTimeoutList
	jsr		DisplayStringB
	ldy		#11
dtol2:
	lda		TimeoutList
	ld		r4,r1
	bmi		dtol1
	spl		tcb_sema + 1
dtol3:
	dey
	beq		dtol1
	ld		r1,r4
	ldx		#3
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	jsr		DisplayChar
	jsr		DisplayChar
	ld		r1,r4
	ldx		#3
	lda		TCB_PrvTo,r4
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	ldx		#3
	lda		TCB_NxtTo,r4
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	lda		TCB_Timeout,r4
	jsr		DisplayWord
	jsr		CRLF
	ld		r4,TCB_NxtTo,r4
	bpl		dtol3
dtol1:
	stz		tcb_sema + 1
	pop		r4
	ply
	plx
	pla
	rts

msgTimeoutList:
	db	CR,LF,"Task Prv Nxt Timeout",CR,LF,0

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
message "DumpIOFocusList"
DumpIOFocusList:
	pha
	phx
	phy
	lda		#msgIOFocusList
	jsr		DisplayStringB
	spl		iof_sema + 1
	lda		IOFocusNdx
diofl2:
	beq		diofl1
	tay
	ldx		#3
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	lda		JCB_iof_prev,y
	ldx		#3
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	lda		JCB_iof_next,y
	ldx		#3
	jsr		PRTNUM
	jsr		CRLF
	lda		JCB_iof_next,y
	cmp		IOFocusNdx
	bne		diofl2
	
diofl1:
	stz		iof_sema + 1
	ply
	plx
	pla
	rts
	
msgIOFocusList:
	db	CR,LF,"Task Prv Nxt",CR,LF,0

RunningTCBErr:
;	lda		#$FF
;	sta		LEDS
	lda		#msgRunningTCB
	jsr		DisplayStringB
rtcberr1:
	jsr		KeybdGetChar
	cmp		#-1
	beq		rtcberr1
	jmp		start

msgRunningTCB:
	db	CR,LF,"RunningTCB is bad.",CR,LF,0

;------------------------------------------------------------------------------
; Get the handle of the currently running job.
;------------------------------------------------------------------------------
;
GetCurrentJob:
	ld		r1,RunningTCB
	ld		r1,TCB_hJCB,r1		; get the handle
	rts

;------------------------------------------------------------------------------
; Get a pointer to the JCB for the currently running task.
;------------------------------------------------------------------------------
;
GetPtrCurrentJCB:
	jsr		GetCurrentJob
	and		r1,r1,#NR_JCB-1		; and convert it to a pointer
;	mul		r1,r1,#JCB_Size
	asl		r1,r1,#JCB_LogSize	; 256 words
	add		r1,r1,#JCBs
	rts

;------------------------------------------------------------------------------
; Get the location of the screen and screen attribute memory. The location
; depends on whether or not the task has the output focus.
;------------------------------------------------------------------------------
GetScreenLocation:
	jsr		GetPtrCurrentJCB
	lda		JCB_pVidMem,r1
	rts

GetColorCodeLocation:
	jsr		GetPtrCurrentJCB
	lda		JCB_pVidMemAttr,r1
	rts

GetNormAttr:
	jsr		GetPtrCurrentJCB
	lda		JCB_NormAttr,r1
	rts

GetCurrAttr:
	jsr		GetPtrCurrentJCB
	lda		JCB_CurrAttr,r1
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
message "CopyVirtualScreenToScreen"
CopyVirtualScreenToScreen
	pha
	phx
	phy
	push	r4
	ldx		IOFocusNdx			; compute virtual screen location
	beq		cvss3
	; copy screen chars
	lda		#4095				; number of words to copy-1
	ldx		JCB_pVirtVid,x
	ldy		#TEXTSCR
	mvn
	; now copy the color codes
	lda		#4095
	ldx		IOFocusNdx
	ldx		JCB_pVirtVidAttr,x
	ldy		#TEXTSCR+$10000
	mvn
cvss3:
	; reset the cursor position in the text controller
	ldy		IOFocusNdx
	ldx		JCB_CursorRow,y
	lda		TEXTREG+TEXT_COLS
	mul		r2,r2,r1
	add		r2,r2,JCB_CursorCol,y
	stx		TEXTREG+TEXT_CURPOS
	pop		r4
	ply
	plx
	pla
	rts
message "CopyScreenToVirtualScreen"
CopyScreenToVirtualScreen
	pha
	phx
	phy
	push	r4
	lda		#4095
	ldx		#TEXTSCR
	ldy		IOFocusNdx
	beq		csvs3
	ldy		JCB_pVirtVid,y
	mvn
	lda		#4095
	ldx		#TEXTSCR+$10000
	ldy		IOFocusNdx
	ldy		JCB_pVirtVidAttr,y
	mvn
csvs3:
	pop		r4
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Clear the screen and the screen color memory
; We clear the screen to give a visual indication that the system
; is working at all.
;------------------------------------------------------------------------------
;
message "ClearScreen"
ClearScreen:
	pha							; holds a space character
	phx							; loop counter
	phy							; memory addressing
	lda		TEXTREG+TEXT_COLS	; calc number to clear
	ldx		TEXTREG+TEXT_ROWS
	mul		r1,r1,r2			; r1 = # chars to clear
	pha
	jsr		GetScreenLocation
	tay							; y = target address
	lda		#' '				; space char
	jsr		AsciiToScreen
	tax							; x is value to store
	pla							; a is count
	pha
	stos						; clear the memory
	jsr		GetCurrAttr
	tax							; x = value to use
	jsr		GetColorCodeLocation
	tay							; y = target address
	pla							; a = count
	stos
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Scroll text on the screen upwards
;------------------------------------------------------------------------------
;
message "ScrollUp"
ScrollUp:
	pha
	phx
	phy
	push	r4
	push	r5
	push	r6
	lda		TEXTREG+TEXT_COLS	; acc = # text columns
	ldx		TEXTREG+TEXT_ROWS
	mul		r2,r1,r2			; calc number of chars to scroll
	sub		r2,r2,r1			; one less row
	pha
	jsr		GetScreenLocation
	tay
	jsr		GetColorCodeLocation
	ld		r6,r1
	pla
scrup1:
	add		r5,r3,r1
	ld		r4,(r5)				; move character
	st		r4,(y)
	add		r5,r6,r1
	ld		r4,(r5)				; and move color code
	st		r4,(r6)
	iny
	inc		r6
	dex
	bne		scrup1
	lda		TEXTREG+TEXT_ROWS
	dea
	jsr		BlankLine
	pop		r6
	pop		r5
	pop		r4
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Blank out a line on the display
; line number to blank is in acc
;------------------------------------------------------------------------------
;
BlankLine:
	pha
	phx
	phy
	push	r4
	push	r5
	ldx		TEXTREG+TEXT_COLS	; x = # chars to blank out from video controller
	mul		r3,r2,r1			; y = screen index (row# * #cols)
	ld		r5,r3				; r5 = screen index
	pha
	jsr		GetScreenLocation
	ld		r4,r1
	pla
	add		r3,r3,r4		; y = screen address
	lda		#' '
	jsr		AsciiToScreen
blnkln1:
	sta		(y)
	iny
	dex
	bne		blnkln1
	; reset the color codes on the display line to the normal attribute
	jsr		GetColorCodeLocation
	tay							; y = destination
	add		r3,r3,r5			; add in index
	jsr		GetNormAttr			; get the value to set
	tax
	lda		TEXTREG+TEXT_COLS	; number of columns to blank out
	dea							; acc is one less
	stos
	pop		r5
	pop		r4
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Convert ASCII character to screen display character.
;------------------------------------------------------------------------------
;
	align	8
AsciiToScreen:
	and		#$FF
	or		#$100
	bit		#%00100000	; if bit 5 isn't set
	beq		.00001
	bit		#%01000000	; or bit 6 isn't set
	beq		.00001
	and		#%110011111
.00001:
	rts

;------------------------------------------------------------------------------
; Convert screen character to ascii character
;------------------------------------------------------------------------------
;
ScreenToAscii:
	and		#$FF
	cmp		#26+1
	bcs		stasc1
	add		#$60
stasc1:
	rts

;------------------------------------------------------------------------------
; HomeCursor
; Set the cursor location to the top left of the screen.
;------------------------------------------------------------------------------
HomeCursor:
	pha
	phx
	phy
	spl		jcb_sema + 1
	jsr		GetPtrCurrentJCB
	tax
	stz		JCB_CursorRow,x
	stz		JCB_CursorCol,x
	stz		jcb_sema + 1
	cpx		IOFocusNdx
	bne		hc1
	stz		TEXTREG+TEXT_CURPOS
hc1:
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Update the cursor position in the text controller based on the
;  CursorRow,CursorCol.
;------------------------------------------------------------------------------
;
UpdateCursorPos:
	pha
	jsr		GetPtrCurrentJCB
	cmp		IOFocusNdx				; update cursor position in text controller
	bne		.ucp1					; only for the task with the output focus
	ld		r0,JCB_CursorOn,r4		; only update if cursor is showing
	beq		.ucp2
	jsr		CursorOn
	phx
	push	r4
	ld		r4,r1
	lda		JCB_CursorRow,r4
	and		#$3F					; limit of 63 rows
	ldx		TEXTREG+TEXT_COLS
	mul		r2,r2,r1
	lda		JCB_CursorCol,r4
	and		#$7F					; limit of 127 cols
	add		r2,r2,r1
	stx		TEXTREG+TEXT_CURPOS
	pop		r4
	plx
.ucp1:
	pla
	rts
.ucp2:
	jsr		CursorOff
	pla
	rts

CursorOff:
	pha
	lda		#5
	bms		TEXTREG+TEXT_CURCTL
	lda		#6
	bmc		TEXTREG+TEXT_CURCTL
	pla
	rts

CursorOn:
	pha
	lda		#5
	bmc		TEXTREG+TEXT_CURCTL
	lda		#6
	bms		TEXTREG+TEXT_CURCTL
	pla
	rts

;------------------------------------------------------------------------------
; Calculate screen memory location from CursorRow,CursorCol.
; Also refreshes the cursor location.
; Returns:
; r1 = screen location
;------------------------------------------------------------------------------
;
CalcScreenLoc:
	phx
	push	r4
	jsr		GetPtrCurrentJCB
	ld		r4,r1
	lda		JCB_CursorRow,r4
	and		#$3F					; limit to 63 rows
	ldx		TEXTREG+TEXT_COLS
	mul		r2,r2,r1
	lda		JCB_CursorCol,r4
	and		#$7F					; limit to 127 cols
	add		r2,r2,r1
	cmp		r4,IOFocusNdx			; update cursor position in text controller
	bne		csl1					; only for the task with the output focus
	stx		TEXTREG+TEXT_CURPOS
csl1:
	jsr		GetScreenLocation
	add		r1,r1,r2
	pop		r4
	plx
	rts

;------------------------------------------------------------------------------
; Display a character on the screen.
; If the task doesn't have the I/O focus then the character is written to
; the virtual screen.
;
; Parameters:
;	r1 = char to display
;------------------------------------------------------------------------------
;
message "DisplayChar"
DisplayChar:
	push	r4
	pha
	jsr		GetPtrCurrentJCB
	ld		r4,r1
	lda		JCB_esc,r4			; are we building an escape sequence ?
	bne		.processEsc
	pla
	and		#$FF				; mask off any higher order bits (called from eight bit mode).
	cmp		#ESC	
	bne		.0001
	sta		JCB_esc,r4			; begin the esc sequence
	pop		r4
	rts
.0001
	cmp		#BELL
	bne		.noBell
	jsr		Beep
	pop		r4
	rts
.noBell
	cmp		#'\r'				; carriage return ?
	bne		.dccr
	stz		JCB_CursorCol,r4	; just set cursor column to zero on a CR
	jsr		UpdateCursorPos
.dcx14:
	pop		r4
	rts
.dccr:
	cmp		#$91				; cursor right ?
	bne		.dcx6
	pha
	lda		JCB_CursorCol,r4
	ina
	cmp		JCB_VideoCols,r4
	bhs		.dcx7
	sta		JCB_CursorCol,r4
.dcx7:
	jsr		UpdateCursorPos
	pla
	pop		r4
	rts
.dcx6:
	cmp		#$90				; cursor up ?
	bne		.dcx8		
	pha
	lda		JCB_CursorRow,r4
	beq		.dcx7
	dea
	sta		JCB_CursorRow,r4
	bra		.dcx7
.dcx8:
	cmp		#$93				; cursor left ?
	bne		.dcx9
	pha
	lda		JCB_CursorCol,r4
	beq		.dcx7
	dea
	sta		JCB_CursorCol,r4
	bra		.dcx7
.dcx9:
	cmp		#$92				; cursor down ?
	bne		.dcx10
	pha
	lda		JCB_CursorRow,r4
	ina
	cmp		JCB_VideoRows,r4
	bhs		.dcx7
	sta		JCB_CursorRow,r4
	bra		.dcx7
.dcx10:
	cmp		#$94				; cursor home ?
	bne		.dcx11
	pha
	lda		JCB_CursorCol,r4
	beq		.dcx12
	stz		JCB_CursorCol,r4
	bra		.dcx7
.dcx12:
	stz		JCB_CursorRow,r4
	bra		.dcx7
.dcx11:
	pha
	phx
	phy
	cmp		#$99				; delete ?
	bne		.dcx13
.doDel:
	jsr		CalcScreenLoc
	tay							; y = screen location
	lda		JCB_CursorCol,r4	; acc = cursor column
	bra		.dcx5
.dcx13	
	cmp		#CTRLH				; backspace ?
	bne		.dcx3
	lda		JCB_CursorCol,r4
	beq		.dcx4
	dea
	sta		JCB_CursorCol,r4
	jsr		CalcScreenLoc		; acc = screen location
	tay							; y = screen location
	lda		JCB_CursorCol,r4
.dcx5:
	ldx		$4,y
	stx		(y)
	iny
	ina
	cmp		JCB_VideoCols,r4
	blo		.dcx5
	lda		#' '
	jsr		AsciiToScreen
	dey
	sta		(y)
	bra		.dcx4
.dcx3:
	cmp		#'\n'			; linefeed ?
	beq		.dclf
	tax						; save acc in x
	jsr 	CalcScreenLoc	; acc = screen location
	tay						; y = screen location
	txa						; restore r1
	jsr		AsciiToScreen	; convert ascii char to screen char
	sta		(y)
	jsr		GetScreenLocation
	sub		r3,r3,r1		; make y an index into the screen
	jsr		GetColorCodeLocation
	add		r3,r3,r1
	jsr		GetCurrAttr
	sta		(y)
	jsr		IncCursorPos
	bra		.dcx4
.dclf:
	jsr		IncCursorRow
.dcx4:
	ply
	plx
	pla
	pop		r4
	rts

	; ESC processing
.processEsc:
	cmp		#(ESC<<24)+('('<<16)+(ESC<<8)+'G'
	beq		.procAttr
	bit		#$FF000000			; is it some other five byte escape sequence ?
	bne		.unrecogEsc
	cmp		#(ESC<<16)+('('<<8)+ESC
	beq		.testG
	bit		#$FF0000			; is it some other four byte escape sequence ?
	bne		.unrecogEsc			; - unrecognized escape sequence
	cmp		#(ESC<<8)+'`'
	beq		.cursOnOff
	cmp		#(ESC<<8)+'('
	beq		.testEsc
	bit		#$FF00				; is it some other three byte sequence ?
	bne		.unrecogEsc			; - unrecognized escape sequence
	cmp		#ESC				; check for single char escapes
	beq		.esc1
	pla							; some other garbage in the esc buffer ?
	stz		JCB_esc,r4
	pop		r4
	rts

.cursOnOff:
	pla
	stz		JCB_CursorOn,r4
	and		#$FF
	cmp		#'0'
	beq		.escRst
	inc		JCB_CursorOn,r4
.escRst:
	stz		JCB_esc,r4			; reset escape sequence capture
	pop		r4
	rts

.procAttr:
	pla
	and		#$FF
	cmp		#'0'
	bne		.0005
	lda		JCB_NormAttr,r4
	sta		JCB_CurrAttr,r4
	bra		.escRst
.0005:
	cmp		#'4'
	bne		.escRst
	phx
	lda		JCB_NormAttr,r4		; get the normal attribute
	tax
	lsr		r1,r1,#5			; swap foreground and background colors
	and		#$1F
	asl		r2,r2,#5
	or		r1,r1,r2
	plx
	sta		JCB_CurrAttr,r4		; store in current attribute
	bra		.escRst

.esc1:
	pla
	and		#$FF
	cmp		#'W'				; esc 'W' - delete char under cursor
	bne		.0006
	stz		JCB_esc,r4
	pha
	phx
	phy
	bra		.doDel
.0006:
	cmp		#'T'				; esc 'T' - clear to end of line
	bne		.0009
	phx
	phy
	ldx		JCB_CursorCol,r4
	jsr 	CalcScreenLoc		; acc = screen location
	tay
	lda		#' '
	jsr		AsciiToScreen
.0008:
	sta		(y)
	iny
	inx
	cpx		JCB_VideoCols,r4
	blo		.0008
	ply
	plx
	bra		.escRst
.0009:
	cmp		#'`'
	bne		.0010
	bra		.stuffChar
.0010:
	cmp		#'('
	bne		.escRst
	bra		.stuffChar

.unrecogEsc:
	pla
	bra		.escRst

.testG:
	pla
	and		#$FF
	cmp		#'G'
	bne		.escRst
	
	; stuff a character into the escape sequence
.stuffChar:
	pha
	lda		JCB_esc,r4
	asl		r1,r1,#8
	or		r1,r1,0,sp
	sta		JCB_esc,r4
	pla
	pop		r4
	rts

.testEsc:
	pla
	and		#$FF
	cmp		#ESC
	bne		.escRst
	bra		.stuffChar

;------------------------------------------------------------------------------
; Increment the cursor position, scroll the screen if needed.
;------------------------------------------------------------------------------
;
message "IncCursorPos"
IncCursorPos:
	pha
	phx
	push	r4
	jsr		GetPtrCurrentJCB
	ld		r4,r1
	lda		JCB_CursorCol,r4
	ina
	sta		JCB_CursorCol,r4
	ldx		JCB_VideoCols,r4
	cmp		r1,r2
	blo		icc1
	stz		JCB_CursorCol,r4		; column = 0
	bra		icr1
IncCursorRow:
	pha
	phx
	push	r4
	jsr		GetPtrCurrentJCB
	ld		r4,r1
icr1:
	lda		JCB_CursorRow,r4
	ina
	sta		JCB_CursorRow,r4
	ldx		JCB_VideoRows,r4
	cmp		r1,r2
	blo		icc1
	dex							; backup the cursor row, we are scrolling up
	stx		JCB_CursorRow,r4
	jsr		ScrollUp
icc1:
	jsr		UpdateCursorPos
icc2:
	pop		r4
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Display a string on the screen.
; The characters are packed 4 per word
;------------------------------------------------------------------------------
;
message "DisplayStringB"
DisplayStringB:
	pha
	phx
	tax						; r2 = pointer to string
dspj1B:
	lb		r1,0,x			; move string char into acc
	inx						; increment pointer
	cmp		#0				; is it end of string ?
	beq		dsretB
	jsr		DisplayChar		; display character
	bra		dspj1B
dsretB:
	plx
	pla
	rts

DisplayStringQ:
	pha
	phx
	tax						; r2 = pointer to string
	lda		#TEXTSCR
	sta		QIndex
dspj1Q:
	lb		r1,0,x			; move string char into acc
	inx						; increment pointer
	cmp		#0				; is it end of string ?
	beq		dsretQ
	jsr		DisplayCharQ	; display character
	bra		dspj1Q
dsretQ:
	plx
	pla
	rts

DisplayCharQ:
	pha
	phx
	jsr		AsciiToScreen
	ldx		#0
	sta		(QIndex,x)
	lda		QIndex
	ina
	sta		QIndex
;	inc		QIndex
	plx
	pla
	rts

	
;------------------------------------------------------------------------------
; Display a string on the screen.
; The characters are packed 1 per word
;------------------------------------------------------------------------------
;
message "DisplayStringW"
DisplayStringW:
	pha
	phx
	tax						; r2 = pointer to string
dspj1W:
	lda		(x)				; move string char into acc
	inx						; increment pointer
	cmp		#0				; is it end of string ?
	beq		dsretW
	jsr		DisplayChar		; display character
	bra		dspj1W			; go back for next character
dsretW:
	plx
	pla
	rts

DisplayStringCRLFB:
	jsr		DisplayStringB
CRLF:
	pha
	lda		#'\r'
	jsr		DisplayChar
	lda		#'\n'
	jsr		DisplayChar
	pla
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
message "TickRout"
TickRout:
	; support EhBASIC's IRQ functionality
	; code derived from minimon.asm
	lda		#3				; Timer is IRQ #3
	sta		IrqSource		; stuff a byte indicating the IRQ source for PEEK()
	lb		r1,IrqBase		; get the IRQ flag byte
	lsr		r4,r1
	or		r1,r1,r4
	and		#$E0
	sb		r1,IrqBase

	inc		TEXTSCR+55		; update IRQ live indicator on screen
	
	; flash the cursor
	jsr		GetPtrCurrentJCB
	tax
	cpx		IOFocusNdx		; only bother to flash the cursor for the task with the IO focus.
	bne		tr1a
	lda		JCB_CursorFlash,x	; test if we want a flashing cursor
	beq		tr1a
	jsr		CalcScreenLoc	; compute cursor location in memory
	tay
	lda		$10000,y		; get color code $10000 higher in memory
	ld		r4,IRQFlag		; get counter
	lsr		r4,r4
	and		r4,r4,#$0F		; limit to low order nybble
	and		#$F0			; prepare to or in new value, mask off foreground color
	or		r1,r1,r4		; set new foreground color for cursor
	sta		$10000,y		; store the color code back to memory
tr1a
	rts

message "null.asm"
include "null.asm"
message "keyboard.asm"
include "keyboard.asm"
message "iofocus.asm"
include "iofocus.asm"
message "serial.asm"
include "serial.asm"

message "797"
;------------------------------------------------------------------------------
; Display the half-word in r1
;------------------------------------------------------------------------------
;
DisplayWord:
	pha
	lsr		r1,r1,#16
	jsr		DisplayHalf
	pla
	
;------------------------------------------------------------------------------
; Display the half-word in r1
;------------------------------------------------------------------------------
;
DisplayHalf:
	pha
	lsr		r1,r1,#8
	jsr		DisplayByte
	pla

;------------------------------------------------------------------------------
; Display the byte in r1
;------------------------------------------------------------------------------
;
DisplayByte:
	pha
	lsr		r1,r1,#4
	jsr		DisplayNybble
	pla
	
;------------------------------------------------------------------------------
; Display nybble in r1
;------------------------------------------------------------------------------
;
DisplayNybble:
	pha
	and		#$0F
	add		#'0'
	cmp		#'9'+1
	bcc		dispnyb1
	add		#7
dispnyb1:
	jsr		DisplayChar
	pla
	rts

message "810"
;------------------------------------------------------------------------------
; Display memory pointed to by r2.
; destroys r1,r3
;------------------------------------------------------------------------------
;
DisplayMemW:
	pha
	lda		#'>'
	jsr		DisplayChar
	txa
	jsr		DisplayWord
	lda		#' '
	jsr		DisplayChar
	lda		(x)
	jsr		DisplayWord
	inx
	lda		#' '
	jsr		DisplayChar
	lda		(x)
	jsr		DisplayWord
	inx
	lda		#' '
	jsr		DisplayChar
	lda		(x)
	jsr		DisplayWord
	inx
	lda		#' '
	jsr		DisplayChar
	lda		(x)
	jsr		DisplayWord
	inx
	jsr		CRLF
	pla
	rts

;------------------------------------------------------------------------------
; Display memory pointed to by r2.
; destroys r1,r3
;------------------------------------------------------------------------------
;
DisplayMemBytes:
	pha
	phy
	lda		#'>'
	jsr		DisplayChar
	lda		#'B'
	jsr		DisplayChar
	lda		#' '
	jsr		DisplayChar
	txa
	jsr		DisplayWord
	ldy		#0
.001:
	lda		#' '
	jsr		DisplayChar
	lb		r1,0,x
	jsr		DisplayByte
	inx
	iny
	cpy		#8
	blo		.001
	lda		#':'
	jsr		DisplayChar
	ldy		#0
	sub		r2,r2,#8
.002
	lb		r1,0,x
	cmp		#26			; convert control characters to '.'
	bhs		.003
	lda		#'.'
.003:
	jsr		DisplayChar
	inx
	iny
	cpy		#8
	blo		.002
	jsr		CRLF
	ply
	pla
	rts

message "Monitor"
;==============================================================================
; System Monitor Program
; The system monitor is task#0
;==============================================================================
;
Monitor:
	ldx		#BIOS_STACKS+0x03FF	; setup stack pointer
	txs
	lda		#0					; turn off keyboard echo
	jsr		SetKeyboardEcho
	jsr		RequestIOFocus
.PromptLn:
	jsr		CRLF
	lda		#'$'
	jsr		DisplayChar

; Get characters until a CR is keyed
;
.Prompt3:
	jsr		RequestIOFocus
;	lw		r1,#2			; get keyboard character
;	syscall	#417
;	jsr		KeybdCheckForKeyDirect
;	cmp		#0
	jsr		KeybdGetChar
	cmp		#-1
	beq		.Prompt3
;	jsr		KeybdGetCharDirect
	cmp		#CR
	beq		.Prompt1
	jsr		DisplayChar
	bra		.Prompt3

; Process the screen line that the CR was keyed on
;
.Prompt1:
	lda		#80
	sta		LEDS
	ldx		RunningTCB
	ldx		TCB_hJCB,x
	cpx		#NR_JCB
	bhs		.Prompt3
	mul		r2,r2,#JCB_Size
	add		r2,r2,#JCBs
	lda		#81
	sta		LEDS
	stz		JCB_CursorCol,x	; go back to the start of the line
	jsr		CalcScreenLoc	; r1 = screen memory location
	tay
	lda		#82
	sta		LEDS
	jsr		MonGetch
	cmp		#'$'
	bne		.Prompt2			; skip over '$' prompt character
	lda		#83
	sta		LEDS
	jsr		MonGetch

; Dispatch based on command character
;
.Prompt2:
	cmp		#'>'
	beq		EditMem
	cmp		#'M'
	bne		.testDIR
	jsr		MonGetch
	cmp		#'B'
	beq		DumpMemBytes
	dey
	bra		DumpMem
.testDIR:
	cmp		#'D'
	bne		.Prompt8
	cmp		#'I'
	beq		DoDir
	bra		Monitor
.Prompt8:
	cmp		#'F'
	bne		.Prompt7
	jsr		MonGetch
	cmp		#'L'
	bne		.Prompt8a
	jsr		DumpIOFocusList
	jmp		Monitor
.Prompt8a:
	cmp		#'I'
	beq		DoFig
	cmp		#'M'
	beq		DoFmt
	dey
	bra		FillMem
.Prompt7:
	cmp		#'B'			; $B - start tiny basic
	bne		.Prompt4
	mStartTask	#PRI_LOW,#0,#CSTART,#0,#4
	bra		Monitor
.Prompt4:
	cmp		#'b'
	bne		.Prompt5
	lda		BASIC_SESSION
	cmp		#0
	bne		.bsess1
	inc		BASIC_SESSION
;	lda		#3				; priority level 3
;	ldy		#$F000			; start address $F000
;	ldx		#$00000000		; flags: 
;	jmp		(y)
;	jsr		($FFFFC004>>2)		; StartTask
;	mStartTask	#PRI_LOW,#0,#$F000,#0,#0
	lda		#PRI_LOW
	ldx		#0
	ldy		#$F000
	ld		r4,#0
	ld		r5,#3
	int		#4
	db		1
	bra		Monitor
.bsess1:
	inc		BASIC_SESSION
	ldx		#$3000
	ldy		#$4303000
	asl		r1,r1,#14		; * 16kW
	add		r3,r3,r1
	phy
	lda		#4095			; 4096 words to copy
	mvn						; copy BASIC ROM
	ply
	asl		r3,r3,#2		; convert to code address	
	add		r3,r3,#$3000	; xxxx_F000
	lda		#3
	ldx		#$00000000		; zero flags at startup
	jsr		($FFFFC004>>2)	; StartTask
	bra		Monitor
	emm
	cpu		W65C02
	jml		$0C000
	cpu		rtf65002
.Prompt5:
	cmp		#'J'			; $J - execute code
	beq		ExecuteCode
	cmp		#'L'			; $L - load dector
	beq		LoadBlock
	cmp		#'W'
	beq		WriteBlock
.Prompt9:
	cmp		#'?'			; $? - display help
	bne		.Prompt10
	lda		#HelpMsg
	jsr		DisplayStringB
	jmp		Monitor
.Prompt10:
	cmp		#'C'			; $C - clear screen
	beq		TestCLS
	cmp		#'r'
	bne		.Prompt12
	lda		#4				; priority level 4
	ldx		#0				; zero all flags at startup
	ldy		#RandomLines	; task address
	jsr		(y)
;	jsr		StartTask
;	jsr		($FFFFC004>>2)	; StartTask
	jmp		Monitor
;	jmp		RandomLinesCall
.Prompt12:
.Prompt13:
	cmp		#'P'
	bne		.Prompt14
	mStartTask	#PRI_NORMAL,#0,#Piano,#0,#2
	jmp		Monitor

.Prompt14:
	cmp		#'T'
	bne		.Prompt15
	jsr		MonGetch
	cmp		#'O'
	bne		.Prompt14a
	jsr		DumpTimeoutList
	jmp		Monitor
.Prompt14a:
	cmp		#'I'
	bne		.Prompt14b
	jsr		DisplayDatetime
	jmp		Monitor
.Prompt14b:
	cmp		#'E'
	bne		.Prompt14c
	jsr		ReadTemp
	jmp		Monitor
.Prompt14c:
	dey
	jsr		DumpTaskList
	jmp		Monitor

.Prompt15:
	cmp		#'S'
	bne		.Prompt16
	jsr		MonGetch
	cmp		#'P'
	bne		.Prompt18
	jsr		ignBlanks
	jsr		GetHexNumber
	sta		SPSave
	jmp		Monitor
.Prompt18:
	cmp		#'U'
	bne		.Prompt18a
;	jsl		$F500
	mStartTask	#PRI_HIGH,#0,#$F500,#0,#6
;	lda		#PRI_HIGH
;	ldx		#0
;	ldy		#$F500
;	ld		r4,#0
;	ld		r5,#6
;	int		#4
;	db		1
	jmp		Monitor
.Prompt18a:
	dey
	jsr		SDInit
	cmp		#0
	bne		Monitor
	jsr		SDReadPart
	cmp		#0
	bne		Monitor
	jsr		SDReadBoot
	cmp		#0
	bne		Monitor
	jsr		loadBootFile
	jmp		Monitor
.Prompt16:
	cmp		#'e'
	bne		.Prompt17
;	lda		#1
;	ldx		#0
;	ldy		#eth_main
;	jsr		StartTask
	mStartTask	#PRI_HIGH,#0,#eth_main,#0,#0
;	jsr		eth_main
	jmp		Monitor
.Prompt17:
	cmp		#'R'
	bne		.Prompt19
	jsr		MonGetch
	cmp		#'S'
	beq		LoadBlock
	dey
	bra		SetRegValue
	jmp		Monitor
.Prompt19:
	cmp		#'K'
	bne		.Prompt20
.Prompt19a:
	jsr		MonGetch
	cmp		#' '
	bne		.Prompt19a
	jsr		ignBlanks
	jsr		GetDecNumber
	jsr		KillTask
	jmp		Monitor
.Prompt20:
	cmp		#'8'
	bne		.Prompt21
	jsr		Test816
	jmp		Monitor
.Prompt21:
	cmp		#'m'
	bne		Monitor
;	lda		#3
;	ldx		#0
;	ldy		#test_mbx_prg
;	jsr		StartTask
	lda		#PRI_LOW
	ldx		#0
	ldy		#test_mbx_prg
	ld		r4,#0
	ld		r5,#1		; Job 1!
	int		#4
	db		1
	bra		Monitor

message "Prompt16"
RandomLinesCall:
;	jsr		RandomLines
	jmp		Monitor

MonGetch:
	lda		(y)
	iny
	jsr		ScreenToAscii
	rts

DoDir:
	jsr		do_dir
	jmp		Monitor
DoFmt:
	jsr		do_fmt
	jmp		Monitor
DoFig:
	lda		#3				; priority level 3
	ldy		#$A000			; start address $A000
	ldx		#$20000000		; flags: emmulation mode set
	jsr		StartTask
	bra		Monitor
	
TestCLS:
	jsr		MonGetch
	cmp		#'L'
	bne		Monitor
	jsr		MonGetch
	cmp		#'S'
	bne		Monitor
	jsr 	ClearScreen
	jsr		HomeCursor
;	jsr		CalcScreenLoc
	jmp		Monitor
message "HelpMsg"
HelpMsg:
	db	"? = Display help",CR,LF
	db	"CLS = clear screen",CR,LF
	db	"S = Boot from SD Card",CR,LF
	db	"SU = supermon816",CR,LF
	db	"L = Load Block",CR,LF
	db	"W = Write Block",CR,LF
	db  "DIR = Disk directory",CR,LF
	db	"M = Dump memory words, MB = Dump memory bytes",CR,LF
	db	"> = Edit memory words",CR,LF
	db	"F = Fill memory",CR,LF
	db  "FL = Dump I/O Focus List",CR,LF
;	db  "FIG = start FIG Forth",CR,LF
	db	"KILL n = kill task #n",CR,LF
	db	"B = start tiny basic",CR,LF
	db	"b = start EhBasic 6502",CR,LF
	db	"J = Jump to code",CR,LF
	db	"R = Dump registers, Rn = Set register value",CR,LF
	db	"r = random lines - test bitmap",CR,LF
	db	"e = ethernet test",CR,LF
	db	"T = Dump task list",CR,LF
	db	"TO = Dump timeout list",CR,LF
	db	"TI = display date/time",CR,LF
	db	"TEMP = display temperature",CR,LF
	db	"P = Piano",CR,LF
	db	"8 = 816 test",CR,LF,0

;------------------------------------------------------------------------------
; Ignore blanks in the input
; r3 = text pointer
; r1 destroyed
;------------------------------------------------------------------------------
;
ignBlanks:
ignBlanks1:
	jsr		MonGetch
	cmp		#' '
	beq		ignBlanks1
	dey
	rts

;------------------------------------------------------------------------------
; Edit memory byte(s).
;------------------------------------------------------------------------------
;
EditMem:
	jsr		ignBlanks
	jsr		GetHexNumber
	ld		r5,r1
	ld		r4,#3
edtmem1:
	jsr		ignBlanks
	jsr		GetHexNumber
	sta		(r5)
	add		r5,r5,#1
	dec		r4
	bne		edtmem1
	jmp		Monitor

;------------------------------------------------------------------------------
; Execute code at the specified address.
;------------------------------------------------------------------------------
;
message "ExecuteCode"
ExecuteCode:
	jsr		ignBlanks
	jsr		GetHexNumber
	st		r1,JMPTMP
	lda		#xcret			; push return address so we can do an indirect jump
	pha
	ld		r1,R1Save
	ld		r2,R2Save
	ld		r3,R3Save
	ld		r4,R4Save
	ld		r5,R5Save
	ld		r6,R6Save
	ld		r7,R7Save
	ld		r8,R8Save
	ld		r9,R9Save
	ld		r10,R10Save
	ld		r11,R11Save
	ld		r12,R12Save
	ld		r13,R13Save
	ld		r14,R14Save
	ld		r15,R15Save
	jmp		(JMPTMP)
xcret:
	php
	st		r1,R1Save
	st		r2,R2Save
	st		r3,R3Save
	st		r4,R4Save
	st		r5,R5Save
	st		r6,R6Save
	st		r7,R7Save
	st		r8,R8Save
	st		r9,R9Save
	st		r10,R10Save
	st		r11,R11Save
	st		r12,R12Save
	st		r13,R13Save
	st		r14,R14Save
	st		r15,R15Save
	tsr		sp,r1
	st		r1,SPSave
	tsr		sp8,r1
	st		r1,SP8Save
	pla
	sta		SRSave
	jmp     Monitor

LoadBlock:
	jsr		ignBlanks
	jsr		GetDecNumber
	pha
	jsr		ignBlanks
	jsr		GetHexNumber
	tax
	phx
;	ld		r2,#0x3800
	lda		#16				; SD Card device #
	ldx		#1				; Init
	jsr		DeviceOp
;	jsr		SDInit
	plx
	pla
	lda		#16				; SD Card device #
	ldx		#11				; opcode: Read blocks
	pop		r5				; r5 = pointer to data storage area
	ply						; y = block number to read
	ld		r4,#1			; 1 block to read	
	jsr		DeviceOp
;	jsr		SDReadSector
	jmp		Monitor

WriteBlock:
	jsr		ignBlanks
	jsr		GetDecNumber
	pha
	jsr		ignBlanks
	jsr		GetHexNumber
	tax
	phx
	jsr		SDInit
	plx
	pla
	jsr		SDWriteSector
	jmp		Monitor

;------------------------------------------------------------------------------
; Command 'R'
; Dump the register set.
;------------------------------------------------------------------------------
message "DumpReg"
DumpReg:
	ldy		#0
DumpReg1:
	jsr		CRLF
	lda		#'$'
	jsr		DisplayChar
	lda		#'R'
	jsr		DisplayChar
	ldx		#1
	tya
	ina
	jsr		PRTNUM
	lda		#' '
	jsr		DisplayChar
	lda		R1Save,y
	jsr		DisplayWord
	iny
	cpy		#15
	bne		DumpReg1
	jsr		CRLF
	lda		#':'
	jsr		DisplayChar
	lda		#'S'
	jsr		DisplayChar
	lda		#'P'
	jsr		DisplayChar
	lda		#' '
	jsr		DisplayChar
	lda		TCB_SPSave
	jsr		DisplayWord
	jsr		CRLF
	jmp		Monitor

;------------------------------------------------------------------------------
; Command 'Rn'
;------------------------------------------------------------------------------
SetRegValue:
	jsr		GetDecNumber
	cmp		#0
	beq		DumpReg
	cmp		#15
	bpl		Monitor
	pha
	jsr		ignBlanks
	jsr		GetHexNumber
	ply
	sta		R1Save,y
	jmp		Monitor

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
GetTwoParams:
	jsr		ignBlanks
	jsr		GetHexNumber	; get start address of dump
	tax
	jsr		ignBlanks
	jsr		GetHexNumber	; get end address of dump
	rts

;------------------------------------------------------------------------------
; Get a range, the end must be greater or equal to the start.
;------------------------------------------------------------------------------
GetRange:
	jsr		GetTwoParams
	cmp		r2,r1
	bhi		DisplayErr
	rts

;------------------------------------------------------------------------------
; Command 'M'
; Do a memory dump of the requested location.
;------------------------------------------------------------------------------
;
DumpMem:
	jsr		GetRange
	jsr		CRLF
DumpmemW:
	jsr		CheckKeys
	jsr		DisplayMemW
	cmp		r2,r1
	bls		DumpmemW
	jmp		Monitor

DumpMemBytes:
	jsr		GetRange
	jsr		CRLF
.001:
	jsr		CheckKeys
	jsr		DisplayMemBytes
	cmp		r2,r1
	bls		.001
	jmp		Monitor

;------------------------------------------------------------------------------
; CheckKeys:
;	Checks for a CTRLC or a scroll lock during long running dumps.
;------------------------------------------------------------------------------
CheckKeys:
	jsr		CTRLCCheck
	jmp		CheckScrollLock

;------------------------------------------------------------------------------
; CTRLCCheck
;	Checks to see if CTRL-C is pressed. If so then the current routine is
; aborted and control is returned to the monitor.
;------------------------------------------------------------------------------

CTRLCCheck:
	pha
	jsr		KeybdGetChar
	cmp		#CTRLC
	beq		.0001
	pla
	rts
.0001:
	pla
	pla
	jmp		Monitor

;------------------------------------------------------------------------------
; CheckScrollLock:
;	Check for a scroll lock by the user. If scroll lock is active then tasks
; are rescheduled while the scroll lock state is tested in a loop.
;------------------------------------------------------------------------------

CheckScrollLock:
	pha
.0002:
	jsr		GetPtrCurrentJCB
	lda		JCB_KeybdLocks,r1
	bit		#$4000				; is scroll lock active ?
	beq		.0001
	int		#2					; reschedule tasks
	bra		.0002
.0001:
	pla
	rts


;------------------------------------------------------------------------------
; Command 'F' or "FB"
; Fill memory with specified value.
;------------------------------------------------------------------------------

FillMem:
	jsr		GetRange
	txy						; y = start address
	sub		r1,r1,r2		; acc = count
	pha
	jsr		ignBlanks
	jsr		GetHexNumber	; get the fill byte
	tax
	pla
	stos
	jmp		Monitor

FillMemBytes:
	jsr		GetRange
	txy
	sub		r2,r1,r2		; x = count
	inx
	jsr		ignBlanks
	jsr		GetHexNumber
.0001:
	sb		r1,0,y
	iny
	dex
	bne		.0001
	jmp		Monitor

	
;------------------------------------------------------------------------------
; Get a hexidecimal number. Maximum of eight digits.
; R3 = text pointer (updated)
; R1 = hex number
;------------------------------------------------------------------------------
;
GetHexNumber:
	phx
	push	r4
	ldx		#0
	ld		r4,#8
gthxn2:
	jsr		MonGetch
	jsr		AsciiToHexNybble
	cmp		#-1
	beq		gthxn1
	asl		r2,r2,#4
	and		#$0f
	or		r2,r2,r1
	dec		r4
	bne		gthxn2
gthxn1:
	txa
	pop		r4
	plx
	rts

GetDecNumber:
	phx
	push	r4
	push	r5
	ldx		#0
	ld		r4,#10
	ld		r5,#10
gtdcn2:
	jsr		MonGetch
	jsr		AsciiToDecNybble
	cmp		#-1
	beq		gtdcn1
	mul		r2,r2,r5
	add		r2,r2,r1
	dec		r4
	bne		gtdcn2
gtdcn1:
	txa
	pop		r5
	pop		r4
	plx
	rts

;------------------------------------------------------------------------------
; Convert ASCII character in the range '0' to '9', 'a' to 'f' or 'A' to 'F'
; to a hex nybble.
;------------------------------------------------------------------------------
;
AsciiToHexNybble:
	cmp		#'0'
	bcc		gthx3
	cmp		#'9'+1
	bcs		gthx5
	sub		#'0'
	rts
gthx5:
	cmp		#'A'
	bcc		gthx3
	cmp		#'F'+1
	bcs		gthx6
	sub		#'A'
	add		#10
	rts
gthx6:
	cmp		#'a'
	bcc		gthx3
	cmp		#'z'+1
	bcs		gthx3
	sub		#'a'
	add		#10
	rts
gthx3:
	lda		#-1		; not a hex number
	rts

AsciiToDecNybble:
	cmp		#'0'
	bcc		gtdc3
	cmp		#'9'+1
	bcs		gtdc3
	sub		#'0'
	rts
gtdc3:
	lda		#-1
	rts

DisplayErr:
	lda		#msgErr
	jsr		DisplayStringB
	jmp		Monitor

msgErr:
	db	"**Err",CR,LF,0

;==============================================================================
;==============================================================================

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
ClearBmpScreen:
	pha
	phx
	phy
	lda		#(680*384)		; a = # bytes to clear
	ldx		#0x29292929			; acc = color for four pixels
	ldy		#BITMAPSCR;<<2		; y = screen address
cbmp1:
;	tsr		LFSR,r2
;	sb		r2,0,y
;	iny
;	dea
;	bne		cbmp1
	stos
	ply
	plx
	pla
	rts

;==============================================================================
;==============================================================================
;--------------------------------------------------------------------------
; Setup the AC97/LM4550 audio controller. Check keyboard for a CTRL-C
; interrupt which may be necessary if the audio controller isn't 
; responding.
;--------------------------------------------------------------------------
;
SetupAC97:
	pha
	phx
	phy
	push	r4
	ld		r4,Milliseconds
sac974:
	stz		AC97+0x26		; trigger a read of register 26 (status reg)
sac971:						; wait for status to register 0xF (all ready)
	ld		r3,Milliseconds
	sub		r3,r3,r4
	cmp		r3,#1000
	bhi		sac97Abort
	jsr		KeybdGetChar	; see if we needed to CTRL-C
	cmp		#CTRLC
	beq		sac973
	lda		AC97+0x68		; wait for dirty bit to clear
	bne		sac971
	lda		AC97+0x26		; check status at reg h26, wait for
	and		#0x0F			; analogue to be ready
	cmp		#$0F
	bne		sac974
sac973:
	stz		AC97+2			; master volume, 0db attenuation, mute off
	stz		AC97+4			; headphone volume, 0db attenuation, mute off
	stz		AC97+0x18		; PCM gain (mixer) mute off, no attenuation
	stz		AC97+0x0A		; mute PC beep
	lda		#0x8000			; bypass 3D sound
	sta		AC97+0x20
	ld		r4,Milliseconds
sac972:
	ld		r3,Milliseconds
	sub		r3,r3,r4
	cmp		r3,#1000
	bhi		sac97Abort
	jsr		KeybdGetChar
	cmp		#CTRLC
	beq		sac975
	lda		AC97+0x68		; wait for dirty bits to clear
	bne		sac972			; wait a while for the settings to take effect
sac975:
	pop		r4
	ply
	plx
	pla
	rts
sac97Abort:
	lda		#msgAC97bad
	jsr		DisplayStringCRLFB
	pop		r4
	ply
	plx
	pla
	rts

msgAC97bad:
	db	"The AC97 controller is not responding.",CR,LF,0

;--------------------------------------------------------------------------
; Sound a 800 Hz beep
;--------------------------------------------------------------------------
;
Beep:
	lda		#2				; check for a PSG
	bmt		CONFIGREC
	beq		.ret
	lda		#15				; master volume to max
	sta		PSG+64
	lda		#13422			; 800Hz
	sta		PSGFREQ0
	; decay  (16.384 ms)2
	; attack (8.192 ms)1
	; release (1.024 s)A
	; sustain level C
	lda		#0xCA12
	sta		PSGADSR0
	lda		#0x1104			; gate, output enable, triangle waveform
	sta		PSGCTRL0
;	lda		#1000			; delay about 1s
	mSleep	#1000
	lda		#0x0104			; gate off, output enable, triangle waveform
	sta		PSGCTRL0
;	lda		#1000			; delay about 1s
	mSleep	#1000
	lda		#83
	sta		LEDS
	lda		#0x0000			; gate off, output enable off, no waveform
	sta		PSGCTRL0
.ret
	rts

include "Piano.asm"
include "SDCard.asm"

; Load the root directory from disk
; r2 = where to place root directory in memory
;
loadBootFile:
	lb		r1,BYTE_SECTOR_BUF+BSI_SecPerFAT+1			; sectors per FAT
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+BSI_SecPerFAT
	bne		loadBootFile7
	lb		r1,BYTE_SECTOR_BUF+$27			; sectors per FAT, FAT32
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$26
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$25
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$24
loadBootFile7:
	lb		r4,BYTE_SECTOR_BUF+$10			; number of FATs
	mul		r3,r1,r4						; offset
	lb		r1,BYTE_SECTOR_BUF+$F			; r1 = # reserved sectors before FAT
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$E
	add		r3,r3,r1						; r3 = root directory sector number
	ld		r6,startSector
	add		r5,r3,r6						; r5 = root directory sector number
	lb		r1,BYTE_SECTOR_BUF+$D			; sectors per cluster
	add		r3,r1,r5						; r3 = first cluster after first cluster of directory
	bra		loadBootFile6

loadBootFile6:
	; For now we cheat and just go directly to sector 512.
	bra		loadBootFileTmp

loadBootFileTmp:
	; We load the number of sectors per cluster, then load a single cluster of the file.
	; This is 16kib
	ld		r5,r3							; r5 = start sector of data area	
	ld		r2,#PROG_LOAD_AREA				; where to place file in memory
	lb		r3,BYTE_SECTOR_BUF+$D			; sectors per cluster
loadBootFile1:
	ld		r1,r5							; r1=sector to read
	jsr		SDReadSector
	inc		r5						; r5 = next sector
	add		r2,r2,#512
	dec		r3
	bne		loadBootFile1
	lda		PROG_LOAD_AREA>>2		; make sure it's bootable
	cmp		#$544F4F42
	bne		loadBootFile2
	lda		#msgJumpingToBoot
	jsr		DisplayStringB
	lda		(PROG_LOAD_AREA>>2)+$1
	jsr		(r1)
	jmp		Monitor
loadBootFile2:
	lda		#msgNotBootable
	jsr		DisplayStringB
	ldx		#PROG_LOAD_AREA>>2
	jsr		DisplayMemW
	jsr		DisplayMemW
	jsr		DisplayMemW
	jsr		DisplayMemW
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
	db	"SD card boot error",CR,LF,0
spi_read_error_msg:
	db	"SD card read error",CR,LF,0
spi_write_error_msg:
	db	"SD card write error",0

do_fmt:
	jsr		SDInit
	cmp		#0
	bne		fmt_abrt
	; clear out the directory buffer
	lda		#65535
	ldx		#0
	ldy		#DIRBUF
	stos
	jsr		store_dir
fmt_abrt:
	rts

do_dir:
	jsr		CRLF
	jsr		SDInit
	cmp		#0
	bne		dirabrt
	jsr		load_dir
	ld		r4,#0			; r4 = entry counter
ddir3:
	asl		r3,r4,#6		; y = start of entry, 64 bytes per entry
	ldx		#32				; 32 chars in filename
ddir4:
	lb		r1,DIRBUF<<2,y
	beq		ddir2			; move to next dir entry if null is found
	cmp		#$20			; don't display control chars
	bmi		ddir1
	jsr		DisplayChar
	bra		ddir5
ddir1:
	lda		#' '
	jsr		DisplayChar
ddir5:
	iny
	dex
	bne		ddir4
	lda		#' '
	jsr		DisplayChar
	asl		r3,r4,#4		; y = start of entry, 16 words per entry
	lda		DIRBUF+$D,y
	ldx		#5
	jsr		PRTNUM
	jsr		CRLF
ddir2:
	jsr		KeybdGetChar
	cmp		#CTRLC
	beq		ddir6
	inc		r4
	cmp		r4,#512		; max 512 dir entries
	bne		ddir3
ddir6:

dirabrt:
	rts

load_dir:
	pha
	phx
	phy
	lda		#4000
	ldx		#DIRBUF<<2
	ldy		#64
	jsr		SDReadMultiple
	ply
	plx
	pla
	rts
store_dir:
	pha
	phx
	phy
	lda		#4000
	ldx		#DIRBUF<<2
	ldy		#64
	jsr		SDWriteMultiple
	ply
	plx
	pla
	rts

; r1 = pointer to file name
; r2 = pointer to buffer to save
; r3 = length of buffer
;
do_save:
	pha
	jsr		SDInit
	cmp		#0
	bne		dsavErr
	pla
	jsr		load_dir
	ld		r4,#0
dsav4:
	asl		r5,r4,#6
	ld		r7,#0
	ld		r10,r1
dsav2:
	lb		r6,DIRBUF<<2,r5
	lb		r8,0,r10
	cmp		r6,r8
	bne		dsav1
	inc		r5
	inc		r7
	inc		r10
	cmp		r7,#32
	bne		dsav2
	; here the filename matched
dsav8:
	asl		r7,r4,#7	; compute file address	64k * entry #
	add		r7,r7,#5000	; start at sector 5,000
	ld		r1,r7		; r1 = sector number
	lsr		r3,r3,#9	; r3/512
	iny					; +1
	jsr		SDWriteMultiple
dsav3:
	rts
	; Here the filename didn't match
dsav1:
	inc		r4
	cmp		r4,#512
	bne		dsav4
	; Here none of the filenames in the directory matched
	; Find an empty entry.
	ld		r4,#0
dsav6:
	asl		r5,r4,#6
	lb		r6,DIRBUF<<2,r5
	beq		dsav5
	inc		r4
	cmp		r4,#512
	bne		dsav6
	; Here there were no empty entries
	lda		#msgDiskFull
	jsr		DisplayStringB
	rts
dsav5:
	ld		r7,#32
	ld		r10,r1
dsav7:
	lb		r6,0,r10	; copy the filename into the directory entry
	sb		r6,DIRBUF<<2,r5
	inc		r5
	inc		r10
	dec		r7
	bne		dsav7
						; copy the file size into the directory entry
	asl		r5,r4,#4	; 16 words per dir entry
	sty		DIRBUF+$D,r5
	jsr		store_dir
	bra		dsav8
dsavErr:
	pla
	rts

msgDiskFull
	db	CR,LF,"The disk is full, unable to save file.",CR,LF,0

do_load:
	pha
	jsr		SDInit
	cmp		#0
	bne		dsavErr
	pla
	jsr		load_dir
	ld		r4,#0
dlod4:
	asl		r5,r4,#6
	ld		r7,#0
	ld		r10,r1
dlod2:
	lb		r6,DIRBUF<<2,r5
	lb		r8,0,r10
	cmp		r6,r8
	bne		dlod1
	inc		r5
	inc		r7
	inc		r10
	cmp		r7,#32
	bne		dlod2
	; here the filename matched
dlod8:
	asl		r5,r4,#4				; 16 words
	ld		r3,DIRBUF+$d,r5			; get file size into y register
	asl		r7,r4,#7	; compute file address	64k * entry #
	add		r7,r7,#5000	; start at sector 5,000
	ld		r1,r7		; r1 = sector number
	lsr		r3,r3,#9	; r3/512
	iny					; +1
	jsr		SDReadMultiple
dlod3:
	rts
	; Here the filename didn't match
dlod1:
	inc		r4
	cmp		r4,#512
	bne		dlod4
	; Here none of the filenames in the directory matched
	; 
	lda		#msgFileNotFound
	jsr		DisplayStringB
	rts

msgFileNotFound:
	db	CR,LF,"File not found.",CR,LF

;include "ethernet.asm"	

;--------------------------------------------------------------------------
; Initialize sprite image caches with random data.
;--------------------------------------------------------------------------
message "RandomizeSprram"
RandomizeSprram:
	ldx		#SPRRAM
	ld		r4,#14336		; number of chars to initialize
rsr1:
	tsr		LFSR,r1
	sta		(x)
	inx
	dec		r4
	bne		rsr1
	rts

;include "float.asm"
include "RandomLines.asm"

;--------------------------------------------------------------------------
; RTF65002 code to display the date and time from the date/time device.
;--------------------------------------------------------------------------
DisplayDatetime
	pha
	phx
	lda		#' '
	jsr		DisplayChar
	stz		DATETIME_SNAPSHOT	; take a snapshot of the running date/time
	lda		DATETIME_DATE
	tax
	lsr		r1,r1,#16
	jsr		DisplayHalf		; display the year
	lda		#'/'
	jsr		DisplayChar
	txa
	lsr		r1,r1,#8
	and		#$FF
	jsr		DisplayByte		; display the month
	lda		#'/'
	jsr		DisplayChar
	txa
	and		#$FF
	jsr		DisplayByte		; display the day
	lda		#' '
	jsr		DisplayChar
	lda		#' '
	jsr		DisplayChar
	lda		DATETIME_TIME
	tax
	lsr		r1,r1,#24
	jsr		DisplayByte		; display hours
	lda		#':'
	jsr		DisplayChar
	txa
	lsr		r1,r1,#16
	jsr		DisplayByte		; display minutes
	lda		#':'
	jsr		DisplayChar
	txa
	lsr		r1,r1,#8
	jsr		DisplayByte		; display seconds
	lda		#'.'
	jsr		DisplayChar
	txa
	jsr		DisplayByte		; display 100ths seconds
	jsr		CRLF
	plx
	pla
	rts

include "ReadTemp.asm"

include "memory.asm"

;------------------------------------------------------------------------------
; Bus Error Routine
; This routine display a message then restarts the BIOS.
;------------------------------------------------------------------------------
;
message "bus_err_rout"
bus_err_rout:
	cld
	ldx		#87
	stx		LEDS
	pla							; get rid of the stacked flags
	ply							; get the error PC
	ldx		#$05FFFFF8			; setup stack pointer top of memory
	txs
	ldx		#88
	stx		LEDS
	jsr		CRLF
	stz		RunningTCB
	lda		#JCBs
	sta		IOFocusNdx
	lda		#msgBusErr
	jsr		DisplayStringB
	tya
	jsr		DisplayWord			; display the originating PC address
	lda		#msgDataAddr
	jsr		DisplayStringB
	tsr		#9,r1
	jsr		DisplayWord
	ldx		#89
	stx		LEDS
	ldx		#128
ber2:
	lda		#' '
	jsr		DisplayChar
	tsr		hist,r1
	jsr		DisplayWord
	dex
	bne		ber2
	jsr		CRLF
ber3:
	nop
	jmp		ber3
	;cli							; enable interrupts so we can get a char
ber1:
	jsr		KeybdGetCharDirect	; Don't use the keyboard buffer
	cmp		#-1
	beq		ber1
	lda		RunningTCB
	jsr		KillTask
	jmp		SelectTaskToRun
	
msgBusErr:
	db		"Bus error at: ",0
msgDataAddr:
	db		" data address: ",0


;------------------------------------------------------------------------------
; 1000 Hz interrupt
; This IRQ must be fast.
; Increments the millisecond counter
;------------------------------------------------------------------------------
message "p1000Hz"
p1000Hz:
	pha
	lda		#2						; reset edge sense circuit
	sta		PIC_RSTE
	inc		Milliseconds			; increment milliseconds count
	pla
	rti

;------------------------------------------------------------------------------
; Sleep interrupt
; This interrupt just selects another task to run. The current task is
; stuck in an infinite loop.
;------------------------------------------------------------------------------
message "slp_rout"
slp_rout:
	cld		; clear extended precision mode
	pusha
	lda		RunningTCB
	cmp		#MAX_TASKNO
	bhi		slp1
	jsr		RemoveTaskFromReadyList
	tax
	tsa						; save off the stack pointer
	sta		TCB_SPSave,x
	tsr		sp8,r1			; and the eight bit mode stack pointer
	sta		TCB_SP8Save,x
	tsr		abs8,r1
	sta		TCB_ABS8Save,x
	lda		#TS_SLEEP		; set the task status to SLEEP
	sta		TCB_Status,x
slp1:
	jmp		SelectTaskToRun

;------------------------------------------------------------------------------
; Check for and emulate unsupoorted instructions.
;------------------------------------------------------------------------------
InvalidOpIRQ:
	pha
	phx
	phy
	tsx
	lda		4,x		; get the address of the invalid op off the stack
	lb		r3,0,r1	; get the opcode byte
	cpy		#$44	; is it MVP ?
	beq		EmuMVP
	cpy		#$54	; is it MVN ?
	beq		EmuMVN
	; We don't know what the op is. Treat it like a NOP
	; Increment the address and return.
	pha
	lda		#msgUnimp
	jsr		DisplayStringB
	pla
	jsr		DisplayWord
	jsr		CRLF
	ina
	sta		4,x		; save incremented return address back to stack
	jsr		DumpHistoryTable
	ply
	plx
	pla
	rti

DumpHistoryTable:
	pha
	phx
	ldx		#64
ioi1:
	tsr		hist,r1
	jsr		DisplayWord
	lda		#' '
	jsr		DisplayChar
	dex
	bne		ioi1
	plx
	pla
	rts

EmuMVP:
	push	r4
	push	r5
	tsr		sp,r4
	lda		4,r4
	ldx		3,r4
	ldy		2,r4
EmuMVP1:
	ld		r5,(x)
	st		r5,(y)
	dex
	dey
	dea
	cmp		#$FFFFFFFF
	bne		EmuMVP1
	sta		4,r4
	stx		3,r4
	sty		2,r4
	inc		6,r4		; increment the return address by one.
	pop		r5
	pop		r4
	ply
	plx
	pla
	rti

EmuMVN:
	push	r4
	push	r5
	tsr		sp,r4
	lda		4,r4
	ldx		3,r4
	ldy		2,r4
EmuMVN1:
	ld		r5,(x)
	st		r5,(y)
	inx
	iny
	dea
	cmp		#$FFFFFFFF
	bne		EmuMVN1
	sta		4,r4
	stx		3,r4
	sty		2,r4
	inc		6,r4		; increment the return address by one.
	pop		r5
	pop		r4
	ply
	plx
	pla
	rti

msgUnimp:
	db	"Unimplemented at: ",0

brk_rout:
	lda		#16
	sta		LEDS
	jsr		kernel_panic
	db		"Break routine",0
	jsr		DumpHistoryTable
	stp
	rti

nmirout:
	pha
	lda		#msgPerr
	jsr		DisplayStringB
	lda		3,sp
	jsr		DisplayWord
	jsr		CRLF
	pla
	rti

msgPerr:
	db	"Parity error at: ",0

;==============================================================================
; Finitron Multi-Tasking Kernel (FMTK)
;        __
;   \\__/ o\    (C) 2013, 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@opencores.org
;       ||
;==============================================================================
message "FMTK"
	org		$FFFFC000
syscall_vectors:
	dw		MTKInitialize
	dw		StartTask
	dw		ExitTask
	dw		KillTask
	dw		SetTaskPriority
	dw		Sleep
	dw		AllocMbx
	dw		FreeMbx
	dw		PostMsg
	dw		SendMsg
	dw		WaitMsg
	dw		CheckMsg

	org		$FFFFC200
message "MTKInitialize"
MTKInitialize:
	; Initialize semaphores
	lda		#1
	sta		freetcb_sema
	sta		freembx_sema
	sta		freemsg_sema
	sta		tcb_sema
	sta		readylist_sema
	sta		tolist_sema
	sta		mbx_sema
	sta		msg_sema
	sta		jcb_sema

	tsr		vbr,r2
	and		r2,#-2
	lda		#reschedule
	sta		2,x
	lda		#syscall_int
	sta		4,x
	lda		#MTKTick
	sta		448+3,x
	stz		UserTick

	lda		#-1
	sta		TimeoutList		; no entries in timeout list
	sta		QNdx0
	sta		QNdx1
	sta		QNdx2
	sta		QNdx3
	sta		QNdx4

	stz		missed_ticks

	; Initialize IO Focus List
	;
	lda		#7
	ldx		#0
	ldy		#IOFocusTbl
	stos

	; Set owning job to zero (the monitor)
	lda		#255
	ldx		#0
	ldy		#TCB_hJCB
	stos

	; zero out JCB's
	; This will NULL out the I/O focus list pointers
	lda		#NR_JCB * JCB_Size
	ldx		#0
	lea		r3,JCBs
	stos

	; Setup default values in the JCB's
	ldy		#0
	ldx		#JCBs
ijcb1:
	sty		JCB_Number,x
	sty		JCB_Map,x
	stz		JCB_esc,x
	lda		#31
	sta		JCB_VideoRows,x
	lda		#56
	sta		JCB_VideoCols,x
	lda		#1					; turn on keyboard echo
	sta		JCB_KeybdEcho,x
	sta		JCB_CursorOn,x
	sta		JCB_CursorFlash,x
	stz		JCB_CursorRow,x
	stz		JCB_CursorCol,x
	stz		JCB_CursorType,x
	lda		#%1011_01111		; grey on grey
	sta		JCB_NormAttr,x
	sta		JCB_CurrAttr,x
	ld		r4,r3
	mul		r4,r4,#8192			; 8192 words per screen
	add		r4,r4,#BIOS_SCREENS
	st		r4,JCB_pVirtVid,x
	st		r4,JCB_pVidMem,x
	add		r4,r4,#$1000
	st		r4,JCB_pVirtVidAttr,x
	st		r4,JCB_pVidMemAttr,x
	cpy		#0
	bne		ijcb2
	lda		#%0110_01110		; CE =blue on blue FB = grey on grey
	sta		JCB_NormAttr,x
	sta		JCB_CurrAttr,x
	ld		r4,#TEXTSCR
	st		r4,JCB_pVidMem,x
	add		r4,r4,#$10000
	st		r4,JCB_pVidMemAttr,x
ijcb2:
	lda		#8
	sta		JCB_LogSize,x
	iny
	add		r2,r2,#JCB_Size
	cpy		#32
	blo		ijcb1
	

	; Initialize free message list
	lda		#NR_MSG
	sta		nMsgBlk
	stz		FreeMsg
	ldx		#0
	lda		#1
st4:
	sta		MSG_LINK,x
	ina
	inx
	cpx		#NR_MSG
	bne		st4
	lda		#-1
	sta		MBX_LINK+NR_MSG-1

	; Initialize free mailbox list
	; Note the first NR_TCB mailboxes are statically allocated to the tasks.
	; They are effectively pre-allocated.
	lda		#NR_MBX-NR_TCB
	sta		nMailbox
	
	ldx		#NR_TCB
	stx		FreeMbxHandle
	lda		#NR_TCB+1
st3:
	sta		MBX_LINK,x
	ina
	inx
	cpx		#NR_MBX
	bne		st3
	lda		#-1
	sta		MBX_LINK+NR_MBX-1

	; Initialize the FreeJCB list
	lda		#JCBs+JCB_Size		; the next available JCB
	sta		FreeJCB
	tax
	add		r1,r1,#JCB_Size
	ldy		#NR_JCB-1
st5:
	sta		JCB_Next,x
	add		r1,r1,#JCB_Size
	add		r2,r2,#JCB_Size
	dey
	bne		st5
	stz		JCB_Next,x

	; Initialize the FreeTCB list
	lda		#1				; the next available TCB
	sta		FreeTCB
	ldx		#1
	lda		#2
st2:
	sta		TCB_NxtTCB,x
	ina
	inx
	cpx		#256
	bne		st2
	lda		#-1
	sta		TCB_NxtTCB+255
	lda		#4
	sta		LEDS

	; Manually setup the BIOS task
	stz		RunningTCB		; BIOS is task #0
	stz		TCB_NxtRdy		; manually build the ready list
	stz		TCB_PrvRdy
	lda		#-1
	sta		TCB_NxtTo
	sta		TCB_PrvTo
	stz		QNdx2			; insert at priority 2
	; manually build the IO focus list
	lda		#JCBs
	sta		IOFocusNdx		; Job #0 (Monitor) has the focus
	stz		JCB_iof_next,r1
	stz		JCB_iof_prev,r1
	lda		#1
	sta		IOFocusTbl		; set the job #0 request bit

	lda		#PRI_NORMAL
	sta		TCB_Priority
	stz		TCB_Timeout
	lda		#TS_RUNNING|TS_READY
	sta		TCB_Status
	stz		TCB_CursorRow
	stz		TCB_CursorCol
	stz		TCB_ABS8Save
	ldx		#BIOS_STACKS+0x03FF	; setup stack pointer top of memory
	stx		TCB_SPSave
	ldx		#$1FF
	stx		TCB_SP8Save
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
message "startIdleTask"
StartIdleTask:
	lda		#4
	ldx		#0
	ldy		#IdleTask
	jsr		StartTask
	rts

;------------------------------------------------------------------------------
; IdleTask
;
; IdleTask is a low priority task that is always running. It runs when there
; is nothing else to run.
; This task check for tasks that are stuck in infinite loops and kills them.
;------------------------------------------------------------------------------
IdleTask:
	stz		TestTask
it2:
	inc		TEXTSCR+111		; increment IDLE active flag
	ldx		TestTask
	and		r2,r2,#$FF
	beq		it1
	lda		TCB_Status,x
	cmp		#TS_SLEEP
	bne		it1
	txa
	int		#4				; KillTask function
	db		3
;	jsr		KillTask
it1:
	inc		TestTask
	cli						; enable interrupts
	wai						; wait for one to happen
	bra		it2

;------------------------------------------------------------------------------
; Parameters:
;	r1 = job name
;	r2 = start address
;------------------------------------------------------------------------------
;
StartJob:
	pha
	
	; Get a free JCB
	spl		freejcb_sema + 1
	ld		r6,FreeJCB
	beq		sjob1
	ld		r7,JCB_Next,r6
	st		r7,FreeJCB
	stz		freejcb_sema + 1

	lea		r7,JCB_Name,r6		; r7 = address of name field
	asl		r7,r7,#2			; convert word to byte address
	ld		r9,r7				; save off buffer address
	ld		r8,#0				; r8 = count of characters (0 to 31)
sjob3:
	lb		r5,0,r1				; get a character
	beq		sjob2				; end of string ?
	sb		r5,1,r7
	ina
	inc		r7
	inc		r8
	cmp		r8,#31				; max number of chars ?
	blo		sjob3
sjob2:
	sb		r8,0,r9				; save name length

sjob1:
	stz		freejcb_sema + 1
	pla
	rts

;------------------------------------------------------------------------------
; StartTask
;
; Startup a task. The task is automatically allocated a 1kW stack from the BIOS
; stacks area. The scheduler is invoked after the task is added to the ready
; list.
;
; Parameters:
;	r1 = task priority
;	r2 = start flags
;	r3 = start address
;	r4 = start parameter
;	r5 = job handle
;------------------------------------------------------------------------------
message "StartTask"
StartTask:
	pusha
	ld		r6,r1				; r6 = task priority
	ld		r8,r2				; r8 = flag register value on startup
	
	; get a free TCB
	;
	spl		freetcb_sema+1
	lda		FreeTCB				; get free tcb list pointer
	bmi		stask1
	tax
	lda		TCB_NxtTCB,x
	sta		FreeTCB				; update the FreeTCB list pointer
	stz		freetcb_sema+1
	lda		#81
	sta		LEDS
	txa							; acc = TCB index (task number)
	sta		TCB_mbx,x
	
	; setup the stack for the task
	; Zap the stack memory.
	ld		r7,r2
	asl		r2,r2,#10			; 1kW stack per task
	add		r2,r2,#BIOS_STACKS	;+0x3ff	; add in stack base
	pha
	phx
	phy
	txy							; y = target address
	ldx		#ExitTask			; x = fill value
	lda		#$3FF				; acc = # words to fill -1
	stos
	ply
	plx
	pla
	
	add		r2,r2,#$3FF			; Move pointer to top of stack
	stx		TCB_StackTop,r7
	sub		r2,r2,#128
	tsr		sp,r9				; save off current stack pointer
	spl		tcb_sema + 1
	txs
	st		r6,TCB_Priority,r7
	stz		TCB_Status,r7
	stz		TCB_Timeout,r7
	st		r5,TCB_hJCB,r7		; save job handle
	; setup virtual video for the task
;	stz		TCB_CursorRow,r7
;	stz		TCB_CursorCol,r7
	stz		TCB_mmu_map,r7		; use mmu map
;	jsr		AllocateMemPage
	pha
	lda		#82
	sta		LEDS
	lda		#-1
	sta		TCB_MbxList,r7
	lda		BASIC_SESSION
	cmp		#1
	bls		stask3
	asl		r1,r1,#14
	add		r1,r1,#$430_0000
	sta		TCB_ABS8Save,r7
	add		r1,r1,#$1FF
	sta		TCB_SP8Save,r7
	bra		stask4
stask3:
	lda		#$1FF
	sta		TCB_SP8Save,r7
	stz		TCB_ABS8Save,r7
stask4:
	lda		#83
	sta		LEDS
	pla
;	tay

	; setup the initial stack image for the task
	; Cause a return to the ExitTask routine when the task does a 
	; final rts.
	; fake an IRQ call by stacking the return address and processor
	; flags on the stack
	ldx		#ExitTask			; save the address of the task exit routine
	phx
	phy							; save start address on stack
	push	r8					; save processor status reg on stack
	
	; now fake pushing the register set onto the stack. Registers start up
	; in an undefined state.
;	sub		sp,#15				; 15 registers
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	push	r4
	tsx
	stx		TCB_SPSave,r7
	; now restore the current stack pointer
	trs		r9,sp

	; Insert the task into the ready list
	ld		r4,#84
	st		r4,LEDS
	jsr		AddTaskToReadyList
	lda		#1
	sta		tcb_sema
	int		#2			; invoke the scheduler
;	GoReschedule		; invoke the scheduler
stask2:
	popa
	rts
stask1:
	stz		freetcb_sema+1
	jsr		kernel_panic
	db		"No more task control blocks available.",0
	bra		stask2

;------------------------------------------------------------------------------
; ExitTask
;
; This routine is called when the task exits with an rts instruction. OR
; it may be invoked with a JMP ExitTask. In either case the task must be
; running so it can't be on the timeout list. The scheduler is invoked
; after the task is removed from the ready list.
;------------------------------------------------------------------------------
message "ExitTask"
ExitTask:
	; release any aquired resources
	; - mailboxes
	; - messages
	hoff
	spl		tcb_sema + 1
	lda		RunningTCB
	cmp		#MAX_TASKNO
	bhi		xtsk1
	jsr		RemoveTaskFromReadyList
	jsr		RemoveFromTimeoutList
	stz		TCB_Status,r1				; set task status to TS_NONE
	jsr		ReleaseIOFocus
;	lda		TCB_ABS8Save,x
;	jsr		FreeMemPage
	; Free up all the mailboxes associated with the task.
xtsk7:
	pha
	lda		TCB_MbxList,r1
	bmi		xtsk6
	jsr		FreeMbx
	pla
	bra		xtsk7
xtsk6:
	pla
	ldx		#86
	stx		LEDS
	spl		freetcb_sema+1
	ldx		FreeTCB						; add the task control block to the free list
	stx		TCB_NxtTCB,r1
	sta		FreeTCB
	stz		freetcb_sema+1
xtsk1:
	jmp		SelectTaskToRun

;------------------------------------------------------------------------------
; r1 = task number
; r2 = new priority
;------------------------------------------------------------------------------
;
SetTaskPriority:
	cmp		#MAX_TASKNO					; make sure task number is reasonable
	bhi		stp1
	phy
	spl		tcb_sema + 1
	ldy		TCB_Status,r1				; if the task is on the ready list
	bit		r3,#TS_READY|TS_RUNNING		; then remove it and re-add it.
	beq		stp2						; Otherwise just go set the priority field
	jsr		RemoveTaskFromReadyList
	stx		TCB_Priority,r1
	jsr		AddTaskToReadyList
	bra		stp3
stp2:
	stx		TCB_Priority,r1
stp3:
	ldy		#1
	sty		tcb_sema
	int		#2
	ply
stp1:
	rts

;------------------------------------------------------------------------------
; AddTaskToReadyList
;
; The ready list is a group of five ready lists, one for each priority
; level. Each ready list is organized as a doubly linked list to allow fast
; insertions and removals. The list is organized as a ring (or bubble) with
; the last entry pointing back to the first. This allows a fast task switch
; to the next task. Which task is at the head of the list is maintained
; in the variable QNdx for the priority level.
;
; Registers Affected: none
; Parameters:
;	r1 = task number
; Returns:
;	none
;------------------------------------------------------------------------------
;
message "AddTaskToReadyList"
AddTaskToReadyList:
	phx
	phy
	ldx		#TS_READY
	stx		TCB_Status,r1
	ldx		#-1
	stx		TCB_NxtRdy,r1
	stx		TCB_PrvRdy,r1
	ldy		TCB_Priority,r1
	cpy		#5
	blo		arl1
	ldy		#PRI_LOWEST
arl1:
	ldx		QNdx0,y
	bmi		arl5
	ldy		TCB_PrvRdy,x
	sta		TCB_NxtRdy,y
	sty		TCB_PrvRdy,r1
	sta		TCB_PrvRdy,x
	stx		TCB_NxtRdy,r1
	ply
	plx
	rts

	; Here the ready list was empty, so add at head
arl5:
	sta		QNdx0,y
	sta		TCB_NxtRdy,r1
	sta		TCB_PrvRdy,r1
	ply
	plx
	rts
	
;------------------------------------------------------------------------------
; RemoveTaskFromReadyList
;
; This subroutine removes a task from the ready list.
;
; Registers Affected: none
; Parameters:
;	r1 = task number
; Returns:
;   r1 = task number
;------------------------------------------------------------------------------

message "RemoveTaskFromReadyList"
RemoveTaskFromReadyList:
	phx
	phy
	push	r4
	push	r5

	ldy		TCB_Status,r1	; is the task on the ready list ?
	bit		r3,#TS_READY|TS_RUNNING
	beq		rfr2
	and		r3,r3,#~(TS_READY|TS_RUNNING)
	sty		TCB_Status,r1		; task status no longer running or ready
	ld		r4,TCB_NxtRdy,r1	; Get previous and next fields.
	ld		r5,TCB_PrvRdy,r1
	st		r4,TCB_NxtRdy,r5
	st		r5,TCB_PrvRdy,r4
	ldy		TCB_Priority,r1
	cmp		r1,QNdx0,y			; Are we removing the QNdx task ?
	bne		rfr2
	st		r4,QNdx0,y
	; Now we test for the case where the task being removed was the only one
	; on the ready list of that priority level. We can tell because the
	; NxtRdy would point to the task itself.
	cmp		r4,r1				
	bne		rfr2
	ldx		#-1					; Make QNdx negative
	stx		QNdx0,y
	stx		TCB_NxtRdy,r1
	stx		TCB_PrvRdy,r1
rfr2:
	pop		r5
	pop		r4
	ply
	plx
	rts

;------------------------------------------------------------------------------
; AddToTimeoutList
; AddToTimeoutList adds a task to the timeout list. The task is placed in the
; list depending on it's timeout value.
;
; Registers Affected: none
; Parameters:
;	r1 = task
;	r2 = timeout value
;------------------------------------------------------------------------------
message "AddToTimeoutList"
AddToTimeoutList:
	phx
	push	r4
	push	r5

	ld		r5,#-1
	st		r5,TCB_NxtTo,r1		; these fields should already be -1
	st		r5,TCB_PrvTo,r1
	ld		r4,TimeoutList		; are there any tasks on the timeout list ?
	bmi		attl_add_at_head	; If not, update head of list
attl_check_next:
	sub		r2,r2,TCB_Timeout,r4	; is this timeout > next
	bmi		attl_insert_before
	ld		r5,r4
	ld		r4,TCB_NxtTo,r4
	bpl		attl_check_next

	; Here we scanned until the end of the timeout list and didn't find a 
	; timeout of a greater value. So we add the task to the end of the list.
attl_add_at_end:
	st		r4,TCB_NxtTo,r1		; r4 is = -1
	st		r1,TCB_NxtTo,r5
	st		r5,TCB_PrvTo,r1
	stx		TCB_Timeout,r1
	bra		attl_exit

attl_insert_before:
	cmp		r5,#0
	bmi		attl_insert_before_head
	st		r4,TCB_NxtTo,r1		; next on list goes after this task
	st		r5,TCB_PrvTo,r1		; set previous link
	st		r1,TCB_NxtTo,r5
	st		r1,TCB_PrvTo,r4
	bra		attl_adjust_timeout

	; Here there is no previous entry in the timeout list
	; Add at start
attl_insert_before_head:
	sta		TCB_PrvTo,r4
	st		r5,TCB_PrvTo,r1		; r5 is = -1
	st		r4,TCB_NxtTo,r1
	sta		TimeoutList			; update the head pointer
attl_adjust_timeout:
	add		r2,r2,TCB_Timeout,r4	; get back timeout
	stx		TCB_Timeout,r1
	ld		r5,TCB_Timeout,r4	; adjust the timeout of the next task
	sub		r5,r5,r2
	st		r5,TCB_Timeout,r4
	bra		attl_exit

	; Here there were no tasks on the timeout list, so we add at the
	; head of the list.
attl_add_at_head:
	sta		TimeoutList			; set the head of the timeout list
	stx		TCB_Timeout,r1
	ldx		#-1					; flag no more entries in timeout list
	stx		TCB_NxtTo,r1		; no next entries
	stx		TCB_PrvTo,r1		; and no prev entries
attl_exit:
	ldx		TCB_Status,r1		; set the task's status as timing out
	or		r2,r2,#TS_TIMEOUT
	stx		TCB_Status,r1
	pop		r5
	pop		r4
	plx
	rts
	
;------------------------------------------------------------------------------
; RemoveFromTimeoutList
;
; This routine is called when a task is killed. The task may need to be
; removed from the middle of the timeout list.
;
; On entry: the timeout list semaphore must be already set.
; Registers Affected: none
; Parameters:
;	 r1 = task number
;------------------------------------------------------------------------------
message "RemoveFromTimeoutList"
RemoveFromTimeoutList:
	cmp		#MAX_TASKNO
	bhi		rftl_not_on_list2
	phx
	push	r4
	push	r5

	ld		r4,TCB_Status,r1		; Is the task even on the timeout list ?
	bit		r4,#TS_TIMEOUT
	beq		rftl_not_on_list
	cmp		TimeoutList				; Are we removing the head of the list ?
	beq		rftl_remove_from_head
	ld		r4,TCB_PrvTo,r1			; adjust the links of the next and previous
	bmi		rftl_empty_list			; no previous link - list corrupt?
	ld		r5,TCB_NxtTo,r1			; tasks on the list to point around the task
	st		r5,TCB_NxtTo,r4
	bmi		rftl_empty_list
	st		r4,TCB_PrvTo,r5
	ldx		TCB_Timeout,r1			; update the timeout of the next on list
	add		r2,r2,TCB_Timeout,r5	; with any remaining timeout in the task
	stx		TCB_Timeout,r5			; removed from the list
	bra		rftl_empty_list

	; Update the head of the list.
rftl_remove_from_head:
	ld		r5,TCB_NxtTo,r1
	st		r5,TimeoutList			; store next field into list head
	bmi		rftl_empty_list
	ld		r4,TCB_Timeout,r1		; add any remaining timeout to the timeout
	add		r4,r4,TCB_Timeout,r5	; of the next task on the list.
	st		r4,TCB_Timeout,r5
	ld		r4,#-1					; there is no previous item to the head
	sta		TCB_PrvTo,r5
	
	; Here there is no previous or next items in the list, so the list
	; will be empty once this task is removed from it.
rftl_empty_list:
	tax
	lda		#0					; clear timeout status (bit #0)
	bmc		TCB_Status,x
	dea							; acc=-1; make sure the next and prev fields indicate
	sta		TCB_NxtTo,x			; the task is not on a list.
	sta		TCB_PrvTo,x
	txa
rftl_not_on_list:
	pop		r5
	pop		r4
	plx
rftl_not_on_list2:
	rts

;------------------------------------------------------------------------------
; PopTimeoutList
;
; This subroutine is called from within the timer ISR when the task's 
; timeout expires. It's always the head of the list that's being removed in
; the timer ISR so the removal from the timeout list is optimized. We know
; the timeout expired, so the amount of time to add to the next task is zero.
;	This routine is written as a macro since it's only called from one place.
; This routine is inlined. Implementing it as a macro increases performance.
;
; Registers Affected: acc, x, y, flags
; Parameters:
;	x: head of timeout list
; Returns:
;	r1 = task id of task popped from timeout list
;------------------------------------------------------------------------------
;
message "PopTimeoutList"
macro PopTimeoutList
	ldy		#-1
	lda		TCB_NxtTo,x
	sta		TimeoutList		; store next field into list head
	bmi		ptl1
	sty		TCB_PrvTo,r1	; previous link = -1
ptl1:
	lda		#0				; clear timeout status
	bmc		TCB_Status,x
	sty		TCB_NxtTo,x		; make sure the next and prev fields indicate
	sty		TCB_PrvTo,x		; the task is not on a list.
	txa
endm

;------------------------------------------------------------------------------
; Sleep
;
; Put the currently running task to sleep for a specified time.
;
; Registers Affected: none
; Parameters:
;	r1 = time duration in centi-seconds (1/100 second).
; Returns: none
;------------------------------------------------------------------------------
;
Sleep:
	pha
	phx
	tax
	spl		tcb_sema + 1
	lda		RunningTCB
	jsr		RemoveTaskFromReadyList
	jsr		AddToTimeoutList	; The scheduler will be returning to this
	lda		#1
	sta		tcb_sema
	int		#2				; task eventually, once the timeout expires,
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Short delay routine.
;	This routine works by reading the tick register. When a subsequent read
; of the tick register exceeds the value of the original read by at least
; the value passed as a parameter, then this routine returns.
;	The tick register increments at the clock rate (eg 25 MHz).
;------------------------------------------------------------------------------
;
short_delay:
	phx
	phy
	tsr		tick,r2
usec1:
	tsr		tick,r3
	sub		r3,r3,r2
	cmp		r1,r3
	blo		usec1
	ply
	plx
	rts

;------------------------------------------------------------------------------
; KillTask
;
; "Kills" a task, removing it from all system lists. If the task has the 
; IO focus, the IO focus is switched. Task #0 is immortal and cannot be
; killed.
;
; Registers Affected: none
; Parameters:
;	r1 = task number
;------------------------------------------------------------------------------
;
KillTask:
	phx
	cmp		#1							; BIOS task and IDLE task are immortal
	bls		kt1
	cmp		#MAX_TASKNO
	bhi		kt1
	tax
	lda		TCB_hJCB,r1
	jsr		ForceReleaseIOFocus
	txa
	spl		tcb_sema + 1
	jsr		RemoveTaskFromReadyList
	jsr		RemoveFromTimeoutList
	stz		TCB_Status,r1				; set task status to TS_NONE

	; Free up all the mailboxes associated with the task.
kt7:
	pha
	tax
	lda		TCB_MbxList,r1
	bmi		kt6
	jsr		FreeMbx2
	pla
	bra		kt7
kt6:
	lda		#1
	sta		tcb_sema
	pla

	spl		freetcb_sema + 1
	ldx		FreeTCB						; add the task control block to the free list
	stx		TCB_NxtTCB,r1
	sta		FreeTCB
	stz		freetcb_sema + 1
	cmp		RunningTCB					; keep running the current task as long as
	bne		kt1							; the task didn't kill itself.
	int		#2							; invoke scheduler to reschedule tasks
kt1:
	plx
	rts

;------------------------------------------------------------------------------
; Allocate a mailbox
; Parameters:
;	r1 = pointer to place to store handle
; Returns:
;	r1 = E_Ok	means mailbox allocated properly
;	r1 = E_Arg	means a NULL pointer was passed in r1
;	r1 = E_NoMoreMbx	means no more mailboxes were available
;	zf is set if everything is ok, otherwise zf is clear
;------------------------------------------------------------------------------
;
message "AllocMbx"
AllocMbx:
	cmp		#0
	beq		ambx_bad_ptr
	phx
	phy
	push	r4
	ld		r4,r1			; r4 = pointer to returned handle
	spl		freembx_sema + 1
	lda		FreeMbxHandle			; Get mailbox off of free mailbox list
	sta		(r4)			; store off the mailbox number
	bmi		ambx_no_mbxs
	ldx		MBX_LINK,r1		; and update the head of the list
	stx		FreeMbxHandle
	dec		nMailbox		; decrement number of available mailboxes
	stz		freembx_sema + 1
	spl		tcb_sema + 1
	ldy		RunningTCB		; Add the mailbox to the list of mailboxes
	ldx		TCB_MbxList,y	; managed by the task.
	stx		MBX_LINK,r1
	sta		TCB_MbxList,y
	tax
	ldy		RunningTCB			; set the mailbox owner
;	bmi		RunningTCBErr
	lda		TCB_hJCB,y
	stz		tcb_sema + 1

	spl		mbx_sema + 1
	sta		MBX_OWNER,x
	lda		#-1				; initialize the head and tail of the queues
	sta		MBX_TQ_HEAD,x
	sta		MBX_TQ_TAIL,x
	sta		MBX_MQ_HEAD,x
	sta		MBX_MQ_TAIL,x
	stz		MBX_TQ_COUNT,x	; initialize counts to zero
	stz		MBX_MQ_COUNT,x
	stz		MBX_MQ_MISSED,x
	lda		#8				; set the max queue size
	sta		MBX_MQ_SIZE,x	; and
	lda		#MQS_NEWEST		; queueing strategy
	sta		MBX_MQ_STRATEGY,x
	stz		mbx_sema + 1
	pop		r4
	ply
	plx
	lda		#E_Ok
	rts
ambx_bad_ptr:
	lda		#E_Arg
	rts
ambx_no_mbxs:
	stz		freembx_sema + 1
	pop		r4
	ply
	plx
	lda		#E_NoMoreMbx
	rts

;------------------------------------------------------------------------------
; Free up a mailbox.
;	This function frees a mailbox from the currently running task. It may be
; called by ExitTask().
;
; Parameters:
;	r1 = mailbox handle
;------------------------------------------------------------------------------
;
FreeMbx:
	phx
	ldx		RunningTCB
	jsr		FreeMbx2
	plx
	rts

;------------------------------------------------------------------------------
; Free up a mailbox.
;	This function dequeues any messages from the mailbox and adds the messages
; back to the free message pool. The function also dequeues any threads from
; the mailbox.
;	Called from KillTask() and FreeMbx().
;
; Parameters:
;	r1 = mailbox handle
;	r2 = task handle
; Returns:
;	r1 = E_Ok	if everything ok
;	r1 = E_Arg	if a bad handle is passed
;------------------------------------------------------------------------------
;
FreeMbx2:
	cmp		#NR_MBX				; check mailbox handle parameter
	bhs		fmbx1
	cpx		#MAX_TASKNO
	bhi		fmbx1
	phx
	phy
	spl		mbx_sema + 1

	; Dequeue messages from mailbox and add them back to the free message list.
fmbx5:
	pha
	jsr		DequeueMsgFromMbx
	bmi		fmbx3
	spl		freemsg_sema + 1
	phx
	ldx		FreeMsg
	stx		MSG_LINK,r1
	sta		FreeMsg
	stz		freemsg_sema + 1
	plx
	pla
	bra		fmbx5
fmbx3:
	pla

	; Dequeue threads from mailbox.
fmbx6:
	pha
	jsr		DequeueThreadFromMbx2
	bmi		fmbx7
	pla
	bra		fmbx6
fmbx7:
	pla

	; Remove mailbox from TCB list
	ldy		TCB_MbxList,x
	phx
	ldx		#-1
fmbx10:
	cmp		r1,r3
	beq		fmbx9
	tyx
	ldy		MBX_LINK,y
	bpl		fmbx10
	; ?The mailbox was not in the list managed by the task.
	plx
	bra		fmbx2
fmbx9:
	cmp		r2,r0
	bmi		fmbx11
	ldy		MBX_LINK,y
	sty		MBX_LINK,x
	plx
	bra		fmbx12
fmbx11:
	; No prior mailbox in list, update head
	ldy		MBX_LINK,r1
	plx
	sty		TCB_MbxList,x

fmbx12:
	; Add mailbox back to mailbox pool
	spl		freembx_sema + 1
	ldx		FreeMbxHandle
	stx		MBX_LINK,r1
	sta		FreeMbxHandle
	stz		freembx_sema + 1
fmbx2:
	stz		mbx_sema + 1
	ply
	plx
	lda		#E_Ok
	rts
fmbx1:
	lda		#E_Arg
	rts

;------------------------------------------------------------------------------
; Queue a message at a mailbox.
; On entry the mailbox semaphore is already activated.
;
; Parameters:
;	r1 = message
;	r2 = mailbox
;------------------------------------------------------------------------------
message "QueueMsgAtMbx"
QueueMsgAtMbx:
	cmp		#0
	beq		qmam_bad_msg
	pha
	phx
	phy
	push	r4
	ld		r4,MBX_MQ_STRATEGY,x
	cmp		r4,#MQS_UNLIMITED
	beq		qmam_unlimited
	cmp		r4,#MQS_NEWEST
	beq		qmam_newest
	cmp		r4,#MQS_OLDEST
	beq		qmam_oldest
	jsr		kernel_panic
	db		"Illegal message queue strategy",0
	bra		qmam8
	; Here we assumed "unlimited" message storage. Just add the new message at
	; the tail of the queue.
qmam_unlimited:
	ldy		MBX_MQ_TAIL,x
	bmi		qmam_add_at_head
	sta		MSG_LINK,y
	bra		qmam2
qmam_add_at_head:
	sta		MBX_MQ_HEAD,x
qmam2:
	sta		MBX_MQ_TAIL,x
qmam6:
	inc		MBX_MQ_COUNT,x		; increase the queued message count
	ldx		#-1
	stx		MSG_LINK,r1
	pop		r4
	ply
	plx
	pla
qmam_bad_msg:
	rts
	; Here we are queueing a limited number of messages. As new messages are
	; added at the tail of the queue, messages drop off the head of the queue.
qmam_newest:
	ldy		MBX_MQ_TAIL,x
	bmi		qmam3
	sta		MSG_LINK,y
	bra		qmam4
qmam3:
	sta		MBX_MQ_HEAD,x
qmam4:
	sta		MBX_MQ_TAIL,x
	ldy		MBX_MQ_COUNT,x
	iny
	cmp		r3,MBX_MQ_SIZE,x
	bls		qmam6
	ldy		#-1
	sty		MSG_LINK,r1
	; Remove the oldest message which is the one at the head of the mailbox queue.
	; Add the message back to the pool of free messages.
	lda		MBX_MQ_HEAD,x
	ldy		MSG_LINK,r1			; move next in queue
	sty		MBX_MQ_HEAD,x		; to head of list
qmam8:
	inc		MBX_MQ_MISSED,x
qmam1:
	spl		freemsg_sema + 1
	ldy		FreeMsg				; put old message back into free message list
	sty		MSG_LINK,r1
	sta		FreeMsg
	inc		nMsgBlk
	stz		freemsg_sema + 1
	;GoReschedule
	pop		r4
	ply
	plx
	pla
	rts
	; Here we are buffering the oldest messages. So if there are too many messages
	; in the queue already, then the queue doesn't change and the new message is
	; lost.
qmam_oldest:
	ldy		MBX_MQ_COUNT,x		; Check if the queue is full
	cmp		r3,MBX_MQ_SIZE,x
	bhs		qmam8				; If the queue is full, then lose the current message
	bra		qmam_unlimited		; Otherwise add message to queue

;------------------------------------------------------------------------------
; Dequeue a message from a mailbox.
;
; Returns
;	r1 = message number
;	nf set if there is no message, otherwise clear
;------------------------------------------------------------------------------
message "DequeueMsgFromMbx"
DequeueMsgFromMbx:
	phx
	phy
	tax						; x = mailbox index
	lda		MBX_MQ_COUNT,x		; are there any messages available ?
	beq		dmfm3
	dea
	sta		MBX_MQ_COUNT,x		; update the message count
	lda		MBX_MQ_HEAD,x		; Get the head of the list, this should not be -1
	bmi		dmfm3			; since the message count > 0
	ldy		MSG_LINK,r1		; get the link to the next message
	sty		MBX_MQ_HEAD,x		; update the head of the list
	bpl		dmfm2			; if there was no more messages then update the
	sty		MBX_MQ_TAIL,x		; tail of the list as well.
dmfm2:
	sta		MSG_LINK,r1		; point the link to the messahe itself to indicate it's dequeued
dmfm1:
	ply
	plx
	cmp		#0
	rts
dmfm3:
	ply
	plx
	lda		#-1
	rts

;------------------------------------------------------------------------------
; Parameters:
;	r1 = mailbox handle
; Returns:
;	r1 = E_arg		means pointer is invalid
;	r1 = E_NoThread	means no thread was queued at the mailbox
;	r2 = thead handle
;------------------------------------------------------------------------------
message "DequeueThreadFromNbx"
DequeueThreadFromMbx:
	push	r4
	ld		r4,MBX_TQ_HEAD,r1
	bpl		dtfm2
	pop		r4
	ldx		#-1
	lda		#E_NoThread
	rts
dtfm2:
	push	r5
	dec		MBX_TQ_COUNT,r1
	ld		r2,r4
	ld		r4,TCB_mbq_next,r4
	st		r4,MBX_TQ_HEAD,r1
	bmi		dtfm3
		ld		r5,#-1
		st		r5,TCB_mbq_prev,r4
		bra		dtfm4
dtfm3:
		ld		r5,#-1
		st		r5,MBX_TQ_TAIL,r1
dtfm4:
;	stz		MBX_SEMA+1
	ld		r5,r2
	lda		TCB_Status,r5
	bit		#TS_TIMEOUT
	beq		dtfm5
	ld		r1,r5
	jsr		RemoveFromTimeoutList
dtfm5:
	ld		r4,#-1
	st		r4,TCB_mbq_next,r5
	st		r4,TCB_mbq_prev,r5
	stz		TCB_hWaitMbx,r5
	stz		TCB_Status,r5		; set task status = TS_NONE
	pop		r5
	pop		r4
	lda		#E_Ok
	rts

;------------------------------------------------------------------------------
;	This function is called from FreeMbx(). It dequeues threads from the
; mailbox without removing the thread from the timeout list. The thread will
; then timeout waiting for a message that can never be delivered.
;
; Parameters:
;	r1 = mailbox handle
; Returns:
;	r1 = E_arg		means pointer is invalid
;	r1 = E_NoThread	means no thread was queued at the mailbox
;	r2 = thead handle
;------------------------------------------------------------------------------
message "DequeueThreadFromNbx2"
DequeueThreadFromMbx2:
	push	r4
	ld		r4,MBX_TQ_HEAD,r1
	bpl		dtfm2a
	pop		r4
	ldx		#-1
	lda		#E_NoThread
	rts
dtfm2a:
	push	r5
	dec		MBX_TQ_COUNT,r1
	ld		r2,r4
	ld		r4,TCB_mbq_next,r4
	st		r4,MBX_TQ_HEAD,r1
	bmi		dtfm3a
		ld		r5,#-1
		st		r5,TCB_mbq_prev,r4
		bra		dtfm4a
dtfm3a:
		ld		r5,#-1
		st		r5,MBX_TQ_TAIL,r1
dtfm4a:
	ld		r4,#-1
	st		r4,TCB_mbq_next,x
	st		r4,TCB_mbq_prev,x
	stz		TCB_hWaitMbx,x
	sei
	lda		#TS_WAITMSG_BIT
	bmc		TCB_Status,x
	cli
	pop		r5
	pop		r4
	lda		#E_Ok
	rts

;------------------------------------------------------------------------------
; PostMsg and SendMsg are the same operation except that PostMsg doesn't
; invoke rescheduling while SendMsg does. So they both call the same
; SendMsgPrim primitive routine. This two wrapper functions for convenience.
;------------------------------------------------------------------------------
;
PostMsg:
	push	r4
	ld		r4,#0			; Don't invoke scheduler
	jsr		SendMsgPrim
	pop		r4
	rts

SendMsg:
	push	r4
	ld		r4,#1			; Do invoke scheduler
	jsr		SendMsgPrim
	pop		r4
	rts

;------------------------------------------------------------------------------
; SendMsgPrim
; Send a message to a mailbox
;
; Parameters
;	r1 = handle to mailbox
;	r2 = message D1
;	r3 = message D2
;	r4 = scheduler flag		1=invoke,0=don't invoke
;
; Returns
;	r1=E_Ok			everything is ok
;	r1=E_BadMbx		for a bad mailbox number
;	r1=E_NotAlloc	for a mailbox that isn't allocated
;	r1=E_NoMsg		if there are no more message blocks available
;	zf is set if everything is okay, otherwise zf is clear
;------------------------------------------------------------------------------
message "SendMsgPrim"
SendMsgPrim:
	cmp		#NR_MBX					; check the mailbox number to make sure
	bhs		smsg1					; that it's sensible
	push	r5
	push	r6
	push	r7

	spl		mbx_sema + 1
	ld		r7,MBX_OWNER,r1
	bmi		smsg2					; error: no owner
	pha
	phx
	jsr		DequeueThreadFromMbx	; r1=mbx
	ld		r6,r2					; r6 = thread
	plx
	pla
	cmp		r6,#0
	bpl		smsg3
		; Here there was no thread waiting at the mailbox, so a message needs to
		; be allocated
smp2:
		spl		freemsg_sema + 1
		ld		r7,FreeMsg
		bmi		smsg4		; no more messages available
		ld		r5,MSG_LINK,r7
		st		r5,FreeMsg
		dec		nMsgBlk		; decrement the number of available messages
		stz		freemsg_sema + 1
		stx		MSG_D1,r7
		sty		MSG_D2,r7
		pha
		phx
		tax						; x = mailbox
		ld		r1,r7			; acc = message
		jsr		QueueMsgAtMbx
		plx
		pla
		cmp		r6,#0			; check if there is a thread waiting for a message
		bmi		smsg5
smsg3:
	stx		TCB_MSG_D1,r6
	sty		TCB_MSG_D2,r6
smsg7:
	spl		tcb_sema + 1
	ld		r5,TCB_Status,r6
	bit		r5,#TS_TIMEOUT
	beq		smsg8
	ld		r1,r6
	jsr		RemoveFromTimeoutList
smsg8:
	lda		#TS_WAITMSG_BIT
	bmc		TCB_Status,r6
	lda		#1
	sta		tcb_sema
	ld		r1,r6
	spl		tcb_sema + 1
	jsr		AddTaskToReadyList
	stz		tcb_sema + 1
	cmp		r4,#0
	beq		smsg5
	stz		mbx_sema + 1
	int		#2
	;GoReschedule
	bra		smsg9
smsg5:
	stz		mbx_sema + 1
smsg9:
	pop		r7
	pop		r6
	pop		r5
	lda		#E_Ok
	rts
smsg1:
	lda		#E_BadMbx
	rts
smsg2:
	stz		mbx_sema + 1
	pop		r7
	pop		r6
	pop		r5
	lda		#E_NotAlloc
	rts
smsg4:
	stz		freemsg_sema + 1
	stz		mbx_sema + 1
	pop		r7
	pop		r6
	pop		r5
	lda		#E_NoMsg
	rts

;------------------------------------------------------------------------------
; WaitMsg
; Wait at a mailbox for a message to arrive. This subroutine will block the
; task until a message is available or the task times out on the timeout
; list.
;
; Parameters
;	r1=mailbox
;	r2=timeout
; Returns:
;	r1=E_Ok			if everything is ok
;	r1=E_BadMbx		for a bad mailbox number
;	r1=E_NotAlloc	for a mailbox that isn't allocated
;	r2=message D1
;	r3=message D2
;------------------------------------------------------------------------------
message "WaitMsg"
WaitMsg:
	cmp		#NR_MBX				; check the mailbox number to make sure
	bhs		wmsg1				; that it's sensible
	push	r4
	push	r5
	push	r6
	push	r7
	ld		r6,r1
wmsg11:
	spl		mbx_sema + 1
	ld		r5,MBX_OWNER,r1
	cmp		r5,#MAX_TASKNO
	bhi		wmsg2					; error: no owner
	jsr		DequeueMsgFromMbx
;	cmp		#0
	bpl		wmsg3

	; Here there was no message available, remove the task from
	; the ready list, and optionally add it to the timeout list.
	; Queue the task at the mailbox.
wmsg12:
	spl		tcb_sema + 1
	lda		RunningTCB				; remove the task from the ready list
	jsr		RemoveTaskFromReadyList
	stz		tcb_sema + 1
wmsg13:
	spl		tcb_sema + 1
	ld		r7,TCB_Status,r1
	or		r7,r7,#TS_WAITMSG			; set task status to waiting
	st		r7,TCB_Status,r1
	st		r6,TCB_hWaitMbx,r1			; set which mailbox is waited for
	ld		r7,#-1
	st		r7,TCB_mbq_next,r1			; adding at tail, so there is no next
	ld		r7,MBX_TQ_HEAD,r6			; is there a task que setup at the mailbox ?
	bmi		wmsg6
	ld		r7,MBX_TQ_TAIL,r6
	st		r7,TCB_mbq_prev,r1
	sta		TCB_mbq_next,r7
	sta		MBX_TQ_TAIL,r6
	inc		MBX_TQ_COUNT,r6				; increment number of tasks queued
wmsg7:
	stz		tcb_sema + 1
	stz		mbx_sema + 1
	cmp		r2,#0						; check for a timeout
	beq		wmsg10
wmsg14:
	spl		tcb_sema + 1
	jsr		AddToTimeoutList
	stz		tcb_sema + 1
	int		#2	;	GoReschedule			; invoke the scheduler
wmsg10:
	; At this point either a message was sent to the task, or the task
	; timed out. If a message is still not available then the task must
	; have timed out. Return a timeout error.
	; Note that SendMsg will directly set the message D1, D2 data
	; without queing a message at the mailbox (if there is a task
	; waiting already). So we cannot just try dequeing a message again.
	ldx		TCB_MSG_D1,r1
	ldy		TCB_MSG_D2,r1
	ld		r4,TCB_Status,r1
	bit		r4,#TS_WAITMSG	; Is the task still waiting for a message ?
	beq		wmsg8			; If not, go return OK status
	pop		r7				; Otherwise return timeout error
	pop		r6
	pop		r5
	pop		r4
	lda		#E_Timeout
	rts
	
	; Here there were no prior tasks queued at the mailbox
wmsg6:
	ld		r7,#-1
	st		r7,TCB_mbq_prev,r1		; no previous tasks
	st		r7,TCB_mbq_next,r1
	sta		MBX_TQ_HEAD,r6			; set both head and tail indexes
	sta		MBX_TQ_TAIL,r6
	ld		r7,#1
	st		r7,MBX_TQ_COUNT,r6		; one task queued
	bra		wmsg7					; check for a timeout value
	
wmsg3:
	stz		mbx_sema + 1
	ldx		MSG_D1,r1
	ldy		MSG_D2,r1
	; Add the newly dequeued message to the free messsage list
wmsg5:
	spl		freemsg_sema + 1
	ld		r7,FreeMsg
	st		r7,MSG_LINK,r1
	sta		FreeMsg
	inc		nMsgBlk
	stz		freemsg_sema + 1
wmsg8:
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	lda		#E_Ok
	rts
wmsg1:
	lda		#E_BadMbx
	rts
wmsg2:
	stz		mbx_sema + 1
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	lda		#E_NotAlloc
	rts

;------------------------------------------------------------------------------
; Check for a message at a mailbox. Does not block. This function is a
; convenience wrapper for CheckMsg().
;
; Parameters
;	r1=mailbox handle
; Returns:
;	r1=E_Ok			if everything is ok
;	r1=E_NoMsg		if no message is available
;	r1=E_BadMbx		for a bad mailbox number
;	r1=E_NotAlloc	for a mailbox that isn't allocated
;	r2=message D1
;	r3=message D2
;------------------------------------------------------------------------------
;
PeekMsg:
	ld		r2,#0		; don't remove from queue
	jsr		CheckMsg
	rts

;------------------------------------------------------------------------------
; CheckMsg
; Check for a message at a mailbox. Does not block.
;
; Parameters
;	r1=mailbox handle
;	r2=remove from queue if present
; Returns:
;	r1=E_Ok			if everything is ok
;	r1=E_NoMsg		if no message is available
;	r1=E_BadMbx		for a bad mailbox number
;	r1=E_NotAlloc	for a mailbox that isn't allocated
;	r2=message D1
;	r3=message D2
;------------------------------------------------------------------------------
CheckMsg:
	cmp		#NR_MBX					; check the mailbox number to make sure
	bhs		cmsg1					; that it's sensible
	push	r4
	push	r5

	spl		mbx_sema + 1
	ld		r5,MBX_OWNER,r1
	bmi		cmsg2					; error: no owner
	cpx		#0						; are we to dequeue the message ?
	php
	beq		cmsg3
	jsr		DequeueMsgFromMbx
	bra		cmsg4
cmsg3:
	lda		MBX_MQ_HEAD,r1			; peek the message at the head of the messages queue
cmsg4:
	cmp		#0
	bmi		cmsg5
	ldx		MSG_D1,r1
	ldy		MSG_D2,r1
	plp								; get back dequeue flag
	beq		cmsg8
cmsg10:
	spl		freemsg_sema + 1
	ld		r5,FreeMsg
	st		r5,MSG_LINK,r1
	sta		FreeMsg
	inc		nMsgBlk
	stz		freemsg_sema + 1
cmsg8:
	stz		mbx_sema + 1
	pop		r5
	pop		r4
	lda		#E_Ok
	rts
cmsg1:
	lda		#E_BadMbx
	rts
cmsg2:
	stz		mbx_sema + 1
	pop		r5
	pop		r4
	lda		#E_NotAlloc
	rts
cmsg5:
	stz		mbx_sema + 1
	pop		r5
	pop		r4
	lda		#E_NoMsg
	rts

;------------------------------------------------------------------------------
; Spinlock interrupt
;	Go reschedule tasks if a spinlock is taking too long.
;------------------------------------------------------------------------------
;
spinlock_irq:
	cli
	ld		r0,tcb_sema + 1
	beq		spi1
	cld
	pusha
	bra		resched1	
spi1:
	rti

;------------------------------------------------------------------------------
; System Call Interrupt
;
; The system call is executed using the caller's system stack.
;
; Stack Frame
; 4,sp:	 return address
; 3,sp:	 status register
; 2,sp:  r6 save
; 1,sp:  r7 save
; 0,sp:  r8 save
;------------------------------------------------------------------------------
;
syscall_int:
	cli
	cld
	push	r6					; save off some working registers
	push	r7
	push	r8
	ld		r6,4,sp				; get return address into r6
	lb		r7,0,r6				; get static call number parameter into r7
	inc		r6					; update return address
	st		r6,4,sp
;	tsr		sp,r8				; save off stack pointer
;	ld		r6,RunningTCB		; load the stack pointer with the system call
;	ld		r6,TCB_StackTop,r6	; stack area
;	trs		r6,sp
	ld		r6,(syscall_vectors>>2),r7	; load the vector into r6
	jsr		(r6)				; do the system function
;	trs		r8,sp				; restore the stack pointer
	pop		r8
	pop		r7
	pop		r6
	rti

;------------------------------------------------------------------------------
; Reschedule tasks to run without affecting the timeout list timing.
;------------------------------------------------------------------------------
;
reschedule:
	cli		; enable interrupts
	cld		; clear extended precision mode

	pusha	; save off regs on the stack
	spl		tcb_sema + 1
resched1:
	ldx		RunningTCB
	tsa
	sta		TCB_SPSave,x	; save stack pointer in TCB
	tsr		sp8,r1			; and the eight bit mode stack pointer
	sta		TCB_SP8Save,x
	tsr		abs8,r1
	sta		TCB_ABS8Save,x	; 8 bit emulation base register
	lda		#TS_RUNNING_BIT	; clear RUNNING status (bit #3)
	bmc		TCB_Status,x
;	lda		TCB_StackTop,x	; switch to the system call stack
;	tas
	jmp		SelectTaskToRun


strStartQue:
	db		0,0,0,1,0,0,0,2,0,1,0,3,0,0,0,4
;	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;------------------------------------------------------------------------------
; 100 Hz interrupt
; - takes care of "flashing" the cursor
; - decrements timeouts for tasks on timeout list
; - switching tasks
;------------------------------------------------------------------------------
;
MTKTick:
	pha
	lda		#3				; reset the edge sense circuit
	sta		PIC_RSTE
	pla
	inc		IRQFlag
	; Try and aquire the ready list and tcb. If unsuccessful it means there is
	; a system function in the process of updating the list. All we can do is
	; return to the system function and let it complete whatever it was doing.
	; As if we don't return to the system function we will be deadlocked.
	; The tick will be deferred; however if the system function was busy updating
	; the ready list, in all likelyhood it's about to call the reschedule
	; interrupt.
	ld		r0,tcb_sema+1
	bne		p100Hz11
	inc		missed_ticks
	rti
p100Hz11:
	cli
	cld		; clear extended precision mode

	pusha	; save off regs on the stack
	lda		#96
	sta		LEDS
	lda		UserTick
	beq		p100Hz4
	jsr		(r1)
	cli
p100Hz4:

	ldx		RunningTCB
	tsa						; save off the stack pointer
	sta		TCB_SPSave,x
	tsr		sp8,r1			; and the eight bit mode stack pointer
	sta		TCB_SP8Save,x
	tsr		abs8,r1
	sta		TCB_ABS8Save,x	; 8 bit emulation base register
	lda		#TS_RUNNING_BIT
	bmc		TCB_Status,x
	lda		#97
	sta		LEDS

	; Check the timeout list to see if there are items ready to be removed from
	; the list. Also decrement the timeout of the item at the head of the list.
p100Hz15:
	ldx		TimeoutList
	bmi		p100Hz12				; are there any entries in the timeout list ?
	lda		TCB_Timeout,x
	bgt		p100Hz14				; has this entry timed out ?
	PopTimeoutList
	jsr		AddTaskToReadyList
	bra		p100Hz15				; go back and see if there's another task to be removed
									; there could be a string of tasks to make ready.
p100Hz14:
	dea								; decrement the entry's timeout
	sub		r1,r1,missed_ticks		; account for any missed ticks
	stz		missed_ticks
	sta		TCB_Timeout,x
	
p100Hz12:
	; Falls through into selecting a task to run
tck3:
	lda		#98
	sta		LEDS
;------------------------------------------------------------------------------
; Search the ready queues for a ready task.
; The search is occasionally started at a lower priority queue in order
; to prevent starvation of lower priority tasks. This is managed by 
; using a tick count as an index to a string containing the start que.
;------------------------------------------------------------------------------
;
SelectTaskToRun:
	ld		r6,#5			; number of queues to search
	ldy		IRQFlag			; use the IRQFlag as a buffer index
;	lsr		r3,r3,#1		; the LSB is always the same
	and		r3,r3,#$0F		; counts from 0 to 15
	lb		r3,strStartQue,y	; get the queue to start search at
sttr2:
	lda		QNdx0,y
	bmi		sttr1
	lda		TCB_NxtRdy,r1		; Advance the queue index
	sta		QNdx0,y
	; This is the only place the RunningTCB is set (except for initialization).
	sta		RunningTCB
	tax
	lda		#TS_RUNNING_BIT
	bms		TCB_Status,x		; flag the task as the running task
	lda		#99
	sta		LEDS
	lda		TCB_ABS8Save,x		; 8 bit emulation base register
	trs		r1,abs8
	lda		TCB_SP8Save,x		; get back eight bit stack pointer
	trs		r1,sp8
	ldx		TCB_SPSave,x		; get back stack pointer
	txs
	lda		#1
	sta		tcb_sema
	ld		r0,iof_switch		
	beq		sttr6				
	ld		r0,iof_sema + 1		; just ignore the request to switch
	beq		sttr6				; I/O focus if the semaphore can't be aquired
	stz		iof_switch
	jsr		SwitchIOFocus
	stz		iof_sema + 1
sttr6:
	popa						; restore registers
	rti

	; Set index to check the next ready list for a task to run
sttr1:
	iny
	cpy		#5
	bne		sttr5
	ldy		#0
sttr5:
	dec		r6
	bne		sttr2

	; Here there were no tasks ready
	; This should not be able to happen, so hang the machine (in a lower
	; power mode).
sttr3:
	ldx		#94
	stx		LEDS
	jsr		kernel_panic
	db		"No tasks in ready queue.",0
	; Might as well power down the clock and wait for a reset or
	; NMI. In the case of an NMI the kernel is reinitialized without
	; doing the boot reset.
	stp								
	jmp		MTKInitialize

;------------------------------------------------------------------------------
; kernal_panic:
;	All this does right now is display the panic message on the screen.
; Parameters:
;	inline: string
;------------------------------------------------------------------------------
;
kernel_panic:
	pla					; pop the return address off the stack
	push	r4			; save off r4
	ld		r4,r1
kpan2:
	lb		r1,0,r4		; get a byte from the code space
	add		r4,#1		; increment pointer
	and		#$FF		; we want only eight bits
	beq		kpan1			; is it end of string ?
	jsr		DisplayChar
	bra		kpan2
kpan1:						; must update the return address !
	jsr		CRLF
	ld		r1,r4		; get return address into acc
	pop		r4			; restore r4
	jmp		(r1)

include "DeviceDriver.asm"

;------------------------------------------------------------------
;------------------------------------------------------------------
include "Test816.asm"
include "pi_calc816.asm"

;------------------------------------------------------------------
; Kind of a chicken and egg problem here. If there is something
; wrong with the processor, then this code likely won't execute.
;

; put message to screen
; tests pla,sta,ldy,inc,bne,ora,jmp,jmp(abs)

putmsg
	pla					; pop the return address off the stack
	wdm					; switch to 32 bits
	xce
	cpu		RTF65002
	push	r4			; save off r4
	or		r4,r1,#$FFFF0000	; set program bank bits; code is at $FFFFxxxx
pm2
	add		r4,#1		; increment pointer
	lb		r1,0,r4		; get a byte from the code space
	and		#$FF		; we want only eight bits
	beq		pm1			; is it end of string ?
	jsr		DisplayChar
	jmp		pm2
pm1						; must update the return address !
	ld		r1,r4		; get return address into acc
	pop		r4			; restore r4
	clc					; switch back to '816 mode
	xce
	cpu		W65C816S
	rep		#$30		; mem,ndx = 16 bits
	pha
	rts
	
	cpu		RTF65002
;------------------------------------------------------------------
; This test program just loop around waiting to recieve a message.
; The message is a pointer to a string to display.
;------------------------------------------------------------------
;
test_mbx_prg:
	jsr		RequestIOFocus
	lda		#test_mbx	; where to put mailbox handle
	int		#4
	db		6			; AllocMbx
	ldx		#5
	jsr		PRTNUM
;	mStartTask	#PRI_LOWEST,#0,#test_mbx_prg2,#0,#0
	lda		#PRI_LOWEST
	ldx		#0
	ldy		#test_mbx_prg2
	ld		r4,#0
	ld		r5,#1
	int		#4
	db		1			; StartTask
tmp2:
	lda		test_mbx
	ldx		#100
	int		#4
	db		10			; WaitMsg
	cmp		#E_Ok
	bne		tmp1
	txa
	jsr		DisplayStringB
	bra		tmp2
tmp1:
	ldx		#4
	jsr		PRTNUM
	bra		tmp2

test_mbx_prg2:
tmp2a:
	lda		test_mbx
	ldx		#msg_hello
	ldy		#0
	int		#4
	db		8			; PostMsg
	bra		tmp2a
msg_hello:
	db		"Hello from RTF",13,10,0

message "DOS.asm"
include "DOS.asm"

	cpu		RTF65002

message "1298"
include "TinyBasic65002.asm"
message "1640"
	org $0FFFFFFF4		; NMI vector
	dw	nmirout

	org	$0FFFFFFF8		; reset vector, native mode
	dw	start
	
	end
	