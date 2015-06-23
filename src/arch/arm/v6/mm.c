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
#include <l4/api/errno.h>
#include INC_SUBARCH(mm.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_GLUE(memory.h)
#include INC_PLAT(printascii.h)
#include INC_GLUE(memlayout.h)
#include INC_ARCH(linker.h)
#include INC_ARCH(asm.h)
#include INC_API(kip.h)

/*
 * These are indices into arrays with pgd_t or pmd_t sized elements,
 * therefore the index must be divided by appropriate element size
 */
#define PGD_INDEX(x)		(((((unsigned long)(x)) >> 18) & 0x3FFC) / sizeof(pgd_t))
/* Strip out the page offset in this megabyte from a total of 256 pages. */
#define PMD_INDEX(x)		(((((unsigned long)(x)) >> 10) & 0x3FC) / sizeof (pmd_t))

/*
 * Removes initial mappings needed for transition to virtual memory.
 * Used one-time only.
 */
void remove_section_mapping(unsigned long vaddr)
{
	pgd_table_t *pgd = &init_pgd;;
	pgd_t pgd_i = PGD_INDEX(vaddr);
	if (!((pgd->entry[pgd_i] & PGD_TYPE_MASK)
	      & PGD_TYPE_SECTION))
		while(1);
	pgd->entry[pgd_i] = 0;
	pgd->entry[pgd_i] |= PGD_TYPE_FAULT;
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
		*ppte |= PGD_TYPE_SECTION;	/* Assign translation type */
		/* Domain is 0, therefore no writes. */
		/* Only kernel access allowed */
		*ppte |= (SVC_RW_USR_NONE << SECTION_AP0);
		/* Cacheability/Bufferability flags */
		*ppte |= flags;
		ppte++;				/* Next section entry */
		paddr += ARM_SECTION_SIZE;	/* Next physical section */
	}
	return;
}

void add_section_mapping_init(unsigned int paddr, unsigned int vaddr,
			      unsigned int size, unsigned int flags)
{
	unsigned int psection;
	unsigned int vsection;

	/* Align each address to the pages they reside in */
	psection = paddr & ~ARM_SECTION_MASK;
	vsection = vaddr & ~ARM_SECTION_MASK;

	if(size == 0)
		return;

	__add_section_mapping_init(psection, vsection, size, flags);

	return;
}

/* TODO: Make sure to flush tlb entry and caches */
void __add_mapping(unsigned int paddr, unsigned int vaddr,
		   unsigned int flags, pmd_table_t *pmd)
{
	unsigned int pmd_i = PMD_INDEX(vaddr);
	pmd->entry[pmd_i] = paddr;
	pmd->entry[pmd_i] |= PMD_TYPE_SMALL;	   /* Small page type */
	pmd->entry[pmd_i] |= flags;

	/* TODO: Is both required? Investigate */

	/* TEST:
	 * I think cleaning or invalidating the cache is not required,
	 * because the entries in the cache aren't for the new mapping anyway.
	 * It's required if a mapping is removed, but not when newly added.
	 */
	arm_clean_invalidate_cache();

	/* TEST: tlb must be flushed because a new mapping is present in page
	 * tables, and tlb is inconsistent with the page tables */
	arm_invalidate_tlb();
}

/* Return whether a pmd associated with @vaddr is mapped on a pgd or not. */
pmd_table_t *pmd_exists(pgd_table_t *pgd, unsigned long vaddr)
{
	unsigned int pgd_i = PGD_INDEX(vaddr);

	/* Return true if non-zero pgd entry */
	switch (pgd->entry[pgd_i] & PGD_TYPE_MASK) {
		case PGD_TYPE_COARSE:
			return (pmd_table_t *)
			       phys_to_virt((pgd->entry[pgd_i] &
					    PGD_COARSE_ALIGN_MASK));
			break;

		case PGD_TYPE_FAULT:
			return 0;
			break;

		case PGD_TYPE_SECTION:
			dprintk("Warning, a section is already mapped "
				"where a coarse page mapping is attempted:",
				(u32)(pgd->entry[pgd_i]
				      & PGD_SECTION_ALIGN_MASK));
				BUG();
			break;

		case PGD_TYPE_FINE:
			dprintk("Warning, a fine page table is already mapped "
				"where a coarse page mapping is attempted:",
				(u32)(pgd->entry[pgd_i]
				      & PGD_FINE_ALIGN_MASK));
			printk("Fine tables are unsupported. ");
			printk("What is this doing here?");
			BUG();
			break;

		default:
			dprintk("Unrecognised pmd type @ pgd index:", pgd_i);
			BUG();
			break;
	}
	return 0;
}

