
#include <sys/types.h>
#include <unistd.h>
#include <libposix.h>

pid_t getpid(void)
{
	return self_tid();
}
