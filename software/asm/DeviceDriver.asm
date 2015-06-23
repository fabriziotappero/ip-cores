
; ============================================================================
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
; ============================================================================
;
;------------------------------------------------------------------
; Initialize/install a device driver.
;
; Parameters:
;	r1 = device number
;	r2 = pointer to (static) DCB array
;	r3 = # of devices in array
;------------------------------------------------------------------
;
	cpu		RTF65002
InitDevDrv:
	push	r5
	push	r6
	push	r7
	cmp		#NR_DCB					; check for a good device number
	bhs		.idd1
	mul		r5,r1,#DCB_SIZE
	add		r5,r5,#DCBs
	ld		r0,DCB_pDevOp,r5		; check a pointer to see if device is setup
	beq		.idd2
	cmp		r4,#1
	beq		.idd2
	lda		#E_DCBInUse
	pop		r7
	pop		r6
	pop		r5
	rts
.idd2:
.idd4:
	; Copy the DCB parameter to DCB array
	pha
	phy
	lda		#DCB_SIZE-1
	ld		r3,r5
	mvn
	ply
	pla
	; Initialize device semaphores
	pha
	asl		r1,r1,#4		; * 16 words per semaphore
	add		r1,r1,#device_semas
	sta		DCB_Sema,r5
	ld		r7,DCB_ReentCount,x	; prime the semaphore
	st		r7,(r1)
	pla
	add		r5,r5,#DCB_SIZE
	add		r2,r2,#DCB_SIZE
	dey
	bne		.idd4
	pop		r7
	pop		r6
	pop		r5
	lda		#E_Ok
	rts
.idd1:
	pop		r7
	pop		r6
	pop		r5
	lda		#E_BadDevNum
	rts

;------------------------------------------------------------------
; Parameters:
;	r1 = device number
;------------------------------------------------------------------
;
public DeviceInit:
	cmp		#NR_DCB
	bhs		.dvi1
	phx
	push	r6
	mul		r2,r1,#DCB_SIZE
	add		r2,r2,#DCBs
	ld		r2,DCB_pDevInit,x	; check a pointer to see if device is setup
	beq		.dvi2
	
	asl		r6,r1,#4
	spl		device_semas+1,r6	; Wait for semaphore
	jsr		(x)
	stz		device_semas+1,r6	; unlock device semaphore
	pop		r6
	plx
	; lda # result from jsr() above
	rts
.dvi2:
	pop		r6
	plx
.dvi1:
	lda		#E_BadDevNum
	rts

;------------------------------------------------------------------
; Parameters:
;	r1 = device number
;	r2 = operation code
;	r3 = block address
;	r4 = number of blocks
;	r5 = pointer to data
;------------------------------------------------------------------
;
public DeviceOp:
	cmp		#NR_DCB
	bhs		dvo1
	push	r6
	push	r7
	mul		r6,r1,#DCB_SIZE
	add		r6,r6,#DCBs
	ld		r6,DCB_pDevOp,r6		; check a pointer to see if device is setup
	beq		dvo2

	asl		r7,r1,#4
	spl		device_semas+1,r7		; Wait for semaphore
	jsr		(r6)
	stz		device_semas+1,r7		; unlock device semaphore
	pop		r7
	pop		r6
	rts
dvo2:
	pop		r7
	pop		r6
dvo1:
	lda		#E_BadDevNum
	rts

;------------------------------------------------------------------
; Parameters:
;	r1 = device number
;	r2 = pointer to status return buffer
;	r3 = size of buffer
;	r4 = pointer to status word returned
;------------------------------------------------------------------
;
public DeviceStat:
	cmp		#NR_DCB
	bhs		dvs1
	push	r6
	push	r7
	mul		r6,r1,#DCB_SIZE
	add		r6,r6,#DCBs
	ld		r6,DCB_pDevStat,r6		; check a pointer to see if device is setup
	beq		dvs2

	asl		r7,r1,#4
	spl		device_semas+1,r7		; Wait for semaphore
	jsr		(r6)					; Call the stat function
	stz		device_semas+1,r7		; unlock device semaphore
	pop		r7
	pop		r6
	rts
dvs2:
	pop		r7
	pop		r6
dvs1:
	lda		#E_BadDevNum
	rts

;------------------------------------------------------------------
; Load up the system's built in device drivers.
;------------------------------------------------------------------

public InitDevices:
	lda		#0	
	ldx		#NullDCB>>2
	ldy		#1
	jsr		InitDevDrv
	lda		#1
	ldx		#KeybdDCB>>2
	ldy		#1
	jsr		InitDevDrv
	lda		#16
	ldx		#SDCardDCB>>2
	ldy		#1
	jsr		InitDevDrv
	rts



