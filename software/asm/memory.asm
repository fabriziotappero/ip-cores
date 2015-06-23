
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
MAX_VIRTUAL_PAGE	EQU		320
MAX_PHYSICAL_PAGE	EQU		2048
INV_PAGE	EQU	000		; page number to use for invalid entries

;------------------------------------------------------------------------------
; InitMMU
;
; Initialize the 64 maps of the MMU.
; Initially all the maps are set the same:
; Virtual Page  Physical Page
; 000-319		000 (invalid page marker)
; 320-511		1856-2047
; Note that there are only 512 virtual pages per map, and 2048 real
; physical pages of memory. This limits maps to 32MB.
; This range includes the BIOS assigned stacks for the tasks and tasks
; virtual video buffers.
; Note that physical pages 0 to 1855 are not mapped, but do exist. They may
; be mapped into a task's address space as required.
; If changing the maps the last 192 pages (12MB) of the map should always point
; to the BIOS area. Don't change map entries 320-511 or the system may
; crash. The last 192 pages map the virtual memory to the same physical
; addresses so that the physical and virtual address are the same.
; If the rts at the end of this routine works, then memory was mapped
; successfully.
;
; System Memory Map (Physical Addresses)
; Page
; 0000			BASIC ROM, scratch memory ( 1 page global)
; 0001-0063		unassigned (4MB - 63 pages)
; 0064-0191		Bitmap video memory (8 MB - 128 pages)
; 0192-0336		DOS usage, disk cache etc. (9.4MB - 145 pages)
; 0337-1855		Heap space (99MB - 1519 pages)
; 1856-1983		Virtual Screen buffers (8MB - 128 pages)
; 1984-2047		BIOS/OS area (4MB - 64 pages)
;	2032-2047		Stacks area (1MB - 16 pages)
; 65535			BIOS ROM (64kB - 1 Page global)
; 261952-262015		I/O area (4MB - 64 pages global)
;------------------------------------------------------------------------------

	align	8
public InitMMU:
	lda		#1
	sta		MMU_KVMMU+1
	dea
	sta		MMU_KVMMU
immu1:
	sta		MMU_AKEY	; set access key for map
	ldx		#0
immu2:
	; set the first 320 pages to invalid page marker
	; set the last 192 pages to physical page 1856-2047
	ld		r4,#INV_PAGE
	cpx		#320
	blo		immu3
	ld		r4,r2
	add		r4,r4,#1536	; 1856-320
immu3:
	st		r4,MMU,x
	inx
	cpx		#512
	bne		immu2
	ina
	cmp		#64			; 64 MMU maps
	bne		immu1
	stz		MMU_OKEY	; set operating key to map #0
	lda		#2
	sta		MMU_FUSE	; set fuse to 2 clocks before mapping starts
	nop
	nop

;------------------------------------------------------------------------------
; Note that when switching the memory map, the stack address should not change
; as the virtual address was mapped to the physical one.
;------------------------------------------------------------------------------
;
	align	8
public EnableMMUMapping:
	pha
	lda		RunningTCB			; no need to enable mapping for Monitor/Debugger job
	lda		TCB_hJCB,r1
	cmp		#2
	blo		dmm2
	lda		#12					; is there even an MMU present ?
	bmt		CONFIGREC
	beq		emm1
	lda		RunningTCB
	lda		TCB_hJCB,r1
	sta		MMU_OKEY			; select the mmu map for the job
	lda		#2
	sta		MMU_FUSE			; set fuse to 2 clocks before mapping starts
	lda		#1
	sta		MMU_MAPEN			; set MMU_MAPEN = 1
emm1:
	pla
	rts

public DisableMMUMapping:
	pha
dmm2:
	lda		#12			; is there even an MMU present ?
	bmt		CONFIGREC
	beq		dmm1
	stz		MMU_MAPEN
dmm1:
	pla
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
SetAKEYForCurrentJob:
	pha
	jsr		GetPtrCurrentJCB
	lda		JCB_Map,r1
	sta		MMU_AKEY
	pla
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
	align	8
