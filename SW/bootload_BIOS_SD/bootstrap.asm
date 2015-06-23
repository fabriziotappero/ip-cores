; This file is part of the Next186 SoC PC project
; http://opencores.org/project,next186

; Filename: bootstrap.asm
; Description: Part of the Next186 SoC PC project, bootstrap "ROM" code (RAM initialized with cache)
; Version 1.0
; Creation date: Jun2013

; Author: Nicolae Dumitrache 
; e-mail: ndumitrache@opencores.org

; -------------------------------------------------------------------------------------
 
; Copyright (C) 2013 Nicolae Dumitrache
 
; This source file may be used and distributed without 
; restriction provided that this copyright statement is not 
; removed from the file and that any derivative work contains 
; the original copyright notice and the associated disclaimer.
 
; This source file is free software; you can redistribute it 
; and/or modify it under the terms of the GNU Lesser General 
; Public License as published by the Free Software Foundation;
; either version 2.1 of the License, or (at your option) any 
; later version. 
 
; This source is distributed in the hope that it will be 
; useful, but WITHOUT ANY WARRANTY; without even the implied 
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
; PURPOSE. See the GNU Lesser General Public License for more 
; details. 
 
; You should have received a copy of the GNU Lesser General 
; Public License along with this source; if not, download it 
; from http://www.opencores.org/lgpl.shtml 
 
; -----------------------------------------------------------------------

; Additional Comments: 
; Assembled with MASM v6.14.8444
; No hardware resources are required for the bootstrap ROM, I use only the initial value of the cache memory
; BIOS will be read from the last BIOSSIZE sectors of SD Card and placed in DRAM at F000:(-BIOSSIZE*512)
; SD HC card required



.186
.model tiny
.code


BIOSSIZE    EQU     16      ; sectors
BOOTOFFSET  EQU     0fc00h  ; bootstrap code offset in segment 0f000h

; this code is for bootstrap deployment only, it will not be present in ROM (cache)
;---------------- EXECUTE -----------------
		org		100h        ; this code is loaded at 0f000h:100h
exec    label near

		mov		si, begin
		mov		di, BOOTOFFSET
		mov		cx, 256*4/2 ; last 4 cache lines (from total 8)
		rep		movsw
		db		0eah
		dw		0, -1       ; CPU reset, execute bootstrap


; Loads BIOS (8K = 16 sectors) from last sectors of SD card (if present)
; If no SD card detected, wait on RS232 115200bps and load program at F000:100h
; the following code is placed in the last 1kB of cache (last 4 lines), each with the dirty bit set
; the corresponding position in RAM will be F000:BOOTOFFSET
; ----------------- RS232 bootstrap - last 256byte cache line ---------------
        org     200h
begin label far               ; this code is placed at F000:BOOTOFFSET

		cli
		cld
		mov		ax, cs        ; cs = 0f000h
		mov		ds, ax
		mov		es, ax
		mov		ss, ax
		mov		sp, BOOTOFFSET
		xor		ax, ax        ; map seg0
		out		80h, ax
		mov		al, 0bh       ; map text segB
		out		8bh, ax
		mov		al, 0fh       ; map ROM segF
		out		8fh, ax
		mov		al, 34h
		out		43h, al
		xor		al, al
		out		40h, al
		out		40h, al       ; program PIT for RS232

		call		sdinit_
		test		ax, ax
		jz		short RS232
		mov		dx, ax
		shr		dx, 6
		shl		ax, 10
		mov		cx, BIOSSIZE       ;  sectors
		sub		ax, cx
		sbb		dx, 0
		xor		bx, bx       ; read BIOSSIZE/2 KB BIOS at 0f000h:0h
nextsect:      
		push		ax
		push		dx
		push		cx
		call		sdread_
		dec		cx
		pop		cx
		pop		dx
		pop		ax
		jnz		short RS232  ; cx was not 1
		add		ax, 1
		adc		dx, 0
		add		bx, 512    
		loop		nextsect
		cmp		word ptr ds:[0], 'eN'
		jne		short RS232             
		cmp		word ptr ds:[2], 'tx'
		je		short   BIOSOK

