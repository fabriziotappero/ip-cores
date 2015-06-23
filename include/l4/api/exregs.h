/*
 * Exchange registers system call data.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#ifndef __EXREGS_H__
#define __EXREGS_H__

#include <l4/macros.h>
#include INC_GLUE(syscall.h)
#include INC_GLUE(context.h)
#include <l4/types.h>

#define EXREGS_SET_PAGER		1
#define	EXREGS_SET_UTCB			2
#define EXREGS_READ			4

#define EXREGS_VALID_REGULAR_REGS 			\
	(FIELD_TO_BIT(exregs_context_t, r0) |		\
	 FIELD_TO_BIT(exregs_context_t, r1) |		\
	 FIELD_TO_BIT(exregs_context_t, r2) |		\
	 FIELD_TO_BIT(exregs_context_t, r3) |		\
	 FIELD_TO_BIT(exregs_context_t, r4) |		\
	 FIELD_TO_BIT(exregs_context_t, r5) |		\
	 FIELD_TO_BIT(exregs_context_t, r6) |		\
	 FIELD_TO_BIT(exregs_context_t, r7) |		\
	 FIELD_TO_BIT(exregs_context_t, r8) |		\
	 FIELD_TO_BIT(exregs_context_t, r9) |		\
	 FIELD_TO_BIT(exregs_context_t, r10) |		\
	 FIELD_TO_BIT(exregs_context_t, r11) |		\
	 FIELD_TO_BIT(exregs_context_t, r12) |		\
	 FIELD_TO_BIT(exregs_context_t, lr))		\

#define EXREGS_VALID_SP 				\
	FIELD_TO_BIT(exregs_context_t, sp)		\

#define EXREGS_VALID_PC 				\
	FIELD_TO_BIT(exregs_context_t, pc)		\

/* Structure passed by userspace pagers for exchanging registers */
struct exregs_data {
	exregs_context_t context;
	u32 valid_vect;
	u32 flags;
	l4id_t pagerid;
	unsigned long utcb_address;
};



#endif /* __EXREGS_H__ */
