/* Copyright (C) 1998, 1999, 2000, 2005 Free Software Foundation, Inc.
   Contributed by Wolfgang Puffitsch <hausen@gmx.at>

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

	.file	"libgcc.S"

/* Most of the functions here are called directly from scarts.md
   patterns, instead of using the standard libcall mechanisms.
   This can make better code because GCC knows exactly which
   of the call-used registers (not all of them) are clobbered.  */

/*******************************************************
		Multiplication  32 x 32
*******************************************************/
#ifdef L_mulsi3

	.section	.text
	.global	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	ldli r0, 0		; clear result
__mulsi3_loop:
	btest r2, 0
	add_ct r0, r1
	sli r1, 1
	sri r2, 1
	cmpi_eq r2, 0
	jmpi_cf __mulsi3_loop
	rts
	.size   __mulsi3, .-__mulsi3

#endif

/*******************************************************
		Multiplication  64 x 64
*******************************************************/
#ifdef L_muldi3

	.section	.text
	.global	__muldi3
	.type	__muldi3, @function
__muldi3:
	ldfpz r4,0
	ldfpz r5,1

	mov r0,r1

	ldli r6, 0
	ldli r7, 0

__muldi3_loop:
	btest r2, 0
	add_ct r6, r4
	addc_ct r7, r5

	sli r4, 1
	addc r5, r5
	sri r3, 1
	rrc r2

	cmpi_eq r2, 0
	jmpi_cf __muldi3_loop
	cmpi_eq r3, 0
	jmpi_cf __muldi3_loop

	mov r13,r0
	stw r6,r13
	addi r13,4
	stw r7,r13

	rts
	.size   __muldi3, .-__muldi3

#endif

/*******************************************************
		Division 32 x 32
*******************************************************/
#ifdef L_divsi3

	.section	.text
	.global	__divsi3
	.type	__divsi3, @function
__divsi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __divsi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __divsi3_end

__divsi3_cmpsign:
	mov r3, r1		; compute the sign of the result
	eor r3, r2

	cmpi_lt r1, 0		; make positive
	neg_ct r1

	cmpi_lt r2, 0		; make positive
	neg_ct r2

__divsi3_copy:
	mov r13, r2		; make a copy of the divisor

__divsi3_scale:
	btest r2, 31		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __divsi3_scale

	ldli r0, 0		; clear result

__divsi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __divsi3_resign

	sli r0, 1

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	addi_cf r0, 1
	sri r2, 1

	jmpi __divsi3_loop

__divsi3_resign:		; add sign again
	cmpi_lt r3, 0
	neg_ct r0

__divsi3_end:
	rts
	.size   __divsi3, .-__divsi3

#endif

/*******************************************************
		Division 64 x 64
*******************************************************/
#ifdef L_divdi3

	.section	.text
	.global	__divdi3
	.type	__divdi3, @function
__divdi3:
	stfpz_dec r1,-1
	ldfpz r4,1
	ldfpz r5,2

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __divdi3_start
	cmpi_eq r5, 0
	jmpi_ct __divdi3_end
	
__divdi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __divdi3_cmpsign
	cmpi_eq r3, 0
	mov_ct r0, r2
	mov_ct r1, r3
	jmpi_ct __divdi3_end

__divdi3_cmpsign:
	mov r8, r3
	eor r8, r5

	ldli r13, 0		; we use that for incrementing

	cmpi_lt r3, 0		; make positive
	not_ct r2
	not_ct r3
	addi_ct r2, 1
	addc_ct r3, r13

	cmpi_lt r5, 0		; make positive
	not_ct r4
	not_ct r5
	addi_ct r4, 1
	addc_ct r5, r13

__divdi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__divdi3_scale:
	btest r5, 31		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __divdi3_scale

	ldli r0, 0		; clear result
	ldli r1, 0

__divdi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __divdi3_resign
	cmpu_gt r5, r7
	jmpi_ct __divdi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __divdi3_resign

