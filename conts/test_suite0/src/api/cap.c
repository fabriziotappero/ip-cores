/*
 * Test capability control system call
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include <l4lib/lib/cap.h>
#include L4LIB_INC_ARCH(syscalls.h)

#define TOTAL_CAPS				32

struct capability cap_array[TOTAL_CAPS];

/*
 * Read number of capabilities
 */
int test_cap_read(void)
{
	int ncaps;
	int err;

	/* Read number of capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_NCAPS,
					 0, &ncaps)) < 0) {
		printf("l4_capability_control() reading # of"
		       " capabilities failed.\n Could not "
		       "complete CAP_CONTROL_NCAPS request.\n");
		return err;
	}

	/* Read all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_READ,
					 0, cap_array)) < 0) {
		printf("l4_capability resource_control() reading of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_READ_CAPS request.\n");
		return err;
	}
	//cap_array_print(ncaps, caparray);

	return 0;
}


int test_api_capctrl(void)
{
	int err;

	if ((err = test_cap_read()) < 0)
		return err;

	return 0;
}

