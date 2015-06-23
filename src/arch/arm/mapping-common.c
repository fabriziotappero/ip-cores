/*
 * Low-level page table functions that are common
 * and abstracted between v5-v7 ARM architectures
 *
 * Copyright (C) 2007 - 2010 B Labs Ltd.
 * Written by Bahadir Balban
 */

#include INC_SUBARCH(mm.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(memlayout.h)
#include INC_ARCH(linker.h)
#include INC_GLUE(mapping.h)
#include <l4/generic/platform.h>
#include <l4/api/errno.h>
#include <l4/lib/printk.h>
#include <l4/generic/tcb.h>
#include <l4/generic/bootmem.h>
#include <l4/generic/space.h>

/* Find out whether a pmd exists or not and return it */
pmd_table_t *pmd_exists(pgd_table_t *task_pgd, unsigned long vaddr)
{
	pmd_t *pmd = arch_pick_pmd(task_pgd, vaddr);

	/*
	 * Check that it has a valid pmd
	 * (i.e. not a fault, not a section)
	 */
	if ((*pmd & PMD_TYPE_MASK) == PMD_TYPE_PMD)
		return (pmd_table_t *)
		       phys_to_virt(*pmd & PMD_ALIGN_MASK);
	else if ((*pmd & PMD_TYPE_MASK) == 0)
		return 0;
	else
		BUG(); /* Anything that's not a pmd or fault is bug */
	return 0;
}

/*
 * Convert virtual address to a pte from a task-specific pgd
 * FIXME: Remove this by using ptep version, leaving due to
 * too many things to test right now.
 */
pte_t virt_to_pte_from_pgd(pgd_table_t *task_pgd,
			   unsigned long virtual)
{
	pmd_table_t *pmd = pmd_exists(task_pgd, virtual);

	if (pmd)
		return (pte_t)pmd->entry[PMD_INDEX(virtual)];
	else
		return (pte_t)0;
}

/* Convert virtual address to a pte from a task-specific pgd */
pte_t *virt_to_ptep_from_pgd(pgd_table_t *task_pgd,
			     unsigned long virtual)
{
	pmd_table_t *pmd = pmd_exists(task_pgd, virtual);

	if (pmd)
		return (pte_t *)&pmd->entry[PMD_INDEX(virtual)];
	else
		return (pte_t *)0;
}

/*
 * Convert a virtual address to a pte if it
 * exists in the page tables.
 */
pte_t virt_to_pte(unsigned long virtual)
{
	return virt_to_pte_from_pgd(TASK_PGD(current), virtual);
}

pte_t *virt_to_ptep(unsigned long virtual)
{
	return virt_to_ptep_from_pgd(TASK_PGD(current), virtual);
}

unsigned long virt_to_phys_by_pgd(pgd_table_t *pgd, unsigned long vaddr)
{
	pte_t pte = virt_to_pte_from_pgd(pgd, vaddr);
	return pte & ~PAGE_MASK;
}

static inline unsigned long
virt_to_phys_by_task(struct ktcb *task, unsigned long vaddr)
{
	return virt_to_phys_by_pgd(TASK_PGD(task), vaddr);
}

/*
 * Attaches a pmd to either a task or the global pgd
 * depending on the virtual address passed.
 */
void attach_pmd(pgd_table_t *task_pgd, pmd_table_t *pmd_table,
		unsigned long vaddr)
{
	u32 pmd_phys = virt_to_phys(pmd_table);
	pmd_t *pmd;

	BUG_ON(!is_aligned(pmd_phys, PMD_SIZE));

	/*
	 * Pick the right pmd from the right pgd.
	 * It makes a difference if split tables are used.
	 */
	pmd = arch_pick_pmd(task_pgd, vaddr);

	/* Write the pmd into hardware pgd */
	arch_write_pmd(pmd, pmd_phys, vaddr);
}

void add_mapping_pgd(unsigned long physical, unsigned long virtual,
		     unsigned int sz_bytes, unsigned int flags,
		     pgd_table_t *task_pgd)
{
	unsigned long npages = (sz_bytes >> PFN_SHIFT);
	pmd_table_t *pmd_table;

	if (sz_bytes < PAGE_SIZE) {
		print_early("Error: Mapping size less than PAGE_SIZE. "
			   "Mapping size is in bytes not pages.\n");
		BUG();
	}

	if (sz_bytes & PAGE_MASK)
		npages++;

	/* Convert generic map flags to arch specific flags */
	BUG_ON(!(flags = space_flags_to_ptflags(flags)));

	/* Map all pages that cover given size */
	for (int i = 0; i < npages; i++) {
		/* Check if a pmd was attached previously */
		if (!(pmd_table = pmd_exists(task_pgd, virtual))) {

			/* First mapping in pmd, allocate it */
			pmd_table = alloc_pmd();

			/* Prepare the pte but don't sync */
			arch_prepare_pte(physical, virtual, flags,
			&pmd_table->entry[PMD_INDEX(virtual)]);

			/* Attach pmd to its pgd and sync it */
			attach_pmd(task_pgd, pmd_table, virtual);
		} else {
			/* Prepare, write the pte and sync */
			arch_prepare_write_pte(physical, virtual,
			flags, &pmd_table->entry[PMD_INDEX(virtual)]);
		}

		/* Move on to the next page */
		physical += PAGE_SIZE;
		virtual += PAGE_SIZE;
	}
}

