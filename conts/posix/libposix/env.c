/*
 * Environment accessor functions
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <string.h>
#include <stdlib.h>
#include <libposix.h>

char **__environ;


/*
 * Search for given name in name=value string pairs located
 * in the environment segment, and return the pointer to value
 * string.
 */
char *getenv(const char *name)
{
	char **envp = __environ;
	int length;

	if (!envp)
		return 0;
	length = strlen(name);

	while(*envp) {
		if (memcmp(name, *envp, length) == 0 &&
		    (*envp)[length] == '=')
			return *envp + length + 1;
		envp++;
	}

	return 0;
}