public MemInit:
	lda		#1					; initialize memory semaphore
	sta		mem_sema
	lda		#1519
	sta		nPagesFree

	; Initialize the allocated page map to zero.
	lda		#64				; 64*32 = 2048 bits
	ldx		#0
	ldy		#PageMap
	stos
	; Mark the last 192 pages as used (by the OS)
	; 6-32 bit words
	lda		#-1
	sta		PageMap+58
	sta		PageMap+59
	sta		PageMap+60
	sta		PageMap+61
	sta		PageMap+62
	sta		PageMap+63
	; Mark page #0 used
	lda		#1		
	sta		PageMap
	; Mark 64-336 used (DOS)
	lda		#64
meminit1:
	bms		PageMap
	ina
	cmp		#336
	blo		meminit1
	rts

;------------------------------------------------------------------------------
; Allocate a memory page from the available memory pool.
; Returns a pointer to the page in memory. The address returned is the
; virtual memory address.
;
; Returns:
;	r1 = 0 if no more memory is available or max mapped capacity is reached.
;	r1 = virtual address of allocated memory page
;------------------------------------------------------------------------------
;
	align	8
public AllocMemPage:
	phx
	phy
	; Search the page bitmap for a free memory page.
	lda		#0
	ldx		#MAX_PHYSICAL_PAGE
	spl		mem_sema + 1
amp2:
	bmt		PageMap
	beq		amp1		; found a free page ?
	ina
	dex
	bne		amp2
	; Here all memory pages are already in use. No more memmory is available.
	stz		mem_sema + 1
	ply
	plx
	lda		#0
	rts
	; Here we found an unallocated memory page. Next find a spot in the MMU
	; map to place the page.
amp1:
	; Find unallocated map slot in the MMU
	jsr		SetAKEYForCurrentJob
	ldx		#0
amp4:
	ldy		MMU,x
	cpy		#INV_PAGE
	beq		amp3
	inx
	cpx		#MAX_VIRTUAL_PAGE
	bne		amp4
	; Here we searched the entire MMU slots and none were available
	stz		mem_sema + 1
	ply
	plx
	lda		#0		; return NULL pointer
	rts
	; Here we have both an available page, and available map slot.
amp3:
	bms		PageMap		; mark page as allocated
	sta		MMU,x		; put the page# into the map slot
	asl		r1,r2,#14	; pages are 16kW in size (compute virtual address)
	dec		nPagesFree
	stz		mem_sema + 1
	ply
	plx
	rts

;------------------------------------------------------------------------------
; Parameters:
;	r1 = size of allocation in words
; Returns:
;	r1 = word pointer to memory
; No MMU
;------------------------------------------------------------------------------
;
	align	8
public AllocMemPages:
	php
	phx
	phy
	push	r4
	sei
amp5:
	tay
	lsr		r3,r3,#14	; convert amount to #pages
	iny					; round up
	cpy		nPagesFree
	bhi		amp11
	tyx					; x = request size in pages
	; Search for enough free pages to satisfy the request
	lda		#0
amp7:
	bmt		PageMap		; test for a free page
	bne		amp6		; not a free page
	cpx		#1			; did we find enough free pages ?
	bls		amp8
	dex
amp6:					; keep checking for next free page
	ina
	cmp		#1855		; did we hit end of map ?
	bhi		amp11		; can't allocate enough memory
	bra		amp7		; go back and test for another free page

	; Insufficient memory, return NULL pointer
amp11:
	lda		#0
	pop		r4
	ply
	plx
	plp
	rts

	; Mark pages as allocated
amp8:
	tyx		; x= #pages to allocate
	cpx		#1
	bne		amp9
	txa							; flag indicates last page
	bra		amp10
amp9:
	lda		#0					; flag indicates middle page
amp10:
	jsr		AllocMemPage		; allocate first page
	ld		r4,r1				; save virtual address of first page allocated
	dex
	beq		amp14
amp13:
	cpx		#1
	bne		amp15
	txa
	bra		amp12
amp15:
	lda		#0
amp12:
	jsr		AllocMemPage
	dex
	bne		amp13
amp14:
	ld		r1,r4				; r1 = first virtual address
	pop		r4
	ply
	plx
	plp
	rts

;------------------------------------------------------------------------------
; FreeMemPage:
;
;	Free a single page of memory. This is an internal function called by
; FreeMemPages(). Normally FreeMemPages() will be called to free up the
; entire run of pages. This function both unmarks the memory page in the
; page bitmap and invalidates the page in the MMU.
;
; Parameters:
;	r1 = virtual memory address
;------------------------------------------------------------------------------
;
	align	8