RS232: 
		mov		dx, 3c0h
		mov		al, 10h
		out		dx, al
		mov		al, 8h
		out		dx, al      ; set text mode
		mov		dx, 3d4h
		mov		al, 0ah
		out		dx, al
		inc		dx
		mov		al, 1 shl 5 ; hide cursor
		out		dx, al
		dec		dx
		mov		al, 0ch
		out		dx, al
		inc		dx
		mov		al, 0
		out		dx, al
		dec		dx
		mov		al, 0dh
		out		dx, al
		inc		dx
		mov		al, 0
		out		dx, al      ; reset video offset
      
		push		0b800h      ; clear screen
		pop		es
		xor		di, di
		mov		cx, 25*80
		xor		ax, ax
		rep		stosw
		
		mov		dx, 3c8h    ; set palette entry 1
		mov		ax, 101h
		out		dx, al
		inc		dx
		mov		al, 2ah
		out		dx, al
		out		dx, al
		out		dx, al
		
		xor		di, di      
		mov		si, booterrmsg + BOOTOFFSET - begin
		lodsb
nextchar:      
		stosw
		lodsb
		test		al, al
		jnz		short nextchar

		mov		bh, 8
flush:        
		mov		al, [bx]
		dec		bh
		jnz		flush
	
		mov		si, 100h
		call		srecb
		mov		bh, ah
		call		srecb
		mov		bl, ah

sloop:	
		call		srecb
		mov		[si], ah
		inc		si
		dec		bx
		jnz		sloop
		xor		sp, sp
		mov		ss, sp
		db		0eah
		dw		100h,0f000h ; execute loaded program
	
BIOSOK:
		mov		si, reloc + BOOTOFFSET - begin
		mov		di, bx
		mov		cx, endreloc - reloc
		rep		movsb       ; relocate code from reloc to endreloc after loaded BIOS
		mov		di, -BIOSSIZE*512
		xor		si, si
		mov		cx, BIOSSIZE*512/2
		jmp		bx
reloc:      
		rep		movsw
		db		0eah
		dw		0, -1       ; CPU reset, execute BIOS
endreloc:
      

; ----------------  serial receive byte 115200 bps --------------
srecb:  
		mov		ah, 80h
		mov		dx, 3dah
		mov		cx, -5aeh ; (half start bit)
srstb:  
		in		al, dx
		shr		al, 2
		jc		srstb

		in		al, 40h ; lo counter
		add		ch, al
		in		al, 40h ; hi counter, ignore
l1:
		call		dlybit
		in		al, dx
		shr		al, 2
		rcr		ah, 1
		jnc		l1
dlybit:
		sub		cx, 0a5bh  ;  (full bit)
dly1:
		in		al, 40h
		cmp		al, ch
		in		al, 40h
		jnz		dly1
		ret

;---------------------  read/write byte ----------------------
sdrb:   
		mov		al, 0ffh
sdsb:               ; in AL=byte, DX = 03dah, out AX=result
		mov		ah, 1
sdsb1:
		out		dx, al
		add		ax, ax
		jnc		sdsb1
		in		ax, dx
		ret

;---------------------  write block ----------------------
sdwblk:              ; in DS:SI=data ptr, DX=03dah, CX=size
		lodsb
		call		sdsb
		loop		sdwblk
		ret

;---------------------  read block ----------------------
sdrblk:              ; in DS:DI=data ptr, DX=03dah, CX=size
		call		sdrb
		mov		[di], ah
		inc		di
		loop		sdrblk
		ret

;---------------------  write command ----------------------
sdcmd8T:
		call	sdrb
sdcmd:              ; in DS:SI=6 bytes cmd buffer, DX=03dah, out AH = 0ffh on error
		mov		cx, 6
		call		sdwblk
sdresp:
		xor		si, si
