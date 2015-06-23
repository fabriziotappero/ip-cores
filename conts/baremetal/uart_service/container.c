/*
 * Container entry point for pager
 *
 * Copyright (C) 2007-2009 B Labs Ltd.
 */

#include <l4lib/init.h>
#include <l4lib/utcb.h>


extern void main(void);

void __container_init(void)
{
	/* Generic L4 initialisation */
	__l4_init();

	/* Entry to main */
	main();
}

