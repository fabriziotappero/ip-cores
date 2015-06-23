#ifndef __ARM_IO_H__
#define __ARM_IO_H__
/*
 * Arch-specific io functions/macros.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#if defined (__KERNEL__)

#include INC_GLUE(memlayout.h)

#define read(address)		*((volatile unsigned int *) (address))
#define write(val, address)	*((volatile unsigned int *) (address)) = val

#endif /* ends __KERNEL__ */

/*
 * Generic uart virtual address until a file-based console access
 * is available for userspace
 */
#define	USERSPACE_CONSOLE_VBASE		0xF9800000


#endif /* __ARM_IO_H__ */
