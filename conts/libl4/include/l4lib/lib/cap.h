/*
 * Capability-related management.
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#ifndef __LIBL4_CAPABILITY_H__
#define __LIBL4_CAPABILITY_H__

#include <l4lib/types.h>
#include <l4/lib/list.h>
#include <l4/api/capability.h>
#include <l4/generic/cap-types.h>

void cap_dev_print(struct capability *cap);
void cap_print(struct capability *cap);
void cap_array_print(int total_caps, struct capability *caparray);

/*
 * Definitions for lists of capabilities
 */
struct cap_list {
	int ncaps;
	struct link caps;
};

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

/* Detach a whole list of capabilities from list head */
static inline struct capability *
cap_list_detach(struct cap_list *clist)
{
	struct link *list = list_detach(&clist->caps);
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
	struct capability *cap_head = cap_list_detach(from);
	cap_list_attach(cap_head, to);
}

/*
 * Definitions for reading from the library capability array
 */
void __l4_capability_init(void);
struct capability *cap_get_by_type(unsigned int cap_type);
struct capability *cap_get_physmem(unsigned int cap_type);


#endif /* __LIBL4_CAPABILITY_H__ */