__divdi3_noteq:
	sli r0, 1
	addc r1, r1

	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __divdi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __divdi3_sub
	cmpu_gt r4, r2
	jmpi_ct __divdi3_nosub
__divdi3_sub:
	sub r2, r4
	subc r3, r5
	addi r0, 1
	addc r1, r13
__divdi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __divdi3_loop

__divdi3_resign:
	cmpi_lt r8, 0		; add sign again
	not_ct r0
	not_ct r1
	addi_ct r0, 1
	addc_ct r1, r13

__divdi3_end:
	ldfpz r13, 0

	stw r0, r13
	addi r13, 4
	stw r1, r13

	ldfpz_inc r0, 0

	rts
	.size   __divdi3, .-__divdi3

#endif

/*******************************************************
		Unsigned Division 32 x 32
*******************************************************/
#ifdef L_udivsi3

	.section	.text
	.global	__udivsi3
	.type	__udivsi3, @function
__udivsi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __udivsi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __udivsi3_end

__udivsi3_copy:
	mov r13, r2		; make a copy of the divisor

__udivsi3_scale:
	btest r2, 31		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __udivsi3_scale

	ldli r0, 0		; clear result

__udivsi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __udivsi3_end

	sli r0, 1

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	addi_cf r0, 1
	sri r2, 1

	jmpi __udivsi3_loop

__udivsi3_end:
	rts
	.size   __udivsi3, .-__udivsi3

#endif

/*******************************************************
		Unsigned Division 64 x 64
*******************************************************/
#ifdef L_udivdi3

	.section	.text
	.global	__udivdi3
	.type	__udivdi3, @function
__udivdi3:
	stfpz_dec r1,-1
	ldfpz r4,1
	ldfpz r5,2

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __udivdi3_start
	cmpi_eq r5, 0
	jmpi_ct __udivdi3_end

__udivdi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __udivdi3_copy
	cmpi_eq r3, 0
	mov_ct r0, r2
	mov_ct r1, r3
	jmpi_ct __udivdi3_end

__udivdi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__udivdi3_scale:
	btest r5, 31		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __udivdi3_scale

	ldli r0, 0		; clear result
	ldli r1, 0

	ldli r13, 0		; we use that for incrementing

__udivdi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __udivdi3_end
	cmpu_gt r5, r7
	jmpi_ct __udivdi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __udivdi3_end

__udivdi3_noteq:
	sli r0, 1
	addc r1, r1

	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __udivdi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __udivdi3_sub
	cmpu_gt r4, r2
	jmpi_ct __udivdi3_nosub
__udivdi3_sub:
	sub r2, r4
	subc r3, r5
	addi r0, 1
	addc r1, r13
__udivdi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __udivdi3_loop

__udivdi3_end:
	ldfpz r13, 0

	stw r0, r13
	addi r13, 4
	stw r1, r13

	ldfpz_inc r0, 0

	rts
	.size   __udivdi3, .-__udivdi3

#endif

/*******************************************************
		Modulo 32 x 32
*******************************************************/
#ifdef L_modsi3

	.section	.text
	.global	__modsi3
	.type	__modsi3, @function
__modsi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __modsi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __modsi3_end

__modsi3_cmpsign:
	mov r3, r1		; compute the sign of the result

	cmpi_lt r1, 0		; make positive
	neg_ct r1

	cmpi_lt r2, 0		; make positive
	neg_ct r2

__modsi3_copy:
	mov r13, r2		; make a copy of the divisor

__modsi3_scale:
	btest r2, 31		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __modsi3_scale

__modsi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __modsi3_resign

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	sri r2, 1

	jmpi __modsi3_loop

__modsi3_resign:		; add sign again
	mov r0, r1
	cmpi_lt r3, 0
	neg_ct r0

__modsi3_end:
	rts
	.size   __modsi3, .-__modsi3

#endif

/*******************************************************
		Modulo 64 x 64
*******************************************************/
#ifdef L_moddi3

	.section	.text
	.global	__moddi3
	.type	__moddi3, @function
