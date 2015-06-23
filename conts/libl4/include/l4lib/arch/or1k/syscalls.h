/*
 * System call prototypes.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __ARM_SYSCALLS_H__
#define __ARM_SYSCALLS_H__


#include L4LIB_INC_ARCH(types.h)
#include L4LIB_INC_ARCH(utcb.h)
#include <l4/generic/space.h>
#include <l4/api/space.h>
#include <l4/api/kip.h>
#include <l4/api/ipc.h>
#include <l4/api/thread.h>

struct task_ids {
	l4id_t tid;
	l4id_t spid;
	l4id_t tgid;
};

static inline void *
l4_kernel_interface(unsigned int *api_version, unsigned int *api_flags,
		   unsigned int *kernel_id)
{
	return (void *)L4_KIP_ADDRESS;
}

typedef unsigned int (*__l4_thread_switch_t)(u32);
extern __l4_thread_switch_t __l4_thread_switch;
unsigned int l4_thread_switch (u32 dest);

typedef int (*__l4_getid_t)(struct task_ids *ids);
extern __l4_getid_t __l4_getid;
int l4_getid(struct task_ids *ids);

typedef int (*__l4_ipc_t)(l4id_t to, l4id_t from, u32 flags);
extern __l4_ipc_t __l4_ipc;
int l4_ipc(l4id_t to, l4id_t from, u32 flags);

typedef int (*__l4_capability_control_t)(unsigned int req, unsigned int flags, void *buf);
extern __l4_capability_control_t __l4_capability_control;
int l4_capability_control(unsigned int req, unsigned int flags, void *buf);

typedef int (*__l4_map_t)(void *phys, void *virt,
			  u32 npages, u32 flags, l4id_t tid);
extern __l4_map_t __l4_map;
int l4_map(void *p, void *v, u32 npages, u32 flags, l4id_t tid);

typedef int (*__l4_unmap_t)(void *virt, unsigned long npages, l4id_t tid);
extern __l4_unmap_t __l4_unmap;
int l4_unmap(void *virtual, unsigned long numpages, l4id_t tid);

typedef int (*__l4_thread_control_t)(unsigned int action, struct task_ids *ids);
extern __l4_thread_control_t __l4_thread_control;
int l4_thread_control(unsigned int action, struct task_ids *ids);

typedef int (*__l4_irq_control_t)(unsigned int req, unsigned int flags, l4id_t id);
extern __l4_irq_control_t __l4_irq_control;
int l4_irq_control(unsigned int req, unsigned int flags, l4id_t id);

typedef int (*__l4_ipc_control_t)(unsigned int action, l4id_t blocked_sender,
				  u32 blocked_tag);
extern __l4_ipc_control_t __l4_ipc_control;
int l4_ipc_control(unsigned int, l4id_t blocked_sender, u32 blocked_tag);

typedef int (*__l4_exchange_registers_t)(void *exregs_struct, l4id_t tid);
extern __l4_exchange_registers_t __l4_exchange_registers;
int l4_exchange_registers(void *exregs_struct, l4id_t tid);

typedef int (*__l4_container_control_t)(unsigned int req, unsigned int flags, void *buf);
extern __l4_container_control_t __l4_container_control;
int l4_container_control(unsigned int req, unsigned int flags, void *buf);

typedef int (*__l4_time_t)(void *timeval, int set);
extern __l4_time_t __l4_time;
int l4_time(void *timeval, int set);

typedef int (*__l4_mutex_control_t)(void *mutex_word, int op);
extern __l4_mutex_control_t __l4_mutex_control;
int l4_mutex_control(void *mutex_word, int op);

typedef int (*__l4_cache_control_t)(void *start, void *end, unsigned int flags);
extern __l4_cache_control_t __l4_cache_control;
int l4_cache_control(void *start, void *end, unsigned int flags);

/* To be supplied by server tasks. */
void *virt_to_phys(void *);
void *phys_to_virt(void *);


#endif /* __ARM_SYSCALLS_H__ */

