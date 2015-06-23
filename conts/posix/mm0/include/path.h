/*
 * Copyright (C) 2008 Bahadir Balban
 *
 * Path lookup related information
 */
#ifndef __PATH_H__
#define __PATH_H__

#include <l4/lib/list.h>
#include <task.h>

/*
 * FIXME:
 * These ought to be strings and split/comparison functions should
 * always use strings because formats like UTF-8 wouldn't work.
 */
#define VFS_CHAR_SEP		'/'
#define VFS_STR_ROOTDIR		"/"
#define VFS_STR_PARDIR		".."
#define VFS_STR_CURDIR		"."
#define VFS_STR_XATDIR		"...."

struct pathdata {
	struct link list;
	struct vnode *vstart;
};

struct pathcomp {
	struct link list;
	const char *str;
};

struct pathdata *pathdata_parse(const char *pathname, char *pathbuf,
				struct tcb *task);
void pathdata_destroy(struct pathdata *p);

/* Destructive, i.e. unlinks those components from list */
const char *pathdata_next_component(struct pathdata *pdata);
const char *pathdata_last_component(struct pathdata *pdata);

#endif /* __PATH_H__ */
