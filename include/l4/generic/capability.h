/*
 * Codezero Capability Definitions
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#ifndef __GENERIC_CAPABILITY_H__
#define __GENERIC_CAPABILITY_H__

#include <l4/api/exregs.h>
#include <l4/api/capability.h>

/*
 * Some resources that capabilities possess don't
 * have unique ids or need ids at all.
 *
 * E.g. a threadpool does not need a resource id.
 * A virtual memory capability does not require
 * a resource id, its capid is sufficient.
 */
#define CAP_RESID_NONE		-1


struct cap_list {
	int ktcb_refs;
	int ncaps;
	struct link caps;
};

void capability_init(struct capability *cap);
struct capability *capability_create(void);
struct capability *boot_capability_create(void);


static inline void cap_list_init(struct cap_list *clist)
{
	clist->ncaps = 0;
	link_init(&clist->caps);
}

static inline void cap_list_insert(struct capability *cap,
				   struct cap_list *clist)
{
	list_insert(&cap->list, &clist->caps);
	clist->ncaps++;
}

static inline void cap_list_remove(struct capability *cap,
				   struct cap_list *clist)
{
	list_remove(&cap->list);
	clist->ncaps--;
}

/* Detach a whole list of capabilities from list head */
static inline struct capability *
cap_list_detach(struct cap_list *clist)
{
	struct link *list;

	if (!clist->ncaps)
		return 0;

	list = list_detach(&clist->caps);
	clist->ncaps = 0;
	return link_to_struct(list, struct capability, list);
}

/* Attach a whole list of capabilities to list head */
static inline void cap_list_attach(struct capability *cap,
				   struct cap_list *clist)
{
	/* Attach as if cap is the list and clist is the element */
	list_insert(&clist->caps, &cap->list);

	/* Count the number of caps attached */
	list_foreach_struct(cap, &clist->caps, list)
		clist->ncaps++;
}

static inline void cap_list_move(struct cap_list *to,
				 struct cap_list *from)
{
	if (!from->ncaps)
		return;

	struct capability *cap_head = cap_list_detach(from);
	cap_list_attach(cap_head, to);
}

/* Have to have these as tcb.h includes this file */
struct ktcb;
struct task_ids;

/* Capability checking for quantitative capabilities */
int capability_consume(struct capability *cap, int quantity);
int capability_free(struct capability *cap, int quantity);
struct capability *capability_find_by_rtype(struct ktcb *task,
					    unsigned int rtype);
int cap_count(struct ktcb *task);
struct capability *cap_list_find_by_rtype(struct cap_list *clist,
					  unsigned int rtype);
struct capability *cap_find_by_capid(l4id_t capid, struct cap_list **clist);

/* Capability checking on system calls */
int cap_map_check(struct ktcb *task, unsigned long phys, unsigned long virt,
		  unsigned long npages, unsigned int flags);
int cap_unmap_check(struct ktcb *task, unsigned long virt,
		    unsigned long npages);
int cap_thread_check(struct ktcb *task, unsigned int flags,
		     struct task_ids *ids);
int cap_exregs_check(struct ktcb *task, struct exregs_data *exregs);
int cap_ipc_check(l4id_t to, l4id_t from,
		  unsigned int flags, unsigned int ipc_type);
int cap_cap_check(struct ktcb *task, unsigned int req, unsigned int flags);
int cap_mutex_check(unsigned long mutex_address, int mutex_op);

int cap_irq_check(struct ktcb *registrant, unsigned int req,
		  unsigned int flags, l4id_t irq);
int cap_cache_check(unsigned long start, unsigned long end,
		    unsigned int flags);

#endif /* __GENERIC_CAPABILITY_H__ */
