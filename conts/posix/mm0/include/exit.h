/*
 * Definitions for do_exit() flags
 *
 * Copyright (C) 2008 Bahadir Balban
 */

#ifndef __EXIT_H__
#define __EXIT_H__

void do_exit(struct tcb *task, int status);
int execve_recycle_task(struct tcb *new, struct tcb *orig);

#endif /* __EXIT_H__ */