/* Convert a virtual address to a pte if it exists in the page tables. */
pte_t virt_to_pte_from_pgd(unsigned long virtual, pgd_table_t *pgd)
{
	pmd_table_t *pmd = pmd_exists(pgd, virtual);

	if (pmd)
		return (pte_t)pmd->entry[PMD_INDEX(virtual)];
	else
		return (pte_t)0;
}

/* Convert a virtual address to a pte if it exists in the page tables. */
pte_t virt_to_pte(unsigned long virtual)
{
	return virt_to_pte_from_pgd(virtual, TASK_PGD(current));
}

unsigned long virt_to_phys_by_pgd(unsigned long vaddr, pgd_table_t *pgd)
{
	pte_t pte = virt_to_pte_from_pgd(vaddr, pgd);
	return pte & ~PAGE_MASK;
}

unsigned long virt_to_phys_by_task(unsigned long vaddr, struct ktcb *task)
{
	return virt_to_phys_by_pgd(vaddr, TASK_PGD(task));
}

void attach_pmd(pgd_table_t *pgd, pmd_table_t *pmd, unsigned int vaddr)
{
	u32 pgd_i = PGD_INDEX(vaddr);
	u32 pmd_phys = virt_to_phys(pmd);

	/* Domain is 0, therefore no writes. */
	pgd->entry[pgd_i] = (pgd_t)pmd_phys;
	pgd->entry[pgd_i] |= PGD_TYPE_COARSE;
}

/*
 * Same as normal mapping but with some boot tweaks.
 */
void add_boot_mapping(unsigned int paddr, unsigned int vaddr,
		      unsigned int size, unsigned int flags)
{
	pmd_table_t *pmd;
	pgd_table_t *pgd = &init_pgd;
	unsigned int numpages = (size >> PAGE_BITS);

	if (size < PAGE_SIZE) {
		printascii("Error: Mapping size must be in bytes not pages.\n");
		while(1);
	}
	if (size & PAGE_MASK)
		numpages++;

	/* Convert generic map flags to pagetable-specific */
	BUG_ON(!(flags = space_flags_to_ptflags(flags)));

	/* Map all consecutive pages that cover given size */
	for (int i = 0; i < numpages; i++) {
		/* Check if another mapping already has a pmd attached. */
		pmd = pmd_exists(pgd, vaddr);
		if (!pmd) {
			/*
			 * If this is the first vaddr in
			 * this pmd, allocate new pmd
			 */
			pmd = alloc_boot_pmd();

			/* Attach pmd to its entry in pgd */
			attach_pmd(pgd, pmd, vaddr);
		}

		/* Attach paddr to this pmd */
		__add_mapping(page_align(paddr),
			      page_align(vaddr), flags, pmd);

		/* Go to the next page to be mapped */
		paddr += PAGE_SIZE;
		vaddr += PAGE_SIZE;
	}
}

/*
 * Maps @paddr to @vaddr, covering @size bytes also allocates new pmd if
 * necessary. This flavor explicitly supplies the pgd to modify. This is useful
 * when modifying userspace of processes that are not currently running. (Only
 * makes sense for userspace mappings since kernel mappings are common.)
 */
void add_mapping_pgd(unsigned int paddr, unsigned int vaddr,
		     unsigned int size, unsigned int flags,
		     pgd_table_t *pgd)
{
	pmd_table_t *pmd;
	unsigned int numpages = (size >> PAGE_BITS);


	if (size < PAGE_SIZE) {
		printascii("Error: Mapping size must be in bytes not pages.\n");
		while(1);
	}
	if (size & PAGE_MASK)
		numpages++;

	/* Convert generic map flags to pagetable-specific */
	BUG_ON(!(flags = space_flags_to_ptflags(flags)));

	/* Map all consecutive pages that cover given size */
	for (int i = 0; i < numpages; i++) {
		/* Check if another mapping already has a pmd attached. */
		pmd = pmd_exists(pgd, vaddr);
		if (!pmd) {
			/*
			 * If this is the first vaddr in
			 * this pmd, allocate new pmd
			 */
			pmd = alloc_pmd();

			/* Attach pmd to its entry in pgd */
			attach_pmd(pgd, pmd, vaddr);
		}

		/* Attach paddr to this pmd */
		__add_mapping(page_align(paddr),
			      page_align(vaddr), flags, pmd);

		/* Go to the next page to be mapped */
		paddr += PAGE_SIZE;
		vaddr += PAGE_SIZE;
	}
}

