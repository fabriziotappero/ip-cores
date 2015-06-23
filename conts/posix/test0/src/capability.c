#include <capability.h>
#include <l4lib/ipcdefs.h>
#include L4LIB_INC_ARCH(syslib.h)

int cap_request_pager(struct capability *cap)
{
	int err;

	write_mr(L4SYS_ARG0, (u32)cap);

	if ((err = l4_sendrecv(pagerid, pagerid,
			       L4_REQUEST_CAPABILITY)) < 0) {
		printf("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Check if syscall itself was successful */
	if ((err = l4_get_retval()) < 0) {
		printf("%s: Error: %d\n", __FUNCTION__, err);
		return err;
	}
	return err;
}