__moddi3:
	ldfpz r4,0
	ldfpz r5,1

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __moddi3_start
	cmpi_eq r5, 0
	jmpi_ct __moddi3_end

__moddi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __moddi3_cmpsign
	cmpi_eq r3, 0
	jmpi_ct __moddi3_end

__moddi3_cmpsign:
	mov r0, r3		; compute the sign of result

	ldli r13, 0		; we use that for incrementing

	cmpi_lt r3, 0		; make positive
	not_ct r2
	not_ct r3
	addi_ct r2, 1
	addc_ct r3, r13

	cmpi_lt r5, 0		; make positive
	not_ct r4
	not_ct r5
	addi_ct r4, 1
	addc_ct r5, r13

__moddi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__moddi3_scale:
	btest r5, 31		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __moddi3_scale

__moddi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __moddi3_resign
	cmpu_gt r5, r7
	jmpi_ct __moddi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __moddi3_resign

__moddi3_noteq:
	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __moddi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __moddi3_sub
	cmpu_gt r4, r2
	jmpi_ct __moddi3_nosub
__moddi3_sub:
	sub r2, r4
	subc r3, r5
__moddi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __moddi3_loop

__moddi3_resign:
	cmpi_lt r0, 0		; add sign again
	not_ct r2
	not_ct r3
	addi_ct r2, 1
	addc_ct r3, r13

__moddi3_end:
	mov r13, r1

	stw r2, r13
	addi r13, 4
	stw r3, r13

	mov r0, r1

	rts
	.size   __moddi3, .-__moddi3

#endif

/*******************************************************
		Unsigned Modulo 32 x 32
*******************************************************/
#ifdef L_umodsi3

	.section	.text
	.global	__umodsi3
	.type	__umodsi3, @function
__umodsi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __umodsi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __umodsi3_end

__umodsi3_copy:
	mov r13, r2		; make a copy of the divisor

__umodsi3_scale:
	btest r2, 31		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __umodsi3_scale

__umodsi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __umodsi3_end

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	sri r2, 1

	jmpi __umodsi3_loop

__umodsi3_end:
	mov r0, r1
	rts
	.size   __umodsi3, .-__umodsi3

#endif

/*******************************************************
		Unsigned Modulo 64 x 64
*******************************************************/
#ifdef L_umoddi3

	.section	.text
	.global	__umoddi3
	.type	__umoddi3, @function
__umoddi3:
	ldfpz r4,0
	ldfpz r5,1

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __umoddi3_start
	cmpi_eq r5, 0
	jmpi_ct __umoddi3_end

__umoddi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __umoddi3_copy
	cmpi_eq r3, 0
	mov_ct r4, r2
	mov_ct r5, r3
	jmpi_ct __umoddi3_end

__umoddi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__umoddi3_scale:
	btest r5, 31		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __umoddi3_scale

__umoddi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __umoddi3_end
	cmpu_gt r5, r7
	jmpi_ct __umoddi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __umoddi3_end

__umoddi3_noteq:
	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __umoddi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __umoddi3_sub
	cmpu_gt r4, r2
	jmpi_ct __umoddi3_nosub
__umoddi3_sub:
	sub r2, r4
	subc r3, r5
__umoddi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __umoddi3_loop

__umoddi3_end:
	mov r13, r1

	stw r2, r13
	addi r13, 4
	stw r3, r13

	mov r0, r1

	rts
	.size   __umoddi3, .-__umoddi3

#endif

/*******************************************************
		Shift right logic 64
*******************************************************/
#ifdef L_lshrdi3

	.section	.text
	.global	__lshrdi3
	.type	__lshrdi3, @function
__lshrdi3:
	mov r0,r1

__lshrdi3_loop:
	cmpi_gt r4, 0
	sri_ct r3, 1
	rrc_ct r2
	addi_ct r4, -1
	jmpi_ct __lshrdi3_loop

	mov r13,r0
	stw r2, r13
	addi r13, 4
	stw r3, r13

	rts
	.size   __lshrdi3, .-__lshrdi3

