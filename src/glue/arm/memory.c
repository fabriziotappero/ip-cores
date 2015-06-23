/*
 * ARM virtual memory implementation
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/lib/list.h>
#include <l4/lib/string.h>
#include <l4/lib/printk.h>
#include <l4/generic/space.h>
#include <l4/generic/tcb.h>
#include <l4/generic/platform.h>
#include INC_SUBARCH(mm.h)
#include INC_GLUE(memlayout.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)
#include INC_PLAT(offsets.h)
#include INC_ARCH(linker.h)
#include INC_ARCH(asm.h)

/*
 * Return arch-specific pte flags from generic space flags.
 */
unsigned int space_flags_to_ptflags(unsigned int flags)
{
	switch (flags) {
	case MAP_FAULT:
		return __MAP_FAULT;
	case MAP_USR_RW:
		return __MAP_USR_RW;
	case MAP_USR_RO:
		return __MAP_USR_RO;
	case MAP_KERN_RW:
		return __MAP_KERN_RW;
	case MAP_USR_IO:
		return __MAP_USR_IO;
	case MAP_KERN_IO:
		return __MAP_KERN_IO;
	case MAP_USR_RWX:
		return __MAP_USR_RWX;
	case MAP_KERN_RWX:
		return __MAP_KERN_RWX;
	case MAP_USR_RX:
		return __MAP_USR_RX;
	case MAP_KERN_RX:
		return __MAP_KERN_RX;
	/*
	 * Don't remove this, if a flag with
	 * same value is introduced, compiler will warn us
	 */
	case MAP_INVALID_FLAGS:
	default:
		return MAP_INVALID_FLAGS;
	}

	return 0;
}

void task_init_registers(struct ktcb *task, unsigned long pc)
{
	task->context.pc = (u32)pc;
	task->context.spsr = ARM_MODE_USR;
}


/*
 * Copies all global kernel entries that a user process
 * should have in its pgd. In split page table setups
 * this is a noop.
 */
void copy_pgd_kernel_entries(pgd_table_t *to)
{
	arch_copy_pgd_kernel_entries(to);
}

