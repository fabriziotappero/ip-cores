/* Startup code for SCARTS (32-bit).
 * Copyright (C) 2010, 2011 Embedded Computing Systems Group,
 * Department of Computer Engineering, Vienna University of Technology.
 * Contributed by Martin Walter <mwalter@opencores.org>
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */

	.file	"crt0.S"

.macro CLEAR_REG reg
	ldhi \reg, 0
	ldliu \reg, 0
.endm

.macro CLEAR_MEM_REG addr
	ldli r7, \addr
	CLEAR_REG r13
	stw r13, r7
.endm

.macro STORE_MEM_REG addr
	ldli r7, \addr
	stw r13, r7
.endm

.macro LOAD_SYM_TO_REG reg symbol
	.global \symbol
	ldhi	\reg, 4th(\symbol)
	ldliu	\reg, 3rd(\symbol)
	sli	\reg, 8
	ldliu	\reg, hi(\symbol)
	sli	\reg, 8
	ldliu	\reg, lo(\symbol)
.endm

	.section .text
	.global	_start
	.type start, @function
_start: ; the linker script defines start as the application entry point
	; clear the bss section ('__bss_start' and '_end' are provided through the linker script)
	LOAD_SYM_TO_REG r5 __bss_start	; store symbol '__bss_start' in r5
	LOAD_SYM_TO_REG r6 _end		; store symbol '_end' in r6
	cmp_eq r5, r6			; check if address in r5 equals address in r6 (.bss empty)
	jmpi_ct .bss_clear

	ldli r7, 0			; load value 0 into r7
.bss_clear_loop:
	stw r7, r5			; store value in r7 at address in r5
	addi r5, 4			; increase address in r5 by the word size in bytes
	cmp_lt r5, r6			; check if address in r5 is less than address in r6
	jmpi_ct .bss_clear_loop

.bss_clear:
	; clear hardware registers
	CLEAR_REG r0
	CLEAR_REG r1
	CLEAR_REG r2
	CLEAR_REG r3
	CLEAR_REG r4
	CLEAR_REG r5
	CLEAR_REG r6
	CLEAR_REG r7
	CLEAR_REG r8
	CLEAR_REG r9
	CLEAR_REG r10
	CLEAR_REG r11
	CLEAR_REG r12
	CLEAR_REG r13
	CLEAR_REG r14
	CLEAR_REG r15

	; clear memory-mapped extension module registers
	CLEAR_MEM_REG -24 ; frame pointer W register
	CLEAR_MEM_REG -20 ; frame pointer X register
	CLEAR_MEM_REG -16 ; frame pointer Y register
	CLEAR_MEM_REG -12 ; frame pointer Z register

	; initialize the FP and SP register to the beginning of the stack
	; ('__stack' is provided through the linker script)
	LOAD_SYM_TO_REG r13 __stack	; store symbol '__stack' in r13
	STORE_MEM_REG -16		; frame pointer register Y (FP)
	STORE_MEM_REG -12		; frame pointer register Z (SP)

	; call main
	LOAD_SYM_TO_REG r13 main	; store symbol 'main' in r13
	jsr r13

	; call _exit ('_exit' is provided by the libc and loops indefinitely)
	mov r1, r0			; move return value of 'main' in r0 to argument register r1
	LOAD_SYM_TO_REG r13 _exit	; store symbol ' exit' in r13
	jsr r13
	.size	_start, .-_start
