/*
 * Register definitions
 * 
 * This file is subject to the terms and conditions of the GNU General
 * Public License.  See the file "COPYING" in the main directory of
 * this archive for more details.
 */
#ifndef _REGDEF_H
#define _REGDEF_H

#define zero	$0	/* wired zero */
#define AT	$at	/* assembler temp - uppercase because of ".set at" */
#define v0	$2	/* return value - caller saved */
#define v1	$3
#define a0	$4	/* argument registers */
#define a1	$5
#define a2	$6
#define a3	$7
#define t0	$8	/* caller saved in 32 bit (arg reg 64 bit) */
#define t1	$9
#define t2	$10
#define t3	$11
#define t4	$12	/* caller saved */
#define t5	$13
#define t6	$14
#define t7	$15
#define s0	$16	/* callee saved */
#define s1	$17
#define s2	$18
#define s3	$19
#define s4	$20
#define s5	$21
#define s6	$22
#define s7	$23
#define t8	$24	/* caller saved */
#define t9	$25	/* callee address for PIC/temp */
#define k0	$26	/* kernel temporary */
#define k1	$27
#define gp	$28	/* global pointer - caller saved for PIC */
#define sp	$29	/* stack pointer */
#define fp	$30	/* frame pointer */
#define s8	$30	/* callee saved */
#define ra	$31	/* return address */

#endif /* _REGDEF_H */
