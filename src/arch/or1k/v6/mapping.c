/*
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/lib/printk.h>
#include <l4/lib/mutex.h>
#include <l4/lib/string.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/space.h>
#include <l4/generic/bootmem.h>
#include <l4/generic/resource.h>
#include <l4/generic/platform.h>
#include <l4/api/errno.h>
#include INC_SUBARCH(mm.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)
#include INC_GLUE(memlayout.h)
#include INC_ARCH(linker.h)
#include INC_ARCH(asm.h)
#include INC_API(kip.h)
#include INC_ARCH(io.h)

/*
 * Removes initial mappings needed for transition to virtual memory.
 * Used one-time only.
 */
void remove_section_mapping(unsigned long vaddr)
{
	pgd_table_t *pgd = &init_pgd;
	pmd_t pgd_i = PGD_INDEX(vaddr);
	if (!((pgd->entry[pgd_i] & PMD_TYPE_MASK)
	      & PMD_TYPE_SECTION))
		while(1);
	pgd->entry[pgd_i] = 0;
	pgd->entry[pgd_i] |= PMD_TYPE_FAULT;
	arm_invalidate_tlb();
}

/*
 * Maps given section-aligned @paddr to @vaddr using enough number
 * of section-units to fulfill @size in sections. Note this overwrites
 * a mapping if same virtual address was already mapped.
 */
void __add_section_mapping_init(unsigned int paddr,
				unsigned int vaddr,
				unsigned int size,
				unsigned int flags)
{
	pte_t *ppte;
	unsigned int l1_ptab;
	unsigned int l1_offset;

	/* 1st level page table address */
	l1_ptab = virt_to_phys(&init_pgd);

	/* Get the section offset for this vaddr */
	l1_offset = (vaddr >> 18) & 0x3FFC;

	/* The beginning entry for mapping */
	ppte = (unsigned int *)(l1_ptab + l1_offset);
	for(int i = 0; i < size; i++) {
		*ppte = 0;			/* Clear out old value */
		*ppte |= paddr;			/* Assign physical address */
		*ppte |= PMD_TYPE_SECTION;	/* Assign translation type */
		/* Domain is 0, therefore no writes. */
		/* Only kernel access allowed */
		*ppte |= (SVC_RW_USR_NONE << SECTION_AP0);
		/* Cacheability/Bufferability flags */
		*ppte |= flags;
		ppte++;				/* Next section entry */
		paddr += SECTION_SIZE;		/* Next physical section */
	}
	return;
}

void add_section_mapping_init(unsigned int paddr, unsigned int vaddr,
			      unsigned int size, unsigned int flags)
{
	unsigned int psection;
	unsigned int vsection;

	/* Align each address to the pages they reside in */
	psection = paddr & ~SECTION_MASK;
	vsection = vaddr & ~SECTION_MASK;

	if (size == 0)
		return;

	__add_section_mapping_init(psection, vsection, size, flags);

	return;
}

void arch_prepare_pte(u32 paddr, u32 vaddr, unsigned int flags,
		      pte_t *ptep)
{
	/* They must be aligned at this stage */
	BUG_ON(!is_page_aligned(paddr));
	BUG_ON(!is_page_aligned(vaddr));

	/*
	 * NOTE: In v5, the flags converted from generic
	 * by space_flags_to_ptflags() can be directly
	 * written to the pte. No further conversion is needed.
	 * Therefore this function doesn't do much on flags. In
	 * contrast in ARMv7 the flags need an extra level of
	 * processing.
	 */
	if (flags == __MAP_FAULT)
		*ptep = paddr | flags | PTE_TYPE_FAULT;
	else
		*ptep = paddr | flags | PTE_TYPE_SMALL;
}

