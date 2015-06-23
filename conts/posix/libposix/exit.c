
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/ipcdefs.h>
#include <unistd.h>
#include <l4/macros.h>
#include <libposix.h>

static inline void __attribute__ ((noreturn)) l4_exit_ipc(int status)
{
	int ret;

	write_mr(L4SYS_ARG0, status);

	/* Call pager with exit() request and block on its receive phase */
	ret = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_EXIT);

	/* This call should not fail or return */
	print_err("%s: L4 IPC returned: %d.\n", __FUNCTION__, ret);
	BUG();
}

void __attribute__ ((noreturn)) _exit(int status)
{
	l4_exit_ipc(status);
}

