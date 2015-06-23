/*
 * Syscall offsets in the syscall page.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include INC_GLUE(syscall.h)
#include INC_API(exregs.h)
#include <l4/generic/time.h>

#define syscall_offset_mask			0xFF

#define	sys_ipc_offset				0x0
#define sys_thread_switch_offset		0x4
#define sys_thread_control_offset		0x8
#define sys_exchange_registers_offset		0xC
#define sys_schedule_offset			0x10
#define sys_unmap_offset			0x14
#define sys_irq_control_offset			0x18
#define sys_ipc_control_offset			0x1C
#define sys_map_offset				0x20
#define sys_getid_offset			0x24
#define sys_capability_control_offset		0x28
#define sys_container_control_offset		0x2C
#define sys_time_offset				0x30
#define sys_mutex_control_offset		0x34
#define sys_cache_control_offset		0x38
#define syscalls_end_offset			sys_cache_control_offset
#define SYSCALLS_TOTAL				((syscalls_end_offset >> 2) + 1)

void print_syscall_context(struct ktcb *t);

int sys_ipc(l4id_t to, l4id_t from, unsigned int flags);
int sys_thread_switch(void);
int sys_thread_control(unsigned int flags, struct task_ids *ids);
int sys_exchange_registers(struct exregs_data *exregs, l4id_t tid);
int sys_schedule(void);
int sys_unmap(unsigned long virtual, unsigned long npages, unsigned int tid);
int sys_irq_control(unsigned int req, unsigned int flags, l4id_t id);
int sys_ipc_control(void);
int sys_map(unsigned long phys, unsigned long virt, unsigned long npages,
	    unsigned int flags, l4id_t tid);
int sys_getid(struct task_ids *ids);
int sys_capability_control(unsigned int req, unsigned int flags, void *addr);
int sys_container_control(unsigned int req, unsigned int flags, void *addr);
int sys_time(struct timeval *tv, int set);
int sys_mutex_control(unsigned long mutex_address, int mutex_op);
int sys_cache_control(unsigned long start, unsigned long end,
		      unsigned int flags);

#endif /* __SYSCALL_H__ */
