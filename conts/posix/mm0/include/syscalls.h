/*
 * Copyright (C) 2007 Bahadir Balban
 *
 * MM0 Posix system call prototypes and structure
 * definitions for converting data in message registers
 * into system call argument format.
 */

#ifndef __MM0_SYSARGS_H__
#define __MM0_SYSARGS_H__

#include <sys/types.h>
#include <l4lib/types.h>
#include <task.h>

/* For reading argument data from a system call */
struct sys_mmap_args {
	void *start;
	size_t length;
	int prot;
	int flags;
	int fd;
	off_t offset;
};

void *sys_mmap(struct tcb *task, struct sys_mmap_args *args);
int sys_munmap(struct tcb *sender, void *vaddr, unsigned long size);
int sys_msync(struct tcb *task, void *start, unsigned long length, int flags);
void *sys_shmat(struct tcb *task, l4id_t shmid, const void *shmadr, int shmflg);
int sys_shmdt(struct tcb *requester, const void *shmaddr);

int sys_shmget(key_t key, int size, int shmflg);

int sys_execve(struct tcb *sender, char *pathname, char *argv[], char *envp[]);
int sys_fork(struct tcb *parent);
int sys_clone(struct tcb *parent, void *child_stack, unsigned int clone_flags);
void sys_exit(struct tcb *task, int status);

/* Posix calls */
int sys_open(struct tcb *sender, const char *pathname, int flags, u32 mode);
int sys_readdir(struct tcb *sender, int fd, int count, char *dirbuf);
int sys_mkdir(struct tcb *sender, const char *pathname, unsigned int mode);
int sys_chdir(struct tcb *sender, const char *pathname);

#endif /* __MM0_SYSARGS_H__ */

