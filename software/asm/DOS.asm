;==============================================================================
;        __
;   \\__/ o\    (C) 2014  Robert Finch, Stratford
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
; DOS.asm
;	Disk operating system code
;==============================================================================
;
	cpu		rtf65002
; 64GB card
; 36 address bits
; 9 bits for 512 byte block size
; 27 bits for block number
; 4kB cluster size = 3 bits
; 24 bit cluster number
; 2MB bitmap of allocated clusters ( contained in 512 clusters)
; 512 super bitmap bits
; 
NO_DEV		EQU		-1
READING		EQU		'R'
WRITING		EQU		'W'
DIRTY		EQU		'D'
CLEAN		EQU		'C'
NORMAL		EQU		0

ONE_SHOT	EQU		1
WRITE_IMMED	EQU		2
ZUPER_BLOCK	EQU		2	; write superblock immediately
SUPER_BLOCK_NUM		EQU		1	; should calculate this
;
; Note that structure offsets are word offsets
; The super block always occupies a whole block for simplicity even though
; it's mostly unused.
;
; STRUCT SUPER_BLOCK
;
s_inodes_count			EQU		0
s_blocks_count			EQU		1
s_r_blocks_count		EQU		2
s_free_blocks_count		EQU		3
s_free_inodes_count		EQU		4
s_first_data_block		EQU		5
s_log_block_size		EQU		6
s_log_frag_size			EQU		7
s_blocks_per_group		EQU		8
s_frags_per_group		EQU		9
s_inodes_per_group		EQU		10
s_pad					EQU		11
s_mtime					EQU		12
s_wtime					EQU		14
s_mnt_cnt				EQU		16
s_max_mnt_cnt			EQU		17
s_magic					EQU		18
s_state					EQU		19
s_errors				EQU		20
s_minor_rev_level		EQU		21
s_lastcheck				EQU		22
s_checkinterval			EQU		24
s_creator_os			EQU		26
s_rev_level				EQU		27
s_def_res_uid			EQU		28
s_def_res_gid			EQU		29
s_inode_size			EQU		31
s_volume_name			EQU		40
; In memory management fields
s_inodes_per_block		EQU		124
s_dev					EQU		125
s_dirty					EQU		126
SUPERBUF_SIZE			EQU		128

; STRUCT INODE
;
i_mode		EQU		0
i_uid		EQU		1
i_size		EQU		2
i_gid		EQU		3
i_atime		EQU		4
i_ctime		EQU		6
i_mtime		EQU		8
i_dtime		EQU		10
i_links_count	EQU	12
i_blocks	EQU		13
i_flags		EQU		14
i_osd1		EQU		15
INODE_P0	EQU		16
INODE_P1	EQU		INODE_P0+1
INODE_P2	EQU		INODE_P1+1
INODE_P3	EQU		INODE_P2+1
INODE_P4	EQU		INODE_P3+1
INODE_P5	EQU		INODE_P4+1
INODE_P6	EQU		INODE_P5+1
INODE_P7	EQU		INODE_P6+1
INODE_P8	EQU		INODE_P7+1
INODE_P9	EQU		INODE_P8+1
INODE_P10	EQU		INODE_P9+1
INODE_P11	EQU		INODE_P10+1
INODE_IP	EQU		INODE_P11+1		; indirect pointer
INODE_IIP	EQU		INODE_IP+1		; double indirect pointer
INODE_IIIP	EQU		INODE_IIP+1		; triple indirect pointer
i_generation	EQU		31
i_file_acl		EQU		32
i_dir_acl		EQU		33
i_faddr			EQU		34
i_osd2			EQU		35
INODE_DEV	EQU		37
INODE_INUM	EQU		38
INODE_ICOUNT	EQU	39
INODE_DIRTY	EQU		40
INODE_SIZE	EQU		41				; 41 words

; STRUCT BGDESC
;
bg_block_bitmap			EQU		0
bg_inode_bitmap			EQU		1
bg_inode_table			EQU		2
bg_free_blocks_count	EQU		3
bg_free_inodes_count	EQU		4
bg_used_dirs_count		EQU		5
bg_reserved				EQU		6
BGDESC_SIZE				EQU		8
bg_dev					EQU		9
bg_group_num			EQU		10
bg_dirty				EQU		11
BGD_BUFSIZE				EQU		12

; STRUCT DIRENTRY
; Directory entries are 64 bytes
; 28 character file name
;  4 byte i-node number
;
DE_NAME			EQU		0
DE_TYPE			EQU		14
DE_INODE		EQU		15
DE_SIZE			EQU		16		; size in words

