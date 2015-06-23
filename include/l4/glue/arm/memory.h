/*
 * Includes memory-related architecture specific definitions and their
 * corresponding generic wrappers.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __GLUE_ARM_MEMORY_H__
#define __GLUE_ARM_MEMORY_H__

#include INC_GLUE(memlayout.h) /* Important generic definitions */
#include INC_SUBARCH(mm.h)

/* Generic definitions */
#define PFN_SHIFT			12
#define PAGE_BITS			PFN_SHIFT
#define PAGE_SIZE			SZ_4K
#define PAGE_MASK			(PAGE_SIZE - 1)

/* Aligns to the upper page (ceiling) FIXME: Must add a wraparound checker. */
#define page_align_up(addr) 		((((unsigned long)(addr)) + PAGE_MASK) & \
					 (~PAGE_MASK))

/* Aligns to the lower page (floor) */
#define page_align(addr)		(((unsigned long)(addr)) &  \
					 (~PAGE_MASK))

#define is_aligned(val, size)		(!(((unsigned long)(val)) & (((unsigned long)size) - 1)))
#define is_page_aligned(val)		(!(((unsigned long)(val)) & PAGE_MASK))
#define page_boundary(x)		is_page_aligned(x)

/*
 * Align to given size.
 *
 * Note it must be an alignable size i.e. one that is a power of two.
 * E.g. 0x1000 would work but 0x1010 would not.
 */
#define	align(addr, size)		(((unsigned int)(addr)) & (~((unsigned long)size-1)))
#define align_up(addr, size)		((((unsigned long)(addr)) + \
					((size) - 1)) & (~(((unsigned long)size) - 1)))

/* The bytes left until the end of the page that x is in */
#define TILL_PAGE_ENDS(x)	(PAGE_SIZE - ((unsigned long)(x) & PAGE_MASK))

/* Extract page frame number from address and vice versa. */
#define __pfn(x)		(((unsigned long)(x)) >> PAGE_BITS)
#define __pfn_to_addr(x)	(((unsigned long)(x)) << PAGE_BITS)

/* Extract physical address from page table entry (pte) */
#define __pte_to_addr(x)	(((unsigned long)(x)) & ~PAGE_MASK)

/* Minimum excess needed for word alignment */
#define SZ_WORD				sizeof(unsigned int)
#define WORD_BITS			32
#define WORD_BITS_LOG2			5
#define BITWISE_GETWORD(x)	((x) >> WORD_BITS_LOG2) /* Divide by 32 */
#define	BITWISE_GETBIT(x)	(1 << ((x) % WORD_BITS))

/* Minimum stack alignment restriction across functions, exceptions */
#define STACK_ALIGNMENT				8

/* Endianness conversion */
static inline void be32_to_cpu(unsigned int x)
{
	char *p = (char *)&x;
	char tmp;

	/* Swap bytes */
	tmp = p[0];
	p[0] = p[3];
	p[3] = tmp;

	tmp = p[1];
	p[1] = p[2];
	p[2] = tmp;
}

struct ktcb;
void task_init_registers(struct ktcb *task, unsigned long pc);

#endif /* __GLUE_ARM_MEMORY_H__ */

