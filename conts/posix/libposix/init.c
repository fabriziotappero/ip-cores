

#include <string.h>
#include <stdlib.h>
#include <libposix.h>
#include <posix_init.h>
#include <unistd.h>

int __libposix_init(void *envp)
{
	__environ = envp;
	return 0;
}

