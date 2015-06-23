/*
 * System Calls
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/lib/mutex.h>
#include <l4/lib/printk.h>
#include <l4/generic/space.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/debug.h>
#include <l4/generic/tcb.h>
#include <l4/api/errno.h>
#include INC_GLUE(memlayout.h)
#include INC_GLUE(syscall.h)
#include INC_GLUE(mapping.h)
#include INC_GLUE(debug.h)
#include INC_SUBARCH(mm.h)
#include INC_SUBARCH(perfmon.h)
#include INC_API(syscall.h)
#include INC_API(kip.h)

void kip_init_syscalls(void)
{
	kip.irq_control = ARM_SYSCALL_PAGE + sys_irq_control_offset;
	kip.thread_control = ARM_SYSCALL_PAGE + sys_thread_control_offset;
	kip.ipc_control = ARM_SYSCALL_PAGE + sys_ipc_control_offset;
	kip.map = ARM_SYSCALL_PAGE + sys_map_offset;
	kip.ipc = ARM_SYSCALL_PAGE + sys_ipc_offset;
	kip.capability_control = ARM_SYSCALL_PAGE + sys_capability_control_offset;
	kip.unmap = ARM_SYSCALL_PAGE + sys_unmap_offset;
	kip.exchange_registers = ARM_SYSCALL_PAGE + sys_exchange_registers_offset;
	kip.thread_switch = ARM_SYSCALL_PAGE + sys_thread_switch_offset;
	kip.schedule = ARM_SYSCALL_PAGE + sys_schedule_offset;
	kip.getid = ARM_SYSCALL_PAGE + sys_getid_offset;
	kip.container_control = ARM_SYSCALL_PAGE + sys_container_control_offset;
	kip.time = ARM_SYSCALL_PAGE + sys_time_offset;
	kip.mutex_control = ARM_SYSCALL_PAGE + sys_mutex_control_offset;
	kip.cache_control = ARM_SYSCALL_PAGE + sys_cache_control_offset;
}

/* Jump table for all system calls. */
syscall_fn_t syscall_table[SYSCALLS_TOTAL];


int arch_sys_ipc(syscall_context_t *regs)
{
	return sys_ipc((l4id_t)regs->r0, (l4id_t)regs->r1,
		       (unsigned int)regs->r2);
}

int arch_sys_thread_switch(syscall_context_t *regs)
{
	return sys_thread_switch();
}

int arch_sys_thread_control(syscall_context_t *regs)
{
	return sys_thread_control((unsigned int)regs->r0,
				  (struct task_ids *)regs->r1);
}

int arch_sys_exchange_registers(syscall_context_t *regs)
{
	return sys_exchange_registers((struct exregs_data *)regs->r0,
				      (l4id_t)regs->r1);
}

int arch_sys_schedule(syscall_context_t *regs)
{
	return sys_schedule();
}

int arch_sys_getid(syscall_context_t *regs)
{
	return sys_getid((struct task_ids *)regs->r0);
}

int arch_sys_unmap(syscall_context_t *regs)
{
	return sys_unmap((unsigned long)regs->r0, (unsigned long)regs->r1,
			 (unsigned int)regs->r2);
}

int arch_sys_irq_control(syscall_context_t *regs)
{
	return sys_irq_control((unsigned int)regs->r0,
			       (unsigned int)regs->r1,
			       (l4id_t)regs->r2);
}

int arch_sys_ipc_control(syscall_context_t *regs)
{
	return sys_ipc_control();
}

int arch_sys_map(syscall_context_t *regs)
{
	return sys_map((unsigned long)regs->r0, (unsigned long)regs->r1,
		       (unsigned long)regs->r2, (unsigned long)regs->r3,
		       (l4id_t)regs->r4);
}

int arch_sys_capability_control(syscall_context_t *regs)
{
	return sys_capability_control((unsigned int)regs->r0,
				      (unsigned int)regs->r1,
				      (void *)regs->r2);
}