void add_boot_mapping(unsigned long physical, unsigned long virtual,
		     unsigned int sz_bytes, unsigned int flags)
{
	unsigned long npages = (sz_bytes >> PFN_SHIFT);
	pmd_table_t *pmd_table;

	if (sz_bytes < PAGE_SIZE) {
		print_early("Error: Mapping size less than PAGE_SIZE. "
			   "Mapping size should be in _bytes_ "
			   "not pages.\n");
		BUG();
	}

	if (sz_bytes & PAGE_MASK)
		npages++;

	/* Convert generic map flags to arch specific flags */
	BUG_ON(!(flags = space_flags_to_ptflags(flags)));

	/* Map all pages that cover given size */
	for (int i = 0; i < npages; i++) {
		/* Check if a pmd was attached previously */
		if (!(pmd_table = pmd_exists(&init_pgd, virtual))) {

			/* First mapping in pmd, allocate it */
			pmd_table = alloc_boot_pmd();

			/* Prepare the pte but don't sync */
			arch_prepare_pte(physical, virtual, flags,
			&pmd_table->entry[PMD_INDEX(virtual)]);

			/* Attach pmd to its pgd and sync it */
			attach_pmd(&init_pgd, pmd_table, virtual);
		} else {
			/* Prepare, write the pte and sync */
			arch_prepare_write_pte(physical, virtual,
			flags, &pmd_table->entry[PMD_INDEX(virtual)]);
		}

		/* Move on to the next page */
		physical += PAGE_SIZE;
		virtual += PAGE_SIZE;
	}
}

void add_mapping(unsigned long paddr, unsigned long vaddr,
		 unsigned int size, unsigned int flags)
{
	add_mapping_pgd(paddr, vaddr, size, flags, TASK_PGD(current));
}

/*
 * Checks if a virtual address range has same or more permissive
 * flags than the given ones, returns 0 if not, and 1 if OK.
 */
int check_mapping_pgd(unsigned long vaddr, unsigned long size,
		      unsigned int flags, pgd_table_t *pgd)
{
	unsigned int npages = __pfn(align_up(size, PAGE_SIZE));
	pte_t pte;

	/* Convert generic map flags to pagetable-specific */
	BUG_ON(!(flags = space_flags_to_ptflags(flags)));

	for (int i = 0; i < npages; i++) {
		pte = virt_to_pte_from_pgd(pgd, vaddr + i * PAGE_SIZE);

		/* Check if pte perms are equal or gt given flags */
		if (arch_check_pte_access_perms(pte, flags))
			continue;
		else
			return 0;
	}

	return 1;
}

int check_mapping(unsigned long vaddr, unsigned long size,
		  unsigned int flags)
{
	return check_mapping_pgd(vaddr, size, flags,
				 TASK_PGD(current));
}

/*
 * This can be made common for v5/v7, keeping split/page table
 * and cache flush parts in arch-specific files.
 */
int remove_mapping_pgd(pgd_table_t *task_pgd, unsigned long vaddr)
{
	pmd_table_t *pmd_table;
	int pgd_i, pmd_i;
	pmd_t *pmd;
	unsigned int pmd_type, pte_type;

	vaddr = page_align(vaddr);
	pgd_i = PGD_INDEX(vaddr);
	pmd_i = PMD_INDEX(vaddr);

	/*
	 * Get the right pgd's pmd according to whether
	 * the address is global or task-specific.
	 */
	pmd = arch_pick_pmd(task_pgd, vaddr);

	pmd_type = *pmd & PMD_TYPE_MASK;

	if (pmd_type == PMD_TYPE_FAULT)
		return -ENOMAP;

	/* Anything else must be a proper pmd */
	BUG_ON(pmd_type != PMD_TYPE_PMD);

	/* Get the 2nd level pmd table */
	pmd_table = (pmd_table_t *)
		    phys_to_virt((unsigned long)*pmd
				 & PMD_ALIGN_MASK);

	/* Get the pte type already there */
	pte_type = pmd_table->entry[pmd_i] & PTE_TYPE_MASK;

	/* If it's a fault we're done */
	if (pte_type == PTE_TYPE_FAULT)
		return -ENOMAP;
	/* It must be a small pte if not fault */
	else if (pte_type != PTE_TYPE_SMALL)
		BUG();

	/* Write to pte, also syncing it as required by arch */
	arch_prepare_write_pte(0, vaddr,
			       space_flags_to_ptflags(MAP_FAULT),
			       (pte_t *)&pmd_table->entry[pmd_i]);
	return 0;
}