void add_mapping(unsigned int paddr, unsigned int vaddr,
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
		pte = virt_to_pte_from_pgd(vaddr + i * PAGE_SIZE, pgd);

		/* Check if pte perms are equal or gt given flags */
		if ((pte & PTE_PROT_MASK) >= (flags & PTE_PROT_MASK))
			continue;
		else
			return 0;
	}

	return 1;
}

int check_mapping(unsigned long vaddr, unsigned long size,
		  unsigned int flags)
{
	return check_mapping_pgd(vaddr, size, flags, TASK_PGD(current));
}

/* FIXME: Empty PMDs should be returned here !!! */
int __remove_mapping(pmd_table_t *pmd, unsigned long vaddr)
{
	pmd_t pmd_i = PMD_INDEX(vaddr);
	int ret;

	switch (pmd->entry[pmd_i] & PMD_TYPE_MASK) {
		case PMD_TYPE_FAULT:
			ret = -ENOENT;
			break;
		case PMD_TYPE_LARGE:
			pmd->entry[pmd_i] = 0;
			pmd->entry[pmd_i] |= PMD_TYPE_FAULT;
			ret = 0;
			break;
		case PMD_TYPE_SMALL:
			pmd->entry[pmd_i] = 0;
			pmd->entry[pmd_i] |= PMD_TYPE_FAULT;
			ret = 0;
			break;
		default:
			printk("Unknown page mapping in pmd. Assuming bug.\n");
			BUG();
	}
	return ret;
}

/*
 * Tell if a pgd index is a common kernel index. This is used to distinguish
 * common kernel entries in a pgd, when copying page tables.
 */
int is_kern_pgdi(int i)
{
	if ((i >= PGD_INDEX(KERNEL_AREA_START) && i < PGD_INDEX(KERNEL_AREA_END)) ||
	    (i >= PGD_INDEX(IO_AREA_START) && i < PGD_INDEX(IO_AREA_END)) ||
	    (i == PGD_INDEX(USER_KIP_PAGE)) ||
	    (i == PGD_INDEX(ARM_HIGH_VECTOR)) ||
	    (i == PGD_INDEX(ARM_SYSCALL_VECTOR)) ||
	    (i == PGD_INDEX(USERSPACE_UART_BASE)))
		return 1;
	else
		return 0;
}

/*
 * Removes all userspace mappings from a pgd. Frees any pmds that it
 * detects to be user pmds
 */
int remove_mapping_pgd_all_user(pgd_table_t *pgd)
{
	pmd_table_t *pmd;

	/* Traverse through all pgd entries */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {

		/* Detect a pgd entry that is not a kernel entry */
		if (!is_kern_pgdi(i)) {

			/* Detect a pmd entry */
			if (((pgd->entry[i] & PGD_TYPE_MASK)
			     == PGD_TYPE_COARSE)) {

				/* Obtain the user pmd handle */
				pmd = (pmd_table_t *)
				      phys_to_virt((pgd->entry[i] &
						    PGD_COARSE_ALIGN_MASK));
				/* Free it */
				free_pmd(pmd);
			}

			/* Clear the pgd entry */
			pgd->entry[i] = PGD_TYPE_FAULT;
		}
	}

	return 0;
}

int remove_mapping_pgd(unsigned long vaddr, pgd_table_t *pgd)
{
	pgd_t pgd_i = PGD_INDEX(vaddr);
	pmd_table_t *pmd;
	pmd_t pmd_i;
	int ret;

	/*
	 * Clean the cache to main memory before removing the mapping. Otherwise
	 * entries in the cache for this mapping will cause tranlation faults
	 * if they're cleaned to main memory after the mapping is removed.
	 */
	arm_clean_invalidate_cache();

	/* TEST:
	 * Can't think of a valid reason to flush tlbs here, but keeping it just
	 * to be safe. REMOVE: Remove it if it's unnecessary.
	 */
	arm_invalidate_tlb();

	/* Return true if non-zero pgd entry */
	switch (pgd->entry[pgd_i] & PGD_TYPE_MASK) {
		case PGD_TYPE_COARSE:
			// printk("Removing coarse mapping @ 0x%x\n", vaddr);
			pmd = (pmd_table_t *)
			      phys_to_virt((pgd->entry[pgd_i]
					   & PGD_COARSE_ALIGN_MASK));
			pmd_i = PMD_INDEX(vaddr);
			ret = __remove_mapping(pmd, vaddr);
			break;

		case PGD_TYPE_FAULT:
			ret = -1;
			break;

		case PGD_TYPE_SECTION:
			printk("Removing section mapping for 0x%lx",
			       vaddr);
			pgd->entry[pgd_i] = 0;
			pgd->entry[pgd_i] |= PGD_TYPE_FAULT;
			ret = 0;
			break;

		case PGD_TYPE_FINE:
			printk("Table mapped is a fine page table.\n"
			       "Fine tables are unsupported. Assuming bug.\n");
			BUG();
			break;

		default:
			dprintk("Unrecognised pmd type @ pgd index:", pgd_i);
			printk("Assuming bug.\n");
			BUG();
			break;
	}
	/* The tlb must be invalidated here because it might have cached the
	 * old translation for this mapping. */
	arm_invalidate_tlb();

	return ret;
}

