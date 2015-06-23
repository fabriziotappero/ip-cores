
	.text
	.align 4
	.global _regtest, regtest
	.proc	04

_regtest:
regtest:


#ifndef _FLAT
	save %sp, -96, %sp
#endif

# do jmp/jmpl pipeline tests

	set  0, %o2
	set  b1, %o0
	set  b1+4, %o1
	set  b2, %o3
	set  b2+4, %o4

	jmpl  %o0, %o1
	jmp  %o1
	ba   err1
b1:
	jmp  %o3
	jmp  %o4
	ba   err1
b2:
	add %o2, 1, %o2
	add %o2, 1, %o2
	subcc %o2, 3, %g0
	bne err1
	nop

#ifdef LEON2
	set	0x80000024, %l2
	ld	[%l2], %l2
	srl	%l2, 20, %g5
	and	%g5, 0x1f, %g5
	ba 2f
	mov	%g5, %g6
#else
!	ba 1f
	
	
!	mov %g0, %asr16
!	nop; nop; nop
	mov %asr16, %g3
	srl %g3, 14, %g6
	andcc %g6, 7, %g6
	subcc %g6, 0, %g0
	be 1f			! no FT
	nop
	srl %g3, 11, %l7
	and %l7, 0x7, %l7
	subcc %l7, 0, %g0	! error counter should be 0
	bne 1f
	nop
	subcc %g6, 2, %g0
	bne ft1			! only test if IUFT = 2
	nop

	set 0x40000000, %l2
	ldd [%l2], %l2		! pre-load dcache
	set 0x40000000, %l2
	set 0x40000104, %l4
	mov %l2, %l3
	mov %l2, %l5
	mov %l4, %l6
	mov 0x46, %asr16	! single bit error in byte 0
	mov %g0, %l2
	mov %g0, %l5
	nop; 
	mov 0x4E, %asr16	! double bit error in byte 0 & 3
	mov 0x100, %l4
	nop; 
	mov %g0, %asr16		! test mode off
	nop; nop; 
	
	std %l4, [%l2+0x30]

	subcc %l2, %l3, %g1	! %l3 should be 0 (corrected)
	bne err1
	subcc %l4, %l6, %g1	! %l6 should be 0 (corrected)
	bne err1
	nop
	nop; nop		! wait until error counters are updated
	mov %asr16, %g3
	srl %g3, 11, %g6
	andcc %g6, 0x7, %g6
	subcc %g6, 5, %g6
	bne err1		! error counter should be 4
	mov %g0, %asr16		! test mode off
	nop; nop; nop
	ldd [%l2+0x30], %l4
	subcc %l4, %l6, %g1	! %l3 should be 0 (corrected)
	bne err1
	subcc %l5, %l2, %g1	! %l6 should be 0 (corrected)
	mov %g0, %l2		! clear remaining error
	bne err1
	nop; nop		! wait until error counters are updated
	mov %asr16, %g3
	srl %g3, 11, %g6
	andcc %g6, 0x7, %g6
	subcc %g6, 3, %g6
	bne err1		! error counter should be 4
	nop


	ba 1f
	nop

ft1:
	subcc %g6, 1, %g0
	bne ft3			! only test if IUFT = 1

	set 0x40000000, %l2
	ldd [%l2], %l2		! pre-load dcache
	set 0x40000000, %l2
	set 0x40000104, %l4
	mov %l2, %l3
	mov %l2, %l5
	mov %l4, %l6
	mov 0x46, %asr16	! single bit error in byte 0
	mov %g0, %l2
	mov %g0, %l5
	nop; 
	mov 0x4E, %asr16	! double bit error in byte 0 & 3
	mov 0x100, %l4
	nop; 
	mov %g0, %asr16		! test mode off
	nop; nop; nop

	std %l4, [%l2]

	subcc %l2, %l3, %g1	! %l3 should be 0 (corrected)
	bne err1
	subcc %l4, %l6, %g1	! %l6 should be 0 (corrected)
	bne err1
	nop; nop		! wait until error counters are updated
	mov %asr16, %g3
	srl %g3, 11, %g6
	andcc %g6, 0x7, %g6
	subcc %g6, 2, %g6
	bne err1		! error counter should be 2
	nop
	ba 1f
	nop