sdresp1:
		call		sdrb
		inc		si
		jz		sdcmd1
		cmp		ah, 0ffh
		je		sdresp1
sdcmd1: 
		ret         

;---------------------  read one sector ----------------------
sdread_ proc near   ; DX:AX sector, DS:BX buffer, returns CX=read sectors
		push		ax
		mov		al, dl
		push		ax
		mov		dl, 51h     ; CMD17
		push		dx
		mov		si, sp

		mov		dx, 3dah
		mov		ah, 1
		out		dx, ax      ; CS on
		call		sdcmd
		add		sp, 6
		or		ah, ah
		jnz		sdr1        ; error (cx=0)
		call		sdresp      ; wait for 0feh token
		cmp		ah, 0feh
		jne		sdr1        ; read token error (cx=0)
		mov		ch, 2       ; 512 bytes
		mov		di, bx
		call		sdrblk
		call		sdrb        ; ignore CRC
		call		sdrb        ; ignore CRC
		inc		cx          ; 1 block
 sdr1:       
		xor		ax, ax
		out		dx, ax
		call		sdrb        ; 8T
		ret     
sdread_ endp
        
;---------------------  init SD ----------------------
sdinit_ proc near       ; returns AX = num kilosectors
		mov		dx, 3dah
		mov		cx, 10
sdinit1:                   ; send 80T
		call		sdrb
		loop		sdinit1

		mov		ah, 1
		out		dx, ax       ; select SD

		mov		si, SD_CMD0 + BOOTOFFSET - begin
		call		sdcmd
		dec		ah
		jnz		sdexit      ; error
		
		mov		si, SD_CMD8 + BOOTOFFSET - begin
		call		sdcmd8T
		dec		ah
		jnz		sdexit      ; error
		mov		cl, 4
		sub		sp, cx
		mov		di, sp
		call		sdrblk
		pop		ax
		pop		ax
		cmp		ah, 0aah
		jne		sdexit      ; CMD8 error
repinit:        
		mov		si, SD_CMD55 + BOOTOFFSET - begin
		call		sdcmd8T
		call		sdrb
		mov		si, SD_CMD41 + BOOTOFFSET - begin
		call		sdcmd
		dec		ah
		jz		repinit
		
		mov		si, SD_CMD58 + BOOTOFFSET - begin
		call		sdcmd8T
		mov		cl, 4
		sub		sp, cx
		mov		di, sp
		call		sdrblk
		pop		ax
		test		al, 40h     ; test OCR bit 30 (CCS)
		pop		ax
		jz		sdexit      ; no SDHC

		mov		si, SD_CMD9 + BOOTOFFSET - begin ; get size info
		call		sdcmd8T
		or		ah, ah
		jnz		sdexit
		call		sdresp      ; wait for 0feh token
		cmp		ah, 0feh
		jne		sdexit
		mov		cl, 18      ; 16bytes + 2bytes CRC
		sub		sp, cx
		mov		di, sp
		call		sdrblk
		mov		cx, [di-10]
		xchg		cl, ch
		inc		cx
		mov		sp, di
sdexit: 
		xor		ax, ax      ; raise CS
		out		dx, ax
		call	sdrb
		mov		ax, cx       
		ret
sdinit_ endp

    
booterrmsg  db  'BIOS not present on SDCard last 8KB, waiting on RS232 (115200bps, f000:100) ...', 0
SD_CMD0		db		40h, 0, 0, 0, 0, 95h
SD_CMD8		db		48h, 0, 0, 1, 0aah, 087h
SD_CMD9		db		49h, 0, 0, 0, 0, 0ffh
SD_CMD41	db		69h, 40h, 0, 0, 0, 0ffh
SD_CMD55	db		77h, 0, 0, 0, 0, 0ffh
SD_CMD58	db		7ah, 0, 0, 0, 0, 0ffh


; ---------------- RESET ------------------
		org 05f0h
start:
		db		0eah
		dw		BOOTOFFSET, 0f000h
		db		0,0,0,0,0,0,0,0,0,0,0
       
end exec
