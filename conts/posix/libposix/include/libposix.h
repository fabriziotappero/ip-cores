#ifndef __LIBPOSIX_H__
#define __LIBPOSIX_H__

#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)

#include <l4lib/types.h>
#include <l4lib/ipcdefs.h>

/* Abort debugging conditions */
// #define LIBPOSIX_ERROR_MESSAGES
#if defined (LIBPOSIX_ERROR_MESSAGES)
#define print_err(...)	printf(__VA_ARGS__)
#else
#define print_err(...)
#endif


#endif /* __LIBPOSIX_H__ */
