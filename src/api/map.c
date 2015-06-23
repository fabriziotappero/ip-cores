/*
 * Space-related system calls.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/generic/tcb.h>
#include INC_API(syscall.h)
#include INC_SUBARCH(mm.h)
#include <l4/api/errno.h>
#include <l4/api/space.h>
#include INC_GLUE(mapping.h)

/*
 * Userspace syscall requests can only map
 * using read/write/exec userspace flags.
 */
int user_map_flags_validate(unsigned int flags)
{
	switch (flags) {
	case MAP_USR_RO:
	case MAP_USR_RW:
	case MAP_USR_RWX:
	case MAP_USR_RX:
	case MAP_USR_IO:
		return 1;
	default:
		return 0;
	}
	return 0;
}

int sys_map(unsigned long phys, unsigned long virt,
	    unsigned long npages, unsigned int flags, l4id_t tid)
{
	struct ktcb *target;
	int err;

	if (!(target = tcb_find(tid)))
		return -ESRCH;

	/* Check flags validity */
	if (!user_map_flags_validate(flags))
		return -EINVAL;

	if (!npages || !phys || !virt)
		return -EINVAL;

	if ((err = cap_map_check(target, phys, virt, npages, flags)) < 0)
		return err;

	add_mapping_pgd(phys, virt, npages << PAGE_BITS,
			flags, TASK_PGD(target));

	return 0;
}

/*
 * Unmaps given range from given task. If the complete range is unmapped
 * sucessfully, returns 0. If part of the range was found to be already
 * unmapped, returns -1. This is may or may not be an error.
 */
int sys_unmap(unsigned long virtual, unsigned long npages, unsigned int tid)
{
	struct ktcb *target;
	int ret = 0, retval = 0;

	if (!(target = tcb_find(tid)))
		return -ESRCH;

	if (!npages || !virtual)
		return -EINVAL;

	if ((ret = cap_unmap_check(target, virtual, npages)) < 0)
		return ret;

	for (int i = 0; i < npages; i++) {
		ret = remove_mapping_pgd(TASK_PGD(target),
					 virtual + i * PAGE_SIZE);
		if (ret)
			retval = ret;
	}

	return ret;
}

