	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test interrupt on code in Program Memory Bank 1.
	;; => Bug report "Problem with INT and JMP"
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

test_byte:	equ	020h

	ORG	0

	;; Start of test
	jmp	start

	;; interrupt hits djnz instruction with opcode 0EAh
	;; bus conflict results on interrupt vector address 002h
	;; -> retr instruction placed here, so test finds FAIL
	retr

	ORG	3
	;; interrupt executed
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
	
	

	ORG	0800H
program_memory_bank_1:
	;; spend some time and wait for interrupt
	mov	r2, #020h
	djnz	r2, $

	ret
