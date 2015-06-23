#include <errno.h>
#include <stdio.h>
#include <libposix.h>

int errno_variable;

void perror(const char *str)
{
	print_err("%s: %d\n", str, errno);
}

int *__errno_location(void)
{
	return &errno_variable;
}
