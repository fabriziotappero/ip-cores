	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test interrupt on CALL in Program Memory Bank 1.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

test_byte:	equ	020h

	ORG	0

	;; Start of test
	jmp	start

	ORG	3
	;; check that interrupt hit CALL instruction
	;; stack must contain target of CALL instruction at
	;; location call_instruction
	mov	r0, #00ch
	mov	a, @r0
	;; check low byte of program counter on stack
	xrl	a, #000h
	jnz	fail
	inc	r0
	mov	a, @r0
	anl	a, #00fh
	;; check high byte of program counter on stack
	mov	r0, a
	xrl	a, #009h	; target of PASS case?
	jz	int_goon
	mov	a, r0
	xrl	a, #001h	; target of FAIL case?
	jnz	fail

int_goon:
	;; interrupt hit correct instruction
	mov	r0, #test_byte
	mov	a, #0ffh
	mov	@r0, a
	retr

start:
	;; enable interrupt
	en	i

	;; clear test byte
	mov	r1, #test_byte
	clr	a
	mov	@r1, a

	call	program_memory_bank_1
	sel	mb0

	;; check if interrupt was successful
	mov	a, @r1
	jz	fail


pass:	PASS

fail:	FAIL
	
	
	ORG	0100H
	;; program flow continues in fail case at address 0100h
	;; after interrupt
	;; i.e. bit 11 of address is erroneously cleared.

	;; make sure that jump to fail reaches memory bank 0
	sel	mb0
	jmp	fail


	ORG	0800H
program_memory_bank_1:
	;; spend some time and wait for interrupt
	mov	r2, #013h
	djnz	r2, $

call_instruction:
	;; interrupt must hit this CALL (checked by examining stack
	;; in interrupt handler)
	call	test_call
	ret

	ORG	0900H
test_call:
	;; program flow continues in pass case here after interrupt
	ret