ft3:
	subcc %g6, 3, %g0
	bne 1f			! only test if IUFT = 3
	mov %g0, %l3
	set 0xe, %l1		! test mode enable, xor lsb of check bits
	mov %l1, %asr16		! regfile EDAC test mode enable
	mov %g0, %l3
	mov %g0, %asr16	
	or %l3, 0, %l4
	mov %asr16, %l5
	nop
	or %l3, 0, %l6
	nop
	mov %asr16, %l7
	subcc %l4, 0, %g0	! %l4 should be zero
	bne err1
	andcc %l5, 0xe00, %l5	! data-forwarding should not trigger EDAC error
	subcc %l5, %g0, %g0	
	bne err1
	subcc %l6, 0, %g0	! %l6 should be 0 (corrected)
	bne err1
	srl %l7, 11, %l7
	and %l7, 0x7, %l7
	subcc %l7, 1, %g0	! error counter should be incremented
	bne err1
	nop

	mov %g0, %l0		! correctable EDAC error in LD
	mov %l1, %asr16		
	mov %g0, %l3	
	mov %g0, %asr16	
	ldd [%g0], %l4
	mov %g0, %l6
	mov %g0, %l7
	ld [%l3], %l6
	ld [%l3 + 4], %l7
	cmp %l4, %l6
	bne err1
	cmp %l5, %l7
	bne err1
	nop
	mov %asr16, %l2
	srl %l2, 11, %l2
	and %l2, 0x7, %l2
	subcc %l2, 1, %g0	! error counter should be incremented
	bne err1
	nop

	mov %g0, %l0		! 2 correctable EDAC errors in LD
	mov %l1, %asr16		
	mov %g0, %l3	
	mov %g0, %asr16	
	set 0xa, %l1		! test mode enable, xor lsb of check bits
	mov %l1, %asr16		
	mov %g0, %l2	
	mov %g0, %asr16	
	ldd [%g0], %l4
	mov %g0, %l6
	mov %g0, %l7
	ld [%l3 + %l2], %l6
	ld [%l3 + 4], %l7
	cmp %l4, %l6
	bne err1
	cmp %l5, %l7
	bne err1
	nop
	mov %asr16, %l2
	srl %l2, 11, %l2
	and %l2, 0x7, %l2
	subcc %l2, 2, %g0	! error counter should be incremented
	bl err1
	nop

!	set 0x40000000, %l0		! 4 correctable EDAC errors in STD
	set ftbuf, %l0		! 4 correctable EDAC errors in STD
	ldd [%l0], %l6
!	set 0x41000000, %l0
	add %l0, 8, %l0
	ldd [%l0], %l4
	mov %l1, %asr16		
	mov %g0, %l3	
	mov %g0, %asr16	
	set 0xe, %l1		! test mode enable, xor lsb of check bits
	mov %l1, %asr16		
	mov %l0, %l2	
	mov %g0, %l6	
	mov %g0, %l7	
	mov %g0, %asr16	
	nop; nop
	std %l6, [%l2 + %l3]
	mov %g0, %l6
	mov %g0, %l7
	ldd [%l3 + %l2], %l4
	cmp %l4, %l6
	bne err1
	cmp %l5, %l7
	bne err1
	nop
	mov %asr16, %l2
	srl %l2, 11, %l2
	and %l2, 0x7, %l2
	subcc %l2, 4, %g0	! error counter should be incremented
	bne err1
	nop
	ba 1f
	nop

	! flush all register windows (maximum 32)
1:
	mov 	%asr17, %g5
	and	%g5, 0x1f, %g5
	subcc	%g5, 1, %g0
	be 	4f
	mov	%g5, %g6
#endif
2:
	save %sp, -96, %sp
	subcc	%g5, 1, %g5
	bge	2b
	nop
3:
	restore
	subcc	%g6, 1, %g6
	bge	3b
	nop

	! save global and input registers
4:
	nop; nop
	sub	%sp, 128, %l0
	andn	%l0, 0x7, %l0
	mov	%l0, %g7
	mov	%psr, %l1
	st	%l1, [%l0]
	st	%g1, [%l0+4]
	std	%g2, [%l0+8]
	std	%g4, [%l0+16]
	std	%g6, [%l0+24]
	std	%i0, [%l0+32]
	std	%i2, [%l0+40]
	std	%i4, [%l0+48]
	std	%i6, [%l0+56]
	std	%o0, [%l0+64]
	std	%o2, [%l0+72]
	std	%o4, [%l0+80]
	std	%o6, [%l0+88]
	mov	%wim, %l2
	st	%l2, [%l0+96]

	! test gloabal registers

	mov	8, %g0
	mov	1, %g1
	mov	2, %g2
	mov	3, %g3
	mov	4, %g4
	mov	5, %g5
	mov	6, %g6