; Structure of a disk buffer
; The disk buffer contains a number of fields for file system management
; followed by a payload area containing disk block contents.
;
; STRUCT BUF
;
b_dev			EQU		0		; device 
b_blocknum	EQU		1		; disk block number
b_count		EQU		2		; reference count
b_dirty		EQU		3		; buffer has been altered
b_next		EQU		4		; next buffer on LRU list
b_prev		EQU		5
b_hash		EQU		6		; pointer to hashed buffer
b_data		EQU		8		; beginning of data area
BUF_INODE		EQU		8
BUF_SIZE		EQU		b_data+256

NR_BUFS			EQU		8192	; number of disk buffers in the system (must be a power of 2)
NR_BUF_HASH		EQU		1024	; number of hash chains (must be a power of two)
NR_BGD_BUFS		EQU		1024
BT_DATA_BLOCK	EQU		0
BT_SUPERBLOCK	EQU		1

IAM_BUF_SIZE	EQU		1032	; 1024 + 8
CAM_SUPERMAP_SIZE	EQU		128

; $00000000 super block
; $00000001 iam super map (512 bits)
; $00000002 inode allocation map (128kB)
; $00000102 inode array (1M x 128 byte entries)
; $00040102 cam super bitmap bits (512 bits)
; $00040103 cluster allocation map (2MB)
; $00041103 start of data clusters

; Approximately 12MB (10% of memory) is allowed for the file system variables.
; Most of the space 8MB+ is alloted to disk buffers.

DOS_DATA		EQU		0x00300000					; start address of DOS data area
super_bufs		EQU		DOS_DATA
super_bufs_end	EQU		super_bufs + SUPERBUF_SIZE * 32
BGD_bufs		EQU		super_bufs_end
BGD_bufs_end	EQU		BGD_bufs + NR_BGD_BUFS * BGD_BUFSIZE	; 32 kB = 1024 descriptors
iam_bufs		EQU		BGD_bufs_end
inode_array		EQU		iam_bufs + IAM_BUF_SIZE * 32	; 129 kB worth 
inode_array_end	EQU		inode_array + INODE_SIZE * 256	; 41kB worth (256 open files)
data_bufs		EQU		0x00320000			; room for 8192 buffers
data_bufs_end	EQU		data_bufs + BUF_SIZE * NR_BUFS
buf_hash		EQU		data_bufs_end
buf_hash_end	EQU		buf_hash + NR_BUF_HASH
superbuf_dump	EQU		buf_hash_end + 1
bufs_in_use		EQU		superbuf_dump + 1
blockbuf_dump	EQU		bufs_in_use + 1
disk_size		EQU		blockbuf_dump + 1
block_size		EQU		disk_size + 1
fs_start_block	EQU		block_size + 1
bgdt_valid		EQU		fs_start_block + 1
front			EQU		bgdt_valid + 1
rear			EQU		front + 1
panicking		EQU		rear + 1
fs_active		EQU		panicking + 1
DOS_DATA_ENDS	EQU		0x0540000

; number of buffers for the inode allocation map
; number of buffers for inode array
; Total caching to be 12MB
; 9MB reserved for data block caching
; 3MB reserved for file management caching

inode_bufs	EQU		DOS_DATA	; 128B x 256 bufs
iam_buf		EQU		0x01FBE800
sector_buf	EQU		0x01FBEC00

	org		$FFFFD800

;------------------------------------------------------------------------------
; Initialize the file system.
;------------------------------------------------------------------------------
;
init_fs:
	stz		bgdt_valid
	jsr		init_superbufs
	jsr		init_databufs
	lda		#'A'
	sta		fs_active
	lda		#4
	ldx		#0				; no flags (em =0 native mode)
	ldy		#fs_clean
	jsr		StartTask
	rts

;------------------------------------------------------------------------------
; The file system offset is the offset in disk sectors to the start
; of the file system. It may be desireable to reserve a number of
; disk sectors prior to the actual file system start.
;------------------------------------------------------------------------------
;
get_filesystem_offset:
	lda		#2
	rts

;------------------------------------------------------------------------------
; Initialize super block buffer array.
;------------------------------------------------------------------------------
;
init_superbufs:
	pha
	phx
	ldx		#super_bufs
isb1:
	lda		#NO_DEV
	sta		s_dev,x
	lda		#CLEAN
	sta		s_dirty,x
	add		r2,r2,#SUPERBUF_SIZE
	cpx		#super_bufs_end
	bltu	isb1
	plx
	pla
	rts

init_databufs:
	pha
	phx
	phy
	stz		bufs_in_use
	ldx		#data_bufs
	stx		front
	lda		#data_bufs_end
	sub		#BUF_SIZE
	sta		rear
