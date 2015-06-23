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
		Multiplication  16 x 16
*******************************************************/
#ifdef L_mulhi3

	.section	.text
	.global	__mulhi3
	.type	__mulhi3, @function
__mulhi3:
	ldli r0, 0		; clear result
__mulhi3_loop:
	btest r2, 0
	add_ct r0, r1
	sli r1, 1
	sri r2, 1
	cmpi_eq r2, 0
	jmpi_cf __mulhi3_loop
	rts
	.size   __mulhi3, .-__mulhi3

#endif

/*******************************************************
		Multiplication  32 x 32
*******************************************************/
#ifdef L_mulsi3

	.section	.text
	.global	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	ldfpz r4,0
	ldfpz r5,1

	mov r0,r1
	
	ldli r6, 0
	ldli r7, 0

__mulsi3_loop:
	btest r2, 0
	add_ct r6, r4
	addc_ct r7, r5

	sli r4, 1
	addc r5, r5
	sri r3, 1
	rrc r2

	cmpi_eq r2, 0
	jmpi_cf __mulsi3_loop
	cmpi_eq r3, 0
	jmpi_cf __mulsi3_loop
	
	mov r13,r0
	sth r6,r13
	addi r13, 2
	sth r7,r13

	rts
	.size   __mulsi3, .-__mulsi3

#endif

/*******************************************************
		Division 16 x 16
*******************************************************/
#ifdef L_divhi3

	.section	.text
	.global	__divhi3
	.type	__divhi3, @function
__divhi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __divhi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __divhi3_end

__divhi3_cmpsign:
	mov r3, r1		; compute the sign of the result
	eor r3, r2

	cmpi_lt r1, 0		; make positive
	neg_ct r1

	cmpi_lt r2, 0		; make positive
	neg_ct r2

__divhi3_copy:
	mov r13, r2		; make a copy of the divisor

__divhi3_scale:
	btest r2, 15		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __divhi3_scale

	ldli r0, 0		; clear result

__divhi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __divhi3_resign

	sli r0, 1

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	addi_cf r0, 1
	sri r2, 1

	jmpi __divhi3_loop

__divhi3_resign:		; add sign again
	cmpi_lt r3, 0
	neg_ct r0

__divhi3_end:
	rts
	.size   __divhi3, .-__divhi3

#endif

/*******************************************************
		Division 32 x 32
*******************************************************/
#ifdef L_divsi3

	.section	.text
	.global	__divsi3
	.type	__divsi3, @function
__divsi3:
	stfpz_dec r1,-1
	ldfpz r4,1
	ldfpz r5,2

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __divsi3_start
	cmpi_eq r5, 0
	jmpi_ct __divsi3_end

__divsi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __divsi3_cmpsign
	cmpi_eq r3, 0
	mov_ct r0, r2
	mov_ct r1, r3
	jmpi_ct __divsi3_end

__divsi3_cmpsign:
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

__divsi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__divsi3_scale:
	btest r5, 15		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __divsi3_scale

	ldli r0, 0		; clear result
	ldli r1, 0

__divsi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __divsi3_resign
	cmpu_gt r5, r7
	jmpi_ct __divsi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __divsi3_resign

__divsi3_noteq:
	sli r0, 1
	addc r1, r1

	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __divsi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __divsi3_sub
	cmpu_gt r4, r2
	jmpi_ct __divsi3_nosub
__divsi3_sub:
	sub r2, r4
	subc r3, r5
	addi r0, 1
	addc r1, r13
__divsi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __divsi3_loop

__divsi3_resign:
	cmpi_lt r8, 0		; add sign again
	not_ct r0
	not_ct r1
	addi_ct r0, 1
	addc_ct r1, r13

__divsi3_end:
	ldfpz r13, 0

	sth r0, r13
	addi r13, 2
	sth r1, r13

	ldfpz_inc r0, 0

	rts
	.size   __divsi3, .-__divsi3

#endif

/*******************************************************
		Unsigned Division 16 x 16
*******************************************************/
#ifdef L_udivhi3

	.section	.text
	.global	__udivhi3
	.type	__udivhi3, @function
