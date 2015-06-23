/*
 * Main function for all tests
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <tests.h>
#include <thread.h>
#include <container.h>
#include <l4/api/space.h>
#include <l4/api/errno.h>


void run_tests(void)
{
	/* Performance tests */
	//if (test_performance() < 0)
	//	printf("Performance tests failed.\n");

	if (test_smp() < 0)
		printf("SMP tests failed.\n");

	/* API Tests */
	if (test_api() < 0)
		printf("API tests failed.\n");

	/* Container client/server setup test */
	if (test_cli_serv() < 0)
		printf("Client/server tests failed.\n");

	/* Container multithreaded/standalone setup test */
	if (test_mthread() < 0)
		printf("Multi-threaded tests failed.\n");
}

int main(void)
{
	printf("%s: Container %s started\n",
	       __CONTAINER__, __CONTAINER_NAME__);

	run_tests();

	return 0;
}