FreeMemPage:
	pha
	php
	phx
	sei
	; First mark the page as available in the virtual page map.
	pha
	lsr		r1,r1,#14
	and		#$1ff			; 512 virtual pages max
	ldx		RunningTCB
	ldx		TCB_mmu_map,x	; x = map #
	asl		r2,r2,#4		; 16 words per map
	bmc		VPM_bitmap_b0,x	; clear both bits
	bmc		VPM_bitmap_b1,x
	pla
	; Mark the page available in the physical page map
	pha
	jsr		VirtToPhys		; convert to a physical address
	lsr		r1,r1,#14
	and		#$7ff			; 2048 physical pages max
	bmc		PageMap
	pla
	; Now mark the MMU slot as empty
	lsr		r1,r1,#14		; / 16kW r1 = page # now
	and		#$1ff			; 512 pages max
	jsr		SetAKEYForCurrentJob
	tax
	lda		#INV_PAGE
	sta		MMU,x
	inc		nPagesFree
	plx
	plp
	pla
	rts

;------------------------------------------------------------------------------
; FreeMemPages:
;
;	Free up multiple pages of memory. The pages freed are a consecutive
; run of pages. A double-bit bitmap is used to identify where the run of
; pages ends. Bit code 00 indicates a unallocated page, 01 indicates an
; allocated page somewhere in the run, and 11 indicates the end of a run
; of allocated pages.
;
; Parameters:
;	r1 = pointer to memory
;------------------------------------------------------------------------------
;
	align	8
public FreeMemPages:
	cmp		#0x3fff				; test for a proper pointer
	bls		fmp5
	pha
	; Turn the memory pointer into a bit index
	lsr		r1,r1,#14			; / 16kW acc = virtual page #
	cmp		#MAX_VIRTUAL_PAGE	; make sure index is sensible
	bhs		fmp4
	phx
	spl		mem_sema + 1
	ldx		RunningTCB
	ldx		TCB_mmu_map,x
	asl		r2,r2,#4
fmp2:
	bmt		VPM_bitmap_b1,x		; Test to see if end of allocation
	bne		fmp3
	asl		r1,r1,#14			; acc = virtual address
	jsr		FreeMemPage			; 
	lsr		r1,r1,#14			; acc = virtual page # again
	ina
	cmp		#MAX_VIRTUAL_PAGE	; last 192 pages aren't freeable
	blo		fmp2
fmp3
	; Clear the last bit
	asl		r1,r1,#14			; acc = virtual address
	jsr		FreeMemPage			; 
	lsr		r1,r1,#14			; acc = virtual page # again
	bmc		VPM_bitmap_b1,x
	stz		mem_sema + 1
	plx
fmp4:
	pla
fmp5:
	rts

;------------------------------------------------------------------------------
; Convert a virtual address to a physical address.
; Parameters:
;	r1 = virtual address to translate
; Returns:
;	r1 = physical address
;------------------------------------------------------------------------------
;
	align	8
public VirtToPhys:
	cmp		#$3FFF				; page #0 is physical page #0
	bls		vtp2
	cmp		#$01FFFFFF			; outside of managed address bounds (ROM / IO)
	bhi		vtp2
	phx
	ldx		CONFIGREC			; check if there is an MMU present
	bit		r2,#4096			; if not, then virtual and physical addresses
	beq		vtp3				; will match
	phy
	tay							; save original address
	and		r3,r3,#$FF803FFF	; mask off MMU managed address bits
	jsr		SetAKEYForCurrentJob
	lsr		r2,r1,#14			; convert to MMU index
	and		r2,r2,#511			; 512 mmu pages
	lda		MMU,x				; a = physical page#
	beq		vtp1				; zero = invalid address translation
	asl		r1,r1,#14			; *16kW
	or		r1,r1,r3			; put back unmanaged address bits
vtp1:
	ply
vtp3:
	plx
vtp2:
	rts

;------------------------------------------------------------------------------
; PhysToVirt
;
; Convert a physical address to a virtual address. A little more complex
; than converting virtual to physical addresses as the MMU map table must
; be searched for the physical page.
;
; Parameters:
;	r1 = physical address to translate
; Returns:
;	r1 = virtual address
;------------------------------------------------------------------------------
;
	align	8
