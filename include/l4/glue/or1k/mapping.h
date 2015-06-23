/*
 * Generic mapping operations
 *
 * Operations on address space mappings that
 * all subarchitectures support generically.
 *
 * Copyright (C) 2008 - 2010 B Labs Ltd.
 * Written by Bahadir Balban
 */

#ifndef __ARM_GLUE_MAPPING_H__
#define __ARM_GLUE_MAPPING_H__

#include INC_SUBARCH(mm.h)

#define TASK_PGD(x)		(x)->space->pgd

unsigned int space_flags_to_ptflags(unsigned int flags);

void add_mapping_pgd(unsigned long paddr, unsigned long vaddr,
		     unsigned int size, unsigned int flags,
		     pgd_table_t *pgd);

void add_mapping(unsigned long paddr, unsigned long vaddr,
		 unsigned int size, unsigned int flags);

void add_boot_mapping(unsigned long paddr, unsigned long vaddr,
		      unsigned int size, unsigned int flags);

int remove_mapping(unsigned long vaddr);
int remove_mapping_pgd(pgd_table_t *pgd, unsigned long vaddr);
void remove_mapping_pgd_all_user(pgd_table_t *pgd);

int check_mapping_pgd(unsigned long vaddr, unsigned long size,
		      unsigned int flags, pgd_table_t *pgd);

int check_mapping(unsigned long vaddr, unsigned long size,
		  unsigned int flags);

void copy_pgd_kern_all(pgd_table_t *);

struct address_space;
int delete_page_tables(struct address_space *space);
int copy_user_tables(struct address_space *new, struct address_space *orig);
void remap_as_pages(void *vstart, void *vend);

void copy_pgds_by_vrange(pgd_table_t *to, pgd_table_t *from,
			 unsigned long start, unsigned long end);

/*
 * TODO: Some of these may be made inline by
 * removing their signature from here completely
 * and creating an arch-specific mapping.h which
 * has inline definitions or just signatures.
 */

pte_t virt_to_pte(unsigned long vaddr);
pte_t *virt_to_ptep(unsigned long vaddr);
pte_t virt_to_pte_from_pgd(pgd_table_t *pgd, unsigned long vaddr);
unsigned long virt_to_phys_by_pgd(pgd_table_t *pgd, unsigned long vaddr);

void arch_prepare_pte(u32 paddr, u32 vaddr, unsigned int flags,
		      pte_t *ptep);

void arch_write_pte(pte_t *ptep, pte_t pte, u32 vaddr);

void arch_prepare_write_pte(u32 paddr, u32 vaddr,
			    unsigned int flags, pte_t *ptep);

pmd_t *arch_pick_pmd(pgd_table_t *pgd, unsigned long vaddr);

void arch_write_pmd(pmd_t *pmd_entry, u32 pmd_phys, u32 vaddr);

int arch_check_pte_access_perms(pte_t pte, unsigned int flags);

pgd_table_t *arch_realloc_page_tables(void);

void arch_copy_pgd_kernel_entries(pgd_table_t *to);

int is_global_pgdi(int i);

struct ktcb;
void arch_space_switch(struct ktcb *task);

int pgd_count_boot_pmds();

void idle_task(void);

#endif /* __ARM_GLUE_MAPPING_H__ */
