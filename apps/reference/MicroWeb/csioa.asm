; Copyright (C) 2002 Mason Kidd (mrkidd@nettaxi.com)
;
; This file is part of MicroWeb.
;
; MicroWeb is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; MicroWeb is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with MicroWeb; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

; csio.a51: driver code for CS8900A chip located at 7000h

	.module csioa

	.globl _write_byte
	.globl _read_byte
	.globl _write_word
	.globl _read_wordL
	.globl _read_wordH
	.globl _write_byte_PARM_2
	.globl _write_word_PARM_2

	.area XSEG (XDATA)
_write_byte_PARM_2::
	.ds 2
_write_word_PARM_2::
	.ds 2

csio_port = 0x70

	.area CSEG (CODE)

; write_byte(io_port = R7, data = R5)
_write_byte:
	push	ACC
	mov	A, dpl
	add	A, #csio_port
	mov	DPH, A
	mov	A, R5
	movx	@dptr, a
	pop	ACC
	ret
	
; read_byte(io_port = R7), value returned in R7
_read_byte:
	push	ACC
	mov	A, R7
	add	A, #csio_port
	mov	DPH, A
	movx	a, @dptr
	mov	R7, A
	pop	ACC
	ret
	
; write_word(io_port(8 bits), data(16 bits))
_write_word:
	push	ACC
	mov	A, DPL
	add	A, #csio_port
	mov	R1, A
	mov	dptr, #_write_word_PARM_2
	movx	a, @dptr
	push	acc
	mov	a, r1
	mov	dph, a
	pop	acc
	movx	@dptr, a
	mov	dptr, #_write_word_PARM_2
	inc	dptr
	movx	a, @dptr
	push	acc
	mov	A, R1
	inc	A
	mov	DPH, A
	pop	acc
	movx	@dptr, a
	pop	ACC
	ret
	
; read_wordL(io_port = DPL) return in DPTR
; read the low order byte first(R7)
_read_wordL:
	push	ACC
	mov	A, DPL
	add	A, #csio_port
	mov	R1, A
	mov	DPH, A
	movx	A, @dptr
	push	acc
	mov	A, R1
	inc	A
	mov	DPH, A
	movx	a, @dptr
	mov	dph, A
	pop	dpl
	pop	ACC
	ret
	
; read_wordH(io_port = DPL) return in DPTR
; read the high order byte first(R6)
_read_wordH:
	push	ACC
	mov	A, dpl
	add	A, #csio_port
	mov	R1, A
	inc	A
	mov	DPH, A
	movx	a, @dptr
	push	acc
	mov	A, R1
	mov	DPH, A
	movx	a, @dptr
	mov	dpl, A
	pop	dph
	pop	ACC
	ret
	
;.end

