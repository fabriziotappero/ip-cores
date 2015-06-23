/*
 * Memory related definitions for test purposes.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */
#ifndef __GLUE_TEST_MEMORY_H__
#define __GLUE_TEST_MEMORY_H__


/* ARM specific definitions */
#define TEST_SECTION_SIZE		SZ_1MB
//#define TEST_PAGE_SIZE			SZ_4K
//#define TEST_PAGE_MASK			0xFFF
//#define TEST_PAGE_BITS			12
#define TEST_PAGE_SIZE			128
#define TEST_PAGE_MASK			(TEST_PAGE_SIZE-1)
#define TEST_PAGE_BITS			7
#define TEST_SECTION_MASK		0xFFFFF

/* Aligns to the upper page (ceiling) */
#define page_align_up(addr) 		((((unsigned int)(addr)) + \
					  (PAGE_SIZE - 1)) & \
					 (~PAGE_MASK))
/* Aligns to the lower page (floor) */
#define page_align(addr)		(((unsigned int)(addr)) &  \
					 (~PAGE_MASK))

/* Align to given size */
#define	align(addr, size)		(((unsigned int)(addr)) & (~(size-1)))

/* Extract page frame number from address */
#define __pfn(x)		(((unsigned long)(x)) >> PAGE_BITS)
#define __pfn_to_addr(x)	(((unsigned long)(x)) << PAGE_BITS)

/* Extract physical address from page table entry (pte) */
#define __pte_to_addr(x)	(((unsigned long)(x)) & ~PAGE_MASK)

/* Minimum excess needed for word alignment */
#define SZ_WORD				sizeof(unsigned long)
#define WORD_BITS			32

#define BITWISE_GETWORD(x)	((x) >> 5) /* Divide by 32 */
#define	BITWISE_GETBIT(x)	(1 << ((x) % WORD_BITS))

#define align_up(addr, size)		((((unsigned long)(addr)) + ((size) - 1)) & (~((size) - 1)))

/* Generic definitions */
extern unsigned int PAGE_SIZE;
extern unsigned int PAGE_MASK;
extern unsigned int PAGE_BITS;


/* Type-checkable page table elements */
typedef u32 pgd_t;
typedef u32 pmd_t;
typedef u32 pte_t;

/* Page global directory made up of pgd_t entries */
typedef struct pgd_table {
	pgd_t entry[SZ_4K];
} pgd_table_t;

/* Page middle directory made up of pmd_t entries */
typedef struct pmd_table {
	pmd_t entry[256];
} pmd_table_t;


/* Number of pmd tables to describe all physical memory.
 * TODO: Need more for IO etc. */
#define NUM_PMD_TABLES	((PHYS_MEM_END - PHYS_MEM_START) / PAGE_SIZE) \
			/ PMD_NUM_PAGES

/* Page table related */
extern pgd_table_t kspace;
extern pmd_table_t pmd_tables[];
extern unsigned long pmdtab_i;

void paging_init(void);
void init_clear_ptab(void);

#endif /* __GLUE_TEST_MEMORY_H__ */

