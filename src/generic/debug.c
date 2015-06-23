/*
 * Basic debug information about the kernel
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Written by Bahadir Balban
 */
#include <l4/lib/printk.h>
#include <l4/generic/debug.h>
#include INC_SUBARCH(cpu.h)
#include <l4/generic/platform.h>

#if defined (CONFIG_DEBUG_ACCOUNTING)

struct system_accounting system_accounting;

void system_accounting_print(struct system_accounting *sys_acc)
{
	printk("System Operations Accounting:\n\n");

	printk("System calls:\n");
	printk("=============\n");
	printk("IPC: %llu\n", sys_acc->syscalls.ipc);
	printk("Thread Switch: %llu\n", sys_acc->syscalls.tswitch);
	printk("Thread Control: %llu\n", sys_acc->syscalls.tctrl);
	printk("Exchange Registers: %llu\n", sys_acc->syscalls.exregs);
	printk("Unmap: %llu\n", sys_acc->syscalls.unmap);
	printk("Irq Control: %llu\n", sys_acc->syscalls.irqctrl);
	printk("Map: %llu\n", sys_acc->syscalls.map);
	printk("Getid: %llu\n", sys_acc->syscalls.getid);
	printk("Capability Control: %llu\n", sys_acc->syscalls.capctrl);
	printk("Time: %llu\n", sys_acc->syscalls.time);
	printk("Mutex Control: %llu\n", sys_acc->syscalls.mutexctrl);
	printk("Cache Control: %llu\n", sys_acc->syscalls.cachectrl);

	printk("\nExceptions:\n");
	printk("===========\n");
	printk("System call: %llu\n", sys_acc->exceptions.syscall);
	printk("Data Abort: %llu\n", sys_acc->exceptions.data_abort);
	printk("Prefetch Abort: %llu\n", sys_acc->exceptions.prefetch_abort);
	printk("Irq: %llu\n", sys_acc->exceptions.irq);
	printk("Undef Abort: %llu\n", sys_acc->exceptions.undefined_abort);
	printk("Context Switch: %llu\n", sys_acc->task_ops.context_switch);
	printk("Space Switch: %llu\n", sys_acc->task_ops.space_switch);

	printk("\nCache operations:\n");

}
#endif


/*
 * For spinlock debugging
 */
#if defined (CONFIG_DEBUG_SPINLOCKS)

#include <l4/lib/bit.h>

#define DEBUG_SPINLOCK_TOTAL	10

DECLARE_PERCPU(static unsigned long, held_lock_array[DEBUG_SPINLOCK_TOTAL]);
DECLARE_PERCPU(static u32, held_lock_bitmap);

void spin_lock_record_check(void *lock_addr)
{
	int bit = 0;

	/*
	 * Check if we already hold this lock
	 */
	for (int i = 0; i < DEBUG_SPINLOCK_TOTAL; i++) {
		if (per_cpu(held_lock_array[i]) == (unsigned long)lock_addr) {
			print_early("Spinlock already held.\n");
			printk("lock_addr=%p\n", lock_addr);
			BUG();
		}
	}

	/*
	 * Add it as a new lock
	 */
	bit = find_and_set_first_free_bit(&per_cpu(held_lock_bitmap),
					  DEBUG_SPINLOCK_TOTAL);
	per_cpu(held_lock_array[bit]) = (unsigned long)lock_addr;
}

void spin_unlock_delete_check(void *lock_addr)
{
	/*
	 * Check if already unlocked
	 */
	if (*((unsigned int *)lock_addr) == 0) {
		print_early("Spinlock already unlocked.");
		BUG();
	}

	/*
	 * Search for the value
	 */
	for (int i = 0; i < DEBUG_SPINLOCK_TOTAL; i++) {
		if (per_cpu(held_lock_array[i]) == (unsigned long)lock_addr) {
			/*
			 * Delete its entry
			 */
			per_cpu(held_lock_array[i]) = 0;
			BUG_ON(check_and_clear_bit(&per_cpu(held_lock_bitmap),
						   i) < 0);
			return;
		}
	}
	/*
	 * It must have been recorded
	 */
	BUG();
}

#endif









