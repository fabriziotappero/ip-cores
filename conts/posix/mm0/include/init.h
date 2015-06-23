/*
 * Data that comes from the kernel, and other init data.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __MM_INIT_H__
#define __MM_INIT_H__

#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>
#include INC_PLAT(offsets.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(memlayout.h)
#include <bootdesc.h>
#include <physmem.h>
#include <vm_area.h>
#include <capability.h>

struct initdata {
	struct bootdesc *bootdesc;
	struct page_bitmap *page_map;
	unsigned long pager_utcb_virt;
	unsigned long pager_utcb_phys;
	struct link boot_file_list;
};

extern struct initdata initdata;

void init(void);

void copy_boot_capabilities(int ncaps);
/* TODO: Remove this stuff from here. */
int init_devzero(void);
struct vm_file *get_devzero(void);
int init_execve(char *path);

#endif /* __MM_INIT_H__ */
