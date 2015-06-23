/*
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __GENERIC_THREAD_H__
#define __GENERIC_THREAD_H__

#include <l4/generic/tcb.h>

/* Thread id creation and deleting */
void thread_id_pool_init(void);
int thread_id_new(void);
int thread_id_del(int tid);

void thread_setup_affinity(struct ktcb *task);
void thread_destroy(struct ktcb *);

#endif /* __GENERIC_THREAD_H__ */