idb1:
	lda		#NO_DEV
	sta		b_dev,x
	lda		#CLEAN
	sta		b_dirty,x
	sub		r3,r2,#BUF_SIZE
	sty		b_prev,x
	add		r3,r2,#BUF_SIZE
	sty		b_next,x
	sty		b_hash,x
	tyx
	cpx		#data_bufs_end
	bltu	idb1
	ldx		front
	stz		b_prev,x
	stx		buf_hash			; buf_hash[0] = front
	ldx		rear
	stz		b_next,x	
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Parameters:
;	r1 = device
; Returns:
;	r1 = block size in bytes
;------------------------------------------------------------------------------
get_block_size:
	phx
	phy
	jsr		get_super
	tax
	ldy		s_log_block_size,x
	lda		#1024
	asl		r1,r1,r3
	ply
	plx
	rts

get_log_block_size:
	phx
	jsr		get_super
	tax
	lda		s_log_block_size,x
	plx
	rts

get_inode_size:
	phx
	jsr		get_super
	tax
	lda		s_inode_size,x
	plx
	rts

get_inodes_per_group:
	phx
	jsr		get_super
	tax
	lda		s_inodes_per_group,x
	plx
	rts

; inodes per block does not need to be a power of 2
;
get_inodes_per_block:
	phx
	pha
	jsr		get_block_size
	tax
	pla
	jsr		get_inode_size
	div		r1,r2,r1
	plx
	rts

get_bgd_per_block:
	jsr		get_block_size
	lsr		; BGD size is 32 bytes
	lsr
	lsr
	lsr
	lsr
	rts
	
get_bits_per_block:
	jsr		get_block_size
	asl
	asl
	asl
	rts

get_num_bgd:
	phx
	jsr		get_super
	lda		s_blocks_count,r1
	tax
	jsr		get_bits_per_block
	div		r1,r2,r1
	plx
	rts
	
;==============================================================================
; INODE code
;==============================================================================
;------------------------------------------------------------------------------
; Free an inode.
;
; Parameters:
;	r1 = device number
;	r2 = inode number
;------------------------------------------------------------------------------
;	
free_inode:
	pha
	phx
	phy
	push	r4
	push	r5
	push	r7
	push	r8
	push	r9
	ld		r7,r1		; r7 = device number
	jsr		get_inodes_per_group
	div		r4,r2,r1	; r4 = group number of inode
	mod		r5,r2,r1	; r5 = group index
	ld		r1,r7
	ld		r2,r4
	jsr		get_bgdt_entry
	ld		r9,r1		; r9 = pointer to BGDesc
	ld		r1,r7
	ld		r2,bg_inode_bitmap,r9
	jsr		get_block	; get the bitmap block
	ld		r8,r1		; r8 = bitmap block
	ld		r1,r5
	bmt		b_data,r8	; is the inode already free ?
	beq		fi1
	bmc		b_data,r8
	inc		bg_free_inodes_count,r9
	lda		#DIRTY
	sta		bg_dirty,r9
	jsr		get_super
	tax
	inc		s_free_inodes_count,x
	lda		#DIRTY
	sta		s_dirty,x
	sta		b_dirty,r8
	txy
	jsr		get_datetime
	stx		s_mtime,y
	sta		s_mtime+1,y
fi1:
	pop		r9
	pop		r8
	pop		r7
	pop		r5
	pop		r4
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Allocate an inode
; This is called when a file or directory is created. The routine allocates
; an inode on disk, then gets an inode buffer.
;
; Parameters:
;	r1 = device number
;	r2 = mode bits
; Returns:
;	r1 = pointer to inode buffer
;------------------------------------------------------------------------------
;		
alloc_inode:
	phx
	phy
	push	r4
	push	r7
	push	r8
	push	r9
	push	r10
	push	r11
; search the super match for a block with available inode
	lda		#0				; start at bit zero
	ld		r7,r1
	ld		r8,r2
	jsr		get_num_bgd
	tay
	jsr		get_inodes_per_block
	ld		r9,r1
	ld		r2,#0			; start with group #0
alin2:
	ld		r1,r7
	jsr		get_bgdt_entry
	ld		r4,r1
	lda		bg_free_inodes_count,r4
	bne		alin3
	inx
	dey
	bne		alin2
	ld		r1,r7
	jsr		dos_msg
	db		"Out of inodes on device ",0
alin7:
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		r7
	pop		r4
	ply
	plx
	lda		#0
	rts
alin3:
	ld		r1,r7
	ld		r10,r2					; r10 = bgd entry number
	ldx		bg_inode_bitmap,r4
	ldy		#NORMAL
	jsr		get_block
	tax
	ld		r3,r9					; r3 = indoes per block
	lda		#0
alin5:
	bmt		b_data,x
	beq		alin4
	ina
	dey
	bne		alin5
alin4:
	bms		b_data,x				; mark inode allocated
	ld		r5,r1					; r5 = inode number within block
	dec		bg_free_inodes_count,r4
	mul		r11,r10,r9
	add		r5,r5,r11					; r5 = inode number
	lda		#DIRTY
	sta		bg_dirty,r4
	jsr		get_super				; decrement free inode count in superblock
	dec		s_free_inodes_count,r1	; and mark the superblock dirty
	tay
	lda		#DIRTY
	sta		s_dirty,y
	jsr		get_datetime
	stx		i_mtime,y
	sta		i_mtime+1,y
	;
	ld		r1,r7					; r1 = device number
	ld		r2,r5					; r2 = inode number
	jsr		get_inode
	cmp		#0
	bne		alin6
	ld		r1,r7
	ld		r2,r5
	jsr		free_inode
	bra		alin7
