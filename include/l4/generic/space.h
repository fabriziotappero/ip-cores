/*
 * Generic address space related information.
 *
 * Copyright (C) 2007-2010 Bahadir Balban
 */
#ifndef __SPACE_H__
#define __SPACE_H__

/*
 * Generic mapping flags.
 */
#define MAP_FAULT			0
#define MAP_USR_RW			1
#define MAP_USR_RO			2
#define MAP_KERN_RW			3
#define MAP_USR_IO			4
#define MAP_KERN_IO			5
#define MAP_USR_RWX			6
#define MAP_KERN_RWX			7
#define MAP_USR_RX			8
#define MAP_KERN_RX			9
#define MAP_UNMAP			10	/* For unmap syscall */
#define MAP_INVALID_FLAGS 		(1 << 31)

/* Some default aliases */
#define	MAP_USR_DEFAULT		MAP_USR_RW
#define MAP_KERN_DEFAULT	MAP_KERN_RW
#define MAP_IO_DEFAULT		MAP_KERN_IO

#if defined (__KERNEL__)

#include <l4/lib/spinlock.h>
#include <l4/lib/list.h>
#include <l4/lib/mutex.h>
#include <l4/lib/idpool.h>
#include <l4/generic/capability.h>
#include INC_SUBARCH(mm.h)

/* A simple page table with a reference count */
struct address_space {
	l4id_t spid;
	struct link list;
	struct mutex lock;
	pgd_table_t *pgd;

	/* Capabilities shared by threads in same space */
	struct cap_list cap_list;
	int ktcb_refs;
};

struct address_space_list {
	struct link list;
	struct mutex lock;
	int count;
};

struct address_space *address_space_create(struct address_space *orig);
void address_space_delete(struct address_space *space,
			  struct ktcb *task_accounted);
void address_space_attach(struct ktcb *tcb, struct address_space *space);
struct address_space *address_space_find(l4id_t spid);
void address_space_add(struct address_space *space);

struct container;
void address_space_remove(struct address_space *space, struct container *cont);
void init_address_space_list(struct address_space_list *space_list);
int check_access(unsigned long vaddr, unsigned long size,
		 unsigned int flags, int page_in);
int check_access_task(unsigned long vaddr, unsigned long size,
		      unsigned int flags, int page_in, struct ktcb *task);
#endif

#endif /* __SPACE_H__ */
