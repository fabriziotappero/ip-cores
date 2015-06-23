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
 * This test tests the multithreaded/standalone style container
 * set up.
 */
int test_mthread(void)
{
	/* Create multiple threads in same space */

	/*
	 * Set up childs' registers to execute the special
	 * child entry function
	 */

	/*
	 * Start the child
	 */

	/*
	 * Run child threads and interact
	 *
	 * Handle short, full, extended ipc
	 */

	/*
	 * Destroy child
	 */

	return 0;
}