alin6:
	st		r8,i_mode,r1
	stz		i_link_count,r1
	; set uid,gid
	st		r7,i_dev,r1
	jsr		wipe_inode
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		r7
	pop		r4
	ply
	plx
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
wipe_inode:
	pha
	phx
	phy
	tay
	stz		i_size,y
	jsr		get_datetime
	stx		i_mtime,y
	sta		i_mtime+1,y
	lda		#DIRTY
	sta		i_dirty,y
	ldx		#15
win1:
	stz		INODE_P0,y
	iny
	dex
	bne		win1
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
; Get an inode
;
; There are 256 inode buffers in the system which allows for 256 files
; to be open at once.
;
; Parameters:
;	r1 = device
;	r2 = inode number
; Returns:
;	r1 = pointer to inode buffer
;------------------------------------------------------------------------------
;
get_inode:
	; push working registers
	push	r4						; r4 = buffer number		
	push	r5						; r5 points to inode buffer
	push	r6
	push	r7
	ld		r7,#0					; tracks the last free buffer
	; Search the in use inode buffers for the one corresponding
	; to the given device and node number. If found then increment
	; the reference count and return a pointer to the buffer.
	ld		r4,#0
	ld		r5,#inode_bufs
gib4:
	ld		r6,INODE_ICOUNT,r5		; check the count field to see if in use
	beq		gib3					; branch if not in use
	cmp		INODE_DEV,r5			; now check for a matching device
	bne		gib5					; branch if no match					
	cpx		INODE_INUM,r5			; now check for matching node number
	bne		gib5
	inc		INODE_ICOUNT,r5			; increment count
	ld		r1,r5
	pop		r7
	pop		r6						; pop working registers
	pop		r5
	pop		r4
	cmp		#0
	rts

gib3:
	ld		r7,r5					; remember the free inode
gib5:
	add		r4,#1					; increment buffer number
	add		r5,r5,#INODE_SIZE		; size of an inode in words
	cmp		r4,#256					; have we searched all buffers ?
	bltu	gib4
	cmp		r7,#0					; test if free buffer found
	bne		gib6
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	ld		r1,#0					; no more inode buffers available
	rts
gib6:
	sta		INODE_DEV,r7
	stx		INODE_INUM,r7
	inc		INODE_ICOUNT,r7			; count field =1, was 0
	cmp		#NO_DEV					; if there was a device number supplied
	beq		gib7					; read the inode from the device
	ld		r1,r7
	ldx		#READING
	jsr		rw_inode
gib7:
	ld		r1,r7
	pop		r7						; restore work registers
	pop		r6
	pop		r5
	pop		r4
	cmp		#0
	rts
		
;------------------------------------------------------------------------------
; Put inode
;
; Parameters:
;	r1 = pointer to inode buffer
;------------------------------------------------------------------------------
;
put_inode:
	cmp		#0					; check for NULL pointer
	bne		pi1
	rts
pi1:
	phx
	tax
	dec		INODE_ICOUNT,x
	bne		pi2
	; If the number of links to the inode is zero
	; then deallocate the storage for the inode
pi2:
	lda		INODE_DIRTY,x
	cmp		#DIRTY
	bne		pi3
	txa							; acc = inode buffer pointer
	ldx		#WRITING
	jsr		rw_inode
pi3:
	plx
	rts

;------------------------------------------------------------------------------
; Parameters:
;	r1 = inode
;	r2 = R/W indicator
;------------------------------------------------------------------------------
rw_inode:
	pha
	phx
	phy
	push	r4
	push	r5
	push	r6
	push	r7
	; get the super block for the device
	phx
	pha
	lda		INODE_DEV,r1
	jsr		get_inodes_per_group
	ld		r5,r1			; r4 = inodes per group
	pla
	ldx		INODE_INUM,r1
	div		r6,r2,r5		; r6 = group number
	mod		r7,r2,r5		; r7 = index into group
	lda		INODE_DEV,r1
	pha
	ld		r2,r6
	jsr		get_bgdt_entry
	lda		bg_inode_table,r1	; get block address of inode table
	pha
	jsr		get_inodes_per_block
	div		r6,r7,r1
	mod		r8,r7,r1
	pla
	add		r2,r1,r6
	pla
	ldy		#NORMAL
	jsr		get_block

	ld		r7,r1				; r7 = pointer to block buffer
	pop		r4					; r4 = inode
	add		r5,r1,#BUF_INODE	; r5 = address of inode data

	mul		r6,r8,#INODE_SIZE
	add		r5,r5,r6
	pop		r6					; r6 = R/W indicator
	cmp		r6,#READING
	bne		rwi1
	jsr		get_inode_size
	dea
	ld		r2,r5
	ld		r3,r4
	mvn
	bra		rwi2
