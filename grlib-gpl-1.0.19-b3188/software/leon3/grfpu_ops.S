/**********************************************************************/
/*  This file is a part of the GRFPU IP core testbench                */
/*  Copyright (C) 2004  Gaisler Research AB                           */
/*  ALL RIGHTS RESERVED                                               */
/*                                                                    */
/**********************************************************************/

/* #include "leon" */
	
	
!  %i0  : operand 1
!  %i1  : operand 1
!  %i2  : result
!  %o0  : 0 - OK, 1 - error	 	

	.text
	.align 4
	.global grfpu_fdivs, grfpu_fdivd, grfpu_sqrtd, grfpu_ttrap
	.global divident, divromtst
	.global grfpu_faddd
	.global grfpu_fmuld		
	.global grfpu_fstoi, grfpu_fdtoi, grfpu_fitos, grfpu_fitod
	.global grfpu_fstod, grfpu_fdtos
	.global grfpu_fnegs, grfpu_fmovs, grfpu_fabss
	.global grfpu_fcmpd, grfpu_fcmped, grfpu_fcmps, grfpu_fcmpes
	.global grfpu_fsubd, grfpu_fadds, grfpu_fsubs, grfpu_fmuls
	.global	grfpu_fdivs, grfpu_fsqrts, initfpreg
	.global grfpc_dpdep_tst, grfpc_spdep_tst, grfpc_spdpdep_tst	
	.global get_tbr, fptrap
	
				
grfpu_faddd:
	ldd	[%o0], %f0
	ldd	[%o1], %f2
	faddd	%f0, %f2, %f4
	retl		
	std	%f4, [%o2]


grfpu_fmuld:
	ldd	[%o0], %f0
	ldd	[%o1], %f2
	fmuld	%f0, %f2, %f4
	retl
	std	%f4, [%o2]		
		
	
grfpu_fdivd:	
	ldd  [%o0], %f0
	ldd  [%o1], %f2
	fdivd %f0, %f2, %f4		
	std  %f4, [%o2]		
	retl 
	nop

grfpu_sqrtd:	
	ldd [%o0], %f0	
	fsqrtd %f0, %f2
	std %f2, [%o1]
	retl
	nop

grfpu_ttrap:	
        nop; nop; nop; nop; nop; nop; nop; nop;
        nop; nop; nop; nop; nop; nop; nop; nop;
        nop; nop; nop; nop; nop; nop; nop; nop;
        nop; nop; nop; nop; nop; nop; nop; nop;
        fmovs %f0, %f0
	retl
	nop
		
divident:	
	ldd  [%o0], %f0		
	retl
	nop					

divromtst:	
	ldd	[%o0], %f2
	fdivd	%f0, %f2, %f4
	std	%f4, [%o1]		
	retl
	nop
			
	
grfpu_fitod:
	set	dw, %o1
	st	%o0, [%o1]
	ld	[%o1], %f0
	fitod	%f0, %f2
	std	%f2, [%o1]
	retl
	ldd	[%o1], %o0

grfpu_fitos:
	set	dw, %o1
	st	%o0, [%o1]
	ld	[%o1], %f0
	fitos	%f0, %f2
	st	%f2, [%o1]
	retl
	ld	[%o1], %o0	

grfpu_fdtoi:	
	set	dw, %o2								
	std	%o0, [%o2]
	ldd	[%o2], %f0
	fdtoi	%f0, %f2
	st	%f2, [%o2]
	retl	
	ld	[%o2], %o0
			
grfpu_fstoi:	
	set	dw, %o2								
	st	%o0, [%o2]
	ld	[%o2], %f0
	fstoi	%f0, %f2
	st	%f2, [%o2]
	retl	
	ld	[%o2], %o0

grfpu_fstod:	
	set	dw, %o2
	st	%o0, [%o2]
	ld	[%o2], %f0
	fstod	%f0, %f0
	std	%f0, [%o2]
	retl
	ldd	[%o2], %o0				

grfpu_fdtos:	
	set	dw, %o2
	std	%o0, [%o2]
	ldd	[%o2], %f0
	fdtos	%f0, %f0
	st	%f0, [%o2]
	retl
	ld	[%o2], %o0							

grfpu_fmovs:
	set	dw, %o2
	st	%o0, [%o2]
	ld	[%o2], %f5
	fmovs	%f5, %f6
	st	%f6, [%o2]
	retl
	ld	[%o2], %o0			


grfpu_fnegs:
	set	dw, %o2
	st	%o0, [%o2]
	ld	[%o2], %f5
	fnegs	%f5, %f6
	st	%f6, [%o2]
	retl
	ld	[%o2], %o0

