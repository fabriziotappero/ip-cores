/*
 * Capability-related operations of the pager.
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#ifndef __MM0_CAPABILITY_H__
#define __MM0_CAPABILITY_H__

#include <l4lib/lib/cap.h>
#include <task.h>

extern struct cap_list capability_list;

struct initdata;
int read_pager_capabilities();
void copy_boot_capabilities();

int sys_request_cap(struct tcb *sender, struct capability *c);

void cap_list_print(struct cap_list *cap_list);
void setup_caps();
#endif /* __MM0_CAPABILITY_H__ */
