/*
 * A default shared page is used by every thread
 * to pass large data for system calls.
 *
 * This file contains relevant shpage definitions.
 */
#ifndef __LIBPOSIX_SHPAGE_H__
#define __LIBPOSIX_SHPAGE_H__

#include <l4/macros.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/utcb.h>
#include INC_GLUE(memory.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)

extern void *shared_page;

int shared_page_init(void);

/*
 * Arguments that are too large to fit in message registers are
 * copied onto another area that is still on the utcb, and the servers
 * map-in the task utcb and read those arguments from there.
 */

static inline int copy_to_shpage(void *arg, int offset, int size)
{
	if (offset + size > PAGE_SIZE)
		return -1;

	memcpy(shared_page + offset, arg, size);
	return 0;
}

static inline int copy_from_shpage(void *buf, int offset, int size)
{
	if (offset + size > PAGE_SIZE)
		return -1;

	memcpy(buf, shared_page + offset, size);
	return 0;
}

#endif /* __LIBPOSIX_SHPAGE_H__ */
