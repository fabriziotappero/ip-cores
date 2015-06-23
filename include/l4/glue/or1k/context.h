#ifndef __ARM_CONTEXT_H__
#define __ARM_CONTEXT_H__

#include <l4/types.h>

/*
 * This describes the register context of each task. Simply set
 * them and they'll be copied onto real registers upon a context
 * switch to that task. exchange_registers() system call is
 * designed for this, whose input structure is defined further
 * below.
 */
typedef struct arm_context {
	u32 spsr;	/* 0x0 */
	u32 r0;		/* 0x4 */
	u32 r1;		/* 0x8 */
	u32 r2;		/* 0xC */
	u32 r3;		/* 0x10 */
	u32 r4;		/* 0x14 */
	u32 r5;		/* 0x18 */
	u32 r6; 	/* 0x1C */
	u32 r7;		/* 0x20 */
	u32 r8;		/* 0x24 */
	u32 r9;		/* 0x28 */
	u32 r10;	/* 0x2C */
	u32 r11;	/* 0x30 */
	u32 r12;	/* 0x34 */
	u32 sp;		/* 0x38 */
	u32 lr;		/* 0x3C */
	u32 pc;		/* 0x40 */
} __attribute__((__packed__)) task_context_t;


typedef struct arm_exregs_context {
	u32 r0;		/* 0x4 */
	u32 r1;		/* 0x8 */
	u32 r2;		/* 0xC */
	u32 r3;		/* 0x10 */
	u32 r4;		/* 0x14 */
	u32 r5;		/* 0x18 */
	u32 r6; 	/* 0x1C */
	u32 r7;		/* 0x20 */
	u32 r8;		/* 0x24 */
	u32 r9;		/* 0x28 */
	u32 r10;	/* 0x2C */
	u32 r11;	/* 0x30 */
	u32 r12;	/* 0x34 */
	u32 sp;		/* 0x38 */
	u32 lr;		/* 0x3C */
	u32 pc;		/* 0x40 */
} __attribute__((__packed__)) exregs_context_t;

#endif /* __ARM_CONTEXT_H__ */
