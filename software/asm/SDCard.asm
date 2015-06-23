
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
; SDCard.asm                                                                         
; ============================================================================
;
		cpu		RTF65002

		.code

	align	4
;------------------------------------------------------------------------------
; Static device control block (SDBC) structure
;------------------------------------------------------------------------------

public SDCardDCB:
	align	4
	db	"CARD1       "	; name
	dw	5	; number of chars in name
	dw	16	; type
	dw	1	; nBPB
	dw	0	; last erc
	dw	8388608	; nBlocks
	dw	SDCmdProc
	dw	SDInit
	dw	SDStat
	dw	1	; reentrancy count (1 to 255 are valid)
	dw	0	; single user
	dw	0	; hJob
	dw	0	; OSD1
	dw	0	; OSD2
	dw	0	; OSD3
	dw	0	; OSD4
	dw	0	; OSD5
	dw	0	; OSD6

SDOpTbl:
	dw	SDNop
	dw	SDInit
	dw	SDMediaCheck
	dw	SDBuildBPB
	dw	SDNop		;	GetChar				; GetChar()
	dw	SDNop		;	CheckForChar		; PeekChar()
	dw	SDNop		;	GetCharDirect		; unbuffered GetChar()
	dw	SDNop		;	CheckForCharDirect	; unbuffered PeekChar()
	dw	SDNop		;	PutChar				; KeybdPutChar
	dw	SDNop		;	SetEcho
	dw	SDSetpos				; set position
	dw	SDReadBlocks			; block read
	dw	SDWriteBlocks			; block write
	dw	SDNop
	dw	SDNop
	dw	SDNop

SDStat:
	rts
SDBuildBPB:
	rts
SDSetpos:
	rts
;
;------------------------------------------------------------------------------
; SDCmdProc:
;	Device command processor.
;
; Parameters:
;	r1 = device #
;	r2 = opcode
;	r3 = position
;	r4 = number of blocks
;	r5 = pointer to data area
;------------------------------------------------------------------------------

SDCmdProc:
	cmp		#16
	bne		.0001
	phx
	phy
	push	r4
	push	r5
	mul		r1,r1,#DCB_SIZE		; convert device number to DCB pointer
	add		#DCBs
	ld		r0,DCB_pDevInit,r1	; check for an initialization routine
	beq		.0002				; to see if device present
	cmp		r2,#MAX_DEV_OP
	bhi		.0003
	pha							; save off DCB pointer
	jsr		(SDOpTbl>>2,x)
	plx
	sta		DCB_last_erc,x		; stuff the error return code in the DCB
.ret:
	pop		r5
	pop		r4
	ply
	plx
	rts
.0001:
	lda		#E_BadDevNum
	rts
.0002:
	lda		#E_NoDev
	bra		.ret
.0003:
	lda		#E_BadDevOp
	bra		.ret

;------------------------------------------------------------------------------
; SDNop:
; No-operation routine.
;------------------------------------------------------------------------------

SDNop:
	lda		#E_Ok
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

SDMediaCheck:
	lda		#E_Ok
	rts

;------------------------------------------------------------------------------
; Initialize the SD card
; Returns
; acc = 0 if successful, 1 otherwise
; Z=1 if successful, otherwise Z=0
;------------------------------------------------------------------------------
;
message "SDInit"
public SDInit:
	lda		#SPI_INIT_SD
	sta		SPIMASTER+SPI_TRANS_TYPE_REG
	lda		#SPI_TRANS_START
	sta		SPIMASTER+SPI_TRANS_CTRL_REG
	nop
.spi_init1
	lda		SPIMASTER+SPI_TRANS_STATUS_REG
	nop
	nop
	cmp		#SPI_TRANS_BUSY
	beq		.spi_init1
	lda		SPIMASTER+SPI_TRANS_ERROR_REG
	and		#3
	cmp		#SPI_INIT_NO_ERROR
	bne		spi_error
;	lda		#spi_init_ok_msg
;	jsr		DisplayStringB
	lda		#0
	rts
spi_error
	jsr		DisplayByte
	lda		#spi_init_error_msg
	jsr		DisplayStringB
	lda		SPIMASTER+SPI_RESP_BYTE1
	jsr		DisplayByte
	lda		SPIMASTER+SPI_RESP_BYTE2
	jsr		DisplayByte
	lda		SPIMASTER+SPI_RESP_BYTE3
	jsr		DisplayByte
	lda		SPIMASTER+SPI_RESP_BYTE4
	jsr		DisplayByte
	lda		#1
	rts

