/*
 * Copyright (c) 2007 The Akuma Project
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 * $Id: linkedlist.c 108 2007-05-13 18:47:48Z eirik $
 */

#include <stdio.h>
#include <stdlib.h>

#include "linkedlist.h"

llist_t
llist_make(void)
{
	llist_t llist;

	llist = malloc(sizeof *llist);
	if (llist == NULL)
		return NULL;
	llist->head = NULL;
	llist->tail = NULL;

	return llist;
}

void
llist_destroy(llist_t head)
{
	llist_node_t node, next;

	for (node = head->head; node; node = next) {
		next = node->next;
		free(node);
	}

	free(head);
}

enum llist_add_type {
	HEAD,
	TAIL
};

static int
llist_add(llist_t head, void *obj, enum llist_add_type type)
{
	llist_node_t node;

	node = malloc(sizeof *node);
	if (node == NULL)
		return 0;

	node->next = NULL;
	node->obj = obj;

	/* First object added */
	if (head->head == NULL) {
		head->head = node;
		head->tail = node;
	} else if (type == TAIL) {
		head->tail->next = node;
		head->tail = node;
	} else if (type == HEAD) {
		node->next = head->head;
		head->head = node;
	}

	return 1;
}

int
llist_add_pos(llist_t head, void *obj, int pos)
{
	llist_node_t node, prev, newnode;
	int n;

	if (head->head == NULL) {
		return llist_add_head(head, obj);
	}
	newnode = malloc(sizeof *newnode);
	if (newnode == NULL)
		return 0;
	newnode->obj = obj;
	newnode->next = NULL;

	node = head->head;
	prev = NULL;
	for(node = head->head, n = 0; n < pos; node = node->next, n++) {
		if (node == NULL) {
			prev->next = newnode;
			head->tail = newnode;
			return 1;
		}
		prev = node;
	}
	if (prev == NULL) {
		head->head = newnode;
		newnode->next = node;
	} else {
		newnode->next = prev->next;
		prev->next = newnode;
	}

	return 1;
}

int
llist_add_tail(llist_t head, void *obj)
{
	return llist_add(head, obj, TAIL);
}

int
llist_add_head(llist_t head, void *obj)
{
	return llist_add(head, obj, HEAD);
}

void *
llist_pop(llist_t head)
{
	llist_node_t node;
	void *obj;

	if (head->head == NULL)
		return NULL;
	node = head->head;
	if (node->next == NULL) {
		head->head = NULL;
		head->tail = NULL;
	}
	else {
		head->head = node->next;
	}
	
	obj = llist_getobj(node);
	free(node);
	return obj;
}

/* zero indexed */
void *
llist_getelem(llist_t head, int num)
{
	int i;
	llist_node_t node;

	i = 0;
	LLIST_FOREACH(head, node) {
		if (i == num)
			return llist_getobj(node);
		i++;
	}
	return NULL;
}

void *
llist_getobj(llist_node_t node)
{
	return node->obj;
}

int
llist_empty(llist_t head)
{
	return (head->head == NULL);
}

llist_t
llist_copy(llist_t old)
{
	llist_t new;
	llist_node_t node;

	new = llist_make();
	if (new == NULL)
		return NULL;
	LLIST_FOREACH(old, node) {
		if (!llist_add_tail(new, llist_getobj(node))) {
			llist_destroy(new);
			return NULL;
		}
	}

	return new;
}

int
llist_insert_list_head(llist_t head, llist_t add)
{
	llist_t copy = llist_copy(add);
	llist_node_t node;

	if (copy == NULL)
		return 0;
	if (head->head == NULL) {
		head->head = copy->head;
		head->tail = copy->tail;
	} else {
		node = head->head;
		head->head = copy->head; 
		copy->tail->next = node;
	}
	free(copy);
	
	return 1;
}

int
llist_size(llist_t head)
{
	int n;
	llist_node_t node;

	n = 0;
	LLIST_FOREACH(head, node)
		n++;

	return n;
}

void
llist_remove_elem(llist_t list, int n)
{
	llist_node_t cur, prev;
	int i;

	if (list->head == NULL)
		return;

	prev = NULL;
	for(cur = list->head, i = 0; cur; cur = cur->next, i++) {
		if (i == n) {
			if (cur == list->head) {
				list->head = cur->next;
			}
			if (cur == list->tail) {
				list->tail = prev;
			}
			prev->next = cur->next;
			free(cur);
			return;
		}
		i++;
		prev = cur;
	}
}

int
llist_insert_list(llist_t list, llist_t newlist, int pos)
{
	llist_node_t node;
	int n;

	n = pos;
	LLIST_FOREACH(newlist, node) {
		if (!llist_add_pos(list, llist_getobj(node), n++))
			return 0;
	}

	return 1;
}

#ifdef TEST_LINKEDLIST

int
main(void)
{
	llist_t head;
	llist_node_t node;

	if ((head = llist_make()) == NULL) {
		fprintf(stderr, "Unable to make linked list\n");
		exit(1);
	}

	printf("Add1: %d\n", llist_add_tail(head, "eirik"));
	printf("Add2: %d\n", llist_add_tail(head, "akuma"));
	printf("Add3: %d\n", llist_add_head(head, "jeroen"));

	LLIST_FOREACH(head, node) {
		printf("Got: %s\n", llist_getobj(node));
	}

	llist_destroy(head);

	return 0;
}

#endif /* TEST_LINKEDLIST */

