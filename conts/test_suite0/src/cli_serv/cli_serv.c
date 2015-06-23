/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Tests client/server style container setup
 *
 * Author: Bahadir Balban
 */
#include <tests.h>

/*
 * A container can be set up in many different combinations
 * of hierarchy where the hierarchical differences between
 * the threads are determined by a finely grained capability
 * configuration.
 *
 * However, this boils down to two main sets of hierarchical
 * setup: client/server or multithreaded/standalone entities.
 *
 * This test tests the client/server style hierarchical set up.
 */
int test_cli_serv(void)
{
	/*
	 * Create a child thread in a new address space.
	 * copying current pager's page tables to child
	 */

	/* Copy current pager's all sections to child pages */

	/*
	 * Set up child's registers to execute the special
	 * child entry function
	 */

	/*
	 * Start the child
	 */

	/*
	 * Interact with the child:
	 *
	 * Handle short, full, extended ipc
	 *
	 * Handle page fault
	 */

	/*
	 * Destroy child
	 */

	return 0;
}

