/*
 * Initialize platform timer virtual address
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Bahadir Balban
 */
#include <perf.h>
#include <linker.h>
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)

/* Note this must be obtained from the capability */
#define TIMER_PHYSICAL_BASE		0x10012000

unsigned long timer_base;

void perf_timer_init(void)
{
	int err;
	struct task_ids ids;

	l4_getid(&ids);

	/* Initialize timer base */
	timer_base = page_align_up(__stack);

	/* Map timer base */
	if ((err = l4_map((void *)TIMER_PHYSICAL_BASE,
			  (void *)timer_base,
			  1, MAP_USR_IO, ids.tid)) < 0) {
		printf("FATAL: Performance tests: Could not map "
		       "timer.\ntimer must be selected as a "
		       "container capability. err=%d\n",
		       err);
		BUG();
	}
}

