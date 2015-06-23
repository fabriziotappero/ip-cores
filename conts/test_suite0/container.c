/*
 * Container entry point for pager
 *
 * Copyright (C) 2007-2009 B Labs Ltd.
 */

#include <l4lib/init.h>
#include <l4lib/utcb.h>
#include <l4lib/lib/thread.h>
#include <l4lib/lib/cap.h>

extern void main(void);

void __container_init(void)
{
	/* Generic L4 initialisation */
	__l4_init();

	/* Thread library initialisation */
	__l4_threadlib_init();

	/* Capability library initialization */
	__l4_capability_init();

	/* Entry to main */
	main();
}