spi_delay:
	nop
	nop
	rts


;------------------------------------------------------------------------------
; SD read sector
;
; r1= sector number to read
; r2= address to place read data
; Returns:
; r1 = 0 if successful
;------------------------------------------------------------------------------
;
public SDReadSector:
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

.spi_read_retry:
	; Force the reciever fifo to be empty, in case a prior error leaves it
	; in an unknown state.
	lda		#1
	sta		SPIMASTER+SPI_RX_FIFO_CTRL_REG

	lda		#RW_READ_SD_BLOCK
	sta		SPIMASTER+SPI_TRANS_TYPE_REG
	lda		#SPI_TRANS_START
	sta		SPIMASTER+SPI_TRANS_CTRL_REG
	nop
.spi_read_sect1:
	lda		SPIMASTER+SPI_TRANS_STATUS_REG
	jsr		spi_delay			; just a delay between consecutive status reg reads
	cmp		#SPI_TRANS_BUSY
	beq		.spi_read_sect1
	lda		SPIMASTER+SPI_TRANS_ERROR_REG
	lsr
	lsr
	and		#3
	cmp		#SPI_READ_NO_ERROR
	bne		.spi_read_error
	ldy		#512		; read 512 bytes from fifo
.spi_read_sect2:
	lda		SPIMASTER+SPI_RX_FIFO_DATA_REG
	sb		r1,0,x
	inx
	dey
	bne		.spi_read_sect2
	lda		#0
	bra		.spi_read_ret
.spi_read_error:
	dec		r4
	bne		.spi_read_retry
	jsr		DisplayByte
	lda		#spi_read_error_msg
	jsr		DisplayStringB
	lda		#1
.spi_read_ret:
	pop		r4
	ply
	plx
	rts

;------------------------------------------------------------------------------
; BlocksToSectors:
;	Convert a logical block number (LBA) to a sector number
;------------------------------------------------------------------------------

BlocksToSectors:
	asl		r1,r1,#1			; 1k blocks = 2 sectors
	rts

;------------------------------------------------------------------------------
; SDReadBlocks:
;
; Registers Affected: r1-r5
; Parameters:
;	r1 = pointer to DCB
;	r3 = block number
;	r4 = number of blocks
;	r5 = pointer to data area
;------------------------------------------------------------------------------

public SDReadBlocks:
	cpy		DCB_nBlocks,r1
	bhs		.0002
	add		r2,r3,r4
	cpx		DCB_nBlocks,r1
	bhi		.0003
	ld		r2,r5				; x = pointer to data buffer
	tya
	jsr		BlocksToSectors		; acc = sector number
	pha
	ld		r1,r4				
	jsr		BlocksToSectors
	tay							; y = # of blocks to read
	pla							; acc = sector number again
	jsr		SDReadMultiple
	cmp		#0
	bne		.0001
	lda		#E_Ok
	rts
.0001
	lda		#E_ReadError
	rts
.0002
	lda		#E_BadBlockNum
	rts
.0003:
	lda		#E_TooManyBlocks
	rts

;------------------------------------------------------------------------------
; SDWriteBlocks:
;
; Parameters:
;	r1 = pointer to DCB
;	r3 = block number
;	r4 = number of blocks
;	r5 = pointer to data area
;------------------------------------------------------------------------------

public SDWriteBlocks:
	cpy		DCB_nBlocks,r1
	bhs		.0002
	add		r2,r3,r4
	cpx		DCB_nBlocks,r1
	bhi		.0003
	ld		r2,r5				; x = pointer to data buffer
	tya
	jsr		BlocksToSectors		; acc = sector number
	pha
	ld		r1,r4				
	jsr		BlocksToSectors
	tay							; y = # of blocks to read
	pla							; acc = sector number again
	jsr		SDWriteMultiple
	cmp		#0
	bne		.0001
	lda		#E_Ok
	rts
.0001
	lda		#E_WriteError
	rts
.0002
	lda		#E_BadBlockNum
	rts
.0003:
	lda		#E_TooManyBlocks
	rts

;------------------------------------------------------------------------------
; SDWriteSector:
;
; r1= sector number to write
; r2= address to get data from
; Returns:
; r1 = 0 if successful
;------------------------------------------------------------------------------
;
public SDWriteSector:
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
.spi_write_sect1:
	lb		r1,0,x
	sta		SPIMASTER+SPI_TX_FIFO_DATA_REG
	nop			; give the I/O time to respond
	nop
	inx
	dey
	bne		.spi_write_sect1

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
.spi_write_sect2:
	lda		SPIMASTER+SPI_TRANS_STATUS_REG
	nop							; just a delay between consecutive status reg reads
	nop
	cmp		#SPI_TRANS_BUSY
	beq		.spi_write_sect2
	lda		SPIMASTER+SPI_TRANS_ERROR_REG
	lsr		r1,r1,#4
	and		#3
	cmp		#SPI_WRITE_NO_ERROR
	bne		.spi_write_error
	lda		#0
	bra		.spi_write_ret