__udivhi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __udivhi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __udivhi3_end

__udivhi3_copy:
	mov r13, r2		; make a copy of the divisor

__udivhi3_scale:
	btest r2, 15		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __udivhi3_scale

	ldli r0, 0		; clear result

__udivhi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __udivhi3_end

	sli r0, 1

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	addi_cf r0, 1
	sri r2, 1

	jmpi __udivhi3_loop

__udivhi3_end:
	rts
	.size   __udivhi3, .-__udivhi3

#endif

/*******************************************************
		Unsigned Division 32 x 32
*******************************************************/
#ifdef L_udivsi3

	.section	.text
	.global	__udivsi3
	.type	__udivsi3, @function
__udivsi3:
	stfpz_dec r1,-1
	ldfpz r4,1
	ldfpz r5,2

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __udivsi3_start
	cmpi_eq r5, 0
	jmpi_ct __udivsi3_end

__udivsi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __udivsi3_copy
	cmpi_eq r3, 0
	mov_ct r0, r2
	mov_ct r1, r3
	jmpi_ct __udivsi3_end

__udivsi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__udivsi3_scale:
	btest r5, 15		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __udivsi3_scale

	ldli r0, 0		; clear result
	ldli r1, 0

	ldli r13, 0		; we use that for incrementing

__udivsi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __udivsi3_end
	cmpu_gt r5, r7
	jmpi_ct __udivsi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __udivsi3_end

__udivsi3_noteq:
	sli r0, 1
	addc r1, r1

	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __udivsi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __udivsi3_sub
	cmpu_gt r4, r2
	jmpi_ct __udivsi3_nosub
__udivsi3_sub:
	sub r2, r4
	subc r3, r5
	addi r0, 1
	addc r1, r13
__udivsi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __udivsi3_loop

__udivsi3_end:
	ldfpz r13, 0

	sth r0, r13
	addi r13, 2
	sth r1, r13

	ldfpz_inc r0, 0

	rts
	.size   __udivsi3, .-__udivsi3

#endif

/*******************************************************
		Modulo 16 x 16
*******************************************************/
#ifdef L_modhi3

	.section	.text
	.global	__modhi3
	.type	__modhi3, @function
__modhi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __modhi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __modhi3_end

__modhi3_cmpsign:
	mov r3, r1		; compute the sign of the result

	cmpi_lt r1, 0		; make positive
	neg_ct r1

	cmpi_lt r2, 0		; make positive
	neg_ct r2

__modhi3_copy:
	mov r13, r2		; make a copy of the divisor

__modhi3_scale:
	btest r2, 15		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __modhi3_scale

__modhi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __modhi3_resign

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	sri r2, 1

	jmpi __modhi3_loop

__modhi3_resign:		; add sign again
	mov r0, r1
	cmpi_lt r3, 0
	neg_ct r0

__modhi3_end:
	rts
	.size   __modhi3, .-__modhi3

#endif

/*******************************************************
		Modulo 32 x 32
*******************************************************/
#ifdef L_modsi3

	.section	.text
	.global	__modsi3
	.type	__modsi3, @function
__modsi3:
	ldfpz r4,0
	ldfpz r5,1

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __modsi3_start
	cmpi_eq r5, 0
	jmpi_ct __modsi3_end

__modsi3_start:	
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __modsi3_cmpsign
	cmpi_eq r3, 0
	jmpi_ct __modsi3_end

__modsi3_cmpsign:
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

__modsi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__modsi3_scale:
	btest r5, 15		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __modsi3_scale

__modsi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __modsi3_resign
	cmpu_gt r5, r7
	jmpi_ct __modsi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __modsi3_resign

__modsi3_noteq:
	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __modsi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __modsi3_sub
	cmpu_gt r4, r2
	jmpi_ct __modsi3_nosub
__modsi3_sub:
	sub r2, r4
	subc r3, r5
__modsi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __modsi3_loop