int remove_mapping(unsigned long vaddr)
{
	return remove_mapping_pgd(vaddr, TASK_PGD(current));
}

int delete_page_tables(struct address_space *space)
{
	remove_mapping_pgd_all_user(space->pgd);
	free_pgd(space->pgd);
	return 0;
}

/*
 * Copies userspace entries of one task to another. In order to do that,
 * it allocates new pmds and copies the original values into new ones.
 */
int copy_user_tables(struct address_space *new, struct address_space *orig_space)
{
	pgd_table_t *to = new->pgd, *from = orig_space->pgd;
	pmd_table_t *pmd, *orig;

	/* Allocate and copy all pmds that will be exclusive to new task. */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Detect a pmd entry that is not a kernel pmd? */
		if (!is_kern_pgdi(i) &&
		    ((from->entry[i] & PGD_TYPE_MASK) == PGD_TYPE_COARSE)) {
			/* Allocate new pmd */
			if (!(pmd = alloc_pmd()))
				goto out_error;

			/* Find original pmd */
			orig = (pmd_table_t *)
				phys_to_virt((from->entry[i] &
				PGD_COARSE_ALIGN_MASK));

			/* Copy original to new */
			memcpy(pmd, orig, sizeof(pmd_table_t));

			/* Replace original pmd entry in pgd with new */
			to->entry[i] = (pgd_t)virt_to_phys(pmd);
			to->entry[i] |= PGD_TYPE_COARSE;
		}
	}

	return 0;

out_error:
	/* Find all non-kernel pmds we have just allocated and free them */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Non-kernel pmd that has just been allocated. */
		if (!is_kern_pgdi(i) &&
		    (to->entry[i] & PGD_TYPE_MASK) == PGD_TYPE_COARSE) {
			/* Obtain the pmd handle */
			pmd = (pmd_table_t *)
			      phys_to_virt((to->entry[i] &
					    PGD_COARSE_ALIGN_MASK));
			/* Free pmd  */
			free_pmd(pmd);
		}
	}
	return -ENOMEM;
}

int pgd_count_pmds(pgd_table_t *pgd)
{
	int npmd = 0;

	for (int i = 0; i < PGD_ENTRY_TOTAL; i++)
		if ((pgd->entry[i] & PGD_TYPE_MASK) == PGD_TYPE_COARSE)
			npmd++;
	return npmd;
}

/*
 * Allocates and copies all levels of page tables from one task to another.
 * Useful when forking.
 *
 * The copied page tables end up having shared pmds for kernel entries
 * and private copies of same pmds for user entries.
 */
pgd_table_t *copy_page_tables(pgd_table_t *from)
{
	pmd_table_t *pmd, *orig;
	pgd_table_t *pgd;

	/* Allocate and copy pgd. This includes all kernel entries */
	if (!(pgd = alloc_pgd()))
		return PTR_ERR(-ENOMEM);

	/* First copy whole pgd entries */
	memcpy(pgd, from, sizeof(pgd_table_t));

	/* Allocate and copy all pmds that will be exclusive to new task. */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Detect a pmd entry that is not a kernel pmd? */
		if (!is_kern_pgdi(i) &&
		    ((pgd->entry[i] & PGD_TYPE_MASK) == PGD_TYPE_COARSE)) {
			/* Allocate new pmd */
			if (!(pmd = alloc_pmd()))
				goto out_error;

			/* Find original pmd */
			orig = (pmd_table_t *)
				phys_to_virt((pgd->entry[i] &
				PGD_COARSE_ALIGN_MASK));

			/* Copy original to new */
			memcpy(pmd, orig, sizeof(pmd_table_t));

			/* Replace original pmd entry in pgd with new */
			pgd->entry[i] = (pgd_t)virt_to_phys(pmd);
			pgd->entry[i] |= PGD_TYPE_COARSE;
		}
	}

	return pgd;

