	;; *******************************************************************
	;; $Id: test.asm 295 2009-04-01 19:32:48Z arniml $
	;;
	;; Test overlap of PSEN and RD/WR.
	;; *******************************************************************

	INCLUDE	"cpu.inc"
	INCLUDE	"pass_fail.inc"

	ORG	0

	;; Start of test

	;; access external memory
	mov	r0, #0FFH
	mov	a, #001H
	movx	@r0, a

	;; jump to external Program Memory
	jmp	extern_rom

pass:	PASS

fail:	FAIL


	ORG	0800H
extern_rom:
	;; write to external memory
	mov	r0, #010H
	mov	a, #0A5H
	movx	@r0, a
	cpl	a
	mov	r1, a
	inc	r0
	movx	@r0, a

	;; read back data
	movx	a, @r0
	cpl	a
	add	a, r1
	cpl	a
	jz	read_next
	jmp	fail

read_next:
	mov	a, r1
	cpl	a
	mov	r1, a
	dec	r0
	movx	a, @r0
	cpl	a
	add	a, r1
	cpl	a
	jz	read_ok
	jmp	fail

read_ok:
	jmp	pass