rwi1:			
	jsr		get_inode_size
	dea
	ld		r2,r4
	ld		r3,r5
	mvn
	jsr		get_datetime
	stx		INODE_WTIME,r4
	sta		INODE_WTIME+1,r4
	lda		#DIRTY
	sta		b_dirty,r7
rwi2:
	jsr		get_datetime
	stx		INODE_ATIME,r4
	sta		INODE_ATIME+1,r4
	ld		r1,r7				; r1 = pointer to block buffer
	ld		r2,#INODE_BLOCK
	jsr		put_block
	lda		#CLEAN
	sta		INODE_DIRTY,r4
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	ply
	plx
	pla
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
dup_inode:
	inc		INODE_ICOUNT,r1
	rts

;------------------------------------------------------------------------------
; get_bgdt_entry:
;	Get block group descriptor from the descriptor table.
;
; Parameters:
;	r1 = device number
;	r2 = group number
; Returns:
;	r1 = pointer to BGD buffer
;------------------------------------------------------------------------------
;
get_bgdt_entry:
	push	r5
	and		r5,r2,#NR_BGD_BUFS-1		; r5 = hashed group number
	mul		r5,r5,#BGD_BUFSIZE
	add		r5,r5,#BGD_bufs		; r5 = pointer to BGD buffer
	cmp		bg_dev,r5
	bne		gbe1
	cpx		bg_group_num,r5
	beq		gbe2
gbe1:
	push	r4
	push	r6
	push	r7
	push	r8
	ld		r6,r1				; r6 = device number
	ld		r7,r2				; r7 = group number
	; does the buffer need to be written to disk ?
	ld		r4,bg_dirty,r5
	cmp		r4,#CLEAN
	beq		gbe3
	; Compute the block number containing the group
	jsr		get_bgd_per_block
	ld		r2,bg_group_num,r5
	div		r8,r2,r1
	mod		r4,r2,r1
	lda		fs_start_block
	ina							; the next block after the file system start
	add		r2,r1,r8			; r2 = block number
	ld		r1,r6				; r1 = device number
	jsr		get_block
	pha
	add		r1,r1,#b_data		; move to data area
	mul		r4,r4,#BGDESC_SIZE
	add		r1,r1,r4			; r1 = pointer to desired BGD
	; copy BGD to the block
	tay
	ld		r2,r5
	lda		#BGDESC_SIZE-1
	mvn
	pla
	ld		r2,#DIRTY
	stx		b_dirty,r1
gbe3:
	; Compute the block number containing the group
	ld		r1,r6
	ld		r2,r7
	jsr		get_bgd_per_block
	div		r8,r2,r1
	mod		r4,r2,r1
	lda		fs_start_block
	ina							; the next block after the file system start
	add		r2,r1,r8			; r2 = block number
	ld		r1,r6				; r1 = device number
	jsr		get_block
	add		r1,r1,#b_data		; move to data area
	mul		r4,r4,#BGDESC_SIZE
	add		r1,r1,r4			; r1 = pointer to desired BGD
	; copy BGD from the block to the buffer
	tax
	ld		r3,r5
	lda		#BGDESC_SIZE-1
	mvn
	st		r6,bg_dev,r5
	st		r7,bg_group_num,r5
	lda		#CLEAN
	sta		bg_dirty,r5
	pop		r8
	pop		r7
	pop		r6
	pop		r4
gbe2:
	ld		r1,r5
	pop		r5
	rts

;==============================================================================
; Block Caching
;==============================================================================

;------------------------------------------------------------------------------
; get_block
;
;	Gets a block from the device. First the block cache is checked for the
; block; if found the cached buffer is returned.
;	The block number is hashed to determine where to start the search for a
; cached buffer. 
;
; Parameters:
;	r1 = device
;	r2 = block number
;	r3 = only searching
; Returns:
;	r1 = pointer to buffer containing block
;------------------------------------------------------------------------------
;
get_block:
	phx
	phy
	push	r4
	push	r5
	push	r6
	push	r7
	push	r8
	ld		r4,r1				; r4 = device number
	ld		r5,r2				; r5 = block number
	and		r6,r5,#NR_BUF_HASH-1
	ldx		buf_hash,r6
	cmp		r4,#NO_DEV
	beq		gb11