grfpu_fabss:
	set	dw, %o2
	st	%o0, [%o2]
	ld	[%o2], %f5
	fabss	%f5, %f6
	st	%f6, [%o2]
	retl
	ld	[%o2], %o0				

grfpu_fcmpd:	
	set	dw, %o4
	std	%o0, [%o4]
	std	%o2, [%o4+8]
	ldd	[%o4], %f0
	ldd	[%o4+8], %f2
	fcmpd	%f0, %f2
	nop
	fbe,a	cmpd_end
	mov	0, %o0
	fbl,a	cmpd_end
	mov	1, %o0
	fbg,a	cmpd_end
	mov	2, %o0
	fbu,a	cmpd_end
	mov	3, %o0
	ta	0x0	!error
cmpd_end:
	retl
	nop


grfpu_fcmped:	
	set	dw, %o4
	std	%o0, [%o4]
	std	%o2, [%o4+8]
	ldd	[%o4], %f0
	ldd	[%o4+8], %f2
	fcmped	%f0, %f2
	nop
	fbe,a	cmpd_end
	mov	0, %o0
	fbl,a	cmpd_end
	mov	1, %o0
	fbg,a	cmpd_end
	mov	2, %o0
	fbu,a	cmpd_end
	mov	3, %o0
	ta	0x0	!error
							

grfpu_fcmps:	
	set	dw, %o4
	st	%o0, [%o4]
	st	%o1, [%o4+8]
	ld	[%o4], %f0
	ld	[%o4+8], %f1
	fcmps	%f0, %f1
	nop
	fbe,a	cmpd_end
	mov	0, %o0
	fbl,a	cmpd_end
	mov	1, %o0
	fbg,a	cmpd_end
	mov	2, %o0
	fbu,a	cmpd_end
	mov	3, %o0
	ta	0x0	!error

grfpu_fcmpes:	
	set	dw, %o4
	st	%o0, [%o4]
	st	%o1, [%o4+8]
	ld	[%o4], %f0
	ld	[%o4+8], %f1
	fcmpes	%f0, %f1
	nop
	fbe,a	cmpd_end
	mov	0, %o0
	fbl,a	cmpd_end
	mov	1, %o0
	fbg,a	cmpd_end
	mov	2, %o0
	fbu,a	cmpd_end
	mov	3, %o0
	ta	0x0	!error	
	
grfpu_fsubd:	
	set	dw, %o4
	std	%o0, [%o4]
	std	%o2, [%o4+8]
	ldd	[%o4], %f0
	ldd	[%o4+8], %f2
	fsubd	%f0, %f2, %f4
	std	%f4, [%o4]
	retl
	ldd	[%o4], %o0
	
grfpu_fadds:	
	set	dw, %o4
	st	%o0, [%o4]
	st	%o1, [%o4+8]
	ld	[%o4], %f0
	ld	[%o4+8], %f1
	fadds	%f0, %f1, %f2
	st	%f2, [%o4]
	retl
	ld	[%o4], %o0
	
grfpu_fsubs:	
	set	dw, %o4
	st	%o0, [%o4]
	st	%o1, [%o4+8]
	ld	[%o4], %f0
	ld	[%o4+8], %f1
	fsubs	%f0, %f1, %f2
	st	%f2, [%o4]
	retl
	ld	[%o4], %o0

grfpu_fmuls:	
	set	dw, %o4
	st	%o0, [%o4]
	st	%o1, [%o4+8]
	ld	[%o4], %f0
	ld	[%o4+8], %f1
	fmuls	%f0, %f1, %f2
	st	%f2, [%o4]
	retl
	ld	[%o4], %o0			

grfpu_fdivs:	
	set	dw, %o4
	st	%o0, [%o4]
	st	%o1, [%o4+8]
	ld	[%o4], %f0
	ld	[%o4+8], %f1
	fdivs	%f0, %f1, %f2
	st	%f2, [%o4]
	retl
	ld	[%o4], %o0

grfpu_fsqrts:	
	set	dw, %o4
	st	%o0, [%o4]
	ld	[%o4], %f0
	fsqrts	%f0, %f1
	st	%f1, [%o4]
	retl
	ld	[%o4], %o0				

grfpc_dpdep_tst:	
	set	dpbuf, %o1
	ldd	[%o1+8], %f2
	ldd	[%o1], %f0
	faddd	%f0, %f0, %f4	! 1 + 1 = 2
	fsubd	%f4, %f2, %f8	! 2 - 3 = -1	
	fdivd	%f8, %f4, %f10  ! -1 / 2 = -0.5
	fmuld	%f10, %f2, %f10 ! -0.5 * 3 = -1.5         
        retl
	std	%f10, [%o0]

