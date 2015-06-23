	.text
	.global get_asr17

get_asr17:
	retl
	mov	%asr17, %o0


	.text
	.global mulscc_test, mulscctmp
mulscc_test:
	addcc %g0, %g0, %g0
	set   mulscctmp, %o2
	mov   0, %o0			
	mov   0x246, %o1	
	mov	%g0, %y
	nop; nop; nop
	ld    [%o2], %o0
	mulscc %o1, %o0, %o0
	retl
	nop

	.text
	.global mulpipe
mulpipe:
	mov	%g0, %y
	set	1, %o0
	orcc	%g0, 1, %g0	! clear icc
	umulcc	%g0, 1, %g0	! set Z
	bne	1f
	nop
	umulcc	%o0, -1, %g0	! set N
	bge	1f
	nop
	smulcc	%o0, -1, %g0	! set N and Y
	mov	%y, %o1
	subcc	%o1, -1, %g0
	bne	1f
	nop
	umulcc	%o0, -1, %g0	! set N
	mov	%psr, %o1
	srl	%o1, 20, %o1
	and	%o1, 0x0f, %o1
	subcc	%o1, 8, %g0
	bne	1f
	nop

	mov	%g0, %y
	set	1, %o0
	umul	%o0, 4, %o2
	umul	%o2, 4, %o2
	umul	%o2, 4, %o2
	subcc	%o2, 64, %o3
	bne	1f
	nop

	retl
	or	%g0, 1, %o0

1:
	retl
	mov	%g0, %o0

	.text
	.global macpipe
macpipe:
	set 	0x55555555, %o1		! test %asr18
	mov	%o1, %asr18
	nop; nop; nop
	mov	%asr18, %o2
	subcc	%o1, %o2, %g0
	bne	1f
	nop
	not	%o1
	mov	%o1, %asr18
	nop; nop; nop
	mov	%asr18, %o2
	subcc	%o1, %o2, %g0
	bne	1f
	nop

	set	0xffff, %o0
	mov	%g0, %asr18
	mov	%g0, %y
	nop; nop; nop
	umac	%o0, -1, %o1
	mov	%o1, %o5
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	umac	%o0, -1, %o1
	mov	%y, %o4
	mov	%asr18, %o3
	set	0xfff00008, %o2
	subcc	%o1, %o2, %g0
	bne	1f
	subcc	%o1, %o3, %g0
	bne	1f
	subcc	%o4, 0x07, %g0
	bne	1f
	set	0xfffe0001, %o0
	subcc	%o5, %o0, %g0
	bne	1f

	set	0xffff, %o0
	mov	%g0, %asr18
	mov	%g0, %y
	nop; nop; nop
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	smac	%o0, -1, %o1
	mov	%y, %o4
	mov	%asr18, %o3
	subcc	%o1, 8, %g0
	bne	1f
	subcc	%o1, 8, %g0
	bne	1f
	subcc	%o4, 0, %g0
	bne	1f
	nop
	
	retl
	or	%g0, 1, %o0

1:
	retl
	mov	%g0, %o0