gb15:
	cmp		r2,r0				; while (bp <> NULL) {
	beq		gb12
	cmp		r4,b_dev,x		;	if (bp->b_dev == dev) {
	bne		gb13
	cmp		r5,b_blocknum,x	;		if (bp->b_blocknum==block) {
	bne		gb13
	cmp		r0,b_count,x		;			if (bp->b_count==0)
	bne		gb14
	inc		bufs_in_use			;				bufs_in_use++
gb14:
	inc		b_count,x			;			bp->b_count++
	txa							;			return (bp)
gb_ret:
	pop		r8
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	ply
	plx
	rts
gb13:
	ldx		b_hash,x			;	bp = bp->b_hash
	bra		gb15
gb11:
gb12:
	lda		bufs_in_use
	cmp		#NR_BUFS
	bltu	gb16
	jsr		panic
	db		"All buffers in use.",0
gb16:
	inc		bufs_in_use
	ldx		front
gb18:
	cmp		r0,b_count,x
	bls		gb17
	cmp		r0,b_next,x
	beq		gb17
	ldx		b_next,x
	bra		gb18
gb17:
	cmp		r2,r0
	beq		gb19
	cmp		r0,b_count,x
	bls		gb20
gb19:	
	jsr		panic
	db		"No free buffer.", 0
gb20:
	ld		r6,b_blocknum,x
	and		r6,r6,#NR_BUF_HASH-1
	ld		r7,buf_hash,r6
	cmp		r7,r2
	bne		gb21
	ld		r8,b_hash,x
	st		r8,buf_hash,r6
	bra		gb22
gb21:
	cmp		r0,b_hash,r7
	beq		gb22
	cmp		r2,b_hash,r7
	bne		gb23
	ld		r8,b_hash,x
	st		r8,b_hash,r7
	bra		gb22
gb23:
	ld		r7,b_hash,r7
	bra		gb21
gb22:
	ld		r8,b_dirty,x
	cmp		r8,#DIRTY
	bne		gb24
	ld		r8,b_dev,x
	cmp		r8,#NO_DEV
	beq		gb24
	phx
	txa
	ldx		#WRITING
	jsr		rw_block
	plx
gb24:
	st		r4,b_dev,x		; bp->b_dev = dev
	st		r5,b_blocknum,x	; bp->b_blocknum = block
	inc		b_count,x			; bp->b_count++
	ld		r7,buf_hash,r6
	st		r7,b_hash,x		; bp->b_hash = buf_hash[bp->b_blocknr & (NR_b_hash - 1)]
	st		r2,buf_hash,r6		; buf_hash[bp->b_blocknr & (NR_b_hash - 1)] = bp
	cmp		r4,#NO_DEV
	beq		gb25
	cmp		r3,#NORMAL
	bne		gb25
	phx
	txa
	ldx		#READING
	jsr		rw_block
	pla
	bra		gb_ret
gb25:
	txa
	bra		gb_ret

;------------------------------------------------------------------------------
; put_block
;	Put a block back to device
;
; Parameters:
;	r1 = pointer to buffer to put
;	r2 = block type
;
;------------------------------------------------------------------------------
;
put_block:
	cmp		#0		; NULL pointer check
	bne		pb1
pb2:
	rts
pb1:
	pha
	phx
	push	r4
	push	r5
	push	r7
	push	r8
	ld		r4,r1
	ld		r5,r2
	dec		b_count,r1	; if buf count > 0 then buffer is still in use
	bne		pb2
	dec		bufs_in_use
	tax
	ld		r7,b_next,x
	ld		r8,b_prev,x
	beq		pb3
	st		r7,b_next,r8	; prev_ptr->b_next = next_ptr
	bra		pb4
pb3:
	st		r7,front		; front = next_ptr
pb4:
	cmp		r7,r0
	beq		pb5
	st		r8,b_next,r7
	bra		pb6
pb5:
	st		r8,rear
pb6:
	bit		r5,#ONE_SHOT
	beq		pb7
	stz		b_prev,x
	lda		front
	sta		b_next,x
	bne		bp8
	stx		rear
	bra		bp9
bp8:
	stx		b_prev,r1		; front->b_prev = bp
bp9:
	stx		front			; front = bp
	bra		bp10
pb7:
	stz		b_next,x		; bp->b_next = NULL
	lda		rear
	sta		b_prev,x		; bp->b_prev = rear
	bne		bp11
	stx		front			; front = bp
	bra		bp12
bp11:
	stx		b_next,r1		; rear->b_next = bp
bp12:
	stx		rear			; read = bp
bp10:
	cmp		r0,b_dev,x
	beq		bp13
	lda		#DIRTY
	cmp		b_dirty,x
	bne		bp13
	bit		r5,#WRITE_IMMED	
	beq		bp13
	phx
	txa
	ldx		#WRITING
	jsr		rw_block
	plx
bp13:
	cmp		r5,#ZUPER_BLOCK
	bne		bp14
	lda		#NO_DEV
	sta		b_dev,x
bp14:
	pop		r8
	pop		r7
	pop		r5
	pop		r4
	plx
	pla
	rts
	
;------------------------------------------------------------------------------
; block_to_sector:
;	Convert a block number to a sector number.
;
; Parameters:
;	r1 = block number
; Returns:
;	r1 = sector number
;------------------------------------------------------------------------------
block_to_sector:
	phx
	pha
	jsr		get_log_block_size
	tax
	pla
	inx
	asl		r1,r1,r2
	plx
	rts

;------------------------------------------------------------------------------
; rw_block:
; ToDo: add error handling
;
; Parameters:
;	r1 = pointer to buffer to operate on
;	r2 = R/W flag
;------------------------------------------------------------------------------
;
rw_block:
	phx
	phy
	push	r4
	push	r5
	pha
	ld		r5,r1				; r5 = pointer to data buffer
	add		r5,r5,#b_data
	ldy		b_dev,r1
	cpy		#NO_DEV
	beq		rwb1
	ldy		b_blocknum,r1		; y = block number
	ld		r4,#1				; r4 = # of blocks
	lda		b_dev,r1			; device number
	cpx		#READING
	bne		rwb2
	ldx		#11					; read blocks opcode
	bra		rwb1
rwb2:
	ldx		#12					; write blocks opcode
rwb1:
	jsr		DeviceOp
	pla
	ldy		#CLEAN
	sty		b_dirty,r1
	pop		r5
	pop		r4
	ply
	plx
	rts

;------------------------------------------------------------------------------
; invalidate_dev
;	Cycle through all the block buffers and mark the buffers for the 
; matching device as free.
;
; Parameters:
;	r1 = device number
;------------------------------------------------------------------------------
;
invalidate_dev:
	phx
	phy
	push	r4
	ldy		#NR_BUFS
	ldx		#data_bufs
id2:
	ld		r4,b_dev,x
	cmp		r4,r1
	bne		id1
	ld		r4,#NO_DEV
	st		r4,b_dev,x
id1:
	add		r2,r2,#BUF_SIZE
	dey
	bne		id2

; invalidate the superblock
;	ldy		#32
;	ldx		#super_bufs
id3:
;	ld		r4,s_dev,x
;	cmp		r4,r1
;	bne		id4
;	ld		r4,#NO_DEV
;	st		r4,s_dev,x
id4:
;	add		r2,r2,#SUPERBUF_SIZE
;	dey
;	bne		id3

	pop		r4
	ply
	plx
	rts
	
;==============================================================================
; SUPERBLOCK code
;==============================================================================

;------------------------------------------------------------------------------
; get_super:
;	Get the super block.
; There is a super block for each device. Superblocks have their own buffer
; cache.
;
; Parameters:
;	r1 = device number
; Returns:
;	r1 = pointer to superblock buffer
;------------------------------------------------------------------------------
;
get_super:
	phx
	phy
	push	r4
	; first search the superbuf array to see if the block is already
	; memory resident
	ldy		#0
	ldx		#super_bufs
gs2:
	ld		r4,s_dev,x
	cmp		r1,r4					; device number match ?
	beq		gs1						; yes, found superblock buffer for device
	cmp		r4,#NO_DEV
	bne		gs4
	txy								; record empty buffer
gs4:
	add		r2,r2,#SUPERBUF_SIZE
	cpx		#super_bufs_end
	blo		gs2
	cpy		#0
	beq		gs5
	tyx
	sta		s_dev,x
	bra		gs3
gs5:
	; Here we couldn't find the device superblock cached and there wasn't a slot free.
	; So dump one from memory and load cache
	inc		superbuf_dump			; "randomizer" for dump select
	ldx		superbuf_dump
	and		r2,r2,#31				; 32 buffers
	mul		r2,r2,#SUPERBUF_SIZE
	add		r2,r2,#super_bufs
	; if the superblock is dirty, then write it out
	ldy		s_dirty,x
	cpy		#DIRTY
	bne		gs3
	jsr		write_super
gs3:
	sta		s_dev,x
	jsr		read_super
gs1:
	txa
	pop		r4
	ply
	plx
	rts

;------------------------------------------------------------------------------
; read_super:
;	Read the superblock from disk. Only a single sector is read.
;
; Parameters:
;	r1 = pointer to superblock buffer
;------------------------------------------------------------------------------
;
read_super:
	pha
	phx
	phy
	ldy		s_dev,r1			; save device number in .Y
	pha
	jsr		get_filesystem_offset
	tax
	pla
	pha
	asl							; convert pointer to byte pointer
	asl
	jsr		SDReadSector
	plx
	lda		#CLEAN				; mark superblock clean
	sta		s_dirty,x
	sty		s_dev,x				; restore device number
	ply
	plx
	pla
	rts
	
;------------------------------------------------------------------------------
; Parameters:
;	r1 = pointer to superblock buffer
;------------------------------------------------------------------------------
write_super:
	pha
	phx
	phy
	push	r4
	ld		r4,r1
	ldy		s_dev,r1			; save device number in .Y
	jsr		get_datetime
	stx		s_wtime,r4
	sta		s_wtime+1,r4
	pop		r4
	pha
	jsr		get_filesystem_offset
	tax
	pla
	pha
	asl							; convert pointer to byte pointer
	asl
	jsr		SDWriteSector
	plx
	lda		#CLEAN
	sta		s_dirty,x
	sty		s_dev,x				; restore device number
	ply
	plx
	pla
	rts
	
;==============================================================================
; Utility functions
;==============================================================================

;------------------------------------------------------------------------------
; get_datetime:
;	Get the date and time.
; Returns:
;	r1 = date
;	r2 = time
;------------------------------------------------------------------------------
get_datetime:
	php
	sei
	stz		DATETIME_SNAPSHOT	; take a snapshot of the running date/time
	lda		DATETIME_DATE
	ldx		DATETIME_TIME
	plp
	rts

;------------------------------------------------------------------------------
; panic
;	Display a filesystem panic message and abort.
;
; Parameters:
;	r1 = numeric constant
;	inline string
;------------------------------------------------------------------------------
;
panic:
	pha
	lda		panicking
	beq		pan1
	pla
	rts
pan1:
	ina
	sta		panicking	; panicking = TRUE;
	jsr		dos_msg
	db		"File system panic: ", 0
	ply
	plx						; pull return address from stack
pan2:
	lb		r1,0,x
	beq		pan3
	jsr		DisplayChar
	inx
	bra		pan2
pan3:
	inx
	phx
	tya
	cmp		#NO_NUM
	beq		pan4
	ldx		#5
	jsr		PRTNUM
pan4:
	jsr		CRLF
	jsr		do_sync
	jsr		sys_abort
	;
pan5:						; we should not get back to here after the sys_abort()
	bra		pan5
	
;------------------------------------------------------------------------------
; Display a message on the screen
; Parameters:
;	inline string
;------------------------------------------------------------------------------
;
dos_msg:
	plx			; get return address
dm2:
	lb		r1,0,x
	beq		dm1
	jsr		DisplayChar
	inx
	bra		dm2
dm1:
	inx
	phx
	rts

;==============================================================================
;==============================================================================
;------------------------------------------------------------------------------
; File system CLEAN task
;------------------------------------------------------------------------------
fs_clean:
fsc4:
	lda		#100			; sleep for 1s
	jsr		Sleep
fsc3:
	lda		fs_active		; is the file system active ?
	cmp		#'A'
	bne		fsc4
	ldx		#data_bufs
fsc2:
	lda		b_dev,x			; is the buffer in use ?
	cmp		#NO_DEV
	beq		fsc1			; if not, goto next buffer
	sei
	lda		b_dirty,x		; is the buffer dirty ?
	cmp		#CLEAN
	beq		fsc1			; if not, goto next buffer
	; Found a dirty buffer
	phx
	txa
	ldx		#WRITING		; write the dirty buffer out to disk
	jsr		rw_block
	plx
	lda		#CLEAN			; mark the buffer as clean
	sta		b_dirty,x
fsc1:						; iterate to the next buffer
	cli
	add		r2,r2,#BUF_SIZE
	cpx		#data_bufs_end
	bltu	fsc2
	bra		fsc3
	

;==============================================================================
; DOS commands
;==============================================================================

;------------------------------------------------------------------------------
; MKFS - make file system
;------------------------------------------------------------------------------
;
;numb_block_group_sectors:
	; nbg = ((disk size in bytes / 
	;	(blocks  per block group * block size)) * block group descriptor size ) / block size + 1
	
	jsr		SDInit
	lda		#1024
	sta		block_size
	jsr		SDReadPart
	jsr		get_super
	tax
	;	blocks_count = disk size * 512 / block size
	jsr		get_log_block_size
	tax
	inx
	lda		disk_size		; disk size in sectors
	lsr		r1,r1,r2		; r1 = disk size in blocks
	sta		s_block_count,x
	sta		s_free_blocks_count,x
	; # files = block count * block size / 2048 (average file size)
	lda		disk_size
	lsr
	lsr
	sta		s_inodes_count,x
	sta		s_free_inodes_count,x
	stz		s_log_block_size,x	; 0=1kB
	lda		#8192
	sta		s_blocks_per_group,x
	sta		s_inodes_per_group,x
	lda		#$EF54EF54
	sta		s_magic,x
	stz		s_errors,x
	jsr		get_filesystem_offset
	jsr		SDWriteSector		; put_block

	lda		disk_size
	div		r1,r1,#16384			; 8388608/512
	div		r1,r1,#32				; divide by size of block group descriptot
	add		r1,#1					; round up
	add		r4,r1,#2				; boot block + superblock
	; acc = number of blocks for descriptor table
	tay
	st		r4,bg_block_bitmap,
	rts	