.spi_write_error:
	jsr		DisplayByte
	lda		#spi_write_error_msg
	jsr		DisplayStringB
	lda		#1

.spi_write_ret:
	ply
	plx
	rts

;------------------------------------------------------------------------------
; SDReadMultiple: read multiple sectors
;
; r1= sector number to read
; r2= address to write data
; r3= number of sectors to read
;
; Returns:
; r1 = 0 if successful
;
;------------------------------------------------------------------------------

public SDReadMultiple:
	push	r4
	ld		r4,#0
.spi_rm1:
	pha
	jsr		SDReadSector
	add		r4,r4,r1
	add		r2,r2,#512
	pla
	ina
	dey
	bne		.spi_rm1
	ld		r1,r4
	pop		r4
	rts

;------------------------------------------------------------------------------
; SPI write multiple sector
;
; r1= sector number to write
; r2= address to get data from
; r3= number of sectors to write
;
; Returns:
; r1 = 0 if successful
;------------------------------------------------------------------------------
;
public SDWriteMultiple:
	push	r4
	ld		r4,#0
.spi_wm1:
	pha
	jsr		SDWriteSector
	add		r4,r4,r1		; accumulate an error count
	add		r2,r2,#512		; 512 bytes per sector
	pla
	ina
	dey
	bne		.spi_wm1
	ld		r1,r4
	pop		r4
	rts
	
;------------------------------------------------------------------------------
; read the partition table to find out where the boot sector is.
; Returns
; r1 = 0 everything okay, 1=read error
; also Z=1=everything okay, Z=0=read error
;------------------------------------------------------------------------------

public SDReadPart:
	phx
	stz		startSector						; default starting sector
	lda		#0								; r1 = sector number (#0)
	ldx		#BYTE_SECTOR_BUF				; r2 = target address (word to byte address)
	jsr		SDReadSector
	cmp		#0
	bne		.spi_rp1
	lb		r1,BYTE_SECTOR_BUF+$1C9
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$1C8
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$1C7
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$1C6
	sta		startSector						; r1 = 0, for okay status
	lb		r1,BYTE_SECTOR_BUF+$1CD
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$1CC
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$1CB
	asl		r1,r1,#8
	orb		r1,r1,BYTE_SECTOR_BUF+$1CA
	sta		disk_size						; r1 = 0, for okay status
	plx
	lda		#0
	rts
.spi_rp1:
	plx
	lda		#1
	rts

;------------------------------------------------------------------------------
; Read the boot sector from the disk.
; Make sure it's the boot sector by looking for the signature bytes 'EB' and '55AA'.
; Returns:
; r1 = 0 means this card is bootable
; r1 = 1 means a read error occurred
; r1 = 2 means the card is not bootable
;------------------------------------------------------------------------------

public SDReadBoot:
	phx
	phy
	push	r5
	lda		startSector					; r1 = sector number
	ldx		#BYTE_SECTOR_BUF			; r2 = target address
	jsr		SDReadSector
	cmp		#0
	bne		spi_read_boot_err
	lb		r1,BYTE_SECTOR_BUF
	cmp		#$EB
	bne		spi_eb_err
spi_read_boot2:
	lda		#msgFoundEB
	jsr		DisplayStringB
	lb		r1,BYTE_SECTOR_BUF+$1FE		; check for 0x55AA signature
	cmp		#$55
	bne		spi_eb_err
	lb		r1,BYTE_SECTOR_BUF+$1FF		; check for 0x55AA signature
	cmp		#$AA
	bne		spi_eb_err
	pop		r5
	ply
	plx
	lda		#0						; r1 = 0, for okay status
	rts
spi_read_boot_err:
	pop		r5
	ply
	plx
	lda		#1
	rts
spi_eb_err:
	lda		#msgNotFoundEB
	jsr		DisplayStringB
	pop		r5
	ply
	plx
	lda		#2
	rts

msgFoundEB:
	db	"Found EB code.",CR,LF,0
msgNotFoundEB:
	db	"EB/55AA Code missing.",CR,LF,0