grfpc_spdep_tst:
	set	spbuf, %o1
	ld	[%o1], %f0
	ld	[%o1+4], %f1
	fadds	%f0, %f0, %f2	! 1 + 1 = 2
	fsubs	%f2, %f1, %f3   ! 2 - 3 = -1
	fdivs	%f3, %f2, %f4	! -1 / 2 = -0.5
	fmuls	%f4, %f1, %f4	! -0.5 * 3 = -1.5
	retl
        st      %f4, [%o0]
	
grfpc_spdpdep_tst:
	set	dpbuf, %o1
	set	spbuf, %o2
	ld	[%o2], %f0
	ldd	[%o1+16], %f2			
	fadds	%f0, %f0, %f1	! 1 + 1 = 2
	fsubd	%f2, %f0, %f4	! 
	fdivs	%f4, %f1, %f5	! 
	fmuld	%f4, %f2, %f6	! 
        fmuls   %f5, %f6, %f7
        fsqrtd  %f6, %f8
	retl
        std     %f8, [%o0]

initfpreg:
        set zbuf, %o0
	ldd [%o0], %f0
	ldd [%o0], %f2
	ldd [%o0], %f4
	ldd [%o0], %f6
	ldd [%o0], %f8
	ldd [%o0], %f10							
	ldd [%o0], %f12
	ldd [%o0], %f14							
	ldd [%o0], %f16
	ldd [%o0], %f18							
	ldd [%o0], %f20
	ldd [%o0], %f22	
	ldd [%o0], %f24	
	ldd [%o0], %f26
	ldd [%o0], %f28
	ldd [%o0], %f30			
        retl 
        nop
	
fptrap:
	set	fsr1, %l4
		
	set	tfsr, %l3	
	st	%fsr, [%l3]
	ld	[%l3], %l3
	srl	%l3, 14, %l0
	and	%l0, 7, %l0
	subcc	%l0, 2, %l0	! %l0 = 0 if unfFPop trap, 1 otherwise
	set	0, %l7		! %l7 = nr of instr. in FQ		
	!be	_skip
	!nop			
	set	grfpufq-8, %l6
1:
	add	%l7, 1, %l7		
	add	%l6, 8, %l6
	std	%fq, [%l6]	
	st	%fsr, [%l4]
	ld	[%l4], %l5
	srl	%l5, 13, %l5
	andcc	%l5, 1, %l5
	bne	1b
	nop
	!std	%fq, [%l3]
	!jmpl	%l2, %g0
	!rett	%l2 + 4
	!subcc	%l0, %g0, %g0
	!be	_skip
	!nop
	
	addcc	%g0, %l0, %g0
	be	_skip		
	set	0xf07fffff, %l5
	and	%l3, %l5, %l3
	st	%l3, [%l4]
	ld	[%l4], %fsr	 ! disable exceptions		
	set	grfpufq+4, %l5
	set	fpreex, %l6
2:	dec	%l7
	ld	[%l5], %l0
	st	%l0, [%l6]
	flush		
	nop; nop; nop; nop; nop;
	nop; nop; nop; nop; nop;	
	nop; nop; nop; nop; nop;
	nop; nop; nop; nop; nop;	
fpreex:	.word 0
	subcc	%l7, %g0, %g0
	bne	2b
	add	%l5, 8, %l5
	st	%fsr, [%l4]
	ld	[%l4], %l3
	set	0x0f000000, %l5
	or	%l3, %l5, %l3
	st	%l3, [%l4]
	ld	[%l4], %fsr	! enable exceptions
	jmpl	%l1, %g0
	rett	%l2		
	nop
_skip:
	jmpl	%l2, %g0
	rett	%l2 + 4 
	nop
	nop	
	
get_tbr:	
	retl
	mov %tbr, %o0				
		
	.data
	.align 8
	.global tfsr, grfpufq
dw:	.word 0
	.word 0				
	.word 0
	.word 0
	
zbuf:	.word 0
	.word 0		

dpbuf:	.word 0x3ff00000 
        .word 0x00000000
	.word 0x40080000 
	.word 0x00000000
	.word 0x3ff00000 
	.word 0x40000000
	.word 0x0        
	.word 0x0
spbuf:	.word 0x3f800000
	.word 0x40400000
	.word 0x0
	.word 0x0

tfsr:	.word 0
	.word 0
grfpufq:
	.word 0
	.word 0
	.word 0
	.word 0