__modsi3_resign:
	cmpi_lt r0, 0		; add sign again
	not_ct r2
	not_ct r3
	addi_ct r2, 1
	addc_ct r3, r13

__modsi3_end:
	mov r13, r1

	sth r2, r13
	addi r13, 2
	sth r3, r13

	mov r0, r1

	rts
	.size   __modsi3, .-__modsi3

#endif

/*******************************************************
		Unsigned Modulo 16 x 16
*******************************************************/
#ifdef L_umodhi3

	.section	.text
	.global	__umodhi3
	.type	__umodhi3, @function
__umodhi3:
	cmpi_eq r2, 0		; avoid division by zero
	jmpi_ct __umodhi3_end

	cmpi_eq r1, 0		; we need not divide zero
	mov_ct r0, r1
	jmpi_ct __umodhi3_end

__umodhi3_copy:	
	mov r13, r2		; make a copy of the divisor

__umodhi3_scale:
	btest r2, 15		; scale divisor up
	sli_cf r2, 1
	jmpi_cf __umodhi3_scale

__umodhi3_loop:
	cmpu_lt r2, r13		; check if the divisor is reached
	jmpi_ct __umodhi3_end

	cmpu_gt r2, r1		; need to scale back?
	sub_cf r1, r2
	sri r2, 1

	jmpi __umodhi3_loop

__umodhi3_end:
	mov r0, r1
	rts
	.size   __umodhi3, .-__umodhi3

#endif

/*******************************************************
		Unsigned Modulo 32 x 32
*******************************************************/
#ifdef L_umodsi3

	.section	.text
	.global	__umodsi3
	.type	__umodsi3, @function
__umodsi3:
	ldfpz r4,0
	ldfpz r5,1

	cmpi_eq r4, 0		; avoid division by zero
	jmpi_cf __umodsi3_start
	cmpi_eq r5, 0
	jmpi_ct __umodsi3_end

__umodsi3_start:
	cmpi_eq r2, 0		; we need not divide zero
	jmpi_cf __umodsi3_copy
	cmpi_eq r3, 0
	mov_ct r4, r2
	mov_ct r5, r3
	jmpi_ct __umodsi3_end

__umodsi3_copy:
	mov r6, r4		; make a copy of the divisor
	mov r7, r5

__umodsi3_scale:
	btest r5, 15		; scale divisor up
	sli_cf r4, 1
	addc_cf r5, r5
	jmpi_cf __umodsi3_scale

__umodsi3_loop:
	cmpu_lt r5, r7		; check if the divisor is reached
	jmpi_ct __umodsi3_end
	cmpu_gt r5, r7
	jmpi_ct __umodsi3_noteq
	cmpu_lt r4, r6
	jmpi_ct __umodsi3_end

__umodsi3_noteq:
	cmpu_gt r5, r3		; need to scale back?
	jmpi_ct __umodsi3_nosub
	cmpu_lt r5, r3
	jmpi_ct __umodsi3_sub
	cmpu_gt r4, r2
	jmpi_ct __umodsi3_nosub
__umodsi3_sub:
	sub r2, r4
	subc r3, r5
__umodsi3_nosub:
	sri r5, 1
	rrc r4

	jmpi __umodsi3_loop

__umodsi3_end:
	mov r13, r1

	sth r2, r13
	addi r13, 2
	sth r3, r13

	mov r0, r1

	rts
	.size   __umodsi3, .-__umodsi3

#endif

/*******************************************************
		Shift right logic 32
*******************************************************/
#ifdef L_lshrsi3

	.section	.text
	.global	__lshrsi3
	.type	__lshrsi3, @function
__lshrsi3:
	mov r0,r1

__lshrsi3_loop:
	cmpi_gt r4, 0
	sri_ct r3, 1
	rrc_ct r2
	addi_ct r4, -1
	jmpi_ct __lshrsi3_loop

	mov r13,r0
	sth r2, r13
	addi r13, 2
	sth r3, r13

	rts
	.size   __lshrsi3, .-__lshrsi3

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

	ldfpz r1, 0
	ldfpz r2, 1
	ldfpz r3, 2
	ldfpz r4, 3
	ldfpz r5, 4