int arch_sys_container_control(syscall_context_t *regs)
{
	return sys_container_control((unsigned int)regs->r0,
				     (unsigned int)regs->r1,
				     (void *)regs->r2);
}

int arch_sys_time(syscall_context_t *regs)
{
	return sys_time((struct timeval *)regs->r0, (int)regs->r1);
}

int arch_sys_mutex_control(syscall_context_t *regs)
{
	return sys_mutex_control((unsigned long)regs->r0, (int)regs->r1);
}

int arch_sys_cache_control(syscall_context_t *regs)
{
	return sys_cache_control((unsigned long)regs->r0,
				 (unsigned long)regs->r1,
				 (unsigned int)regs->r2);
}

/*
 * Initialises the system call jump table, for kernel to use.
 * Also maps the system call page into userspace.
 */
void syscall_init()
{
	syscall_table[sys_ipc_offset >> 2] 			= (syscall_fn_t)arch_sys_ipc;
	syscall_table[sys_thread_switch_offset >> 2] 		= (syscall_fn_t)arch_sys_thread_switch;
	syscall_table[sys_thread_control_offset >> 2] 		= (syscall_fn_t)arch_sys_thread_control;
	syscall_table[sys_exchange_registers_offset >> 2] 	= (syscall_fn_t)arch_sys_exchange_registers;
	syscall_table[sys_schedule_offset >> 2] 		= (syscall_fn_t)arch_sys_schedule;
	syscall_table[sys_getid_offset >> 2]	 		= (syscall_fn_t)arch_sys_getid;
	syscall_table[sys_unmap_offset >> 2] 			= (syscall_fn_t)arch_sys_unmap;
	syscall_table[sys_irq_control_offset >> 2] 		= (syscall_fn_t)arch_sys_irq_control;
	syscall_table[sys_ipc_control_offset >> 2] 		= (syscall_fn_t)arch_sys_ipc_control;
	syscall_table[sys_map_offset >> 2] 			= (syscall_fn_t)arch_sys_map;
	syscall_table[sys_capability_control_offset >> 2]	= (syscall_fn_t)arch_sys_capability_control;
	syscall_table[sys_container_control_offset >> 2]	= (syscall_fn_t)arch_sys_container_control;
	syscall_table[sys_time_offset >> 2]			= (syscall_fn_t)arch_sys_time;
	syscall_table[sys_mutex_control_offset >> 2]		= (syscall_fn_t)arch_sys_mutex_control;
	syscall_table[sys_cache_control_offset >> 2]		= (syscall_fn_t)arch_sys_cache_control;

	add_boot_mapping(virt_to_phys(&__syscall_page_start),
			 ARM_SYSCALL_PAGE, PAGE_SIZE, MAP_USR_RX);
}

/* Checks a syscall is legitimate and dispatches to appropriate handler. */
int syscall(syscall_context_t *regs, unsigned long swi_addr)
{
	int ret = 0;

	/* Check if genuine system call, coming from the syscall page */
	if ((swi_addr & ARM_SYSCALL_PAGE) == ARM_SYSCALL_PAGE) {
		/* Check within syscall offset boundary */
		if (((swi_addr & syscall_offset_mask) >= 0) &&
		    ((swi_addr & syscall_offset_mask) <= syscalls_end_offset)) {

			/* Do system call accounting, if enabled */
			system_account_syscall();
			system_account_syscall_type(swi_addr);

			/* Start measure syscall timing, if enabled */
			system_measure_syscall_start();

			/* Quick jump, rather than compare each */
			ret = (*syscall_table[(swi_addr & 0xFF) >> 2])(regs);

			/* End measure syscall timing, if enabled */
			system_measure_syscall_end(swi_addr);

		} else {
			printk("System call received from call @ 0x%lx."
			       "Instruction: 0x%lx.\n", swi_addr,
			       *((unsigned long *)swi_addr));
			return -ENOSYS;
		}
	} else {
		printk("System call exception from unknown location 0x%lx."
		       "Discarding.\n", swi_addr);
		return -ENOSYS;
	}

	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	}

	return ret;
}

