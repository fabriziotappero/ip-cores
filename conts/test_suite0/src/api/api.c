/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * API tests
 *
 * Author: Bahadir Balban
 */
#include <tests.h>
#include <memory.h>
#include <api/api.h>

/*
 * Tests all api functions by expected and unexpected input
 */
int test_api(void)
{
	int err;

	/* Initialize free pages */
	page_pool_init();

	if ((err = test_api_tctrl()) < 0)
		return err;

	if ((err = test_api_getid()) < 0)
		return err;

	if ((err = test_api_exregs()) < 0)
		return err;

	if ((err = test_api_map_unmap()) < 0)
		return err;

	if ((err = test_api_ipc()) < 0)
		return err;

	if ((err = test_api_mutexctrl()) < 0)
		return err;

	if ((err = test_api_cctrl()) < 0)
		return err;

	if ((err = test_api_capctrl()) < 0)
		return err;

	if ((err = test_api_irqctrl()) < 0)
		return err;

	return 0;
}

