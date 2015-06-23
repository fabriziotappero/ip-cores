/*
 * ARMv7 specific functions
 *
 * Copyright (C) 2008 - 2010 B Labs Ltd.
 */
#include <task.h>
#include <vm_area.h>
#include <l4lib/exregs.h>
#include __INC_ARCH(mm.h)
#include INC_SUBARCH(mm.h)
#include INC_SUBARCH(exception.h)

/* Get simplified access permissions */
int pte_get_access_simple(pte_t pte)
{
	/* Place AP[2] and AP[1] in [1:0] positions and return */
	return (((pte >> PTE_AP2_BIT) & 1) << 1)
	       | ((pte >> PTE_AP1_BIT) & 1);
}

int is_translation_fault(u32 fsr)
{
	return (fsr & FSR_FS_MASK) == ABORT_TRANSLATION_PAGE;
}

unsigned int vm_prot_flags(pte_t pte, u32 fsr)
{
	unsigned int pte_prot_flags = 0;

	/* Translation fault means no permissions */
	if (is_translation_fault(fsr))
		return VM_NONE;

	/* Check simplified permission bits */
	switch (pte_get_access_simple(pte)) {
	case AP_SIMPLE_USER_RW_KERN_RW:
		pte_prot_flags |= VM_WRITE;
	case AP_SIMPLE_USER_RO_KERN_RO:
		pte_prot_flags |= VM_READ;

		/* Also, check exec never bit */
		if (!(pte & (1 << PTE_XN_BIT)))
			pte_prot_flags |= VM_EXEC;
		break;
	case AP_SIMPLE_USER_NONE_KERN_RW:
	case AP_SIMPLE_USER_NONE_KERN_RO:
	default:
		pte_prot_flags = VM_NONE;
		break;
	}

	return pte_prot_flags;
}

void set_generic_fault_params(struct fault_data *fault)
{
	fault->pte_flags = vm_prot_flags(fault->kdata->pte, fault->kdata->fsr);
	fault->reason = 0;

	/*
	 * Prefetch fault denotes exec fault.
	 */
	if (is_prefetch_abort(fault->kdata->fsr)) {
		fault->reason |= VM_EXEC;
		fault->address = fault->kdata->faulty_pc;
	} else {
		fault->address = fault->kdata->far;

		/* Write-not-read bit determines fault */
		if (fault->kdata->fsr & (1 << DFSR_WNR_BIT))
			fault->reason |= VM_WRITE;
		else
			fault->reason |= VM_READ;
	}
	arch_print_fault_params(fault);
}

