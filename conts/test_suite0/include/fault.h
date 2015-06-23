#ifndef __FAULT_H__
#define __FAULT_H__

#include <l4/macros.h>
#include <l4/types.h>
#include INC_GLUE(memory.h)
#include INC_ARCH(exception.h)

/* Protection flags */
#define VM_NONE				(1 << 0)
#define VM_READ				(1 << 1)
#define VM_EXEC				(1 << 2)
#define VM_WRITE			(1 << 3)
#define VM_PROT_MASK			(VM_READ | VM_WRITE | VM_EXEC)

/* Shared copy of a file */
#define VMA_SHARED			(1 << 4)
/* VMA that's not file-backed, always maps devzero as VMA_COW */
#define VMA_ANONYMOUS			(1 << 5)
/* Private copy of a file */
#define VMA_PRIVATE			(1 << 6)
/* For wired pages */
#define VMA_FIXED			(1 << 7)
/* For stack, where mmap returns end address */
#define VMA_GROWSDOWN			(1 << 8)

/* Set when the page is dirty in cache but not written to disk */
#define VM_DIRTY			(1 << 9)

/* Fault data specific to this task + ptr to kernel's data */
struct fault_data {
	fault_kdata_t *kdata;		/* Generic data forged by the kernel */
	unsigned int reason;		/* Generic fault reason flags */
	unsigned int address;		/* Aborted address */
	unsigned int pte_flags;		/* Generic protection flags on pte */
	l4id_t sender;			/* Inittask-related fault data */
};


void set_generic_fault_params(struct fault_data *fault);
void arch_print_fault_params(struct fault_data *fault);
void fault_handle_error(struct fault_data *fault);

#endif /* __FAULT_H__ */