!	mov	7, %g7
	mov	%g0, %wim
	andn	%l1, 0x1f, %l2
	mov	%l2, %psr
	nop; nop; nop
	
	! fill all registers
	set	0x01010101, %g1
	mov	%g0, %g2
	mov	%g0, %g3
#ifdef LEON2
	set	0x80000024, %g4
	ld	[%g4], %g4
	srl	%g4, 20, %g4
	and	%g4, 0x1f, %g4
#else
	mov 	%asr17, %g4
	and	%g4, 0x1f, %g4
#endif
	mov	%g4, %g3
4:
	mov	%g2, %l0
	add	%g1, %g2, %g2
	mov	%g2, %l1
	add	%g1, %g2, %g2
	mov	%g2, %l2
	add	%g1, %g2, %g2
	mov	%g2, %l3
	add	%g1, %g2, %g2
	mov	%g2, %l4
	add	%g1, %g2, %g2
	mov	%g2, %l5
	add	%g1, %g2, %g2
	mov	%g2, %l6
	add	%g1, %g2, %g2
	mov	%g2, %l7
	add	%g1, %g2, %g2
	mov	%g2, %o0
	add	%g1, %g2, %g2
	mov	%g2, %o1
	add	%g1, %g2, %g2
	mov	%g2, %o2
	add	%g1, %g2, %g2
	mov	%g2, %o3
	add	%g1, %g2, %g2
	mov	%g2, %o4
	add	%g1, %g2, %g2
	mov	%g2, %o5
	add	%g1, %g2, %g2
	mov	%g2, %o6
	add	%g1, %g2, %g2
	mov	%g2, %o7
	add	%g1, %g2, %g2
	save
	subcc	%g3, 1, %g3
	bge	4b
	nop
	
	! check values

	set	0x01010101, %g1
	mov	%g0, %g2
	mov	%g4, %g3
5:
	cmp	%l0, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l1, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l2, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l3, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l4, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l5, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l6, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%l7, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o0, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o1, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o2, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o3, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o4, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o5, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o6, %g2
	bne	fail
	add	%g1, %g2, %g2
	cmp	%o7, %g2
	bne	fail
	add	%g1, %g2, %g2
	
	save
	subcc	%g3, 1, %g3
	bge	5b
	nop
	


	subcc	%g0, 0, %g0
	bne	fail
	subcc	%g3, -1, %g0
	bne	fail
	subcc	%g5, 5, %g0
	bne	fail
	subcc	%g6, 6, %g0
	bne	fail
!	subcc	%g7, 7, %g0
!	bne	fail
	nop

testok:
	mov	%g7, %l0
	ba	exit
	st	%g0, [%l0+32]
fail:
	mov	%g7, %l0
	mov	1, %o0
	ba	exit
	st	%o0, [%l0+32]

exit:

	! restore state

	mov	%g7, %g1
	ld	[%g1], %g2
	mov	%g2, %psr
	nop; nop; nop
	ldd	[%g1+8], %g2
	ldd	[%g1+16], %g4
	ldd	[%g1+24], %g6
	ldd	[%g1+32], %i0
	ldd	[%g1+40], %i2
	ldd	[%g1+48], %i4
	ldd	[%g1+56], %i6

	ldd	[%g1+64], %o0
	ldd	[%g1+72], %o2
	ldd	[%g1+80], %o4
	ldd	[%g1+88], %o6

	ld	[%g1+96], %l2
	ld	[%g1+4], %g1
	mov	%l2, %wim
	nop; nop; nop

last:

	mov	%g7, %l0
#ifndef _FLAT
	ld	[%l0+32], %i0
	ret
	restore
#else
	retl
	ld	[%l0+32], %o0
#endif

err1:
	ba last
	mov %g0, %i0

	.align 8
!.common   regbuf, 168,"bss"
	.data   
ftbuf:
	.word 0
	.word 1
	.word 2
	.word 3

.align 32
	.text