int remove_mapping(unsigned long vaddr)
{
	return remove_mapping_pgd(TASK_PGD(current), vaddr);
}


int delete_page_tables(struct address_space *space)
{
	remove_mapping_pgd_all_user(space->pgd);
	free_pgd(space->pgd);
	return 0;
}

/*
 * Copies userspace entries of one task to another.
 * In order to do that, it allocates new pmds and
 * copies the original values into new ones.
 */
int copy_user_tables(struct address_space *new,
		     struct address_space *orig_space)
{
	pgd_table_t *to = new->pgd, *from = orig_space->pgd;
	pmd_table_t *pmd, *orig;

	/* Allocate and copy all pmds that will be exclusive to new task. */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Detect a pmd entry that is not a global pmd? */
		if (!is_global_pgdi(i) &&
		    ((from->entry[i] & PMD_TYPE_MASK)
		     == PMD_TYPE_PMD)) {
			/* Allocate new pmd */
			if (!(pmd = alloc_pmd()))
				goto out_error;

			/* Find original pmd */
			orig = (pmd_table_t *)
				phys_to_virt((from->entry[i] &
				PMD_ALIGN_MASK));

			/* Copy original to new */
			memcpy(pmd, orig, sizeof(pmd_table_t));

			/* Replace original pmd entry in pgd with new */
			to->entry[i] = (pmd_t)(virt_to_phys(pmd)
					       | PMD_TYPE_PMD);
		}
	}

	/* Just in case the new table is written to any ttbr
	 * after here, make sure all writes on it are complete. */
	dmb();

	return 0;

out_error:
	/* Find all non-kernel pmds we have just allocated and free them */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Non-kernel pmd that has just been allocated. */
		if (!is_global_pgdi(i) &&
		    (to->entry[i] & PMD_TYPE_MASK) == PMD_TYPE_PMD) {
			/* Obtain the pmd handle */
			pmd = (pmd_table_t *)
			      phys_to_virt((to->entry[i] &
					    PMD_ALIGN_MASK));
			/* Free pmd  */
			free_pmd(pmd);
		}
	}
	return -ENOMEM;
}



/*
 * Useful for upgrading to page-grained control
 * over the kernel section mapping.
 *
 * Remaps a section mapping in pages. It allocates a pmd,
 * fills in the page information, and replaces the direct
 * section physical translation with the address of the
 * pmd. Syncs the caches.
 *
 * NOTE: Assumes only a single pmd is enough.
 */
void remap_as_pages(void *vstart, void *vend)
{
	unsigned long pstart = virt_to_phys(vstart);
	unsigned long pend = virt_to_phys(vend);
	unsigned long paddr = pstart;
	unsigned long vaddr = (unsigned long)vstart;
	int pmd_i = PMD_INDEX(vstart);
	pgd_table_t *pgd = &init_pgd;
	pmd_table_t *pmd = alloc_boot_pmd();
	int npages = __pfn(pend - pstart);
	int map_flags;

	/* Map the whole kernel into the pmd first */
	for (int n = 0; n < npages; n++) {
		/* Map text pages as executable */
		if ((vaddr >= (unsigned long)_start_text &&
		     vaddr < page_align_up(_end_text)) ||
		    (vaddr >= (unsigned long)_start_vectors &&
		     vaddr < page_align_up(_end_vectors)))
			map_flags = MAP_KERN_RWX;
		else
			map_flags = MAP_KERN_RW;

		arch_prepare_pte(paddr, vaddr,
				 space_flags_to_ptflags(map_flags),
				 &pmd->entry[pmd_i + n]);
		paddr += PAGE_SIZE;
		vaddr += PAGE_SIZE;
	}

	attach_pmd(pgd, pmd, (unsigned long)vstart);

	printk("%s: Kernel area 0x%lx - 0x%lx "
	       "remapped as %d pages\n", __KERNELNAME__,
	       (unsigned long)vstart, (unsigned long)vend,
	       npages);
}

