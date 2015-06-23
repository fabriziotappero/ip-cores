/*
 * Capability-related userspace helpers
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <stdio.h>
#include <l4lib/lib/cap.h>
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syscalls.h)

#if 0
static struct capability cap_array[30];

struct cap_group {
	struct cap_list virtmem;
	struct cap_list physmem;
	struct cap_list threadpool;
	struct cap_list tctrl;
	struct cap_list exregs;
	struct cap_list ipc;
	struct cap_list mutex;
	struct cap_list sched;
	struct cap_list mutexpool;
	struct cap_list spacepool;
	struct cap_list cappool;
};

static inline struct capability *cap_get_thread()
{

}

static inline struct capability *cap_get_space()
{

}

static inline struct capability *cap_get_ipc()
{

}

static inline struct capability *cap_get_virtmem()
{

}

static inline struct capability *cap_get_physmem()
{

}

static inline struct capability *cap_get_physmem(unsigned long phys)
{

}

static inline struct capability *cap_get_virtmem(unsigned long virt)
{

}

static inline struct capability *cap_get_byid(l4id_t id)
{

}


void cap_share_single(struct capability *orig, struct capability *share, l4id_t target, unsigned int flags)
{

}

void cap_grant_single(struct capability *orig, struct capability *share, l4id_t target, unsigned int flags)
{
}


int caps_read_all(void)
{
	int ncaps;
	int err;

	/* Read number of capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_NCAPS,
					 0, &ncaps)) < 0) {
		printf("l4_capability_control() reading # of"
		       " capabilities failed.\n Could not "
		       "complete CAP_CONTROL_NCAPS request.\n");
		BUG();
	}

	/* Read all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_READ,
					 0, cap_array)) < 0) {
		printf("l4_capability resource_control() reading of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_READ_CAPS request.\n");
		BUG();
	}
	//cap_array_print(ncaps, caparray);

	return 0;
}

#endif