public PhysToVirt:
	cmp		#$3FFF				; first check for direct translations
	bls		ptv3				; outside of the MMU managed range
	cmp		#$01FFFFFF
	bhi		ptv3
	phx
	ldx		CONFIGREC			; check if there is an MMU present
	bit		r2,#4096			; if not, then virtual and physical addresses
	beq		ptv4				; will match
	phy
	jsr		SetAKEYForCurrentJob
	tay
	and		r3,r3,#$FF803FFF	; mask off MMU managed address bits
	lsr		r1,r1,#14			; /16k to get index
	and		r1,r1,#$7ff			; 2048 pages max
	ldx		#0
ptv2:
	cmp		MMU,x
	beq		ptv1
	inx
	cpx		#512
	bne		ptv2
	; Return NULL pointer if address translation fails
	ply
	plx
	lda		#0
	rts
ptv1:
	asl		r1,r2,#14	; * 16k
	or		r1,r1,r3			; put back unmanaged address bits
	ply
ptv4:
	plx
ptv3:
	rts

; ============================================================================
; Heap related functions.
;
;	The heap is managed as a doublely linked list of memory blocks.
; ============================================================================

	align	8
public InitHeap:
	lda		RunningTCB
	ldx		TCB_HeapStart,r1
	ldy		TCB_HeapEnd,r1
	lda		#$4D454D20
	sta		MEM_CHK,x
	sta		MEM_FLAG,x
	lda		#$6D656D20		; mark the last block as allocated
	sta		MEM_CHK,y
	sta		MEM_FLAG,y
	lda		#0
	sta		MEM_PREV,x		; prev of first MEMHDR
	sty		MEM_NEXT,x
	sta		MEM_NEXT,y
	stx		MEM_PREV,y
	rts

;------------------------------------------------------------------------------
; Allocate memory from the heap.
; Each task has it's own memory heap.
;------------------------------------------------------------------------------
	align	8
public MemAlloc:
	phx
	phy
	push	r4
	ldx		RunningTCB
	ldx		TCB_HeapStart,x
mema4:
	ldy		MEM_FLAG,x		; Check the flag word to see if this block is available
	cpy		#$4D454D20
	bne		mema1			; block not available, go to next block
	ld		r4,MEM_NEXT,x	; compute the size of this block
	sub		r4,r4,r2
	sub		r4,r4,#4		; minus size of block header
	cmp		r1,r4			; is the block large enough ?
	bmi		mema2			; if yes, go allocate
mema1:
	ldx		MEM_NEXT,x		; go to the next block
	beq		mema3			; if no more blocks, out of memory error
	bra		mema4
mema2:
	ldy		#$6D656D20
	sty		MEM_FLAG,x
	sub		r4,r4,r1
	cmp		r4,#4			; is the block large enough to split
	bpl		memaSplit
	txa
	add		#4				; point to payload area
	pop		r4
	ply
	plx
	rts
mema3:						; insufficient memory
	pop		r4
	ply
	plx
	lda		#0
	rts
memaSplit:
	add		r4,r1,r2
	add		r4,#4
	ldy		#$4D454D20
	sty		(r4)
	sty		MEM_FLAG,r4
	stx		MEM_PREV,r4
	ldy		MEM_NEXT,x
	sty		MEM_NEXT,r4
	st		r4,MEM_PREV,y
	ld		r1,r4
	add		#4
	pop		r4
	ply
	plx
	rts

;------------------------------------------------------------------------------
; Free previously allocated memory. Recombine with next and previous blocks
; if they are free as well.
;------------------------------------------------------------------------------
	align	8
public MemFree:
	cmp		#4			; null pointer ?
	blo		memf2
	phx
	phy
	sub		#4			; backup to header area
	ldx		MEM_FLAG,r1
	cpx		#$6D656D20	; is the block allocated ?
	bne		memf1
	ldx		#$4D454D20
	stx		MEM_FLAG,r1	; mark block as free
	ldx		MEM_PREV,r1	; is the previous block free ?
	beq		memf3		; no previous block
	ldy		MEM_FLAG,x
	cpy		#$4D454D20
	bne		memf3		; the previous block is not free
	ldy		MEM_NEXT,r1
	sty		MEM_NEXT,x
	beq		memf1		; no next block
	stx		MEM_PREV,y
