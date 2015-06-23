/*
 * Container entry point for pager
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */

#include <posix/posix_init.h>
#include <l4lib/init.h>
#include <l4lib/utcb.h>

/*
 * Application specific utcb allocation
 * for this container.
 *
 * Copyright (C) 2007-2009 Bahadir Balban
 */

void main(void);

void __container_init(void)
{
	/* Generic L4 initialisation */
	__l4_init();

	/* Entry to main */
	main();
}