void arch_write_pte(pte_t *ptep, pte_t pte, u32 vaddr)
{
	/* FIXME:
	 * Clean the dcache and invalidate the icache
	 * for the old translation first?
	 *
	 * The dcache is virtual, therefore the data
	 * in those entries should be cleaned first,
	 * before the translation of that virtual
	 * address is changed to a new physical address.
	 *
	 * Check that the entry was not faulty first.
	 */
	arm_clean_invalidate_cache();

	*ptep = pte;

	/* FIXME: Fix this!
	 * - Use vaddr to clean the dcache pte by MVA.
	 * - Use mapped area to invalidate the icache
	 * - Invalidate the tlb for mapped area
	 */
	arm_clean_invalidate_cache();
	arm_invalidate_tlb();
}


void arch_prepare_write_pte(u32 paddr, u32 vaddr,
			    unsigned int flags, pte_t *ptep)
{
	pte_t pte = 0;

	/* They must be aligned at this stage */
	BUG_ON(!is_page_aligned(paddr));
	BUG_ON(!is_page_aligned(vaddr));

	arch_prepare_pte(paddr, vaddr, flags, &pte);

	arch_write_pte(ptep, pte, vaddr);
}

pmd_t *
arch_pick_pmd(pgd_table_t *pgd, unsigned long vaddr)
{
	return &pgd->entry[PGD_INDEX(vaddr)];
}

/*
 * v5 pmd writes
 */
void arch_write_pmd(pmd_t *pmd_entry, u32 pmd_phys, u32 vaddr)
{
	/* FIXME: Clean the dcache if there was a valid entry */
	*pmd_entry = (pmd_t)(pmd_phys | PMD_TYPE_PMD);
	arm_clean_invalidate_cache(); /*FIXME: Write these properly! */
	arm_invalidate_tlb();
}


int arch_check_pte_access_perms(pte_t pte, unsigned int flags)
{
	if ((pte & PTE_PROT_MASK) >= (flags & PTE_PROT_MASK))
		return 1;
	else
		return 0;
}

/*
 * Tell if a pgd index is a common kernel index.
 * This is used to distinguish common kernel entries
 * in a pgd, when copying page tables.
 */
int is_global_pgdi(int i)
{
	if ((i >= PGD_INDEX(KERNEL_AREA_START) &&
	     i < PGD_INDEX(KERNEL_AREA_END)) ||
	    (i >= PGD_INDEX(IO_AREA_START) &&
	     i < PGD_INDEX(IO_AREA_END)) ||
	    (i == PGD_INDEX(USER_KIP_PAGE)) ||
	    (i == PGD_INDEX(ARM_HIGH_VECTOR)) ||
	    (i == PGD_INDEX(ARM_SYSCALL_VECTOR)) ||
	    (i == PGD_INDEX(USERSPACE_CONSOLE_VBASE)))
		return 1;
	else
		return 0;
}

extern pmd_table_t *pmd_array;

void remove_mapping_pgd_all_user(pgd_table_t *pgd)
{
	pmd_table_t *pmd;

	/* Traverse through all pgd entries. */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		if (!is_global_pgdi(i)) {
			/* Detect a pmd entry */
			if (((pgd->entry[i] & PMD_TYPE_MASK)
			     == PMD_TYPE_PMD)) {

				/* Obtain the user pmd handle */
				pmd = (pmd_table_t *)
				      phys_to_virt((pgd->entry[i] &
						    PMD_ALIGN_MASK));
				/* Free it */
				free_pmd(pmd);
			}

			/* Clear the pgd entry */
			pgd->entry[i] = PMD_TYPE_FAULT;
		}
	}
}


int pgd_count_boot_pmds()
{
	int npmd = 0;
	pgd_table_t *pgd = &init_pgd;

	for (int i = 0; i < PGD_ENTRY_TOTAL; i++)
		if ((pgd->entry[i] & PMD_TYPE_MASK) == PMD_TYPE_PMD)
			npmd++;
	return npmd;
}


/*
 * Jumps from boot pmd/pgd page tables to tables allocated from the cache.
 */
