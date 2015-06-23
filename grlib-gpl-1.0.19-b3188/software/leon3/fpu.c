#include "leon3.h"
#include "testmod.h" 
//#include <math.h> 

int __errno;
fputest()
{
	int tmp;

	tmp = xgetpsr();
	setpsr(tmp | (1 << 12));
	tmp = xgetpsr();
	if (!(tmp & (1 <<12))) return(0);
	set_fsr(0);

	report_subtest(FPU_TEST+(get_pid()<<4));

	fpu_main();

}

asm(

"	.global a1, a2\n"
"	.align 8\n"
"a1:	.word 0x48000001\n"
"	.word 0\n"
"b1:	.word 0x48000000\n"
"	.word 0\n"
"c1:	.word 0x46c00000\n"
"	.word 0\n"
"c2:    .word 0x3ff00000\n"
"       .word 0 \n"
"       .word 0x40000000\n"
"       .word 0 \n"
"       .word 0x40080000\n"
"       .word 0 \n"
"       .word 0x3f800000\n"
	);

asm(
"	.global       \n"
"	.text         \n"
"	.align 4      \n"
"	              \n"
"fpu_chkft:           \n"
"       set     1, %o0                 \n"
"       mov     %asr16, %o2            \n"
"       srl     %o2, 30, %o2           \n"
"       and     %o2, 3, %o2                  ! %o2 = fpft \n"
"       cmp     %o2, %g0               \n"
"       beq     1f                     \n"
"       mov     0, %o0                 \n"
"       cmp     %o2, 3                 \n"
"       beq     1f                     \n"
" 	set	c2, %o1                \n"      
"	ldd	[%o1], %f0             \n"
"	ldd	[%o1 + 8], %f2         \n"
"       ld      [%o1 + 0x18], %f30           ! f30 = 1.0 \n"   
"       fmovs   %f30, %f10             \n"
"       fmovs   %f30, %f12             \n"
"       fmovs   %f30, %f14             \n"
"	set	0x03007a, %o3                ! 4-bit error DP ram 0 \n"
"	mov	%o3, %asr16            \n"
"	nop; nop; nop; nop; nop; nop;  \n"
"	fmovs   %f0, %f0               \n"
"	fmovs   %f1, %f1               \n"
"	fmovs   %f10, %f10             \n"
"       fmovs   %f12, %f12             \n"
"       fmovs   %f14, %f14             \n"
"	set	0x03007e, %o3                ! 4-bit error DP ram 1 \n"
"	mov	%o3, %asr16            \n"
"	nop; nop; nop; nop; nop; nop;  \n"
"       fmovs   %f2, %f2               \n"
"       fmovs   %f3, %f3               \n"
"	mov     %g0, %asr16            \n"
"	nop; nop; nop; nop; nop; nop;  \n"
"       faddd   %f0, %f2, %f4                ! should correct 4 errors \n"
"       fadds   %f10, %f30, %f20             ! should correct 1 error  \n"
"       std     %f12, [%o1]                  ! should correct 1 error  \n"
"       st      %f14, [%o1]                  ! should correct 1 error  \n"
"       ldd     [%o1 + 0x10], %f6            ! %f6 = 2.0 (DP) \n"
"       ld      [%o1 + 0x8], %f8             ! %f8 = 2.0 (SP) \n"
"       fcmpd   %f4, %f6               \n"
"       nop                            \n"
"       fbne    1f                     \n"
"       fcmps    %f20, %f8             \n"
"       nop                            \n"
"       fbne    1f                     \n"
"       mov     %asr16, %o1            \n"
"       srl     %o1, 27, %o1           \n"
"       and     %o1, 7, %o1                 ! error counter \n"
"       mov     0, %o0                 \n"
"       cmp     %o2, 1                 \n"
"       beq     1f                     \n"
"       sub     %o1, 7, %o0                 ! should be 7 for fpft = 1 \n" 
"       sub     %o1, 4, %o0                 ! should be 4 for fpft = 2 \n" 
"1:     retl                            \n"
"       nop                             \n" 
); 					
	

fpu_main()
{
	volatile double a, c, d;
	double e;
	extern volatile double a1,b1,c1;
	float b;
	int tmp;

	d = 3.0;
	e = d;
	a = *(double *)&a1 - *(double *)&b1;
	if (a != c1) fail(1);
	a = sqrt(e);
	if (fabs((a * a) - d) > 1E-15) fail(2);
	b = sqrt(e);
	if (fabs((b * b) - d) > 1E-7) fail(3);
	tmp = fpu_pipe();
	if (tmp) fail(tmp);
	tmp = fpu_chkft();
	if (tmp) fail(5);
//	if (((get_asr17() >> 10) & 0x3C0003) == 1) grfpu_test();
}

float f1x = -1.0;
int fsr1[4] = { 0x80000000, 0 , 0, 0 };
int ftest[2] = { 0x48000000, 0x48100000 };

fpu_pipe()
{
	asm(

"	set	fsr1, %o0	! check ldfsr/stfsr interlock\n"
"	ld	[%o0], %fsr\n"
"	st	%g0, [%o0]\n"
"	ld	[%o0], %fsr\n"
"	st	%fsr, [%o0]\n"
"	ld	[%o0], %o2\n"
"	set	0x000E0000, %o1\n"
"	andn	%o2, %o1, %o2\n"
"	subcc	%g0, %o2, %g0\n"
"	bne,a	1f\n"
"	mov	3, %o0\n"
"\n"
"	set 0x0f800000, %o1	! check ldfsr/fpop interlock\n"
"	st	%o1, [%sp-96]\n"
"	st	%g0, [%sp-92]\n"
"	ld	[%sp-96], %fsr\n"
"	st	%g0, [%sp-96]\n"
"	set	f1x, %o2\n"
"	ld	[%o2], %f0\n"
"	nop; nop\n"
"	ld	[%sp-96], %fsr\n"
"	ld	[%sp-92], %fsr\n"
"	fsqrts	%f0, %f1\n"
"	st	%fsr, [%sp-96]\n"
"	ld	[%sp-96], %o0\n"
"	andcc	%o0, 0x200, %g0\n"
"	be,a	1f\n"
"	mov	4, %o0\n"
"\n"
"\n"
"	mov	0, %o0\n"
"\n"
"1:\n"
"	mov	%o0, %i0\n"
"	nop\n"
"	set ftest, %o2\n"
"	ld [%o2], %f8\n"
"	set f1x, %o1\n"
"	ld [%o1], %f3\n"
"	faddd %f2, %f4, %f2\n"
"	fcmps %f2, %f8\n"
"	nop\n"
"	fbe 3f\n"
"	nop\n"
"	set 1, %i0\n"
"3:\n"
"	ld [%o2+4], %f8\n"
"	ld [%o1], %f5\n"
"	faddd %f2, %f4, %f4\n"
"	fcmps %f4, %f8\n"
"	nop\n"
"	fbe 4f\n"
"	nop\n"
"	set 1, %i0\n"
"	nop\n"
"4:\n"

);
}

asm (
"	.global set_fsr, get_fsr\n"
"get_fsr: \n"
"	st	%fsr, [%sp-96]\n"
"	retl\n"
"	ld	[%sp-96], %o0\n"
"set_fsr: \n"
"	st	%o0, [%sp-96]\n"
"	retl\n"
"	ld	[%sp-96], %fsr\n"
);

