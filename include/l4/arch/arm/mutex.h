/*
 * ARM specific low-level mutex interfaces
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __ARCH_MUTEX_H__
#define __ARCH_MUTEX_H__

/* TODO: The return types could be improved for debug checking */
void __spin_lock(unsigned int *s);
void __spin_unlock(unsigned int *s);
unsigned int __mutex_lock(unsigned int *m);
void __mutex_unlock(unsigned int *m);

#endif /* __ARCH_MUTEX_H__ */
