/*
 * IO functions/macros.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __LIBDEV_IO_H__
#define __LIBDEV_IO_H__

#define read(address)		*((volatile unsigned int *)(address))
#define write(val, address)	*((volatile unsigned int *)(address)) = val

#endif /* __LIBDEV_IO_H__ */