#endif

/*******************************************************
		Shift right arithmetic 64
*******************************************************/
#ifdef L_ashrdi3

	.section	.text
	.global	__ashrdi3
	.type	__ashrdi3, @function
__ashrdi3:
	mov r0,r1

__ashrdi3_loop:
	cmpi_gt r4, 0
	srai_ct r3, 1
	rrc_ct r2
	addi_ct r4, -1
	jmpi_ct __ashrdi3_loop

	mov r13,r0
	stw r2, r13
	addi r13, 4
	stw r3, r13

	rts
	.size   __ashrdi3, .-__ashrdi3

#endif

/*******************************************************
		Shift left 64
*******************************************************/
#ifdef L_ashldi3

	.section	.text
	.global	__ashldi3
	.type	__ashldi3, @function
__ashldi3:
	mov r0,r1

__ashldi3_loop:
	cmpi_gt r4, 0
	sli_ct r2, 1
	addc_ct r3, r3
	addi_ct r4, -1
	jmpi_ct __ashldi3_loop

	mov r13,r0
	stw r2, r13
	addi r13, 4
	stw r3, r13

	rts
	.size   __ashldi3, .-__ashldi3

#endif

/*******************************************************
		Find first set bit 32
*******************************************************/
#ifdef L_ffssi2

	.section	.text
	.global	__ffssi2
	.type	__ffssi2, @function
__ffssi2:
	cmpi_eq r1, 0		; return zero if no bit is set
	mov_ct r0, r1
	jmpi_ct __ffssi2_end

	ldli r0, 1
__ffssi2_loop:
	btest r1, 0		; test bit
	sri_cf r1, 1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ffssi2_loop

__ffssi2_end:
	rts
	.size   __ffssi2, .-__ffssi2

#endif

/*******************************************************
		Find first set bit 64
*******************************************************/
#ifdef L_ffsdi2

	.section	.text
	.global	__ffsdi2
	.type	__ffsdi2, @function
__ffsdi2:
	cmpi_eq r1, 0		; return zero if no bit is set
	jmpi_cf __ffsdi2_start
	cmpi_eq r2, 0
	mov_ct r0, r1
	jmpi_ct __ffsdi2_end

__ffsdi2_start:
	ldli r0, 1
__ffsdi2_loop:
	btest r1, 0		; test bit
	sri_cf r2, 1
	rrc_cf r1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ffsdi2_loop

__ffsdi2_end:
	rts
	.size   __ffsdi2, .-__ffsdi2

#endif

/*******************************************************
		Count trailing zero bits 32
*******************************************************/
#ifdef L_ctzsi2

	.section	.text
	.global	__ctzsi2
	.type	__ctzsi2, @function
__ctzsi2:
	ldli r0, 32		; return 32 if no bit is set
	cmpi_eq r1, 0
	jmpi_ct __ctzsi2_end

	ldli r0, 0
__ctzsi2_loop:
	btest r1, 0		; test bit
	sri_cf r1, 1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ctzsi2_loop

__ctzsi2_end:
	rts
	.size   __ctzsi2, .-__ctzsi2

#endif

/*******************************************************
		Count trailing zero bits 64
*******************************************************/
#ifdef L_ctzdi2

	.section	.text
	.global	__ctzdi2
	.type	__ctzdi2, @function
__ctzdi2:
	ldli r0, 64		; return 64 if no bit is set
	cmpi_eq r1, 0
	jmpi_cf __ctzdi2_start
	cmpi_eq r2, 0
	jmpi_ct __ctzdi2_end

__ctzdi2_start:
	ldli r0, 0
__ctzdi2_loop:
	btest r1, 0		; test bit
	sri_cf r2, 1
	rrc_cf r1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ctzdi2_loop

__ctzdi2_end:
	rts
	.size   __ctzdi2, .-__ctzdi2