__lshrdi3_loop:
	cmpi_gt r5, 0
	sri_ct r4, 1
	rrc_ct r3
	rrc_ct r2
	rrc_ct r1

	addi_ct r5, -1
	jmpi_ct __lshrdi3_loop

	mov r13,r0
	sth r1,r13
	addi r13, 2
	sth r2,r13 
	addi r13, 2
	sth r3,r13
	addi r13, 2
	sth r4,r13

	rts
	.size   __lshrdi3, .-__lshrdi3

#endif

/*******************************************************
		Shift right arithmetic 32
*******************************************************/
#ifdef L_ashrsi3

	.section	.text
	.global	__ashrsi3
	.type	__ashrsi3, @function
__ashrsi3:
	mov r0,r1

__ashrsi3_loop:
	cmpi_gt r4, 0
	srai_ct r3, 1
	rrc_ct r2
	addi_ct r4, -1
	jmpi_ct __ashrsi3_loop

	mov r13,r0
	sth r2, r13
	addi r13, 2
	sth r3, r13

	rts
	.size   __ashrsi3, .-__ashrsi3

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

	ldfpz r1, 0
	ldfpz r2, 1
	ldfpz r3, 2
	ldfpz r4, 3
	ldfpz r5, 4

__ashrdi3_loop:
	cmpi_gt r5, 0
	srai_ct r4, 1
	rrc_ct r3
	rrc_ct r2
	rrc_ct r1

	addi_ct r5, -1
	jmpi_ct __ashrdi3_loop

	mov r13,r0
	sth r1,r13
	addi r13, 2
	sth r2,r13
	addi r13, 2
	sth r3,r13
	addi r13, 2
	sth r4,r13

	rts
	.size   __ashrdi3, .-__ashrdi3

#endif

/*******************************************************
		Shift left 32
*******************************************************/
#ifdef L_ashlsi3

	.section	.text
	.global	__ashlsi3
	.type	__ashlsi3, @function
__ashlsi3:
	mov r0,r1

__ashlsi3_loop:
	cmpi_gt r4, 0
	sli_ct r2, 1
	addc_ct r3, r3
	addi_ct r4, -1
	jmpi_ct __ashlsi3_loop

	mov r13,r0
	sth r2, r13
	addi r13, 2
	sth r3, r13

	rts
	.size   __ashlsi3, .-__ashlsi3

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

	ldfpz r1, 0
	ldfpz r2, 1
	ldfpz r3, 2
	ldfpz r4, 3
	ldfpz r5, 4

__ashldi3_loop:
	cmpi_gt r5, 0
	sli_ct r1, 1
	addc_ct r2, r2
	addc_ct r3, r3
	addc_ct r4, r4

	addi_ct r5, -1
	jmpi_ct __ashldi3_loop

	mov r13,r0
	sth r1,r13
	addi r13, 2
	sth r2,r13
	addi r13, 2
	sth r3,r13
	addi r13, 2
	sth r4,r13

	rts
	.size   __ashldi3, .-__ashldi3

#endif

/*******************************************************
		Find first set bit 16
*******************************************************/
#ifdef L_ffshi2

	.section	.text
	.global	__ffshi2
	.type	__ffshi2, @function
__ffshi2:
	cmpi_eq r1, 0		; return zero if no bit is set
	mov_ct r0, r1
	jmpi_ct __ffshi2_end

	ldli r0, 1
__ffshi2_loop:
	btest r1, 0		; test bit
	sri_cf r1, 1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ffshi2_loop

__ffshi2_end:
	rts
	.size   __ffshi2, .-__ffshi2

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
	jmpi_cf __ffssi2_start
	cmpi_eq r2, 0
	mov_ct r0, r1
	jmpi_ct __ffssi2_end

__ffssi2_start:
	ldli r0, 1
__ffssi2_loop:
	btest r1, 0		; test bit
	sri_cf r2, 1
	rrc_cf r1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ffssi2_loop

__ffssi2_end:
	rts
	.size   __ffssi2, .-__ffssi2