pgd_table_t *arch_realloc_page_tables(void)
{
	pgd_table_t *pgd_new = alloc_pgd();
	pgd_table_t *pgd_old = &init_pgd;
	pmd_table_t *orig, *pmd;

	/* Copy whole pgd entries */
	memcpy(pgd_new, pgd_old, sizeof(pgd_table_t));

	/* Allocate and copy all pmds */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Detect a pmd entry */
		if ((pgd_old->entry[i] & PMD_TYPE_MASK) == PMD_TYPE_PMD) {
			/* Allocate new pmd */
			if (!(pmd = alloc_pmd())) {
				printk("FATAL: PMD allocation "
				       "failed during system initialization\n");
				BUG();
			}

			/* Find original pmd */
			orig = (pmd_table_t *)
				phys_to_virt((pgd_old->entry[i] &
				PMD_ALIGN_MASK));

			/* Copy original to new */
			memcpy(pmd, orig, sizeof(pmd_table_t));

			/* Replace original pmd entry in pgd with new */
			pgd_new->entry[i] = (pmd_t)virt_to_phys(pmd);
			pgd_new->entry[i] |= PMD_TYPE_PMD;
		}
	}

	/* Switch the virtual memory system into new area */
	arm_clean_invalidate_cache();
	arm_drain_writebuffer();
	arm_invalidate_tlb();
	arm_set_ttb(virt_to_phys(pgd_new));
	arm_invalidate_tlb();

	printk("%s: Initial page tables moved from 0x%x to 0x%x physical\n",
	       __KERNELNAME__, virt_to_phys(pgd_old),
	       virt_to_phys(pgd_new));

	return pgd_new;
}

/*
 * Copies global kernel entries into another pgd. Even for
 * sub-pmd ranges the associated pmd entries are copied,
 * assuming any pmds copied are applicable to all tasks in
 * the system.
 */
void copy_pgd_global_by_vrange(pgd_table_t *to, pgd_table_t *from,
			       unsigned long start, unsigned long end)
{
	/* Extend sub-pmd ranges to their respective pmd boundaries */
	start = align(start, PMD_MAP_SIZE);

	if (end < start)
		end = 0;

	/* Aligning would overflow if mapping the last virtual pmd */
	if (end < align(~0, PMD_MAP_SIZE) ||
	    start > end) /* end may have already overflown as input */
		end = align_up(end, PMD_MAP_SIZE);
	else
		end = 0;

	copy_pgds_by_vrange(to, from, start, end);
}

void copy_pgds_by_vrange(pgd_table_t *to, pgd_table_t *from,
			 unsigned long start, unsigned long end)
{
	unsigned long start_i = PGD_INDEX(start);
	unsigned long end_i =  PGD_INDEX(end);
	unsigned long irange = (end_i != 0) ? (end_i - start_i)
			       : (PGD_ENTRY_TOTAL - start_i);

	memcpy(&to->entry[start_i], &from->entry[start_i],
	       irange * sizeof(pmd_t));
}

void arch_copy_pgd_kernel_entries(pgd_table_t *to)
{
	pgd_table_t *from = TASK_PGD(current);

	copy_pgd_global_by_vrange(to, from, KERNEL_AREA_START,
				  KERNEL_AREA_END);
	copy_pgd_global_by_vrange(to, from, IO_AREA_START, IO_AREA_END);
	copy_pgd_global_by_vrange(to, from, USER_KIP_PAGE,
				  USER_KIP_PAGE + PAGE_SIZE);
	copy_pgd_global_by_vrange(to, from, ARM_HIGH_VECTOR,
				  ARM_HIGH_VECTOR + PAGE_SIZE);
	copy_pgd_global_by_vrange(to, from, ARM_SYSCALL_VECTOR,
				  ARM_SYSCALL_VECTOR + PAGE_SIZE);

	/* We temporarily map uart registers to every process */
	copy_pgd_global_by_vrange(to, from, USERSPACE_CONSOLE_VBASE,
				  USERSPACE_CONSOLE_VBASE + PAGE_SIZE);
}

/* Scheduler uses this to switch context */
void arch_space_switch(struct ktcb *to)
{
	pgd_table_t *pgd = TASK_PGD(to);

	arm_clean_invalidate_cache();
	arm_invalidate_tlb();
	arm_set_ttb(virt_to_phys(pgd));
	arm_invalidate_tlb();
}

void idle_task(void)
{
	printk("Idle task.\n");

	while(1);
}