memf3:
	ldy		MEM_NEXT,r1
	ldx		MEM_FLAG,y
	cpx		#$4D454D20
	bne		memf1		; next block not free
	ldx		MEM_PREV,r1
	stx		MEM_PREV,y
	beq		memf1		; no previous block
	sty		MEM_NEXT,x
memf1:
	ply
	plx
memf2:
	rts

;------------------------------------------------------------------------------
; Report the amount of system memory free. Counts up the number of
; unallocated pages in the page bitmap.
;------------------------------------------------------------------------------
;
public ReportMemFree:
	jsr		CRLF
	lda		#' '
	jsr		DisplayChar
	lda		#0
	tay
rmf2:
	bmt		PageMap
	bne		rmf1
	iny
rmf1:
	ina
	cmp		#2048
	blo		rmf2
	tya
	asl		r1,r1,#14		; 16kW per bit
	ldx		#5
	jsr		PRTNUM
	lea		r1,msgMemFree
	jsr		DisplayStringB
	rts

msgMemFree:
	db	" words free",CR,LF,0
	
;==============================================================================
; Memory Management routines follow.
;==============================================================================

;------------------------------------------------------------------------------
; brk
; Establish a new program break
;
; Parameters:
; r1 = new program break address
;------------------------------------------------------------------------------
;
public _brk:
	phx
	push	r4
	push	r5
	push	r6
	ldx		RunningTCB
	ld		r4,TCB_ASID,x
	st		r4,MMU_AKEY
	ld		r4,TCB_npages,x
	lsr		r1,r1,#14
	add		r1,r1,#1
	cmp		r1,r4
	beq		brk6			; allocation isn't changing
	blo		brk1			; reducing allocation

	; Here we're increasing the amount of memory allocated to the program.
	;
	cmp		r1,#320			; max 320 RAM pages
	bhi		brk2
	sub		r1,r1,r4		; number of new pages
	cmp		r1,mem_pages_free	; are there enough free pages ?
	bhi		brk2
	ld		r5,mem_pages_free
	sub		r5,r5,r1
	st		r5,mem_pages_free
	ld		r6,r1			; r6 = number of pages to allocate
	add		r1,r1,r4		; get back value of address
	sta		TCB_npages,x
	lda		#0
brk5:
	bmt		PageMap			; test if page is free
	bne		brk4			; no, go for next page
	bms		PageMap			; allocate the page
	sta		MMU,r4			; store the page number in the MMU table
	add		r4,#1			; move to next MMU entry
	sub		r6,#1			; decrement count of needed
	beq		brk6			; we're done if count = 0
brk4:
	ina
	cmp		#2048
	blo		brk5

	; Here there was an OS or hardware error
	; According to mem_pages_free there should have been enough free pages
	; to fulfill the request. Something is corrupt.
	;

	; Here we are reducing the program break, which means freeing up pages of
	; memory.
brk1:
	sta		TCB_npages,x
	add		r5,r1,#1		; move to page after last page
brk7:
	cmp		r5,r4			; are we done freeing pages ?
	bhi		brk6
	lda		MMU,r5			; get the page to free
	bmc		PageMap			; free the page
	inc		mem_pages_free
	add		r5,#1
	bra		brk7

	; Successful return
brk6:
	pop		r6
	pop		r5
	pop		r4
	plx
	lda		#0
	rts

; Return insufficient memory error
;
brk2:
	lda		#E_NoMem
	sta		TCB_errno,x
	pop		r6
	pop		r5
	pop		r4
	plx
	lda		#-1
	rts

;------------------------------------------------------------------------------
; Parameters:
; r1 = change in memory allocation
;------------------------------------------------------------------------------
public _sbrk:
	phx
	push	r4
	push	r5
	ldx		RunningTCB
	ld		r4,TCB_npages,x		; get the current memory allocation
	cmp		r1,#0				; zero difference = get old brk address
	beq		sbrk2
	asl		r5,r4,#14			; convert to words
	add		r1,r1,r5				; +/- amount
	jsr		_brk
	cmp		r1,#-1
	bne		sbrk2

; Failure return, return -1
;
	pop		r5
	pop		r4
	plx
	rts

; Successful return, return the old break address
;	
sbrk2:
	ld		r1,r4
	asl		r1,r1,#14
	pop		r5
	pop		r4
	plx
	rts

