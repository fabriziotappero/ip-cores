/*
 * Common definitions for exceptions
 * across ARM sub-architectures.
 *
 * Copyright (C) 2010 B Labs Ltd.
 */

#ifndef __EXCEPTION_H__
#define __EXCEPTION_H__

#include INC_SUBARCH(exception.h)
#include INC_ARCH(asm.h)

/* Abort debugging conditions */
// #define DEBUG_ABORTS
#if defined (DEBUG_ABORTS)
#define dbg_abort(...)	printk(__VA_ARGS__)
#else
#define dbg_abort(...)
#endif

/* Codezero-specific abort type */
#define ABORT_TYPE_PREFETCH		1
#define ABORT_TYPE_DATA			0

/* If abort is handled and resolved in check_aborts */
#define ABORT_HANDLED			1

/* Codezero makes use of bit 8 (Always Zero) of FSR to define which type of abort */
#define set_abort_type(fsr, x)	{ fsr &= ~(1 << 8); fsr |= ((x & 1) << 8); }
#define is_prefetch_abort(fsr)	((fsr >> 8) & 0x1)
#define is_data_abort(fsr)	(!is_prefetch_abort(fsr))

/* Kernel's data about the fault */
typedef struct fault_kdata {
	u32 faulty_pc;	/* In DABT: Aborting PC, In PABT: Same as FAR */
	u32 fsr;	/* In DABT: DFSR, In PABT: IFSR */
	u32 far;	/* In DABT: DFAR, in PABT: IFAR */
	pte_t pte;	/* Faulty page table entry */
} __attribute__ ((__packed__)) fault_kdata_t;


/* This is filled on entry to irq handler, only if a process was interrupted.*/
extern unsigned int preempted_psr;

/* Implementing these as functions cause circular include dependency for tcb.h */
#define TASK_IN_KERNEL(tcb)	(((tcb)->context.spsr & ARM_MODE_MASK) == ARM_MODE_SVC)
#define TASK_IN_USER(tcb)	(!TASK_IN_KERNEL(tcb))

static inline int is_user_mode(u32 spsr)
{
	return ((spsr & ARM_MODE_MASK) == ARM_MODE_USR);
}

static inline int in_kernel()
{
	return (((preempted_psr & ARM_MODE_MASK) == ARM_MODE_SVC)) ? 1 : 0;
}

static inline int in_user()
{
	return !in_kernel();
}

int pager_pagein_request(unsigned long vaddr, unsigned long size,
			 unsigned int flags);

int fault_ipc_to_pager(u32 faulty_pc, u32 fsr, u32 far, u32 ipc_tag);

int is_kernel_abort(u32 faulted_pc, u32 fsr, u32 far, u32 spsr);
int check_abort_type(u32 faulted_pc, u32 fsr, u32 far, u32 spsr);

#endif /* __EXCEPTION_H__ */