#endif

/*******************************************************
		Count trailing zero bits 16
*******************************************************/
#ifdef L_ctzhi2

	.section	.text
	.global	__ctzhi2
	.type	__ctzhi2, @function
__ctzhi2:
	ldli r0, 16		; return 16 if no bit is set
	cmpi_eq r1, 0
	jmpi_ct __ctzhi2_end

	ldli r0, 0
__ctzhi2_loop:
	btest r1, 0		; test bit
	sri_cf r1, 1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ctzhi2_loop

__ctzhi2_end:
	rts
	.size   __ctzhi2, .-__ctzhi2

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
	jmpi_cf __ctzsi2_start
	cmpi_eq r2, 0
	jmpi_ct __ctzsi2_end

__ctzsi2_start:
	ldli r0, 0
__ctzsi2_loop:
	btest r1, 0		; test bit
	sri_cf r2, 1
	rrc_cf r1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __ctzsi2_loop

__ctzsi2_end:
	rts
	.size   __ctzsi2, .-__ctzsi2

#endif

/*******************************************************
		Count leading zero bits 16
*******************************************************/
#ifdef L_clzhi2

	.section	.text
	.global	__clzhi2
	.type	__clzhi2, @function
__clzhi2:
	ldli r0, 16		; return 16 if no bit is set
	cmpi_eq r1, 0
	jmpi_ct __clzhi2_end

	ldli r0, 0
__clzhi2_loop:
	btest r1, 15		; test bit
	sli_cf r1, 1
	addi_cf r0, 1		; update loop counter
	jmpi_cf __clzhi2_loop

__clzhi2_end:
	rts
	.size   __clzhi2, .-__clzhi2

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
	jmpi_cf __clzsi2_start
	cmpi_eq r2, 0
	jmpi_ct __clzsi2_end

__clzsi2_start:
	ldli r0, 0
__clzsi2_loop:
	btest r2, 15		; test bit
	sli_cf r1, 1
	addc_cf r2, r2
	addi_cf r0, 1		; update loop counter
	jmpi_cf __clzsi2_loop

__clzsi2_end:
	rts
	.size   __clzsi2, .-__clzsi2

#endif

/*******************************************************
		Count set bits 16
*******************************************************/
#ifdef L_popcounthi2

	.section	.text
	.global	__popcounthi2
	.type	__popcounthi2, @function
__popcounthi2:
	ldli r0, 0		; return 0 if no bit is set

__popcounthi2_loop:
	btest r1, 0		; test bit
	addi_ct r0, 1		; update loop counter
	sri r1, 1
	cmpi_eq r1, 0
	jmpi_cf __popcounthi2_loop

__popcounthi2_end:
	rts
	.size   __popcounthi2, .-__popcounthi2

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
	sri r2, 1
	rrc r1
	cmpi_eq r1, 0
	jmpi_cf __popcountsi2_loop
	cmpi_eq r2, 0
	jmpi_cf __popcountsi2_loop

__popcountsi2_end:
	rts
	.size   __popcountsi2, .-__popcountsi2

#endif

/*******************************************************
		Compute parity 16
*******************************************************/
#ifdef L_parityhi2

	.section	.text
	.global	__parityhi2
	.type	__parityhi2, @function
__parityhi2:
	ldli r0, 0		; return 0 if no bit is set

__parityhi2_loop:
	btest r1, 0		; test bit
	addi_ct r0, 1		; update loop counter
	sri r1, 1
	cmpi_eq r1, 0
	jmpi_cf __parityhi2_loop

__parityhi2_end:
	ldli r13, 1
	and r0, r13
	rts
	.size   __parityhi2, .-__parityhi2

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
	sri r2, 1
	rrc r1
	cmpi_eq r1, 0
	jmpi_cf __paritysi2_loop
	cmpi_eq r2, 0
	jmpi_cf __paritysi2_loop

__paritysi2_end:
	ldli r13, 1
	and r0, r13
	rts
	.size   __paritysi2, .-__paritysi2

#endif