out_error:
	/* Find all allocated non-kernel pmds and free them */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Non-kernel pmd that has just been allocated. */
		if (!is_kern_pgdi(i) &&
		    (pgd->entry[i] & PGD_TYPE_MASK) == PGD_TYPE_COARSE) {
			/* Obtain the pmd handle */
			pmd = (pmd_table_t *)
			      phys_to_virt((pgd->entry[i] &
					    PGD_COARSE_ALIGN_MASK));
			/* Free pmd  */
			free_pmd(pmd);
		}
	}
	/* Free the pgd */
	free_pgd(pgd);
	return PTR_ERR(-ENOMEM);
}

extern pmd_table_t *pmd_array;

/*
 * Jumps from boot pmd/pgd page tables to tables allocated from the cache.
 */
pgd_table_t *realloc_page_tables(void)
{
	pgd_table_t *pgd_new = alloc_pgd();
	pgd_table_t *pgd_old = &init_pgd;
	pmd_table_t *orig, *pmd;

	/* Copy whole pgd entries */
	memcpy(pgd_new, pgd_old, sizeof(pgd_table_t));

	/* Allocate and copy all pmds */
	for (int i = 0; i < PGD_ENTRY_TOTAL; i++) {
		/* Detect a pmd entry */
		if ((pgd_old->entry[i] & PGD_TYPE_MASK) == PGD_TYPE_COARSE) {
			/* Allocate new pmd */
			if (!(pmd = alloc_pmd())) {
				printk("FATAL: PMD allocation "
				       "failed during system initialization\n");
				BUG();
			}

			/* Find original pmd */
			orig = (pmd_table_t *)
				phys_to_virt((pgd_old->entry[i] &
				PGD_COARSE_ALIGN_MASK));

			/* Copy original to new */
			memcpy(pmd, orig, sizeof(pmd_table_t));

			/* Replace original pmd entry in pgd with new */
			pgd_new->entry[i] = (pgd_t)virt_to_phys(pmd);
			pgd_new->entry[i] |= PGD_TYPE_COARSE;
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
 * Useful for upgrading to page-grained control over a section mapping:
 * Remaps a section mapping in pages. It allocates a pmd, (at all times because
 * there can't really be an already existing pmd for a section mapping) fills
 * in the page information, and origaces the direct section physical translation
 * with the address of the pmd. Flushes the caches/tlbs.
 */
void remap_as_pages(void *vstart, void *vend)
{
	unsigned long pstart = virt_to_phys(vstart);
	unsigned long pend = virt_to_phys(vend);
	unsigned long paddr = pstart;
	pgd_t pgd_i = PGD_INDEX(vstart);
	pmd_t pmd_i = PMD_INDEX(vstart);
	pgd_table_t *pgd = &init_pgd;
	pmd_table_t *pmd = alloc_boot_pmd();
	u32 pmd_phys = virt_to_phys(pmd);
	int numpages = __pfn(pend - pstart);

	/* Fill in the pmd first */
	for (int n = 0; n < numpages; n++) {
		pmd->entry[pmd_i + n] = paddr;
		pmd->entry[pmd_i + n] |= PMD_TYPE_SMALL; /* Small page type */
		pmd->entry[pmd_i + n] |= space_flags_to_ptflags(MAP_SVC_DEFAULT_FLAGS);
		paddr += PAGE_SIZE;
	}

	/* Fill in the type to produce a complete pmd translator information */
	pmd_phys |= PGD_TYPE_COARSE;

	/* Make sure memory is coherent first. */
	arm_clean_invalidate_cache();
	arm_invalidate_tlb();

	/* Replace the direct section physical address with pmd's address */
	pgd->entry[pgd_i] = (pgd_t)pmd_phys;
	printk("%s: Kernel area 0x%lx - 0x%lx remapped as %d pages\n", __KERNELNAME__,
	       (unsigned long)vstart, (unsigned long)vend, numpages);
}

void copy_pgds_by_vrange(pgd_table_t *to, pgd_table_t *from,
			 unsigned long start, unsigned long end)
{
	unsigned long start_i = PGD_INDEX(start);
	unsigned long end_i =  PGD_INDEX(end);
	unsigned long irange = (end_i != 0) ? (end_i - start_i)
			       : (PGD_ENTRY_TOTAL - start_i);

	memcpy(&to->entry[start_i], &from->entry[start_i],
	       irange * sizeof(pgd_t));
}


/* Scheduler uses this to switch context */
void arch_hardware_flush(pgd_table_t *pgd)
{
	arm_clean_invalidate_cache();
	arm_invalidate_tlb();
	arm_set_ttb(virt_to_phys(pgd));
	arm_invalidate_tlb();
}

