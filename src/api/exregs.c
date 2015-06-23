#include <l4/lib/mutex.h>
#include <l4/lib/printk.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/tcb.h>
#include <l4/generic/resource.h>
#include <l4/generic/tcb.h>
#include <l4/generic/space.h>
#include <l4/generic/capability.h>
#include <l4/generic/container.h>
#include <l4/api/ipc.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include <l4/api/exregs.h>

/* Copy each register to task's context if its valid bit is set */
void exregs_write_registers(struct ktcb *task, struct exregs_data *exregs)
{
	task_context_t *context = &task->context;

	if (!exregs->valid_vect)
		goto flags;
	/*
	 * NOTE:
	 * We don't care if register values point at invalid addresses
	 * since memory protection would prevent any kernel corruption.
	 * We do however, make sure spsr is not modified
	 */

	/* Check register valid bit and copy registers */
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r0))
		context->r0 = exregs->context.r0;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r1))
		context->r1 = exregs->context.r1;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r2))
		context->r2 = exregs->context.r2;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r3))
		context->r3 = exregs->context.r3;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r4))
		context->r4 = exregs->context.r4;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r5))
		context->r5 = exregs->context.r5;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r6))
		context->r6 = exregs->context.r6;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r7))
		context->r7 = exregs->context.r7;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r8))
		context->r8 = exregs->context.r8;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r9))
		context->r9 = exregs->context.r9;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r10))
		context->r10 = exregs->context.r10;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r11))
		context->r11 = exregs->context.r11;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r12))
		context->r12 = exregs->context.r12;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, sp))
		context->sp = exregs->context.sp;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, lr))
		context->lr = exregs->context.lr;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, pc))
		context->pc = exregs->context.pc;

flags:
	/* Set thread's pager if one is supplied */
	if (exregs->flags & EXREGS_SET_PAGER)
		task->pagerid = exregs->pagerid;

	/* Set thread's utcb if supplied */
	if (exregs->flags & EXREGS_SET_UTCB) {
		task->utcb_address = exregs->utcb_address;

		/*
		 * If task is the one currently runnable,
		 * update utcb reference
		 */
		if (task == current)
			task_update_utcb(task);
	}
}

void exregs_read_registers(struct ktcb *task, struct exregs_data *exregs)
{
	task_context_t *context = &task->context;

	if (!exregs->valid_vect)
		goto flags;

	/* Check register valid bit and copy registers */
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r0))
		exregs->context.r0 = context->r0;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r1))
		exregs->context.r1 = context->r1;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r2))
		exregs->context.r2 = context->r2;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r3))
		exregs->context.r3 = context->r3;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r4))
		exregs->context.r4 = context->r4;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r5))
		exregs->context.r5 = context->r5;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r6))
		exregs->context.r6 = context->r6;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r7))
		exregs->context.r7 = context->r7;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r8))
		exregs->context.r8 = context->r8;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r9))
		exregs->context.r9 = context->r9;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r10))
		exregs->context.r10 = context->r10;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r11))
		exregs->context.r11 = context->r11;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, r12))
		exregs->context.r12 = context->r12;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, sp))
		exregs->context.sp = context->sp;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, lr))
		exregs->context.lr = context->lr;
	if (exregs->valid_vect & FIELD_TO_BIT(exregs_context_t, pc))
		exregs->context.pc = context->pc;

flags:
	/* Read thread's pager if pager flag supplied */
	if (exregs->flags & EXREGS_SET_PAGER)
		exregs->pagerid = task->pagerid;

	/* Read thread's utcb if utcb flag supplied */
	if (exregs->flags & EXREGS_SET_UTCB)
		exregs->utcb_address = task->utcb_address;
}

/*
 * exchange_registers()
 *
 * This call is used by the pagers to set (and in the future read)
 * the register context of a thread. The thread's registers that are
 * set by this call are loaded whenever the thread gets a chance to
 * run in user mode.
 *
 * It is ensured that whenever this call is made, the thread is
 * either already running in user mode, or has been suspended in
 * kernel mode, just before returning to user mode.
 *
 * A newly created thread that is the copy of another thread (forked
 * or cloned) will also be given its user mode context on the first
 * chance to execute so such threads can also be modified by this
 * call before execution.
 *
 * A thread executing in the kernel cannot be modified since this
 * would compromise the kernel. Also the thread must be in suspended
 * condition so that the scheduler does not execute it as we modify
 * its context.
 *
 * FIXME: Still looks like suspended threads in the kernel
 * need to be made immutable. see src/glue/arm/systable.c
 */
int sys_exchange_registers(struct exregs_data *exregs, l4id_t tid)
{
	int err = 0;
	struct ktcb *task;

	if ((err = check_access((unsigned long)exregs,
				sizeof(*exregs),
				MAP_USR_RW, 1)) < 0)
		return err;

	/* Find tcb from its list */
	if (!(task = tcb_find(tid)))
		return -ESRCH;

	/*
	 * This lock ensures task is not
	 * inadvertently resumed by a syscall
	 */
	if (!mutex_trylock(&task->thread_control_lock))
		return -EAGAIN;

	/*
	 * Now check that the task is suspended.
	 *
	 * Only modification of non-register fields are
	 * allowed on active tasks and those tasks must
	 * be the pagers making the call on themselves.
	 */
	if (task->state != TASK_INACTIVE && exregs->valid_vect &&
	    current != task && task->pagerid != current->tid) {
		err = -EACTIVE;
		goto out;
	}

	if ((err = cap_exregs_check(task, exregs)) < 0)
		return -ENOCAP;

	/* Copy registers */
	if (exregs->flags & EXREGS_READ)
		exregs_read_registers(task, exregs);
	else
		exregs_write_registers(task, exregs);

out:
	/* Unlock and return */
	mutex_unlock(&task->thread_control_lock);
	return err;
}

