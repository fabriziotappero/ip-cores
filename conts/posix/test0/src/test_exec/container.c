/*
 * Container entry point for this task.
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */

#include <l4lib/types.h>
#include <l4lib/init.h>
#include <l4lib/utcb.h>
#include <posix_init.h>		/* Initialisers for posix library */
#include <stdlib.h>

int main(int argc, char *argv[]);

int __container_init(int argc, char **argv)
{
	void *envp = &argv[argc + 1];

	if ((char *)envp == *argv)
		envp = &argv[argc];

	__libposix_init(envp);

	/* Generic L4 thread initialisation */
	__l4_init();

	/* Entry to main */
	return main(argc, argv);
}