#endif

/*******************************************************
		Count leading zero bits 32
*******************************************************/
#ifdef L_clzsi2

	.section	.text
	.global	__clzsi2
	.type	__clzsi2, @function
__clzsi2:
	ldli r0, 32		; return 32 if no bit is set
	cmpi_eq r1, 0
	jmpi_ct __clzsi2_end

	ldli r0, 0
__clzsi2_loop:
	btest r1, 31		; test bit
	sli_cf r1, 1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __clzsi2_loop

__clzsi2_end:
	rts
	.size   __clzsi2, .-__clzsi2

#endif

/*******************************************************
		Count leading zero bits 64
*******************************************************/
#ifdef L_clzdi2

	.section	.text
	.global	__clzdi2
	.type	__clzdi2, @function
__clzdi2:
	ldli r0, 64		; return 64 if no bit is set
	cmpi_eq r1, 0
	jmpi_cf __clzdi2_start
	cmpi_eq r2, 0
	jmpi_ct __clzdi2_end

__clzdi2_start:
	ldli r0, 0
__clzdi2_loop:
	btest r2, 31		; test bit
	sli_cf r1, 1
	addc_cf r2, r2
	addi_cf r0, 1		; update loop counter
	jmpi_cf __clzdi2_loop

__clzdi2_end:
	rts
	.size   __clzdi2, .-__clzdi2

#endif

/*******************************************************
		Count set bits 32
*******************************************************/
#ifdef L_popcountsi2

	.section	.text
	.global	__popcountsi2
	.type	__popcountsi2, @function
__popcountsi2:
	ldli r0, 0		; return 0 if no bit is set

__popcountsi2_loop:
	btest r1, 0		; test bit
	addi_ct r0, 1		; update loop counter
	sri r1, 1
	cmpi_eq r1, 0
	jmpi_cf __popcountsi2_loop

__popcountsi2_end:
	rts
	.size   __popcountsi2, .-__popcountsi2

#endif

/*******************************************************
		Count set bits 64
*******************************************************/
#ifdef L_popcountdi2

	.section	.text
	.global	__popcountdi2
	.type	__popcountdi2, @function
__popcountdi2:
	ldli r0, 0		; return 0 if no bit is set

__popcountdi2_loop:
	btest r1, 0		; test bit
	addi_ct r0, 1		; update loop counter
	sri r2, 1
	rrc r1
	cmpi_eq r1, 0
	jmpi_cf __popcountdi2_loop
	cmpi_eq r2, 0
	jmpi_cf __popcountdi2_loop

__popcountdi2_end:
	rts
	.size   __popcountdi2, .-__popcountdi2

#endif

/*******************************************************
		Compute parity 32
*******************************************************/
#ifdef L_paritysi2

	.section	.text
	.global	__paritysi2
	.type	__paritysi2, @function
__paritysi2:
	ldli r0, 0		; return 0 if no bit is set

__paritysi2_loop:
	btest r1, 0		; test bit
	addi_ct r0, 1		; update loop counter
	sri r1, 1
	cmpi_eq r1, 0
	jmpi_cf __paritysi2_loop

__paritysi2_end:
	ldli r13, 1
	and r0, r13
	rts
	.size   __paritysi2, .-__paritysi2

#endif

/*******************************************************
		Compute parity 64
*******************************************************/
#ifdef L_paritydi2

	.section	.text
	.global	__paritydi2
	.type	__paritydi2, @function
__paritydi2:
	ldli r0, 0		; return 0 if no bit is set

__paritydi2_loop:	
	btest r1, 0		; test bit
	addi_ct r0, 1		; update loop counter
	sri r2, 1
	rrc r1
	cmpi_eq r1, 0
	jmpi_cf __paritydi2_loop
	cmpi_eq r2, 0
	jmpi_cf __paritydi2_loop

__paritydi2_end:
	ldli r13, 1
	and r0, r13
	rts
	.size   __paritydi2, .-__paritydi2

#endif
