/*
 * ARM v5-specific virtual memory details
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __V5_MM_H__
#define __V5_MM_H__

/* ARM specific definitions */
#define VIRT_MEM_START			0
#define VIRT_MEM_END			0xFFFFFFFF
#define SECTION_SIZE			SZ_1MB
#define SECTION_MASK			(SECTION_SIZE - 1)
#define	SECTION_ALIGN_MASK		(~SECTION_MASK)
#define SECTION_BITS			20
#define ARM_PAGE_SIZE			SZ_4K
#define ARM_PAGE_MASK			0xFFF
#define ARM_PAGE_BITS			12

#define	PGD_SIZE				SZ_4K * 4
#define PGD_ENTRY_TOTAL				SZ_4K

#define PMD_SIZE				SZ_1K
#define PMD_ENTRY_TOTAL				256
#define PMD_MAP_SIZE				SZ_1MB
#define	PMD_ALIGN_MASK				(~(PMD_SIZE - 1))
#define	PMD_TYPE_MASK				0x3
#define	PMD_TYPE_FAULT				0
#define	PMD_TYPE_PMD				1
#define	PMD_TYPE_SECTION			2

#define PTE_TYPE_MASK				0x3
#define PTE_TYPE_FAULT				0
#define PTE_TYPE_LARGE				1
#define PTE_TYPE_SMALL				2
#define PTE_TYPE_TINY				3

/* Permission field offsets */
#define SECTION_AP0				10

/*
 * These are indices into arrays with pgd_t or pmd_t sized elements,
 * therefore the index must be divided by appropriate element size
 */
#define PGD_INDEX(x)		(((((unsigned long)(x)) >> 18) \
				  & 0x3FFC) / sizeof(pmd_t))

/*
 * Strip out the page offset in this
 * megabyte from a total of 256 pages.
 */
#define PMD_INDEX(x)		(((((unsigned long)(x)) >> 10) \
				  & 0x3FC) / sizeof (pte_t))


/* We need this as print-early.S is including this file */
#ifndef __ASSEMBLY__

/* Type-checkable page table elements */
typedef u32 pmd_t;
typedef u32 pte_t;

/* Page global directory made up of pgd_t entries */
typedef struct pgd_table {
	pmd_t entry[PGD_ENTRY_TOTAL];
} pgd_table_t;

/* Page middle directory made up of pmd_t entries */
typedef struct pmd_table {
	pte_t entry[PMD_ENTRY_TOTAL];
} pmd_table_t;

/* Applies for both small and large pages */
#define PAGE_AP0				4
#define PAGE_AP1				6
#define	PAGE_AP2				8
#define PAGE_AP3				10

/* Permission values with rom and sys bits ignored */
#define SVC_RW_USR_NONE				1
#define SVC_RW_USR_RO				2
#define SVC_RW_USR_RW				3

#define PTE_PROT_MASK				(0xFF << 4)

#define CACHEABILITY				3
#define BUFFERABILITY				2
#define cacheable				(1 << CACHEABILITY)
#define bufferable				(1 << BUFFERABILITY)
#define uncacheable				0
#define unbufferable				0

/* Helper macros for common cases */
#define __MAP_USR_RW	(cacheable | bufferable | (SVC_RW_USR_RW << PAGE_AP0)		\
			| (SVC_RW_USR_RW << PAGE_AP1) | (SVC_RW_USR_RW << PAGE_AP2)	\
			| (SVC_RW_USR_RW << PAGE_AP3))
#define __MAP_USR_RO	(cacheable | bufferable | (SVC_RW_USR_RO << PAGE_AP0)		\
			| (SVC_RW_USR_RO << PAGE_AP1) | (SVC_RW_USR_RO << PAGE_AP2)	\
			| (SVC_RW_USR_RO << PAGE_AP3))
#define __MAP_KERN_RW	(cacheable | bufferable | (SVC_RW_USR_NONE << PAGE_AP0) 	\
			| (SVC_RW_USR_NONE << PAGE_AP1) | (SVC_RW_USR_NONE << PAGE_AP2)	\
			| (SVC_RW_USR_NONE << PAGE_AP3))
#define __MAP_KERN_IO	(uncacheable | unbufferable | (SVC_RW_USR_NONE << PAGE_AP0)	\
			| (SVC_RW_USR_NONE << PAGE_AP1) | (SVC_RW_USR_NONE << PAGE_AP2)	\
			| (SVC_RW_USR_NONE << PAGE_AP3))
#define __MAP_USR_IO	(uncacheable | unbufferable | (SVC_RW_USR_RW << PAGE_AP0)	\
			| (SVC_RW_USR_RW << PAGE_AP1) | (SVC_RW_USR_RW << PAGE_AP2)	\
			| (SVC_RW_USR_RW << PAGE_AP3))

/* There is no execute bit in ARMv5, so we ignore it */
#define __MAP_USR_RWX	__MAP_USR_RW
#define __MAP_USR_RX	__MAP_USR_RO
#define __MAP_KERN_RWX	__MAP_KERN_RW
#define __MAP_KERN_RX	__MAP_KERN_RW	/* We always have kernel RW */
#define __MAP_FAULT	0

void add_section_mapping_init(unsigned int paddr, unsigned int vaddr,
			      unsigned int size, unsigned int flags);

void remove_section_mapping(unsigned long vaddr);

extern pgd_table_t init_pgd;

#endif /* __ASSEMBLY__ */
#endif /* __V5_MM_H__ */
