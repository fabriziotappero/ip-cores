/*
 * ARMv5 specific functions
 *
 * Copyright (C) 2008 - 2010 B Labs Ltd.
 */
#include <task.h>
#include <vm_area.h>
#include <l4lib/exregs.h>
#include __INC_ARCH(mm.h)

/* Extracts generic protection flags from architecture-specific pte */
unsigned int vm_prot_flags(pte_t pte)
{
	unsigned int vm_prot_flags = 0;
	unsigned int rw_flags = __MAP_USR_RW & PTE_PROT_MASK;
	unsigned int ro_flags = __MAP_USR_RO & PTE_PROT_MASK;

	/* Clear non-protection flags */
	pte &= PTE_PROT_MASK;

	if (pte == ro_flags)
		vm_prot_flags = VM_READ | VM_EXEC;
	else if (pte == rw_flags)
		vm_prot_flags = VM_READ | VM_WRITE | VM_EXEC;
	else
		vm_prot_flags = VM_NONE;

	return vm_prot_flags;
}

/*
 * PTE STATES:
 * PTE type field: 00 (Translation fault)
 * PTE type field correct, AP bits: None (Read or Write access fault)
 * PTE type field correct, AP bits: RO (Write access fault)
 */

/*
 * Extracts arch-specific fault parameters
 * and puts them into generic format
 */
void set_generic_fault_params(struct fault_data *fault)
{
	unsigned int prot_flags = vm_prot_flags(fault->kdata->pte);

	fault->reason = 0;
	fault->pte_flags = prot_flags;

	if (is_prefetch_abort(fault->kdata->fsr)) {
		fault->reason |= VM_READ;
		fault->address = fault->kdata->faulty_pc;
	} else {
		fault->address = fault->kdata->far;

		/* Always assume read fault first */
		if (prot_flags & VM_NONE)
			fault->reason |= VM_READ;
		else if (prot_flags & VM_READ)
			fault->reason |= VM_WRITE;
		else
			BUG();
	}
	arch_print_fault_params(fault);
}

