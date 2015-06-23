#ifndef __LIST_H__
#define __LIST_H__

#include <l4/macros.h>

#define L4_DEADWORD				0xDEADCCCC

struct link {
	struct link *next;
	struct link *prev;
};

static inline void link_init(struct link *l)
{
	l->next = l;
	l->prev = l;
}

#define LINK_INIT(link)	{ &(link), &(link) }
#define LINK_DECLARE(l)	\
	struct link l = LINK_INIT(l)

static inline void list_insert(struct link *new, struct link *list)
{
	struct link *next = list->next;

	/*
	 * The new link goes between the
	 * current and next links on the list e.g.
	 * list -> new -> next
	 */
	new->next = next;
	next->prev = new;
	list->next = new;
	new->prev = list;

}

static inline void list_insert_tail(struct link *new, struct link *list)
{
	struct link *prev = list->prev;

	/*
	 * The new link goes between the
	 * current and prev links  on the list, e.g.
	 * prev -> new -> list
	 */
	new->next = list;
	list->prev = new;
	new->prev = prev;
	prev->next = new;
}

static inline void list_remove(struct link *link)
{
	struct link *prev = link->prev;
	struct link *next = link->next;

	prev->next = next;
	next->prev = prev;

	link->next = (struct link *)L4_DEADWORD;
	link->prev = (struct link *)L4_DEADWORD;
}

static inline void list_remove_init(struct link *link)
{
	struct link *prev = link->prev;
	struct link *next = link->next;

	//BUG_ON(prev == NULL || next == NULL || link == NULL);
	prev->next = next;
	next->prev = prev;

	link->next = link;
	link->prev = link;
}

/* Cuts the whole list from head and returns it */
static inline struct link *list_detach(struct link *head)
{
	struct link *next = head->next;

	/* Detach head from rest of the list */
	list_remove_init(head);

	/* Return detached list */
	return next;
}

/* append new_list to list given by head/end pair */
static inline void list_attach(struct link *new_list, struct link *head, struct link *end)
{
	/* attach new list at the end of original list */
	end->next = new_list;
	new_list->prev = end;

	/* go to the end of list to be attached */
	while (new_list->next != end->next)
		new_list = new_list->next;

	/* set end nodes properly */
	new_list->next = head;
	head->prev = new_list;

	/* set end to new end */
	end = new_list;
}


static inline int list_empty(struct link *list)
{
	return list->prev == list && list->next == list;
}


#define link_to_struct(link, struct_type, link_field)						\
	container_of(link, struct_type, link_field)

#define list_foreach_struct(struct_ptr, link_start, link_field)					\
	for (struct_ptr = link_to_struct((link_start)->next, typeof(*struct_ptr), link_field);	\
	     &struct_ptr->link_field != (link_start);						\
	     struct_ptr = link_to_struct(struct_ptr->link_field.next, typeof(*struct_ptr), link_field))

#define list_foreach_removable_struct(struct_ptr, temp_ptr, link_start, link_field)			\
	for (struct_ptr = link_to_struct((link_start)->next, typeof(*struct_ptr), link_field),	\
	     temp_ptr = link_to_struct((struct_ptr)->link_field.next, typeof(*struct_ptr), link_field);\
	     &struct_ptr->link_field != (link_start);						\
	     struct_ptr = temp_ptr, temp_ptr = link_to_struct(temp_ptr->link_field.next, typeof(*temp_ptr), link_field))

#endif /* __LIST_H__ */
