/* Copyright (C) 1998, 1999, 2000, 2005 Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

This file is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

In addition to the permissions in the GNU General Public License, the
Free Software Foundation gives you unlimited permission to link the
compiled version of this file into combinations with other programs,
and to distribute those combinations without any restriction coming
from the use of this file.  (The General Public License restrictions
do apply in other respects; for example, they cover modification of
the file, and distribution when not linked into a combine
executable.)

This file is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */

	.file	"setjmp.S"

.macro STORE_REG reg
	stw	\reg, r1	; store contents of 'reg' at address in 'r1'
	addi	r1, 4		; advance address in r1 by the size of one register
.endm

.macro STORE_EXTMOD_REG addr
	ldli	r0, \addr	; store address 'addr' of some extension module register in r0
	ldw	r13, r0		; load value of the extension module register into r13
	STORE_REG r13
.endm

.macro RESTORE_REG reg
	ldw	\reg, r1	; load contents at address in r1 to register 'reg'
	addi	r1, 4		; advance address in r1 by the size of one register
.endm

.macro RESTORE_EXTMOD_REG addr
	ldli r0, \addr		; store address 'addr' of some extension module register in r0
	RESTORE_REG r13
	stw r13, r0		; store contents of 'r13' at address in 'r0'
.endm

; int setjmp(jmp_buf env)

	.section	.text
	.global	setjmp
	.type	setjmp, @function
setjmp:
	STORE_REG r0
	STORE_REG r3
	STORE_REG r4
	STORE_REG r5
	STORE_REG r6
	STORE_REG r7
	STORE_REG r8
	STORE_REG r9
	STORE_REG r10
	STORE_REG r11
	STORE_REG r12
	STORE_REG r13
	STORE_REG r14
	STORE_REG r15
	STORE_EXTMOD_REG -24	; frame pointer register W
	STORE_EXTMOD_REG -20	; frame pointer register X
	STORE_EXTMOD_REG -16	; frame pointer register Y (frame pointer)
	STORE_EXTMOD_REG -12	; frame pointer register Z (stack pointer)
	
	addi r1, -32	; reset the address in r1 to 18*(-4)
	addi r1, -32
	addi r1, -8

	ldli r0, 0	; returns 0
	rts		; return

	.size	setjmp, .-setjmp

; int longjmp(jmp_buf env, int val)

	.section .text
	.global	longjmp
	.type	longjmp, @function
longjmp:
	RESTORE_REG r0
	RESTORE_REG r3
	RESTORE_REG r4
	RESTORE_REG r5
	RESTORE_REG r6
	RESTORE_REG r7
	RESTORE_REG r8
	RESTORE_REG r9
	RESTORE_REG r10
	RESTORE_REG r11
	RESTORE_REG r12
	RESTORE_REG r13
	RESTORE_REG r14
	RESTORE_REG r15
	RESTORE_EXTMOD_REG -24	; frame pointer register W
	RESTORE_EXTMOD_REG -20	; frame pointer register X
	RESTORE_EXTMOD_REG -16	; frame pointer register Y (frame pointer)
	RESTORE_EXTMOD_REG -12	; frame pointer register Z (stack pointer)

	addi r1, -32		; reset the address in r1 to 18*(-4)
	addi r1, -32
	addi r1, -8

	cmpi_eq r2, 0		; if argument2 'val' in r2 equals 0
	addi_ct r2, 1		; then set r2 to 1 (must be non-zero)

	mov r0, r2		; returns r2
	rts			; return after setjmp (at restored r14)

	.size	longjmp, .-longjmp

